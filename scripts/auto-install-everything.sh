#!/bin/bash

# 🐾 Pet Food Shop - Auto Install Everything (Linux/macOS)
# Just run: bash scripts/auto-install-everything.sh

echo "╔═══════════════════════════════════════════════════════╗"
echo "║       🚀 Auto Install Everything - ระบบติดตั้งอัตโนมัติ ║"
echo "║         Pet Food Store Complete Setup                 ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    export APP_NAME=pet-food-store
    export WORDPRESS_PORT=8000
    export PHPMYADMIN_PORT=8080
    export MAILHOG_WEB_PORT=8025
    export DB_ROOT_PASSWORD=rootpassword
    export DB_NAME=wordpress
    export DB_USER=wordpress
    export DB_PASSWORD=wordpress
fi

echo "🎯 เริ่มต้นการติดตั้งระบบร้านอาหารสัตว์เลี้ยงแบบอัตโนมัติ..."
echo ""

# Step 1: Check system requirements
echo "📋 ขั้นตอนที่ 1: ตรวจสอบความพร้อมของระบบ"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker ไม่ได้ติดตั้ง!"
    echo ""
    echo "📥 ติดตั้ง Docker:"
    echo "   Ubuntu/Debian: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    echo "   macOS: brew install --cask docker"
    echo ""
    echo "⚠️  กรุณาติดตั้ง Docker และรีสตาร์ท"
    exit 1
fi

echo "✅ Docker พร้อมใช้งาน"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose ไม่ได้ติดตั้ง!"
    exit 1
fi

echo "✅ Docker Compose พร้อมใช้งาน"
echo ""

# Step 2: Create project structure
echo "📁 ขั้นตอนที่ 2: สร้างโครงสร้างโปรเจค"
echo ""

# Create main directories
mkdir -p wp-content/themes wp-content/plugins wp-content/uploads/2024/12 backups dev-workspace

echo "✅ สร้างโฟลเดอร์หลักเรียบร้อย"

# Step 3: Copy template files
echo ""
echo "📦 ขั้นตอนที่ 3: คัดลอกไฟล์เทมเพลต"
echo ""

# Copy pet-food-shop-template files
if [ -f "pet-food-shop-template/docker-compose.yml" ]; then
    if cp "pet-food-shop-template/docker-compose.yml" "docker-compose.yml" 2>/dev/null; then
        echo "✅ คัดลอก docker-compose.yml"
    else
        echo "❌ ไม่สามารถคัดลอก docker-compose.yml ได้"
    fi
else
    echo "⚠️ ไม่พบไฟล์ pet-food-shop-template/docker-compose.yml - ใช้ไฟล์เดิม"
fi

if [ -f "pet-food-shop-template/install.sh" ]; then
    if cp "pet-food-shop-template/install.sh" "install-template.sh" 2>/dev/null; then
        echo "✅ คัดลอก install.sh"
    else
        echo "❌ ไม่สามารถคัดลอก install.sh ได้"
    fi
else
    echo "⚠️ ไม่พบไฟล์ pet-food-shop-template/install.sh - ข้าม"
fi

if [ -f "pet-food-shop-template/README.md" ]; then
    if cp "pet-food-shop-template/README.md" "README-template.md" 2>/dev/null; then
        echo "✅ คัดลอก README.md"
    else
        echo "❌ ไม่สามารถคัดลอก README.md ได้"
    fi
else
    echo "⚠️ ไม่พบไฟล์ pet-food-shop-template/README.md - ข้าม"
fi

# Step 4: Copy example UI images
echo ""
echo "🖼️ ขั้นตอนที่ 4: คัดลอกรูปภาพตัวอย่าง"
echo ""

if [ -d "exampleUi" ]; then
    mkdir -p "wp-content/uploads/2024/12/example-ui"
    if ls exampleUi/*.jpg 1> /dev/null 2>&1; then
        if cp exampleUi/*.jpg "wp-content/uploads/2024/12/example-ui/" 2>/dev/null; then
            echo "✅ คัดลอกรูปภาพตัวอย่าง"
        else
            echo "❌ ไม่สามารถคัดลอกรูปภาพได้"
        fi
    else
        echo "⚠️ ไม่พบไฟล์รูปภาพใน exampleUi"
    fi
else
    echo "⚠️ ไม่พบโฟลเดอร์ exampleUi - ข้าม"
fi

# Step 5: Copy rimping UI template
echo ""
echo "🎨 ขั้นตอนที่ 5: คัดลอก UI Template"
echo ""

if [ -d "rimping-animal-foods" ]; then
    mkdir -p "dev-workspace/ui-template"
    if cp -r rimping-animal-foods/* "dev-workspace/ui-template/" 2>/dev/null; then
        echo "✅ คัดลอก UI Template ไปยัง dev-workspace"
    else
        echo "❌ ไม่สามารถคัดลอก UI Template ได้"
    fi
else
    echo "⚠️ ไม่พบโฟลเดอร์ rimping-animal-foods - ข้าม"
fi

# Step 6: Create environment file
echo ""
echo "⚙️ ขั้นตอนที่ 6: สร้างไฟล์การตั้งค่า"
echo ""

if [ ! -f .env ]; then
    cat > .env << EOF
APP_NAME=pet-food-store
WORDPRESS_PORT=8000
PHPMYADMIN_PORT=8080
MAILHOG_WEB_PORT=8025
DB_ROOT_PASSWORD=rootpassword
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpress
APP_URL=http://localhost:8000
WORDPRESS_DEBUG=false
WP_MEMORY_LIMIT=256M
DB_HOST=db
REDIS_HOST=redis
SMTP_HOST=mailhog
SMTP_PORT=1025
WC_CURRENCY=THB
EOF
    echo "✅ สร้างไฟล์ .env เรียบร้อย"
else
    echo "✅ ไฟล์ .env มีอยู่แล้ว"
fi

# Step 7: Create custom theme from rimping template
echo ""
echo "🎨 ขั้นตอนที่ 7: สร้างธีม WordPress จาก UI Template"
echo ""

# Call separate script to create theme files
bash scripts/create-theme-files.sh

# Step 8: Start Docker containers
echo ""
echo "🐳 ขั้นตอนที่ 8: เริ่มต้น Docker Containers"
echo ""

echo "กำลังเริ่มต้น containers..."
if docker-compose up -d; then
    echo "✅ เริ่มต้น containers เรียบร้อย"
else
    echo "❌ ไม่สามารถเริ่มต้น containers ได้"
    exit 1
fi

# Step 9: Wait for WordPress to be ready
echo ""
echo "⏳ ขั้นตอนที่ 9: รอให้ WordPress พร้อมใช้งาน"
echo ""

echo "รอให้ WordPress พร้อมใช้งาน..."
while ! docker exec ${APP_NAME}_wordpress wp core is-installed --allow-root &>/dev/null; do
    echo -n "."
    sleep 5
done

echo ""
echo "✅ WordPress พร้อมใช้งาน"

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║              🎯 WordPress พร้อมใช้งานแล้ว!              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "📋 ขั้นตอนต่อไป:"
echo "    1. รัน script: bash scripts/continue-installation.sh"
echo "    2. หรือรัน manual setup สำหรับ WooCommerce"
echo ""
echo "🌐 เข้าดูเว็บไซต์ได้ที่: http://localhost:8000"
echo ""