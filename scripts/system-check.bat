@echo off
chcp 65001
setlocal enabledelayedexpansion

REM System Check Script for WordPress/WooCommerce
REM ตรวจสอบความพร้อมของระบบ

echo 🔍 ตรวจสอบระบบ WordPress/WooCommerce
echo ==========================================
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="WORDPRESS_PORT" set WORDPRESS_PORT=%%B
        if "%%A"=="PHPMYADMIN_PORT" set PHPMYADMIN_PORT=%%B
        if "%%A"=="MAILHOG_WEB_PORT" set MAILHOG_WEB_PORT=%%B
        if "%%A"=="REDIS_PORT" set REDIS_PORT=%%B
        if "%%A"=="APP_URL" set APP_URL=%%B
    )
    echo ✅ พบไฟล์ .env
) else (
    echo ❌ ไม่พบไฟล์ .env
    echo    กรุณาคัดลอกจาก .env.example และแก้ไขค่าต่างๆ
    pause
    exit /b 1
)

if "%APP_NAME%"=="" set APP_NAME=pet-food-store

REM Check Docker
echo.
echo 1. ตรวจสอบ Docker
docker --version >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=3" %%i in ('docker --version') do echo ✅ Docker: %%i
) else (
    echo ❌ Docker ไม่ได้ติดตั้ง
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=3" %%i in ('docker-compose --version') do echo ✅ Docker Compose: %%i
) else (
    echo ❌ Docker Compose ไม่ได้ติดตั้ง
    pause
    exit /b 1
)

REM Check directories
echo.
echo 2. ตรวจสอบโฟลเดอร์
set REQUIRED_DIRS=scripts backups wp-content admin-dashboard
for %%d in (%REQUIRED_DIRS%) do (
    if exist "%%d" (
        echo ✅ โฟลเดอร์ %%d
    ) else (
        echo ⚠️  สร้างโฟลเดอร์ %%d
        mkdir "%%d"
    )
)

REM Check scripts
echo.
echo 3. ตรวจสอบสคริปต์
set REQUIRED_SCRIPTS=scripts\backup.bat scripts\restore.bat scripts\migrate.bat scripts\quick-start.bat scripts\admin-panel.bat scripts\setup-thai.bat
for %%s in (%REQUIRED_SCRIPTS%) do (
    if exist "%%s" (
        echo ✅ %%s
    ) else (
        echo ❌ %%s ไม่พบไฟล์
    )
)

REM Check container status
echo.
echo 4. ตรวจสอบ Container Status
docker-compose ps >nul 2>&1
if not errorlevel 1 (
    set SERVICES=wordpress db redis phpmyadmin mailhog admin
    for %%s in (%SERVICES%) do (
        docker-compose ps | findstr "%APP_NAME%_%%s.*running" >nul 2>&1
        if not errorlevel 1 (
            echo ✅ %%s - ทำงานปกติ
        ) else (
            echo ❌ %%s - ไม่ทำงาน
        )
    )
) else (
    echo ⚠️  Containers ยังไม่เริ่มทำงาน
)

REM Check ports
echo.
echo 5. ตรวจสอบ Ports
if "%WORDPRESS_PORT%"=="" set WORDPRESS_PORT=8000
if "%PHPMYADMIN_PORT%"=="" set PHPMYADMIN_PORT=8080
if "%MAILHOG_WEB_PORT%"=="" set MAILHOG_WEB_PORT=8025
if "%REDIS_PORT%"=="" set REDIS_PORT=6379

netstat -an | findstr ":%WORDPRESS_PORT% " >nul 2>&1
if not errorlevel 1 (
    echo ✅ Port %WORDPRESS_PORT% (WordPress) - ใช้งานอยู่
) else (
    echo ⚠️  Port %WORDPRESS_PORT% (WordPress) - ว่าง
)

netstat -an | findstr ":%PHPMYADMIN_PORT% " >nul 2>&1
if not errorlevel 1 (
    echo ✅ Port %PHPMYADMIN_PORT% (phpMyAdmin) - ใช้งานอยู่
) else (
    echo ⚠️  Port %PHPMYADMIN_PORT% (phpMyAdmin) - ว่าง
)

netstat -an | findstr ":8888 " >nul 2>&1
if not errorlevel 1 (
    echo ✅ Port 8888 (Admin Dashboard) - ใช้งานอยู่
) else (
    echo ⚠️  Port 8888 (Admin Dashboard) - ว่าง
)

