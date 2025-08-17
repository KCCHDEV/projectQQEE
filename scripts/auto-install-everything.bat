@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════╗
echo ║       🚀 Auto Install Everything - ระบบติดตั้งอัตโนมัติ ║
echo ║         Pet Food Store Complete Setup                 ║
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
    set DB_ROOT_PASSWORD=rootpassword
    set DB_NAME=wordpress
    set DB_USER=wordpress
    set DB_PASSWORD=wordpress
)

echo 🎯 เริ่มต้นการติดตั้งระบบร้านอาหารสัตว์เลี้ยงแบบอัตโนมัติ...
echo.

REM Step 1: Check system requirements
echo 📋 ขั้นตอนที่ 1: ตรวจสอบความพร้อมของระบบ
echo.

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker ไม่ได้ติดตั้ง!
    echo.
    echo 📥 ดาวน์โหลด Docker Desktop:
    echo    https://docs.docker.com/desktop/install/windows/
    echo.
    echo ⚠️  กรุณาติดตั้ง Docker Desktop และรีสตาร์ทเครื่อง
    pause
    exit /b 1
)

echo ✅ Docker พร้อมใช้งาน

REM Check Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose ไม่ได้ติดตั้ง!
    pause
    exit /b 1
)

echo ✅ Docker Compose พร้อมใช้งาน
echo.

REM Step 2: Create project structure
echo 📁 ขั้นตอนที่ 2: สร้างโครงสร้างโปรเจค
echo.

REM Create main directories
if not exist "wp-content" mkdir "wp-content"
if not exist "wp-content\themes" mkdir "wp-content\themes"
if not exist "wp-content\plugins" mkdir "wp-content\plugins"
if not exist "wp-content\uploads" mkdir "wp-content\uploads"
if not exist "wp-content\uploads\2024" mkdir "wp-content\uploads\2024"
if not exist "wp-content\uploads\2024\12" mkdir "wp-content\uploads\2024\12"
if not exist "backups" mkdir "backups"
if not exist "dev-workspace" mkdir "dev-workspace"

echo ✅ สร้างโฟลเดอร์หลักเรียบร้อย

REM Step 3: Copy template files
echo.
echo 📦 ขั้นตอนที่ 3: คัดลอกไฟล์เทมเพลต
echo.

REM Copy pet-food-shop-template files
if exist "pet-food-shop-template\docker-compose.yml" (
    copy "pet-food-shop-template\docker-compose.yml" "docker-compose.yml" >nul
    echo ✅ คัดลอก docker-compose.yml
)

if exist "pet-food-shop-template\install.sh" (
    copy "pet-food-shop-template\install.sh" "install-template.sh" >nul
    echo ✅ คัดลอก install.sh
)

if exist "pet-food-shop-template\README.md" (
    copy "pet-food-shop-template\README.md" "README-template.md" >nul
    echo ✅ คัดลอก README.md
)

REM Step 4: Copy example UI images
echo.
echo 🖼️ ขั้นตอนที่ 4: คัดลอกรูปภาพตัวอย่าง
echo.

if exist "exampleUi\*.jpg" (
    if not exist "wp-content\uploads\2024\12\example-ui" mkdir "wp-content\uploads\2024\12\example-ui"
    copy "exampleUi\*.jpg" "wp-content\uploads\2024\12\example-ui\" >nul
    echo ✅ คัดลอกรูปภาพตัวอย่าง %count% ไฟล์
)

REM Step 5: Copy rimping UI template
echo.
echo 🎨 ขั้นตอนที่ 5: คัดลอก UI Template
echo.

if exist "rimping-animal-foods" (
    if not exist "dev-workspace\ui-template" mkdir "dev-workspace\ui-template"
    xcopy "rimping-animal-foods\*" "dev-workspace\ui-template\" /E /Y /Q >nul
    echo ✅ คัดลอก UI Template ไปยัง dev-workspace
)

REM Step 6: Create environment file
echo.
echo ⚙️ ขั้นตอนที่ 6: สร้างไฟล์การตั้งค่า
echo.

if not exist .env (
    echo APP_NAME=pet-food-store > .env
    echo WORDPRESS_PORT=8000 >> .env
    echo PHPMYADMIN_PORT=8080 >> .env
    echo MAILHOG_WEB_PORT=8025 >> .env
    echo DB_ROOT_PASSWORD=rootpassword >> .env
    echo DB_NAME=wordpress >> .env
    echo DB_USER=wordpress >> .env
    echo DB_PASSWORD=wordpress >> .env
    echo APP_URL=http://localhost:8000 >> .env
    echo WORDPRESS_DEBUG=false >> .env
    echo WP_MEMORY_LIMIT=256M >> .env
    echo DB_HOST=db >> .env
    echo REDIS_HOST=redis >> .env
    echo SMTP_HOST=mailhog >> .env
    echo SMTP_PORT=1025 >> .env
    echo WC_CURRENCY=THB >> .env
    echo ✅ สร้างไฟล์ .env เรียบร้อย
) else (
    echo ✅ ไฟล์ .env มีอยู่แล้ว
)

REM Step 7: Create custom theme from rimping template
echo.
echo 🎨 ขั้นตอนที่ 7: สร้างธีม WordPress จาก UI Template
echo.

REM Call separate script to create theme files
call scripts\create-theme-files.bat

REM Step 8: Start Docker containers
echo.
echo 🐳 ขั้นตอนที่ 8: เริ่มต้น Docker Containers
echo.

echo กำลังเริ่มต้น containers...
docker-compose up -d

if errorlevel 1 (
    echo ❌ ไม่สามารถเริ่มต้น containers ได้
    pause
    exit /b 1
)

echo ✅ เริ่มต้น containers เรียบร้อย

REM Step 9: Wait for WordPress to be ready
echo.
echo ⏳ ขั้นตอนที่ 9: รอให้ WordPress พร้อมใช้งาน
echo.

echo รอให้ WordPress พร้อมใช้งาน...
:wait_loop
docker exec %APP_NAME%_wordpress wp core is-installed --allow-root >nul 2>&1
if errorlevel 1 (
    echo -n .
    ping -n 6 127.0.0.1 >nul
    goto :wait_loop
)

echo.
echo ✅ WordPress พร้อมใช้งาน

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║              🎯 WordPress พร้อมใช้งานแล้ว!              ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 📋 ขั้นตอนต่อไป:
echo    1. รัน script: scripts\continue-installation.bat
echo    2. หรือรัน: start-windows.bat และเลือก 15) ตั้งค่าเพิ่มเติมหลังการติดตั้ง
echo.
echo 🌐 เข้าดูเว็บไซต์ได้ที่: http://localhost:8000
echo.
pause
