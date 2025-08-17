@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🔧 แก้ไขปัญหา Container Name
echo.

echo 📊 สถานะ Containers:
docker-compose ps
echo.

echo 📋 รายชื่อ Containers ที่รันอยู่:
docker ps --format "table {{.Names}}\t{{.Status}}"
echo.

echo 🔍 หา WordPress Container:
for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr wordpress') do (
    set CONTAINER_NAME=%%i
    echo พบ: %%i
)

if not defined CONTAINER_NAME (
    echo ❌ ไม่พบ WordPress container!
    echo.
    echo 💡 ลองใช้คำสั่งนี้:
    echo docker ps --format "{{.Names}}" ^| findstr wordpress
    pause
    exit /b 1
)

echo.
echo ✅ ใช้ Container: %CONTAINER_NAME%
echo.

echo 🧪 ทดสอบ WP-CLI:
docker exec %CONTAINER_NAME% wp --version
echo.

echo 🧪 ทดสอบ WordPress:
docker exec %CONTAINER_NAME% wp core version
echo.

echo ✅ Container Name ถูกต้องแล้ว!
pause
