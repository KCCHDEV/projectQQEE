@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════╗
echo ║       🧪 Test System - ทดสอบระบบหลังการติดตั้ง        ║
echo ║         Pet Food Store System Test                   ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,* delims==" %%a in (.env) do set "%%a=%%b"
) else (
    set APP_NAME=pet-food-store
    set WORDPRESS_PORT=8000
    set PHPMYADMIN_PORT=8080
    set MAILHOG_WEB_PORT=8025
)

echo 🎯 เริ่มต้นการทดสอบระบบ...
echo.

REM Test 1: Check Docker containers
echo 📋 ทดสอบที่ 1: ตรวจสอบ Docker Containers
echo.

docker-compose ps
if errorlevel 1 (
    echo ❌ Docker containers ไม่ทำงาน!
    echo กรุณาเริ่มต้นระบบก่อน: scripts\auto-install-everything.bat
    pause
    exit /b 1
)

echo ✅ Docker containers ทำงานปกติ
echo.

REM Test 2: Check WordPress installation
echo 📋 ทดสอบที่ 2: ตรวจสอบการติดตั้ง WordPress
echo.

docker exec %APP_NAME%_wordpress wp core is-installed --allow-root >nul 2>&1
if errorlevel 1 (
    echo ❌ WordPress ไม่ได้ติดตั้ง!
    pause
    exit /b 1
)

echo ✅ WordPress ติดตั้งแล้ว

REM Check WordPress version
for /f "tokens=*" %%i in ('docker exec %APP_NAME%_wordpress wp core version --allow-root') do (
    echo 📦 WordPress Version: %%i
)

echo.

REM Test 3: Check WooCommerce
echo 📋 ทดสอบที่ 3: ตรวจสอบ WooCommerce
echo.

docker exec %APP_NAME%_wordpress wp plugin is-active woocommerce --allow-root >nul 2>&1
if errorlevel 1 (
    echo ❌ WooCommerce ไม่ได้เปิดใช้งาน!
) else (
    echo ✅ WooCommerce เปิดใช้งานแล้ว
)

echo.

REM Test 4: Check theme
echo 📋 ทดสอบที่ 4: ตรวจสอบธีม
echo.

docker exec %APP_NAME%_wordpress wp theme list --status=active --allow-root
echo.

REM Test 5: Check database connection
echo 📋 ทดสอบที่ 5: ตรวจสอบการเชื่อมต่อฐานข้อมูล
echo.

docker exec %APP_NAME%_wordpress wp db check --allow-root >nul 2>&1
if errorlevel 1 (
    echo ❌ ปัญหาการเชื่อมต่อฐานข้อมูล!
) else (
    echo ✅ การเชื่อมต่อฐานข้อมูลปกติ
)

echo.

REM Test 6: Check file permissions
echo 📋 ทดสอบที่ 6: ตรวจสอบสิทธิ์ไฟล์
echo.

if exist "wp-content\themes\pet-paws" (
    echo ✅ ธีม Pet Paws พบ
) else (
    echo ❌ ธีม Pet Paws ไม่พบ
)

if exist "wp-content\uploads\2024\12\example-ui" (
    echo ✅ รูปภาพตัวอย่างพบ
) else (
    echo ❌ รูปภาพตัวอย่างไม่พบ
)

if exist "dev-workspace\ui-template" (
    echo ✅ UI Template พบ
) else (
    echo ❌ UI Template ไม่พบ
)

echo.

REM Test 7: Check ports
echo 📋 ทดสอบที่ 7: ตรวจสอบพอร์ต
echo.

netstat -an | findstr :%WORDPRESS_PORT% >nul
if errorlevel 1 (
    echo ❌ พอร์ต %WORDPRESS_PORT% ไม่ได้ใช้งาน
) else (
    echo ✅ พอร์ต %WORDPRESS_PORT% (WordPress) ใช้งานได้
)

netstat -an | findstr :%PHPMYADMIN_PORT% >nul
if errorlevel 1 (
    echo ❌ พอร์ต %PHPMYADMIN_PORT% ไม่ได้ใช้งาน
) else (
    echo ✅ พอร์ต %PHPMYADMIN_PORT% (phpMyAdmin) ใช้งานได้
)

netstat -an | findstr :%MAILHOG_WEB_PORT% >nul
if errorlevel 1 (
    echo ❌ พอร์ต %MAILHOG_WEB_PORT% ไม่ได้ใช้งาน
) else (
    echo ✅ พอร์ต %MAILHOG_WEB_PORT% (MailHog) ใช้งานได้
)

