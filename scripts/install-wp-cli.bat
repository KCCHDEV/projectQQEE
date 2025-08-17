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
echo 🔧 ติดตั้ง WP-CLI ใน WordPress Container
echo.

REM Check if container is running
docker ps | findstr %APP_NAME%_wordpress >nul
if errorlevel 1 (
    echo ❌ WordPress container ไม่ได้รันอยู่!
    echo กรุณารัน docker-compose up -d ก่อน
    pause
    exit /b 1
)

echo กำลังติดตั้ง WP-CLI...

REM Download WP-CLI
docker exec %APP_NAME%_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

REM Make it executable
docker exec %APP_NAME%_wordpress chmod +x wp-cli.phar

REM Move to system path
docker exec %APP_NAME%_wordpress mv wp-cli.phar /usr/local/bin/wp

REM Test installation
docker exec %APP_NAME%_wordpress wp --version

if errorlevel 1 (
    echo ❌ การติดตั้ง WP-CLI ล้มเหลว
    pause
    exit /b 1
) else (
    echo ✅ ติดตั้ง WP-CLI เรียบร้อย
    echo.
    echo 🧪 ทดสอบ WP-CLI:
    docker exec %APP_NAME%_wordpress wp --version
)

echo.
echo 🚀 WP-CLI พร้อมใช้งานแล้ว!
echo.
pause
