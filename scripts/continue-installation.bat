@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Load environment variables
if exist ".env" (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set %%a=%%b
    )
)

REM Set default values if not in .env
if not defined APP_NAME set APP_NAME=pet-food-store

echo.
echo 🔧 ขั้นตอนที่ 10: ติดตั้งและตั้งค่า WordPress
echo.

REM Install WP-CLI first
echo กำลังติดตั้ง WP-CLI...
call scripts\install-wp-cli.bat

REM Check if WordPress is already installed
docker exec %APP_NAME%_wordpress wp core is-installed --allow-root >nul 2>&1
if errorlevel 1 (
    echo กำลังติดตั้ง WordPress...
    docker exec %APP_NAME%_wordpress wp core install --url=http://localhost:8000 --title="Pet Food Store" --admin_user=admin --admin_password=admin123 --admin_email=admin@example.com --allow-root
    echo ✅ ติดตั้ง WordPress เรียบร้อย
) else (
    echo ✅ WordPress ติดตั้งแล้ว
)

REM Step 11: Install WooCommerce
echo.
echo 🛒 ขั้นตอนที่ 11: ติดตั้ง WooCommerce
echo.

docker exec %APP_NAME%_wordpress wp plugin install woocommerce --activate --allow-root
echo ✅ ติดตั้ง WooCommerce เรียบร้อย

REM Step 12: Configure WooCommerce
echo.
echo ⚙️ ขั้นตอนที่ 12: ตั้งค่า WooCommerce
echo.

REM Set currency to Thai Baht
docker exec %APP_NAME%_wordpress wp option update woocommerce_currency THB --allow-root

REM Set default country to Thailand
docker exec %APP_NAME%_wordpress wp option update woocommerce_default_country TH --allow-root

REM Set timezone
docker exec %APP_NAME%_wordpress wp option update timezone_string Asia/Bangkok --allow-root

REM Set date format
docker exec %APP_NAME%_wordpress wp option update date_format d/m/Y --allow-root

echo ✅ ตั้งค่า WooCommerce เรียบร้อย

REM Step 13: Activate custom theme
echo.
echo 🎨 ขั้นตอนที่ 13: เปิดใช้งานธีม Pet Paws
echo.

docker exec %APP_NAME%_wordpress wp theme activate pet-paws --allow-root
echo ✅ เปิดใช้งานธีม Pet Paws เรียบร้อย

REM Step 14: Create sample pages
echo.
echo 📄 ขั้นตอนที่ 14: สร้างหน้าตัวอย่าง
echo.

REM Create About Us page
docker exec %APP_NAME%_wordpress wp post create --post_type=page --post_title="เกี่ยวกับเรา" --post_content="ร้านอาหารสัตว์เลี้ยงคุณภาพสูง ดูแลสัตว์เลี้ยงของคุณด้วยความรัก" --post_status=publish --allow-root

REM Create Contact page
docker exec %APP_NAME%_wordpress wp post create --post_type=page --post_title="ติดต่อเรา" --post_content="โทร: 02-123-4567 | อีเมล: info@petfoodstore.com" --post_status=publish --allow-root

echo ✅ สร้างหน้าตัวอย่างเรียบร้อย

REM Step 15: Import sample products
echo.
echo 🐕 ขั้นตอนที่ 15: เพิ่มสินค้าตัวอย่าง
echo.

REM Create product categories
docker exec %APP_NAME%_wordpress wp term create product_cat "อาหารสุนัข" --description="อาหารคุณภาพสูงสำหรับสุนัข" --allow-root
docker exec %APP_NAME%_wordpress wp term create product_cat "อาหารแมว" --description="อาหารคุณภาพสูงสำหรับแมว" --allow-root
docker exec %APP_NAME%_wordpress wp term create product_cat "ของเล่นสัตว์เลี้ยง" --description="ของเล่นสนุกสำหรับสัตว์เลี้ยง" --allow-root

REM Create sample products
docker exec %APP_NAME%_wordpress wp post create --post_type=product --post_title="อาหารสุนัขพรีเมียม" --post_content="อาหารคุณภาพสูงสำหรับสุนัขทุกวัย" --post_status=publish --allow-root
docker exec %APP_NAME%_wordpress wp post create --post_type=product --post_title="อาหารแมวพรีเมียม" --post_content="อาหารคุณภาพสูงสำหรับแมวทุกวัย" --post_status=publish --allow-root
docker exec %APP_NAME%_wordpress wp post create --post_type=product --post_title="ลูกบอลของเล่นสุนัข" --post_content="ลูกบอลยางคุณภาพสูงสำหรับสุนัข" --post_status=publish --allow-root

echo ✅ เพิ่มสินค้าตัวอย่างเรียบร้อย

REM Step 16: Set up navigation menu
echo.
echo 🧭 ขั้นตอนที่ 16: ตั้งค่าเมนูนำทาง
echo.

REM Create primary menu
docker exec %APP_NAME%_wordpress wp menu create "Primary Menu" --allow-root

REM Add pages to menu
docker exec %APP_NAME%_wordpress wp menu item add-post "Primary Menu" 1 --allow-root
docker exec %APP_NAME%_wordpress wp menu item add-post "Primary Menu" 2 --allow-root

REM Assign menu to primary location
docker exec %APP_NAME%_wordpress wp menu location assign "Primary Menu" primary --allow-root

echo ✅ ตั้งค่าเมนูนำทางเรียบร้อย

REM Step 17: Final configuration
echo.
echo 🔧 ขั้นตอนที่ 17: การตั้งค่าสุดท้าย
echo.

REM Set homepage to show posts
docker exec %APP_NAME%_wordpress wp option update show_on_front posts --allow-root

REM Clear cache
docker exec %APP_NAME%_wordpress wp cache flush --allow-root

echo ✅ การตั้งค่าสุดท้ายเรียบร้อย

REM Step 18: Display final information
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
