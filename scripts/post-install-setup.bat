@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════╗
echo ║       🔧 Post-Install Setup - การตั้งค่าเพิ่มเติม      ║
echo ║         Pet Food Store Additional Configuration       ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,* delims==" %%a in (.env) do set "%%a=%%b"
) else (
    set APP_NAME=pet-food-store
)

echo 🎯 เริ่มต้นการตั้งค่าเพิ่มเติมหลังการติดตั้ง...
echo.

REM Check if WordPress is running
docker-compose ps | findstr wordpress >nul
if errorlevel 1 (
    echo ❌ WordPress container ไม่ได้ทำงาน!
    echo กรุณาเริ่มต้นระบบก่อน: scripts\auto-install-everything.bat
    pause
    exit /b 1
)

echo ✅ WordPress container ทำงานอยู่
echo.

:main_menu
echo 🔧 เลือกการตั้งค่าเพิ่มเติม:
echo.
echo 🛒 จัดการ WooCommerce:
echo    1) ตั้งค่าการชำระเงิน
echo    2) ตั้งค่าการจัดส่ง
echo    3) เพิ่มสินค้าตัวอย่างเพิ่มเติม
echo    4) ตั้งค่าภาษี
echo.
echo 🎨 จัดการธีม:
echo    5) ปรับแต่งธีม Pet Paws
echo    6) เพิ่มรูปภาพตัวอย่าง
echo    7) ตั้งค่าเมนูเพิ่มเติม
echo.
echo 🔧 จัดการระบบ:
echo    8) ตั้งค่าความปลอดภัย
echo    9) ตั้งค่าการสำรองข้อมูล
echo    10) ตั้งค่าอีเมล
echo.
echo 📊 ข้อมูลและรายงาน:
echo    11) ดูสถิติการใช้งาน
echo    12) ตรวจสอบการติดตั้ง
echo    13) ดูรายการสินค้า
echo.
echo ❌ ออกจากระบบ:
echo    0) ออกจากระบบ
echo.
set /p choice="เลือกตัวเลือก (0-13): "

if "%choice%"=="0" (
    echo 👋 ขอบคุณที่ใช้งาน!
    pause
    exit /b 0
) else if "%choice%"=="1" (
    call :setup_payment_methods
) else if "%choice%"=="2" (
    call :setup_shipping
) else if "%choice%"=="3" (
    call :add_more_products
) else if "%choice%"=="4" (
    call :setup_tax
) else if "%choice%"=="5" (
    call :customize_theme
) else if "%choice%"=="6" (
    call :add_sample_images
) else if "%choice%"=="7" (
    call :setup_additional_menus
) else if "%choice%"=="8" (
    call :setup_security
) else if "%choice%"=="9" (
    call :setup_backup
) else if "%choice%"=="10" (
    call :setup_email
) else if "%choice%"=="11" (
    call :show_statistics
) else if "%choice%"=="12" (
    call :check_installation
) else if "%choice%"=="13" (
    call :list_products
) else (
    echo ❌ ตัวเลือกไม่ถูกต้อง กรุณาลองใหม่
    timeout /t 2 /nobreak >nul
)

echo.
pause
cls
goto :main_menu

:setup_payment_methods
echo.
echo 💳 ตั้งค่าการชำระเงิน...
echo.

REM Enable bank transfer
docker exec %APP_NAME%_wordpress wp option update woocommerce_bacs_settings '{"enabled":"yes","title":"โอนเงินผ่านธนาคาร","description":"โอนเงินผ่านธนาคาร","instructions":"กรุณาโอนเงินไปยังบัญชีธนาคารของเรา","account_name":"","account_number":"","bank_name":"","sort_code":"","iban":"","bic":""}' --format=json --allow-root

REM Enable cash on delivery
docker exec %APP_NAME%_wordpress wp option update woocommerce_cod_settings '{"enabled":"yes","title":"เก็บเงินปลายทาง","description":"ชำระเงินเมื่อได้รับสินค้า","instructions":"ชำระเงินเมื่อได้รับสินค้า","enable_for_methods":"","enable_for_virtual":"","enable_for_methods__enabled":"","enable_for_methods__disabled":""}' --format=json --allow-root