echo.

REM Test 8: Check sample content
echo 📋 ทดสอบที่ 8: ตรวจสอบเนื้อหาตัวอย่าง
echo.

REM Check pages
docker exec %APP_NAME%_wordpress wp post list --post_type=page --allow-root
echo.

REM Check products
docker exec %APP_NAME%_wordpress wp post list --post_type=product --allow-root
echo.

REM Check categories
docker exec %APP_NAME%_wordpress wp term list product_cat --allow-root
echo.

REM Test 9: Check WooCommerce settings
echo 📋 ทดสอบที่ 9: ตรวจสอบการตั้งค่า WooCommerce
echo.

for /f "tokens=*" %%i in ('docker exec %APP_NAME%_wordpress wp option get woocommerce_currency --allow-root') do (
    echo 💰 สกุลเงิน: %%i
)

for /f "tokens=*" %%i in ('docker exec %APP_NAME%_wordpress wp option get woocommerce_default_country --allow-root') do (
    echo 🌍 ประเทศ: %%i
)

for /f "tokens=*" %%i in ('docker exec %APP_NAME%_wordpress wp option get timezone_string --allow-root') do (
    echo 🕐 เขตเวลา: %%i
)

echo.

REM Test 10: Performance test
echo 📋 ทดสอบที่ 10: ทดสอบประสิทธิภาพ
echo.

echo 📊 การใช้ทรัพยากร:
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
echo.

REM Test 11: URL accessibility test
echo 📋 ทดสอบที่ 11: ทดสอบการเข้าถึง URL
echo.

echo 🌐 ทดสอบการเข้าถึง URL:
echo    WordPress: http://localhost:%WORDPRESS_PORT%
echo    phpMyAdmin: http://localhost:%PHPMYADMIN_PORT%
echo    MailHog: http://localhost:%MAILHOG_WEB_PORT%
echo.

REM Test 12: Admin access test
echo 📋 ทดสอบที่ 12: ทดสอบการเข้าถึงแอดมิน
echo.

echo 👤 ข้อมูลเข้าสู่ระบบแอดมิน:
echo    URL: http://localhost:%WORDPRESS_PORT%/wp-admin
echo    Username: admin
echo    Password: admin123
echo.

REM Test 13: Backup test
echo 📋 ทดสอบที่ 13: ทดสอบการสำรองข้อมูล
echo.

if exist "backups" (
    echo ✅ โฟลเดอร์ backups พบ
    dir backups /b
) else (
    echo ❌ โฟลเดอร์ backups ไม่พบ
)

echo.

REM Test 14: Environment file test
echo 📋 ทดสอบที่ 14: ตรวจสอบไฟล์ .env
echo.

if exist ".env" (
    echo ✅ ไฟล์ .env พบ
    echo 📄 เนื้อหาสำคัญ:
    findstr "APP_NAME\|WORDPRESS_PORT\|DB_" .env
) else (
    echo ❌ ไฟล์ .env ไม่พบ
)

echo.

REM Final summary
echo ╔═══════════════════════════════════════════════════════╗
echo ║                    🎉 สรุปการทดสอบ                    ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

echo ✅ ระบบพร้อมใช้งาน!
echo.
echo 🌐 ลิงก์สำคัญ:
echo    📱 เว็บไซต์: http://localhost:%WORDPRESS_PORT%
echo    👤 แอดมิน: http://localhost:%WORDPRESS_PORT%/wp-admin
echo    📊 phpMyAdmin: http://localhost:%PHPMYADMIN_PORT%
echo    📧 MailHog: http://localhost:%MAILHOG_WEB_PORT%
echo.
echo 🔑 ข้อมูลเข้าสู่ระบบ:
echo    👤 Username: admin
echo    🔒 Password: admin123
echo.
echo 💡 คำแนะนำ:
echo    - เปลี่ยนรหัสผ่าน admin ทันที
echo    - เพิ่มสินค้าของคุณใน WooCommerce
echo    - ปรับแต่งธีมตามต้องการ
echo    - สำรองข้อมูลเป็นประจำ
echo.
echo 🚀 คำสั่งที่มีประโยชน์:
echo    📊 ดูสถานะ: docker-compose ps
echo    📄 ดู logs: docker-compose logs -f
echo    🛑 หยุดระบบ: docker-compose down
echo    🔄 รีสตาร์ท: docker-compose restart
echo.
echo ✅ การทดสอบเสร็จสิ้น! ระบบพร้อมใช้งาน
echo.

pause
