@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════╗
echo ║       🚀 Simple Setup - ระบบติดตั้งแบบง่าย ║
echo ║         Pet Food Store Simple Setup                   ║
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

echo 🎯 เริ่มต้นการติดตั้งระบบร้านอาหารสัตว์เลี้ยงแบบง่าย...
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

REM Step 4: Create environment file
echo.
echo ⚙️ ขั้นตอนที่ 4: สร้างไฟล์การตั้งค่า
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
    echo ✅ สร้างไฟล์ .env เรียบร้อย
) else (
    echo ✅ ไฟล์ .env มีอยู่แล้ว
)

REM Step 5: Start Docker containers
echo.
echo 🐳 ขั้นตอนที่ 5: เริ่มต้น Docker Containers
echo.

echo กำลังเริ่มต้น containers...
docker-compose up -d

if errorlevel 1 (
    echo ❌ ไม่สามารถเริ่มต้น containers ได้
    pause
    exit /b 1
)

echo ✅ เริ่มต้น containers เรียบร้อย

REM Step 6: Wait for WordPress to be ready
echo.
echo ⏳ ขั้นตอนที่ 6: รอให้ WordPress พร้อมใช้งาน
echo.

echo รอให้ WordPress พร้อมใช้งาน...
:wait_loop
REM Check if WordPress container is responding on port 8000
curl -s http://localhost:8000 >nul 2>&1
if errorlevel 1 (
    echo -n .
    ping -n 6 127.0.0.1 >nul
    goto :wait_loop
)

echo.
echo ✅ WordPress พร้อมใช้งาน

REM Step 7: Display final information
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║                    🎉 ติดตั้งเสร็จสิ้น!                ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 📋 ข้อมูลการเข้าสู่ระบบ:
echo    🌐 เว็บไซต์: http://localhost:8000
echo    🔧 Admin Panel: http://localhost:8000/wp-admin
echo.
echo 📊 ข้อมูลเพิ่มเติม:
echo    🗄️  phpMyAdmin: http://localhost:8080
echo    📧  MailHog: http://localhost:8025
echo.
echo 💡 คำแนะนำ:
echo    - เข้าไปที่ http://localhost:8000 เพื่อตั้งค่า WordPress
echo    - ใช้ http://localhost:8000/wp-admin เพื่อเข้าสู่ระบบ
echo    - ติดตั้ง WooCommerce จาก WordPress Admin
echo.
echo 🚀 เริ่มต้นใช้งานได้เลย!
echo.
pause