echo ✅ ตั้งค่าการชำระเงินเรียบร้อย
echo    - โอนเงินผ่านธนาคาร
echo    - เก็บเงินปลายทาง
goto :eof

:setup_shipping
echo.
echo 🚚 ตั้งค่าการจัดส่ง...
echo.

REM Create shipping zones
docker exec %APP_NAME%_wordpress wp wc shipping_zone create --name="กรุงเทพฯ" --allow-root
docker exec %APP_NAME%_wordpress wp wc shipping_zone create --name="ต่างจังหวัด" --allow-root

REM Add flat rate shipping to Bangkok
docker exec %APP_NAME%_wordpress wp wc shipping_zone_method add 1 flat_rate --settings='{"cost":"50","title":"จัดส่งในกรุงเทพฯ"}' --allow-root

REM Add flat rate shipping to other provinces
docker exec %APP_NAME%_wordpress wp wc shipping_zone_method add 2 flat_rate --settings='{"cost":"100","title":"จัดส่งต่างจังหวัด"}' --allow-root

echo ✅ ตั้งค่าการจัดส่งเรียบร้อย
echo    - กรุงเทพฯ: 50 บาท
echo    - ต่างจังหวัด: 100 บาท
goto :eof

:add_more_products
echo.
echo 🐕 เพิ่มสินค้าตัวอย่างเพิ่มเติม...
echo.

REM Create more product categories
docker exec %APP_NAME%_wordpress wp term create product_cat "อาหารสัตว์เล็ก" --description="อาหารสำหรับสัตว์เล็ก" --allow-root
docker exec %APP_NAME%_wordpress wp term create product_cat "อาหารสัตว์น้ำ" --description="อาหารสำหรับสัตว์น้ำ" --allow-root
docker exec %APP_NAME%_wordpress wp term create product_cat "อุปกรณ์ดูแลสัตว์" --description="อุปกรณ์สำหรับดูแลสัตว์เลี้ยง" --allow-root

REM Create more sample products
docker exec %APP_NAME%_wordpress wp post create --post_type=product --post_title="อาหารกระต่ายพรีเมียม" --post_content="อาหารคุณภาพสูงสำหรับกระต่าย" --post_status=publish --allow-root
docker exec %APP_NAME%_wordpress wp post create --post_type=product --post_title="อาหารปลาสีสวย" --post_content="อาหารสำหรับปลาสวยงาม" --post_status=publish --allow-root
docker exec %APP_NAME%_wordpress wp post create --post_type=product --post_title="แปรงขนสุนัข" --post_content="แปรงขนคุณภาพสูงสำหรับสุนัข" --post_status=publish --allow-root
docker exec %APP_NAME%_wordpress wp post create --post_type=product --post_title="กรงนกขนาดกลาง" --post_content="กรงนกคุณภาพสูงขนาดกลาง" --post_status=publish --allow-root

echo ✅ เพิ่มสินค้าตัวอย่างเพิ่มเติมเรียบร้อย
echo    - อาหารกระต่ายพรีเมียม
echo    - อาหารปลาสีสวย
echo    - แปรงขนสุนัข
echo    - กรงนกขนาดกลาง
goto :eof

:setup_tax
echo.
echo 💰 ตั้งค่าภาษี...
echo.

REM Enable tax calculation
docker exec %APP_NAME%_wordpress wp option update woocommerce_calc_taxes yes --allow-root

REM Set tax rates for Thailand
docker exec %APP_NAME%_wordpress wp option update woocommerce_tax_display_shop incl --allow-root
docker exec %APP_NAME%_wordpress wp option update woocommerce_tax_display_cart incl --allow-root

REM Create tax rate for Thailand (7% VAT)
docker exec %APP_NAME%_wordpress wp wc tax_rate create --country=TH --rate=7 --name="ภาษีมูลค่าเพิ่ม" --shipping=yes --allow-root

echo ✅ ตั้งค่าภาษีเรียบร้อย
echo    - เปิดใช้งานการคำนวณภาษี
echo    - ภาษีมูลค่าเพิ่ม 7%%
goto :eof

:customize_theme
echo.
echo 🎨 ปรับแต่งธีม Pet Paws...
echo.

