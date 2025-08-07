#!/bin/bash

# System Check Script for WordPress/WooCommerce
# ตรวจสอบความพร้อมของระบบ

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 ตรวจสอบระบบ WordPress/WooCommerce${NC}"
echo "=========================================="
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ พบไฟล์ .env${NC}"
else
    echo -e "${RED}❌ ไม่พบไฟล์ .env${NC}"
    echo "   กรุณาคัดลอกจาก .env.example และแก้ไขค่าต่างๆ"
    exit 1
fi

APP_NAME=${APP_NAME:-"pet-food-store"}

# Check Docker
echo ""
echo -e "${BLUE}1. ตรวจสอบ Docker${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker: $(docker --version)${NC}"
else
    echo -e "${RED}❌ Docker ไม่ได้ติดตั้ง${NC}"
    exit 1
fi

if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✅ Docker Compose: $(docker-compose --version)${NC}"
else
    echo -e "${RED}❌ Docker Compose ไม่ได้ติดตั้ง${NC}"
    exit 1
fi

# Check directories
echo ""
echo -e "${BLUE}2. ตรวจสอบโฟลเดอร์${NC}"
REQUIRED_DIRS=("scripts" "backups" "wp-content" "admin-dashboard")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ โฟลเดอร์ $dir${NC}"
    else
        echo -e "${YELLOW}⚠️  สร้างโฟลเดอร์ $dir${NC}"
        mkdir -p "$dir"
    fi
done

