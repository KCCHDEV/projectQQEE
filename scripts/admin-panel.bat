@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Admin Management Panel for WordPress/WooCommerce
REM Thai Language Support Edition

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
    )
)

if "%APP_NAME%"=="" set APP_NAME=pet-food-store

REM Function to display Thai menu
:show_menu
cls
echo ╔═══════════════════════════════════════════════════════╗
echo ║       🏪 ระบบจัดการร้านค้าอาหารสัตว์เลี้ยง 🐾          ║
echo ║         Pet Food Store Admin Panel                    ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 🔧 การจัดการระบบ (System Management)
echo 1)  🚀 เริ่มระบบ (Start System)
echo 2)  🛑 หยุดระบบ (Stop System)
echo 3)  🔄 รีสตาร์ทระบบ (Restart System)
echo 4)  📊 ตรวจสอบสถานะ (Check Status)
echo.
echo 💾 การสำรองข้อมูล (Backup ^& Restore)
echo 5)  📦 สำรองข้อมูล (Create Backup)
echo 6)  📥 คืนค่าข้อมูล (Restore Backup)
echo 7)  📋 ดูรายการสำรองข้อมูล (List Backups)
echo.
echo 🛒 จัดการ WooCommerce
echo 8)  📝 ดูคำสั่งซื้อล่าสุด (View Recent Orders)
echo 9)  📦 ดูสินค้าทั้งหมด (View Products)
echo 10) 👥 ดูลูกค้า (View Customers)
echo 11) 🔧 ตั้งค่าร้านค้า (Store Settings)
echo.
echo 🔧 เครื่องมือดูแลระบบ (Admin Tools)
echo 12) 🔄 อัพเดท WordPress และปลั๊กอิน (Update WordPress)
echo 13) 🧹 ล้างแคช (Clear Cache)
echo 14) 📄 ดูล็อกระบบ (View Logs)
echo 15) 🔒 ตั้งค่าความปลอดภัย (Security Settings)
echo.
echo 🌐 ตั้งค่าภาษา (Language Settings)
echo 16) 🇹🇭 ติดตั้งภาษาไทย (Install Thai Language)
echo 17) 🌏 เปลี่ยนภาษา (Change Language)
echo.
echo 18) ❌ ออกจากระบบ (Exit)
echo.
goto :main_loop

REM Function to start system
:start_system
echo 🚀 กำลังเริ่มระบบ...
docker-compose up -d
echo ✅ ระบบเริ่มทำงานเรียบร้อย!
timeout /t 2 /nobreak >nul
goto :eof

REM Function to stop system
:stop_system
echo 🛑 กำลังหยุดระบบ...
docker-compose down
echo ✅ หยุดระบบเรียบร้อย!
timeout /t 2 /nobreak >nul
goto :eof

REM Function to check status
:check_status
echo 📊 สถานะระบบปัจจุบัน:
echo.
docker-compose ps
echo.
echo 📈 การใช้ทรัพยากร:
docker stats --no-stream
echo.
pause
goto :eof

REM Function to view recent orders
:view_orders
echo 📝 คำสั่งซื้อล่าสุด 10 รายการ:
echo.
docker exec %APP_NAME%_wordpress wp wc shop_order list --fields=id,status,total,date_created,billing_first_name,billing_last_name --format=table --orderby=date_created --order=desc --limit=10 --allow-root 2>nul || echo ยังไม่มีคำสั่งซื้อ
echo.
pause
goto :eof

REM Function to view products
:view_products
echo 📦 สินค้าทั้งหมด:
echo.
docker exec %APP_NAME%_wordpress wp wc product list --fields=id,name,price,stock_status --format=table --limit=20 --allow-root 2>nul || echo ยังไม่มีสินค้า
echo.
pause
goto :eof

REM Function to install Thai language
:install_thai
echo 🇹🇭 กำลังติดตั้งภาษาไทย...

REM Install Thai language pack
docker exec %APP_NAME%_wordpress wp language core install th --allow-root
docker exec %APP_NAME%_wordpress wp language plugin install woocommerce th --allow-root
docker exec %APP_NAME%_wordpress wp language theme install storefront th --allow-root

REM Set Thai as default language
docker exec %APP_NAME%_wordpress wp site switch-language th --allow-root

REM Update WooCommerce to Thai Baht
docker exec %APP_NAME%_wordpress wp option update woocommerce_currency "THB" --allow-root
docker exec %APP_NAME%_wordpress wp option update woocommerce_currency_pos "left_space" --allow-root

echo ✅ ติดตั้งภาษาไทยเรียบร้อย!
timeout /t 2 /nobreak >nul
goto :eof

REM Function to clear cache
:clear_cache
echo 🧹 กำลังล้างแคช...

REM Clear WordPress cache
docker exec %APP_NAME%_wordpress wp cache flush --allow-root 2>nul

REM Clear Redis cache
docker exec %APP_NAME%_redis redis-cli FLUSHALL 2>nul

REM Clear WooCommerce transients
docker exec %APP_NAME%_wordpress wp transient delete --all --allow-root 2>nul

echo ✅ ล้างแคชเรียบร้อย!
timeout /t 2 /nobreak >nul
goto :eof

REM Function to update WordPress
:update_wordpress
echo 🔄 กำลังอัพเดท WordPress และปลั๊กอิน...

