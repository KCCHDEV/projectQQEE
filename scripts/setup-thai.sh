#!/bin/bash

# Thai Language Setup Script for WordPress/WooCommerce
# ตั้งค่าภาษาไทยสำหรับ WordPress และ WooCommerce

set -e

echo "🇹🇭 ติดตั้งภาษาไทยสำหรับ WordPress/WooCommerce"
echo "=============================================="

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

APP_NAME=${APP_NAME:-"pet-food-store"}

# Wait for WordPress to be ready
echo "⏳ รอให้ WordPress พร้อมใช้งาน..."
until docker exec ${APP_NAME}_wordpress wp core is-installed --allow-root 2>/dev/null; do
    echo -n "."
    sleep 5
done
echo ""

# Install Thai language packs
echo "📦 ติดตั้งแพ็คภาษาไทย..."

# Core WordPress Thai
echo "1️⃣ ติดตั้งภาษาไทยสำหรับ WordPress..."
docker exec ${APP_NAME}_wordpress wp language core install th --allow-root || echo "ภาษาไทยติดตั้งแล้ว"

# Plugin language packs
echo "2️⃣ ติดตั้งภาษาไทยสำหรับปลั๊กอิน..."
docker exec ${APP_NAME}_wordpress wp language plugin install woocommerce th --allow-root || true
docker exec ${APP_NAME}_wordpress wp language plugin install contact-form-7 th --allow-root || true
docker exec ${APP_NAME}_wordpress wp language plugin install wordpress-seo th --allow-root || true

# Theme language packs
echo "3️⃣ ติดตั้งภาษาไทยสำหรับธีม..."
docker exec ${APP_NAME}_wordpress wp language theme install storefront th --allow-root || true
docker exec ${APP_NAME}_wordpress wp language theme install twentytwentythree th --allow-root || true

# Set Thai as default language
echo "4️⃣ ตั้งภาษาไทยเป็นภาษาหลัก..."
docker exec ${APP_NAME}_wordpress wp site switch-language th --allow-root

# Configure Thai-specific settings
echo "5️⃣ ตั้งค่าเฉพาะสำหรับประเทศไทย..."

# Thai Baht and formatting
docker exec ${APP_NAME}_wordpress wp option update woocommerce_currency "THB" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_currency_pos "left_space" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_price_thousand_sep "," --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_price_decimal_sep "." --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_price_num_decimals "2" --allow-root

# Thai timezone
docker exec ${APP_NAME}_wordpress wp option update timezone_string "Asia/Bangkok" --allow-root

# Thai date format
docker exec ${APP_NAME}_wordpress wp option update date_format "j F Y" --allow-root
docker exec ${APP_NAME}_wordpress wp option update time_format "H:i" --allow-root

# Default country for WooCommerce
docker exec ${APP_NAME}_wordpress wp option update woocommerce_default_country "TH" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_specific_allowed_countries '["TH"]' --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_all_except_countries '[]' --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_ship_to_countries "specific" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_specific_ship_to_countries '["TH"]' --allow-root

# Thai provinces for checkout
echo "6️⃣ ตั้งค่าจังหวัดของไทย..."

# Update store address
docker exec ${APP_NAME}_wordpress wp option update woocommerce_store_address "123 ถนนสุขุมวิท" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_store_address_2 "" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_store_city "กรุงเทพมหานคร" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_default_customer_address "base" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_store_postcode "10110" --allow-root

# Tax settings for Thailand (VAT 7%)
echo "7️⃣ ตั้งค่าภาษี VAT 7%..."
docker exec ${APP_NAME}_wordpress wp option update woocommerce_calc_taxes "yes" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_tax_based_on "shipping" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_prices_include_tax "yes" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_tax_display_shop "incl" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_tax_display_cart "incl" --allow-root

# Create Thai tax rate
docker exec ${APP_NAME}_wordpress wp eval '
    global $wpdb;
    $tax_rate = array(
        "tax_rate_country"  => "TH",
        "tax_rate_state"    => "",
        "tax_rate"          => "7.0000",
        "tax_rate_name"     => "VAT",
        "tax_rate_priority" => 1,
        "tax_rate_compound" => 0,
        "tax_rate_shipping" => 1,
        "tax_rate_order"    => 0,
        "tax_rate_class"    => ""
    );
    $wpdb->insert($wpdb->prefix . "woocommerce_tax_rates", $tax_rate);
' --allow-root || true

# Payment methods for Thailand
echo "8️⃣ ตั้งค่าวิธีการชำระเงิน..."

