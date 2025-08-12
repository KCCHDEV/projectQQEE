#!/bin/bash

# Admin Management Panel for WordPress/WooCommerce
# Thai Language Support Edition

set -e

# Thai language colors for terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

APP_NAME=${APP_NAME:-"pet-food-store"}

# Function to display Thai menu
show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       🏪 ระบบจัดการร้านค้าอาหารสัตว์เลี้ยง 🐾          ║${NC}"
    echo -e "${BLUE}║         Pet Food Store Admin Panel                    ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🔧 การจัดการระบบ (System Management)${NC}"
    echo "1)  🚀 เริ่มระบบ (Start System)"
    echo "2)  🛑 หยุดระบบ (Stop System)"
    echo "3)  🔄 รีสตาร์ทระบบ (Restart System)"
    echo "4)  📊 ตรวจสอบสถานะ (Check Status)"
    echo ""
    echo -e "${GREEN}💾 การสำรองข้อมูล (Backup & Restore)${NC}"
    echo "5)  📦 สำรองข้อมูล (Create Backup)"
    echo "6)  📥 คืนค่าข้อมูล (Restore Backup)"
    echo "7)  📋 ดูรายการสำรองข้อมูล (List Backups)"
    echo ""
    echo -e "${GREEN}🛒 จัดการ WooCommerce${NC}"
    echo "8)  📝 ดูคำสั่งซื้อล่าสุด (View Recent Orders)"
    echo "9)  📦 ดูสินค้าทั้งหมด (View Products)"
    echo "10) 👥 ดูลูกค้า (View Customers)"
    echo "11) 🔧 ตั้งค่าร้านค้า (Store Settings)"
    echo ""
    echo -e "${GREEN}🔧 เครื่องมือดูแลระบบ (Admin Tools)${NC}"
    echo "12) 🔄 อัพเดท WordPress และปลั๊กอิน (Update WordPress)"
    echo "13) 🧹 ล้างแคช (Clear Cache)"
    echo "14) 📄 ดูล็อกระบบ (View Logs)"
    echo "15) 🔒 ตั้งค่าความปลอดภัย (Security Settings)"
    echo ""
    echo -e "${GREEN}🌐 ตั้งค่าภาษา (Language Settings)${NC}"
    echo "16) 🇹🇭 ติดตั้งภาษาไทย (Install Thai Language)"
    echo "17) 🌏 เปลี่ยนภาษา (Change Language)"
    echo ""
    echo "18) ❌ ออกจากระบบ (Exit)"
    echo ""
}

# Function to start system
start_system() {
    echo -e "${BLUE}🚀 กำลังเริ่มระบบ...${NC}"
    docker-compose up -d
    echo -e "${GREEN}✅ ระบบเริ่มทำงานเรียบร้อย!${NC}"
    sleep 2
}

# Function to stop system
stop_system() {
    echo -e "${YELLOW}🛑 กำลังหยุดระบบ...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ หยุดระบบเรียบร้อย!${NC}"
    sleep 2
}

# Function to check status
check_status() {
    echo -e "${BLUE}📊 สถานะระบบปัจจุบัน:${NC}"
    echo ""
    docker-compose ps
    echo ""
    echo -e "${BLUE}📈 การใช้ทรัพยากร:${NC}"
    docker stats --no-stream
    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
}

# Function to view recent orders
view_orders() {
    echo -e "${BLUE}📝 คำสั่งซื้อล่าสุด 10 รายการ:${NC}"
    echo ""
    docker exec ${APP_NAME}_wordpress wp wc shop_order list \
        --fields=id,status,total,date_created,billing_first_name,billing_last_name \
        --format=table \
        --orderby=date_created \
        --order=desc \
        --limit=10 \
        --allow-root 2>/dev/null || echo "ยังไม่มีคำสั่งซื้อ"
    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
}

# Function to view products
view_products() {
    echo -e "${BLUE}📦 สินค้าทั้งหมด:${NC}"
    echo ""
    docker exec ${APP_NAME}_wordpress wp wc product list \
        --fields=id,name,price,stock_status \
        --format=table \
        --limit=20 \
        --allow-root 2>/dev/null || echo "ยังไม่มีสินค้า"
    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
}

# Function to install Thai language
install_thai() {
    echo -e "${BLUE}🇹🇭 กำลังติดตั้งภาษาไทย...${NC}"
    
    # Install Thai language pack
    docker exec ${APP_NAME}_wordpress wp language core install th --allow-root
    docker exec ${APP_NAME}_wordpress wp language plugin install woocommerce th --allow-root
    docker exec ${APP_NAME}_wordpress wp language theme install storefront th --allow-root
    
    # Set Thai as default language
    docker exec ${APP_NAME}_wordpress wp site switch-language th --allow-root
    
    # Update WooCommerce to Thai Baht
    docker exec ${APP_NAME}_wordpress wp option update woocommerce_currency "THB" --allow-root
    docker exec ${APP_NAME}_wordpress wp option update woocommerce_currency_pos "left_space" --allow-root
    
    echo -e "${GREEN}✅ ติดตั้งภาษาไทยเรียบร้อย!${NC}"
    sleep 2
}

# Function to clear cache
clear_cache() {
    echo -e "${BLUE}🧹 กำลังล้างแคช...${NC}"
    
    # Clear WordPress cache
    docker exec ${APP_NAME}_wordpress wp cache flush --allow-root 2>/dev/null || true
    
    # Clear Redis cache
    docker exec ${APP_NAME}_redis redis-cli FLUSHALL 2>/dev/null || true
    
    # Clear WooCommerce transients
    docker exec ${APP_NAME}_wordpress wp transient delete --all --allow-root 2>/dev/null || true
    
    echo -e "${GREEN}✅ ล้างแคชเรียบร้อย!${NC}"
    sleep 2
}