REM Update WordPress core
docker exec %APP_NAME%_wordpress wp core update --allow-root

REM Update all plugins
docker exec %APP_NAME%_wordpress wp plugin update --all --allow-root

REM Update all themes
docker exec %APP_NAME%_wordpress wp theme update --all --allow-root

REM Update database if needed
docker exec %APP_NAME%_wordpress wp core update-db --allow-root

echo ✅ อัพเดทเรียบร้อย!
timeout /t 2 /nobreak >nul
goto :eof

REM Function to list backups
:list_backups
echo 📋 รายการสำรองข้อมูล:
echo.
if exist backups\*.info (
    for %%f in (backups\*.info) do (
        set "filename=%%~nf"
        echo 📅 !filename:backup_=!
    )
) else (
    echo ไม่พบข้อมูลสำรอง
)
echo.
pause
goto :eof

REM Function to view logs
:view_logs
echo 📄 เลือกล็อกที่ต้องการดู:
echo 1) WordPress logs
echo 2) Database logs
echo 3) Redis logs
echo 4) All logs
echo.
set /p log_choice="เลือก (1-4): "

if "%log_choice%"=="1" (
    docker-compose logs --tail=50 wordpress
) else if "%log_choice%"=="2" (
    docker-compose logs --tail=50 db
) else if "%log_choice%"=="3" (
    docker-compose logs --tail=50 redis
) else if "%log_choice%"=="4" (
    docker-compose logs --tail=50
)

echo.
pause
goto :eof

REM Function to manage store settings
:store_settings
echo 🔧 ตั้งค่าร้านค้า:
echo.

REM Get current settings
for /f %%c in ('docker exec %APP_NAME%_wordpress wp option get woocommerce_currency --allow-root 2^>nul') do set CURRENCY=%%c
for /f %%s in ('docker exec %APP_NAME%_wordpress wp option get blogname --allow-root 2^>nul') do set STORE_NAME=%%s

echo ชื่อร้าน: %STORE_NAME%
echo สกุลเงิน: %CURRENCY%
echo.
echo 1) เปลี่ยนชื่อร้าน
echo 2) ตั้งค่าการจัดส่ง
echo 3) ตั้งค่าการชำระเงิน
echo 4) กลับเมนูหลัก
echo.
set /p setting_choice="เลือก (1-4): "

if "%setting_choice%"=="1" (
    set /p new_name="ชื่อร้านใหม่: "
    docker exec %APP_NAME%_wordpress wp option update blogname "%new_name%" --allow-root
    echo ✅ เปลี่ยนชื่อร้านเรียบร้อย!
) else if "%setting_choice%"=="2" (
    echo กรุณาไปที่ WooCommerce ^> Settings ^> Shipping ในหน้าแอดมิน
) else if "%setting_choice%"=="3" (
    echo กรุณาไปที่ WooCommerce ^> Settings ^> Payments ในหน้าแอดมิน
)

timeout /t 2 /nobreak >nul
goto :eof

REM Main loop
:main_loop
set /p choice="เลือกเมนู (1-18): "
echo.

if "%choice%"=="1" (
    call :start_system
) else if "%choice%"=="2" (
    call :stop_system
) else if "%choice%"=="3" (
    call :stop_system
    call :start_system
) else if "%choice%"=="4" (
    call :check_status
) else if "%choice%"=="5" (
    call scripts\backup.bat
) else if "%choice%"=="6" (
    echo รายการสำรองข้อมูล:
    if exist backups\*.info (
        for %%f in (backups\*.info) do (
            set "filename=%%~nf"
            echo !filename:backup_=!
        )
    ) else (
        echo ไม่พบข้อมูลสำรอง
    )
    set /p timestamp="ใส่ timestamp ที่ต้องการคืนค่า: "
    call scripts\restore.bat "%timestamp%"
) else if "%choice%"=="7" (
    call :list_backups
) else if "%choice%"=="8" (
    call :view_orders
) else if "%choice%"=="9" (
    call :view_products
) else if "%choice%"=="10" (
    docker exec %APP_NAME%_wordpress wp user list --role=customer --allow-root
    pause
) else if "%choice%"=="11" (
    call :store_settings
) else if "%choice%"=="12" (
    call :update_wordpress
) else if "%choice%"=="13" (
    call :clear_cache
) else if "%choice%"=="14" (
    call :view_logs
) else if "%choice%"=="15" (
    echo 🔒 คำแนะนำด้านความปลอดภัย:
    echo 1. เปลี่ยนรหัสผ่านใน .env
    echo 2. ใช้ SSL certificate
    echo 3. อัพเดทระบบเป็นประจำ
    echo 4. สำรองข้อมูลทุกวัน
    pause
) else if "%choice%"=="16" (
    call :install_thai
) else if "%choice%"=="17" (
    echo ภาษาที่ใช้ได้: en_US, th
    set /p lang="เลือกภาษา: "
    docker exec %APP_NAME%_wordpress wp site switch-language "%lang%" --allow-root
    echo ✅ เปลี่ยนภาษาเรียบร้อย!
    timeout /t 2 /nobreak >nul
) else if "%choice%"=="18" (
    echo 👋 ขอบคุณที่ใช้งาน!
    pause
    exit /b 0
) else (
    echo ❌ ตัวเลือกไม่ถูกต้อง
    timeout /t 1 /nobreak >nul
)

goto :show_menu