# Enable bank transfer
docker exec ${APP_NAME}_wordpress wp option update woocommerce_bacs_settings '{"enabled":"yes","title":"โอนเงินผ่านธนาคาร","description":"โอนเงินผ่านบัญชีธนาคารของเรา","instructions":"กรุณาโอนเงินไปยังบัญชีธนาคารด้านล่าง แล้วส่งหลักฐานการโอนเงิน","account_details":[{"account_name":"ร้านอาหารสัตว์เลี้ยง","account_number":"123-4-56789-0","bank_name":"ธนาคารกรุงเทพ","sort_code":"","iban":"","bic":""}]}' --allow-root

# Enable COD
docker exec ${APP_NAME}_wordpress wp option update woocommerce_cod_settings '{"enabled":"yes","title":"ชำระเงินปลายทาง","description":"ชำระเงินเมื่อได้รับสินค้า","instructions":"ชำระเงินสดเมื่อได้รับสินค้า","enable_for_methods":["flat_rate","free_shipping","local_pickup"],"enable_for_virtual":"no"}' --allow-root

# Shipping zones for Thailand
echo "9️⃣ ตั้งค่าโซนการจัดส่ง..."

docker exec ${APP_NAME}_wordpress wp eval '
    $zone = new WC_Shipping_Zone();
    $zone->set_zone_name("ประเทศไทย");
    $zone->add_location("TH", "country");
    $zone->save();
    
    $zone->add_shipping_method("flat_rate");
    $shipping_method = $zone->get_shipping_methods();
    $method = array_shift($shipping_method);
    if ($method) {
        $method->set_option("title", "จัดส่งทั่วประเทศ");
        $method->set_option("cost", "50");
        $method->save();
    }
' --allow-root || true

# Create sample pages in Thai
echo "🔟 สร้างหน้าเพจภาษาไทย..."

# About Us page
docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=page \
    --post_title="เกี่ยวกับเรา" \
    --post_content="<h2>ยินดีต้อนรับสู่ร้านอาหารสัตว์เลี้ยง</h2><p>เราคือผู้นำด้านอาหารและอุปกรณ์สัตว์เลี้ยงคุณภาพสูงในประเทศไทย มุ่งมั่นที่จะมอบสิ่งที่ดีที่สุดให้กับสัตว์เลี้ยงแสนรักของคุณ</p>" \
    --post_status=publish \
    --allow-root

# Contact page
docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=page \
    --post_title="ติดต่อเรา" \
    --post_content="<h2>ติดต่อเรา</h2><p><strong>ที่อยู่:</strong> 123 ถนนสุขุมวิท กรุงเทพมหานคร 10110</p><p><strong>โทร:</strong> 02-123-4567</p><p><strong>อีเมล:</strong> info@petfoodstore.co.th</p><p><strong>เวลาทำการ:</strong> จันทร์-ศุกร์ 9:00-18:00 น.</p>" \
    --post_status=publish \
    --allow-root

# Shipping policy
docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=page \
    --post_title="นโยบายการจัดส่ง" \
    --post_content="<h2>นโยบายการจัดส่งสินค้า</h2><ul><li>จัดส่งฟรีเมื่อซื้อสินค้าครบ 500 บาท</li><li>จัดส่งภายใน 1-3 วันทำการ</li><li>บริการจัดส่งทั่วประเทศไทย</li></ul>" \
    --post_status=publish \
    --allow-root

# Update site title and tagline in Thai
echo "1️⃣1️⃣ อัพเดทชื่อเว็บไซต์..."
docker exec ${APP_NAME}_wordpress wp option update blogname "ร้านอาหารสัตว์เลี้ยง" --allow-root
docker exec ${APP_NAME}_wordpress wp option update blogdescription "อาหารและอุปกรณ์สัตว์เลี้ยงคุณภาพสูง จัดส่งทั่วไทย" --allow-root

# Create menu in Thai
echo "1️⃣2️⃣ สร้างเมนูภาษาไทย..."
docker exec ${APP_NAME}_wordpress wp menu create "เมนูหลัก" --allow-root || true

# Clear cache
echo "🧹 ล้างแคช..."
docker exec ${APP_NAME}_wordpress wp cache flush --allow-root || true
docker exec ${APP_NAME}_redis redis-cli FLUSHALL || true

echo ""
echo "✅ ติดตั้งภาษาไทยเสร็จสมบูรณ์!"
echo ""
echo "📌 สรุปการตั้งค่า:"
echo "   - ภาษาหลัก: ไทย"
echo "   - สกุลเงิน: บาท (฿)"
echo "   - เขตเวลา: Asia/Bangkok"
echo "   - ภาษี: VAT 7%"
echo "   - วิธีชำระเงิน: โอนเงิน, ปลายทาง"
echo "   - การจัดส่ง: ทั่วประเทศไทย"
echo ""
echo "🌐 เข้าใช้งานได้ที่: ${APP_URL:-http://localhost:8000}"
echo "👤 แอดมิน: ${APP_URL:-http://localhost:8000}/wp-admin"