# Function to update WordPress
update_wordpress() {
    echo -e "${BLUE}🔄 กำลังอัพเดท WordPress และปลั๊กอิน...${NC}"
    
    # Update WordPress core
    docker exec ${APP_NAME}_wordpress wp core update --allow-root
    
    # Update all plugins
    docker exec ${APP_NAME}_wordpress wp plugin update --all --allow-root
    
    # Update all themes
    docker exec ${APP_NAME}_wordpress wp theme update --all --allow-root
    
    # Update database if needed
    docker exec ${APP_NAME}_wordpress wp core update-db --allow-root
    
    echo -e "${GREEN}✅ อัพเดทเรียบร้อย!${NC}"
    sleep 2
}

# Function to list backups
list_backups() {
    echo -e "${BLUE}📋 รายการสำรองข้อมูล:${NC}"
    echo ""
    if ls backups/*.info &> /dev/null; then
        ls -1 backups/*.info | while read file; do
            timestamp=$(basename "$file" | sed 's/backup_//;s/.info//')
            date=$(grep "Date:" "$file" | cut -d':' -f2-)
            echo "📅 $timestamp -$date"
        done
    else
        echo "ไม่พบข้อมูลสำรอง"
    fi
    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
}

# Function to view logs
view_logs() {
    echo -e "${BLUE}📄 เลือกล็อกที่ต้องการดู:${NC}"
    echo "1) WordPress logs"
    echo "2) Database logs"
    echo "3) Redis logs"
    echo "4) All logs"
    echo ""
    read -p "เลือก (1-4): " log_choice
    
    case $log_choice in
        1) docker-compose logs --tail=50 wordpress ;;
        2) docker-compose logs --tail=50 db ;;
        3) docker-compose logs --tail=50 redis ;;
        4) docker-compose logs --tail=50 ;;
    esac
    
    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
}

# Function to manage store settings
store_settings() {
    echo -e "${BLUE}🔧 ตั้งค่าร้านค้า:${NC}"
    echo ""
    
    # Get current settings
    CURRENCY=$(docker exec ${APP_NAME}_wordpress wp option get woocommerce_currency --allow-root)
    STORE_NAME=$(docker exec ${APP_NAME}_wordpress wp option get blogname --allow-root)
    
    echo "ชื่อร้าน: $STORE_NAME"
    echo "สกุลเงิน: $CURRENCY"
    echo ""
    echo "1) เปลี่ยนชื่อร้าน"
    echo "2) ตั้งค่าการจัดส่ง"
    echo "3) ตั้งค่าการชำระเงิน"
    echo "4) กลับเมนูหลัก"
    echo ""
    read -p "เลือก (1-4): " setting_choice
    
    case $setting_choice in
        1)
            read -p "ชื่อร้านใหม่: " new_name
            docker exec ${APP_NAME}_wordpress wp option update blogname "$new_name" --allow-root
            echo -e "${GREEN}✅ เปลี่ยนชื่อร้านเรียบร้อย!${NC}"
            ;;
        2)
            echo "กรุณาไปที่ WooCommerce > Settings > Shipping ในหน้าแอดมิน"
            ;;
        3)
            echo "กรุณาไปที่ WooCommerce > Settings > Payments ในหน้าแอดมิน"
            ;;
    esac
    sleep 2
}

# Main loop
while true; do
    show_menu
    read -p "เลือกเมนู (1-18): " choice
    echo ""
    
    case $choice in
        1) start_system ;;
        2) stop_system ;;
        3) stop_system && start_system ;;
        4) check_status ;;
        5) ./scripts/backup.sh ;;
        6) 
            echo "รายการสำรองข้อมูล:"
            ls -1 backups/*.info 2>/dev/null | sed 's/.*backup_//;s/.info//' || echo "ไม่พบข้อมูลสำรอง"
            read -p "ใส่ timestamp ที่ต้องการคืนค่า: " timestamp
            ./scripts/restore.sh "$timestamp"
            ;;
        7) list_backups ;;
        8) view_orders ;;
        9) view_products ;;
        10) 
            docker exec ${APP_NAME}_wordpress wp user list --role=customer --allow-root
            read -p "กด Enter เพื่อกลับเมนูหลัก..."
            ;;
        11) store_settings ;;
        12) update_wordpress ;;
        13) clear_cache ;;
        14) view_logs ;;
        15)
            echo -e "${BLUE}🔒 คำแนะนำด้านความปลอดภัย:${NC}"
            echo "1. เปลี่ยนรหัสผ่านใน .env"
            echo "2. ใช้ SSL certificate"
            echo "3. อัพเดทระบบเป็นประจำ"
            echo "4. สำรองข้อมูลทุกวัน"
            read -p "กด Enter เพื่อกลับเมนูหลัก..."
            ;;
        16) install_thai ;;
        17)
            echo "ภาษาที่ใช้ได้: en_US, th"
            read -p "เลือกภาษา: " lang
            docker exec ${APP_NAME}_wordpress wp site switch-language "$lang" --allow-root
            echo -e "${GREEN}✅ เปลี่ยนภาษาเรียบร้อย!${NC}"
            sleep 2
            ;;
        18)
            echo -e "${GREEN}👋 ขอบคุณที่ใช้งาน!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ ตัวเลือกไม่ถูกต้อง${NC}"
            sleep 1
            ;;
    esac
done