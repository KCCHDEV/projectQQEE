@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🚀 ดำเนินการต่อหลังจากแก้ไขธีม
echo.

REM Get container name
for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr wordpress') do set CONTAINER_NAME=%%i

if not defined CONTAINER_NAME (
    echo ❌ ไม่พบ WordPress container!
    pause
    exit /b 1
)

echo ใช้ container: %CONTAINER_NAME%
echo.

echo 🛒 ขั้นตอนที่ 12: ติดตั้ง WooCommerce
echo.

docker exec %CONTAINER_NAME% wp plugin install woocommerce --activate --allow-root
echo ✅ ติดตั้ง WooCommerce เรียบร้อย

echo.
echo ⚙️ ขั้นตอนที่ 13: ตั้งค่า WooCommerce
echo.

REM Set currency to Thai Baht
docker exec %CONTAINER_NAME% wp option update woocommerce_currency THB --allow-root

REM Set default country to Thailand
docker exec %CONTAINER_NAME% wp option update woocommerce_default_country TH --allow-root

REM Set timezone
docker exec %CONTAINER_NAME% wp option update timezone_string Asia/Bangkok --allow-root

REM Set date format
docker exec %CONTAINER_NAME% wp option update date_format d/m/Y --allow-root

echo ✅ ตั้งค่า WooCommerce เรียบร้อย

echo.
echo 🎨 ขั้นตอนที่ 14: เปิดใช้งานธีม Pet Paws
echo.

docker exec %CONTAINER_NAME% wp theme activate pet-paws --allow-root
echo ✅ เปิดใช้งานธีม Pet Paws เรียบร้อย

echo.
echo 📄 ขั้นตอนที่ 15: สร้างหน้าตัวอย่าง
echo.

REM Create About Us page
docker exec %CONTAINER_NAME% wp post create --post_type=page --post_title="เกี่ยวกับเรา" --post_content="ร้านอาหารสัตว์เลี้ยงคุณภาพสูง ดูแลสัตว์เลี้ยงของคุณด้วยความรัก" --post_status=publish --allow-root

REM Create Contact page
docker exec %CONTAINER_NAME% wp post create --post_type=page --post_title="ติดต่อเรา" --post_content="โทร: 02-123-4567 | อีเมล: info@petfoodstore.com" --post_status=publish --allow-root

echo ✅ สร้างหน้าตัวอย่างเรียบร้อย

echo.
echo 🐕 ขั้นตอนที่ 16: เพิ่มสินค้าตัวอย่าง
echo.

REM Create product categories
docker exec %CONTAINER_NAME% wp term create product_cat "อาหารสุนัข" --description="อาหารคุณภาพสูงสำหรับสุนัข" --allow-root
docker exec %CONTAINER_NAME% wp term create product_cat "อาหารแมว" --description="อาหารคุณภาพสูงสำหรับแมว" --allow-root
docker exec %CONTAINER_NAME% wp term create product_cat "ของเล่นสัตว์เลี้ยง" --description="ของเล่นสนุกสำหรับสัตว์เลี้ยง" --allow-root

REM Create sample products
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="อาหารสุนัขพรีเมียม" --post_content="อาหารคุณภาพสูงสำหรับสุนัขทุกวัย" --post_status=publish --allow-root
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="อาหารแมวพรีเมียม" --post_content="อาหารคุณภาพสูงสำหรับแมวทุกวัย" --post_status=publish --allow-root
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="ลูกบอลของเล่นสุนัข" --post_content="ลูกบอลยางคุณภาพสูงสำหรับสุนัข" --post_status=publish --allow-root

echo ✅ เพิ่มสินค้าตัวอย่างเรียบร้อย

echo.
echo 🧭 ขั้นตอนที่ 17: ตั้งค่าเมนูนำทาง
echo.

REM Create primary menu
docker exec %CONTAINER_NAME% wp menu create "Primary Menu" --allow-root

REM Add pages to menu
docker exec %CONTAINER_NAME% wp menu item add-post "Primary Menu" 1 --allow-root
docker exec %CONTAINER_NAME% wp menu item add-post "Primary Menu" 2 --allow-root

REM Assign menu to primary location
docker exec %CONTAINER_NAME% wp menu location assign "Primary Menu" primary --allow-root

echo ✅ ตั้งค่าเมนูนำทางเรียบร้อย

echo.
echo 🔧 ขั้นตอนที่ 18: การตั้งค่าสุดท้าย
echo.

REM Set homepage to show posts
docker exec %CONTAINER_NAME% wp option update show_on_front posts --allow-root

REM Clear cache
docker exec %CONTAINER_NAME% wp cache flush --allow-root

echo ✅ การตั้งค่าสุดท้ายเรียบร้อย

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║                    🎉 ติดตั้งเสร็จสิ้น!                ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 📋 ข้อมูลการเข้าสู่ระบบ:
echo    🌐 เว็บไซต์: http://localhost:8000
echo    🔧 Admin Panel: http://localhost:8000/wp-admin
echo    👤 Username: admin
echo    🔑 Password: admin123
echo.
echo 📊 ข้อมูลเพิ่มเติม:
echo    🗄️  phpMyAdmin: http://localhost:8080
echo    📧  MailHog: http://localhost:8025
echo.
echo 🚀 เริ่มต้นใช้งานได้เลย!
echo.
pause

