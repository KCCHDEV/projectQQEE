#!/bin/bash

# Load environment variables
if [ -f ".env" ]; then
    export $(cat .env | xargs)
fi

# Set default values if not in .env
APP_NAME=${APP_NAME:-pet-food-store}

echo ""
echo "🔧 ขั้นตอนที่ 10: ติดตั้งและตั้งค่า WordPress"
echo ""

# Install WP-CLI first
echo "กำลังติดตั้ง WP-CLI..."
bash scripts/install-wp-cli.sh

# Check if WordPress is already installed
if ! docker exec ${APP_NAME}_wordpress wp core is-installed --allow-root &>/dev/null; then
    echo "กำลังติดตั้ง WordPress..."
    docker exec ${APP_NAME}_wordpress wp core install \
        --url=http://localhost:8000 \
        --title="Pet Food Store" \
        --admin_user=admin \
        --admin_password=admin123 \
        --admin_email=admin@example.com \
        --allow-root
    echo "✅ ติดตั้ง WordPress เรียบร้อย"
else
    echo "✅ WordPress ติดตั้งแล้ว"
fi

# Step 11: Install WooCommerce
echo ""
echo "🛒 ขั้นตอนที่ 11: ติดตั้ง WooCommerce"
echo ""

docker exec ${APP_NAME}_wordpress wp plugin install woocommerce --activate --allow-root
echo "✅ ติดตั้ง WooCommerce เรียบร้อย"

# Step 12: Configure WooCommerce
echo ""
echo "⚙️ ขั้นตอนที่ 12: ตั้งค่า WooCommerce"
echo ""

# Set currency to Thai Baht
docker exec ${APP_NAME}_wordpress wp option update woocommerce_currency THB --allow-root

# Set default country to Thailand
docker exec ${APP_NAME}_wordpress wp option update woocommerce_default_country TH --allow-root

# Enable guest checkout
docker exec ${APP_NAME}_wordpress wp option update woocommerce_enable_guest_checkout yes --allow-root

# Set tax settings
docker exec ${APP_NAME}_wordpress wp option update woocommerce_calc_taxes yes --allow-root

echo "✅ ตั้งค่า WooCommerce เรียบร้อย"

# Step 13: Install and activate theme
echo ""
echo "🎨 ขั้นตอนที่ 13: เปิดใช้งานธีม Pet Paws"
echo ""

# Activate custom theme
if docker exec ${APP_NAME}_wordpress wp theme activate pet-paws --allow-root 2>/dev/null; then
    echo "✅ เปิดใช้งานธีม Pet Paws เรียบร้อย"
else
    echo "⚠️ ไม่สามารถเปิดใช้งานธีม Pet Paws ได้ - ใช้ธีมเริ่มต้น"
    docker exec ${APP_NAME}_wordpress wp theme activate twentytwentyfour --allow-root 2>/dev/null || \
    docker exec ${APP_NAME}_wordpress wp theme activate twentytwentythree --allow-root
fi

# Step 14: Create sample products
echo ""
echo "🛍️ ขั้นตอนที่ 14: สร้างสินค้าตัวอย่าง"
echo ""

# Create product categories
docker exec ${APP_NAME}_wordpress wp term create product_cat "อาหารสุนัข" --slug="dog-food" --allow-root
docker exec ${APP_NAME}_wordpress wp term create product_cat "อาหารแมว" --slug="cat-food" --allow-root
docker exec ${APP_NAME}_wordpress wp term create product_cat "ของเล่นสัตว์เลี้ยง" --slug="pet-toys" --allow-root

# Create sample products
docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=product \
    --post_title="อาหารสุนัขพรีเมียม" \
    --post_content="อาหารสุนัขคุณภาพสูง เหมาะสำหรับสุนัขโตทุกสายพันธุ์" \
    --post_status=publish \
    --allow-root

docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=product \
    --post_title="อาหารแมวดีลักซ์" \
    --post_content="อาหารแมวพรีเมียม อุดมไปด้วยโปรตีนคุณภาพสูง" \
    --post_status=publish \
    --allow-root

docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=product \
    --post_title="ลูกบอลของเล่นสัตว์เลี้ยง" \
    --post_content="ลูกบอลสีสันสดใส เหมาะสำหรับการเล่นของสัตว์เลี้ยง" \
    --post_status=publish \
    --allow-root

# Set product prices
PRODUCTS=$(docker exec ${APP_NAME}_wordpress wp post list --post_type=product --format=ids --allow-root)
for PRODUCT_ID in $PRODUCTS; do
    case $PRODUCT_ID in
        *) 
            PRICE=450
            if [[ $(docker exec ${APP_NAME}_wordpress wp post get $PRODUCT_ID --field=post_title --allow-root) == *"แมว"* ]]; then
                PRICE=380
            elif [[ $(docker exec ${APP_NAME}_wordpress wp post get $PRODUCT_ID --field=post_title --allow-root) == *"ลูกบอล"* ]]; then
                PRICE=280
            fi
            docker exec ${APP_NAME}_wordpress wp post meta update $PRODUCT_ID _price $PRICE --allow-root
            docker exec ${APP_NAME}_wordpress wp post meta update $PRODUCT_ID _regular_price $PRICE --allow-root
            ;;
    esac
done

echo "✅ สร้างสินค้าตัวอย่างเรียบร้อย"

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║            🎉 การติดตั้งเสร็จสมบูรณ์!                 ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "🌐 เข้าดูเว็บไซต์ได้ที่: http://localhost:8000"
echo "🔐 เข้าสู่ระบบแอดมิน: http://localhost:8000/wp-admin"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "🗄️ จัดการฐานข้อมูล: http://localhost:8080"
echo "📧 ทดสอบอีเมล: http://localhost:8025"
echo ""
echo "🛑 หยุดระบบ: docker-compose down"
echo "🔄 รีสตาร์ท: docker-compose restart"