# Check scripts
echo ""
echo -e "${BLUE}3. ตรวจสอบสคริปต์${NC}"
REQUIRED_SCRIPTS=(
    "scripts/backup.sh"
    "scripts/restore.sh"
    "scripts/migrate.sh"
    "scripts/quick-start.sh"
    "scripts/admin-panel.sh"
    "scripts/setup-thai.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}✅ $script (executable)${NC}"
        else
            echo -e "${YELLOW}⚠️  $script (making executable)${NC}"
            chmod +x "$script"
        fi
    else
        echo -e "${RED}❌ $script ไม่พบไฟล์${NC}"
    fi
done

# Check container status
echo ""
echo -e "${BLUE}4. ตรวจสอบ Container Status${NC}"
if docker-compose ps &> /dev/null; then
    CONTAINERS=$(docker-compose ps --format json 2>/dev/null | jq -r '.Service' 2>/dev/null || docker-compose ps --format table)
    
    # Check each service
    SERVICES=("wordpress" "db" "redis" "phpmyadmin" "mailhog" "admin")
    for service in "${SERVICES[@]}"; do
        if docker-compose ps | grep -q "${APP_NAME}_${service}.*running"; then
            echo -e "${GREEN}✅ ${service} - ทำงานปกติ${NC}"
        else
            echo -e "${RED}❌ ${service} - ไม่ทำงาน${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠️  Containers ยังไม่เริ่มทำงาน${NC}"
fi

# Check ports
echo ""
echo -e "${BLUE}5. ตรวจสอบ Ports${NC}"
PORTS=(
    "${WORDPRESS_PORT:-8000}:WordPress"
    "${PHPMYADMIN_PORT:-8080}:phpMyAdmin"
    "8888:Admin Dashboard"
    "${MAILHOG_WEB_PORT:-8025}:MailHog"
    "${REDIS_PORT:-6379}:Redis"
)

for port_info in "${PORTS[@]}"; do
    PORT=$(echo $port_info | cut -d: -f1)
    SERVICE=$(echo $port_info | cut -d: -f2)
    
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Port $PORT ($SERVICE) - ใช้งานอยู่${NC}"
    else
        echo -e "${YELLOW}⚠️  Port $PORT ($SERVICE) - ว่าง${NC}"
    fi
done

# Check WordPress installation
echo ""
echo -e "${BLUE}6. ตรวจสอบการติดตั้ง WordPress${NC}"
if docker exec ${APP_NAME}_wordpress wp core is-installed --allow-root 2>/dev/null; then
    echo -e "${GREEN}✅ WordPress ติดตั้งแล้ว${NC}"
    
    # Get WordPress info
    WP_VERSION=$(docker exec ${APP_NAME}_wordpress wp core version --allow-root 2>/dev/null)
    echo "   Version: $WP_VERSION"
    
    # Check language
    SITE_LANG=$(docker exec ${APP_NAME}_wordpress wp option get WPLANG --allow-root 2>/dev/null || echo "en_US")
    if [ "$SITE_LANG" = "th" ]; then
        echo -e "${GREEN}✅ ภาษาไทยติดตั้งแล้ว${NC}"
    else
        echo -e "${YELLOW}⚠️  ภาษาไทยยังไม่ได้ติดตั้ง${NC}"
        echo "   รัน: ./scripts/setup-thai.sh"
    fi
    
    # Check WooCommerce
    if docker exec ${APP_NAME}_wordpress wp plugin is-active woocommerce --allow-root 2>/dev/null; then
        echo -e "${GREEN}✅ WooCommerce เปิดใช้งานแล้ว${NC}"
        WC_VERSION=$(docker exec ${APP_NAME}_wordpress wp plugin get woocommerce --field=version --allow-root 2>/dev/null)
        echo "   Version: $WC_VERSION"
    else
        echo -e "${RED}❌ WooCommerce ยังไม่เปิดใช้งาน${NC}"
    fi
else
    echo -e "${RED}❌ WordPress ยังไม่ได้ติดตั้ง${NC}"
    echo "   รัน: ./scripts/quick-start.sh"
fi

# Check backups
echo ""
echo -e "${BLUE}7. ตรวจสอบการสำรองข้อมูล${NC}"
BACKUP_COUNT=$(ls -1 backups/*.info 2>/dev/null | wc -l)
if [ $BACKUP_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ พบข้อมูลสำรอง: $BACKUP_COUNT ไฟล์${NC}"
    LATEST_BACKUP=$(ls -t backups/*.info 2>/dev/null | head -1)
    if [ -f "$LATEST_BACKUP" ]; then
        echo "   ล่าสุด: $(basename $LATEST_BACKUP)"
    fi
else
    echo -e "${YELLOW}⚠️  ยังไม่มีข้อมูลสำรอง${NC}"
    echo "   รัน: ./scripts/backup.sh"
fi

# Summary
echo ""
echo -e "${BLUE}📊 สรุปผลการตรวจสอบ${NC}"
echo "===================="

# Count issues
ISSUES=0
if [ ! -f .env ]; then ((ISSUES++)); fi
if ! docker-compose ps | grep -q "running"; then ((ISSUES++)); fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ ระบบพร้อมใช้งาน!${NC}"
    echo ""
    echo "🔗 เข้าใช้งาน:"
    echo "   - เว็บไซต์: ${APP_URL:-http://localhost:8000}"
    echo "   - แอดมิน: ${APP_URL:-http://localhost:8000}/wp-admin"
    echo "   - Admin Dashboard: http://localhost:8888"
    echo "   - phpMyAdmin: http://localhost:${PHPMYADMIN_PORT:-8080}"
else
    echo -e "${YELLOW}⚠️  พบปัญหา $ISSUES รายการ${NC}"
    echo ""
    echo "แนะนำ:"
    echo "1. รัน: ./scripts/quick-start.sh"
    echo "2. รัน: ./scripts/setup-thai.sh (สำหรับภาษาไทย)"
fi

echo ""
echo "💡 คำสั่งที่มีประโยชน์:"
echo "   ./scripts/admin-panel.sh - เปิดแผงควบคุม"
echo "   ./scripts/backup.sh - สำรองข้อมูล"
echo "   ./scripts/migrate.sh - ย้ายโฮสต์"
echo "   docker-compose logs -f - ดู logs"