netstat -an | findstr ":%MAILHOG_WEB_PORT% " >nul 2>&1
if not errorlevel 1 (
    echo ✅ Port %MAILHOG_WEB_PORT% (MailHog) - ใช้งานอยู่
) else (
    echo ⚠️  Port %MAILHOG_WEB_PORT% (MailHog) - ว่าง
)

netstat -an | findstr ":%REDIS_PORT% " >nul 2>&1
if not errorlevel 1 (
    echo ✅ Port %REDIS_PORT% (Redis) - ใช้งานอยู่
) else (
    echo ⚠️  Port %REDIS_PORT% (Redis) - ว่าง
)

REM Check WordPress installation
echo.
echo 6. ตรวจสอบการติดตั้ง WordPress
docker exec %APP_NAME%_wordpress wp core is-installed --allow-root >nul 2>&1
if not errorlevel 1 (
    echo ✅ WordPress ติดตั้งแล้ว
    
    REM Get WordPress version
    for /f %%v in ('docker exec %APP_NAME%_wordpress wp core version --allow-root 2^>nul') do (
        echo    Version: %%v
    )
    
    REM Check language
    for /f %%l in ('docker exec %APP_NAME%_wordpress wp option get WPLANG --allow-root 2^>nul') do (
        if "%%l"=="th" (
            echo ✅ ภาษาไทยติดตั้งแล้ว
        ) else (
            echo ⚠️  ภาษาไทยยังไม่ได้ติดตั้ง
            echo    รัน: scripts\setup-thai.bat
        )
    )
    
    REM Check WooCommerce
    docker exec %APP_NAME%_wordpress wp plugin is-active woocommerce --allow-root >nul 2>&1
    if not errorlevel 1 (
        echo ✅ WooCommerce เปิดใช้งานแล้ว
        for /f %%w in ('docker exec %APP_NAME%_wordpress wp plugin get woocommerce --field=version --allow-root 2^>nul') do (
            echo    Version: %%w
        )
    ) else (
        echo ❌ WooCommerce ยังไม่เปิดใช้งาน
    )
) else (
    echo ❌ WordPress ยังไม่ได้ติดตั้ง
    echo    รัน: scripts\quick-start.bat
)

REM Check backups
echo.
echo 7. ตรวจสอบการสำรองข้อมูล
set BACKUP_COUNT=0
for %%f in (backups\*.info) do set /a BACKUP_COUNT+=1
if %BACKUP_COUNT% gtr 0 (
    echo ✅ พบข้อมูลสำรอง: %BACKUP_COUNT% ไฟล์
    for /f %%f in ('dir /b /o-d backups\*.info 2^>nul') do (
        echo    ล่าสุด: %%f
        goto :backup_found
    )
) else (
    echo ⚠️  ยังไม่มีข้อมูลสำรอง
    echo    รัน: scripts\backup.bat
)
:backup_found

REM Summary
echo.
echo 📊 สรุปผลการตรวจสอบ
echo ====================

REM Count issues
set ISSUES=0
if not exist .env set /a ISSUES+=1
docker-compose ps | findstr "running" >nul 2>&1
if errorlevel 1 set /a ISSUES+=1

if %ISSUES% equ 0 (
    echo ✅ ระบบพร้อมใช้งาน!
    echo.
    echo 🔗 เข้าใช้งาน:
    if not "%APP_URL%"=="" (
        echo    - เว็บไซต์: %APP_URL%
        echo    - แอดมิน: %APP_URL%/wp-admin
    ) else (
        echo    - เว็บไซต์: http://localhost:%WORDPRESS_PORT%
        echo    - แอดมิน: http://localhost:%WORDPRESS_PORT%/wp-admin
    )
    echo    - Admin Dashboard: http://localhost:8888
    echo    - phpMyAdmin: http://localhost:%PHPMYADMIN_PORT%
) else (
    echo ⚠️  พบปัญหา %ISSUES% รายการ
    echo.
    echo แนะนำ:
    echo 1. รัน: scripts\quick-start.bat
    echo 2. รัน: scripts\setup-thai.bat (สำหรับภาษาไทย)
)

echo.
echo 💡 คำสั่งที่มีประโยชน์:
echo    scripts\admin-panel.bat - เปิดแผงควบคุม
echo    scripts\backup.bat - สำรองข้อมูล
echo    scripts\migrate.bat - ย้ายโฮสต์
echo    docker-compose logs -f - ดู logs

pause