REM Create custom CSS file
if not exist "wp-content\themes\pet-paws\custom.css" (
    echo /* Custom CSS for Pet Paws Theme */ > "wp-content\themes\pet-paws\custom.css"
    echo .site-title h1 { >> "wp-content\themes\pet-paws\custom.css"
    echo     color: #2c5530; >> "wp-content\themes\pet-paws\custom.css"
    echo     font-size: 2.5em; >> "wp-content\themes\pet-paws\custom.css"
    echo     font-weight: bold; >> "wp-content\themes\pet-paws\custom.css"
    echo } >> "wp-content\themes\pet-paws\custom.css"
    echo. >> "wp-content\themes\pet-paws\custom.css"
    echo .main-header { >> "wp-content\themes\pet-paws\custom.css"
    echo     background: linear-gradient(135deg, #4CAF50, #2E7D32); >> "wp-content\themes\pet-paws\custom.css"
    echo     color: white; >> "wp-content\themes\pet-paws\custom.css"
    echo } >> "wp-content\themes\pet-paws\custom.css"
)

REM Update functions.php to include custom CSS
echo add_action('wp_enqueue_scripts', 'pet_paws_custom_styles'); >> "wp-content\themes\pet-paws\functions.php"
echo function pet_paws_custom_styles() { >> "wp-content\themes\pet-paws\functions.php"
echo     wp_enqueue_style('pet-paws-custom', get_template_directory_uri() . '/custom.css', array(), '1.0'); >> "wp-content\themes\pet-paws\functions.php"
echo } >> "wp-content\themes\pet-paws\functions.php"

echo ✅ ปรับแต่งธีมเรียบร้อย
echo    - สร้างไฟล์ custom.css
echo    - ปรับแต่งสีและฟอนต์
goto :eof

:add_sample_images
echo.
echo 🖼️ เพิ่มรูปภาพตัวอย่าง...
echo.

REM Copy example images to theme directory
if exist "wp-content\uploads\2024\12\example-ui\*.jpg" (
    if not exist "wp-content\themes\pet-paws\images" mkdir "wp-content\themes\pet-paws\images"
    copy "wp-content\uploads\2024\12\example-ui\*.jpg" "wp-content\themes\pet-paws\images\" >nul
    echo ✅ คัดลอกรูปภาพตัวอย่างไปยังธีม
)

REM Create sample product images
if not exist "wp-content\uploads\2024\12\products" mkdir "wp-content\uploads\2024\12\products"

echo ✅ เพิ่มรูปภาพตัวอย่างเรียบร้อย
goto :eof

:setup_additional_menus
echo.
echo 🧭 ตั้งค่าเมนูเพิ่มเติม...
echo.

REM Create footer menu
docker exec %APP_NAME%_wordpress wp menu create "Footer Menu" --allow-root

REM Add links to footer menu
docker exec %APP_NAME%_wordpress wp menu item add-custom "Footer Menu" "นโยบายความเป็นส่วนตัว" "/privacy-policy" --allow-root
docker exec %APP_NAME%_wordpress wp menu item add-custom "Footer Menu" "เงื่อนไขการใช้งาน" "/terms-of-service" --allow-root
docker exec %APP_NAME%_wordpress wp menu item add-custom "Footer Menu" "คืนสินค้า" "/return-policy" --allow-root

REM Create social media menu
docker exec %APP_NAME%_wordpress wp menu create "Social Menu" --allow-root

REM Add social media links
docker exec %APP_NAME%_wordpress wp menu item add-custom "Social Menu" "Facebook" "https://facebook.com/petfoodstore" --allow-root
docker exec %APP_NAME%_wordpress wp menu item add-custom "Social Menu" "Instagram" "https://instagram.com/petfoodstore" --allow-root
docker exec %APP_NAME%_wordpress wp menu item add-custom "Social Menu" "Line" "https://line.me/petfoodstore" --allow-root

echo ✅ ตั้งค่าเมนูเพิ่มเติมเรียบร้อย
echo    - Footer Menu
echo    - Social Menu
goto :eof

:setup_security
echo.
echo 🔒 ตั้งค่าความปลอดภัย...
echo.

REM Change admin password
set /p new_password="ใส่รหัสผ่านใหม่สำหรับ admin: "
if not "%new_password%"=="" (
    docker exec %APP_NAME%_wordpress wp user update admin --user_pass="%new_password%" --allow-root
    echo ✅ เปลี่ยนรหัสผ่าน admin เรียบร้อย
)

REM Enable two-factor authentication (if plugin available)
docker exec %APP_NAME%_wordpress wp plugin install two-factor --activate --allow-root

REM Set file permissions
icacls "wp-content" /grant "Users":(OI)(CI)F /T

echo ✅ ตั้งค่าความปลอดภัยเรียบร้อย
goto :eof

:setup_backup
echo.
echo 💾 ตั้งค่าการสำรองข้อมูล...
echo.

REM Create backup directory if not exists
if not exist "backups\auto" mkdir "backups\auto"

REM Create backup schedule info
echo # Auto Backup Schedule > "backups\auto\schedule.txt"
echo # Daily backup at 2:00 AM >> "backups\auto\schedule.txt"
echo # Weekly backup on Sunday >> "backups\auto\schedule.txt"
echo # Monthly backup on 1st >> "backups\auto\schedule.txt"

REM Create backup script
echo @echo off > "backups\auto\daily-backup.bat"
echo cd /d "%~dp0\.." >> "backups\auto\daily-backup.bat"
echo call scripts\backup.bat >> "backups\auto\daily-backup.bat"

echo ✅ ตั้งค่าการสำรองข้อมูลเรียบร้อย
echo    - สร้างโฟลเดอร์ auto backup
echo    - สร้าง script สำรองข้อมูลอัตโนมัติ
goto :eof

:setup_email
echo.
echo 📧 ตั้งค่าอีเมล...
echo.

REM Configure SMTP settings
docker exec %APP_NAME%_wordpress wp option update smtp_host mailhog --allow-root
docker exec %APP_NAME%_wordpress wp option update smtp_port 1025 --allow-root
docker exec %APP_NAME%_wordpress wp option update smtp_secure "" --allow-root
docker exec %APP_NAME%_wordpress wp option update smtp_auth false --allow-root

REM Set admin email
docker exec %APP_NAME%_wordpress wp option update admin_email admin@petfoodstore.com --allow-root

echo ✅ ตั้งค่าอีเมลเรียบร้อย
echo    - SMTP: mailhog (localhost:1025)
echo    - Admin Email: admin@petfoodstore.com
echo    - ดูอีเมลได้ที่: http://localhost:8025
goto :eof

:show_statistics
echo.
echo 📊 สถิติการใช้งาน...
echo.

echo 📈 สถิติ WordPress:
docker exec %APP_NAME%_wordpress wp user count --allow-root
docker exec %APP_NAME%_wordpress wp post count --allow-root
docker exec %APP_NAME%_wordpress wp post count --post_type=product --allow-root

echo.
echo 🛒 สถิติ WooCommerce:
docker exec %APP_NAME%_wordpress wp wc order list --limit=5 --allow-root

echo.
echo 💾 ข้อมูลระบบ:
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

goto :eof

:check_installation
echo.
echo 🔍 ตรวจสอบการติดตั้ง...
echo.

echo 📋 ตรวจสอบ WordPress:
docker exec %APP_NAME%_wordpress wp core version --allow-root
docker exec %APP_NAME%_wordpress wp core is-installed --allow-root

echo.
echo 🛒 ตรวจสอบ WooCommerce:
docker exec %APP_NAME%_wordpress wp plugin list --status=active --allow-root

echo.
echo 🎨 ตรวจสอบธีม:
docker exec %APP_NAME%_wordpress wp theme list --status=active --allow-root

echo.
echo 📁 ตรวจสอบไฟล์:
if exist "wp-content\themes\pet-paws" echo ✅ ธีม Pet Paws
if exist "wp-content\uploads\2024\12\example-ui" echo ✅ รูปภาพตัวอย่าง
if exist "dev-workspace\ui-template" echo ✅ UI Template

goto :eof

:list_products
echo.
echo 🛍️ รายการสินค้า...
echo.

echo 📦 สินค้าทั้งหมด:
docker exec %APP_NAME%_wordpress wp post list --post_type=product --allow-root

echo.
echo 🏷️ หมวดหมู่สินค้า:
docker exec %APP_NAME%_wordpress wp term list product_cat --allow-root

goto :eof
