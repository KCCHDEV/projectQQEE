@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         🏪 Pet Food Shop - Universal Installer 🐾            ║
echo ║    รองรับทั้ง Docker และ XAMPP - ติดตั้งครบในไฟล์เดียว        ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

REM ===== MENU SELECTION =====
:main_menu
echo 🚀 เลือกวิธีการติดตั้ง:
echo.
echo   1) 🐳 Docker (แนะนำ - ติดตั้งง่าย มีทุกอย่างครบ)
echo   2) 📁 XAMPP (ใช้ XAMPP ที่มีอยู่)
echo   3) ❓ ตรวจสอบระบบ
echo   4) 🚪 ออกจากโปรแกรม
echo.
set /p choice="👉 เลือก (1-4): "

if "%choice%"=="1" goto docker_install
if "%choice%"=="2" goto xampp_install
if "%choice%"=="3" goto system_check
if "%choice%"=="4" exit /b 0
echo ❌ กรุณาเลือก 1-4
goto main_menu

REM ===== SYSTEM CHECK =====
:system_check
echo.
echo 🔍 ตรวจสอบระบบ...
echo ═══════════════════════

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker: ไม่ได้ติดตั้ง
    echo    💡 ดาวน์โหลดได้ที่: https://docs.docker.com/desktop/install/windows/
) else (
    echo ✅ Docker: พร้อมใช้งาน
    docker --version
)

REM Check XAMPP
set xampp_found=false
if exist "C:\xampp\xampp_start.exe" set xampp_found=true
if exist "D:\xampp\xampp_start.exe" set xampp_found=true
if exist "%PROGRAMFILES%\xampp\xampp_start.exe" set xampp_found=true

if "%xampp_found%"=="true" (
    echo ✅ XAMPP: พบการติดตั้ง
) else (
    echo ❌ XAMPP: ไม่พบ
    echo    💡 ดาวน์โหลดได้ที่: https://www.apachefriends.org/
)

echo.
pause
goto main_menu

REM ===== DOCKER INSTALLATION =====
:docker_install
echo.
echo 🐳 การติดตั้งด้วย Docker
echo ═════════════════════════

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker ไม่ได้ติดตั้ง!
    echo.
    echo 📥 กรุณาติดตั้ง Docker Desktop:
    echo    https://docs.docker.com/desktop/install/windows/
    echo.
    pause
    goto main_menu
)

echo ✅ Docker พร้อมใช้งาน
echo.

REM Create project structure
echo 📁 สร้างโครงสร้างโปรเจค...
if not exist "wp-content" mkdir "wp-content"
if not exist "wp-content\themes" mkdir "wp-content\themes"
if not exist "wp-content\plugins" mkdir "wp-content\plugins"
if not exist "wp-content\uploads" mkdir "wp-content\uploads"
if not exist "backups" mkdir "backups"

REM Create .env file
echo ⚙️ สร้างไฟล์การตั้งค่า...
echo APP_NAME=pet-food-store > .env
echo WORDPRESS_PORT=8000 >> .env
echo PHPMYADMIN_PORT=8080 >> .env
echo MAILHOG_WEB_PORT=8025 >> .env
echo DB_ROOT_PASSWORD=petshop456 >> .env
echo DB_NAME=wordpress >> .env
echo DB_USER=wordpress >> .env
echo DB_PASSWORD=petshop123 >> .env
echo APP_URL=http://localhost:8000 >> .env
echo WC_CURRENCY=THB >> .env

REM Create docker-compose.yml
echo 🐳 สร้างไฟล์ Docker...
echo version: '3.8' > docker-compose.yml
echo services: >> docker-compose.yml
echo   db: >> docker-compose.yml
echo     image: mysql:8.0 >> docker-compose.yml
echo     container_name: pet-food-store_db >> docker-compose.yml
echo     restart: unless-stopped >> docker-compose.yml
echo     environment: >> docker-compose.yml
echo       MYSQL_ROOT_PASSWORD: petshop456 >> docker-compose.yml
echo       MYSQL_DATABASE: wordpress >> docker-compose.yml
echo       MYSQL_USER: wordpress >> docker-compose.yml
echo       MYSQL_PASSWORD: petshop123 >> docker-compose.yml
echo     volumes: >> docker-compose.yml
echo       - db_data:/var/lib/mysql >> docker-compose.yml
echo     networks: >> docker-compose.yml
echo       - wordpress_network >> docker-compose.yml
echo. >> docker-compose.yml
echo   wordpress: >> docker-compose.yml
echo     depends_on: >> docker-compose.yml
echo       - db >> docker-compose.yml
echo     image: wordpress:latest >> docker-compose.yml
echo     container_name: pet-food-store_wordpress >> docker-compose.yml
echo     restart: unless-stopped >> docker-compose.yml
echo     ports: >> docker-compose.yml
echo       - "8000:80" >> docker-compose.yml
echo     environment: >> docker-compose.yml
echo       WORDPRESS_DB_HOST: db:3306 >> docker-compose.yml
echo       WORDPRESS_DB_USER: wordpress >> docker-compose.yml
echo       WORDPRESS_DB_PASSWORD: petshop123 >> docker-compose.yml
echo       WORDPRESS_DB_NAME: wordpress >> docker-compose.yml
echo     volumes: >> docker-compose.yml
echo       - wordpress_data:/var/www/html >> docker-compose.yml
echo       - ./wp-content:/var/www/html/wp-content >> docker-compose.yml
echo     networks: >> docker-compose.yml
echo       - wordpress_network >> docker-compose.yml
echo. >> docker-compose.yml
echo   phpmyadmin: >> docker-compose.yml
echo     depends_on: >> docker-compose.yml
echo       - db >> docker-compose.yml
echo     image: phpmyadmin/phpmyadmin:latest >> docker-compose.yml
echo     container_name: pet-food-store_phpmyadmin >> docker-compose.yml
echo     restart: unless-stopped >> docker-compose.yml
echo     ports: >> docker-compose.yml
echo       - "8080:80" >> docker-compose.yml
echo     environment: >> docker-compose.yml
echo       PMA_HOST: db >> docker-compose.yml
echo       PMA_USER: root >> docker-compose.yml
echo       PMA_PASSWORD: petshop456 >> docker-compose.yml
echo     networks: >> docker-compose.yml
echo       - wordpress_network >> docker-compose.yml
echo. >> docker-compose.yml
echo volumes: >> docker-compose.yml
echo   db_data: >> docker-compose.yml
echo   wordpress_data: >> docker-compose.yml
echo. >> docker-compose.yml
echo networks: >> docker-compose.yml
echo   wordpress_network: >> docker-compose.yml
echo     driver: bridge >> docker-compose.yml

REM Start Docker containers
echo 🚀 เริ่มต้น Docker containers...
docker-compose up -d

if errorlevel 1 (
    echo ❌ ไม่สามารถเริ่มต้น containers ได้
    pause
    goto main_menu
)

echo ✅ เริ่มต้น containers เรียบร้อย

REM Wait for WordPress
echo ⏳ รอให้ WordPress พร้อมใช้งาน (อาจใช้เวลา 1-2 นาที)...
timeout /t 30 /nobreak >nul

REM Install WP-CLI and setup
echo 🔧 ติดตั้ง WP-CLI และตั้งค่า WordPress...
docker exec pet-food-store_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >nul 2>&1
docker exec pet-food-store_wordpress chmod +x wp-cli.phar >nul 2>&1
docker exec pet-food-store_wordpress mv wp-cli.phar /usr/local/bin/wp >nul 2>&1

REM Wait a bit more and install WordPress
timeout /t 15 /nobreak >nul
docker exec pet-food-store_wordpress wp core install --url=http://localhost:8000 --title="Pet Food Store" --admin_user=admin --admin_password=admin123 --admin_email=admin@petshop.com --allow-root >nul 2>&1

REM Install WooCommerce
echo 🛒 ติดตั้ง WooCommerce...
docker exec pet-food-store_wordpress wp plugin install woocommerce --activate --allow-root >nul 2>&1

REM Configure WooCommerce for Thailand
docker exec pet-food-store_wordpress wp option update woocommerce_currency THB --allow-root >nul 2>&1
docker exec pet-food-store_wordpress wp option update woocommerce_default_country TH --allow-root >nul 2>&1

REM Create sample products
echo 🛍️ สร้างสินค้าตัวอย่าง...
docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="อาหารสุนัขพรีเมียม" --post_content="อาหารสุนัขคุณภาพสูง" --post_status=publish --allow-root >nul 2>&1
docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="อาหารแมวดีลักซ์" --post_content="อาหารแมวพรีเมียม" --post_status=publish --post_status=publish --allow-root >nul 2>&1

goto docker_success

:docker_success
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                    🎉 ติดตั้งสำเร็จ!                          ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo 🌐 เว็บไซต์: http://localhost:8000
echo 🔐 Admin: http://localhost:8000/wp-admin
echo    Username: admin
echo    Password: admin123
echo.
echo 🗄️ phpMyAdmin: http://localhost:8080
echo    Username: root
echo    Password: petshop456
echo.
echo 🛑 หยุดระบบ: docker-compose down
echo 🔄 รีสตาร์ท: docker-compose restart
echo.
pause
goto main_menu

REM ===== XAMPP INSTALLATION =====
:xampp_install
echo.
echo 📁 การติดตั้งด้วย XAMPP
echo ══════════════════════════

REM Find XAMPP installation
set xampp_path=
if exist "C:\xampp\htdocs" set xampp_path=C:\xampp
if exist "D:\xampp\htdocs" set xampp_path=D:\xampp
if exist "%PROGRAMFILES%\xampp\htdocs" set xampp_path=%PROGRAMFILES%\xampp

if "%xampp_path%"=="" (
    echo ❌ ไม่พบ XAMPP!
    echo.
    echo 📥 กรุณาติดตั้ง XAMPP จาก: https://www.apachefriends.org/
    echo.
    pause
    goto main_menu
)

echo ✅ พบ XAMPP ที่: %xampp_path%

REM Check if XAMPP is running
echo 🔍 ตรวจสอบสถานะ XAMPP...
tasklist /FI "IMAGENAME eq httpd.exe" 2>NUL | find /I /N "httpd.exe" >NUL
if errorlevel 1 (
    echo ⚠️ Apache ไม่ทำงาน - กรุณาเปิด XAMPP Control Panel
    echo.
    set /p continue="กด Enter หลังจากเปิด Apache และ MySQL แล้ว..."
)

tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe" >NUL
if errorlevel 1 (
    echo ⚠️ MySQL ไม่ทำงาน - กรุณาเปิด XAMPP Control Panel
    echo.
    set /p continue="กด Enter หลังจากเปิด Apache และ MySQL แล้ว..."
)

REM Create project directory
set project_path=%xampp_path%\htdocs\pet-food-store
echo 📁 สร้างโปรเจคที่: %project_path%

if exist "%project_path%" (
    echo ⚠️ โฟลเดอร์ %project_path% มีอยู่แล้ว
    set /p overwrite="ต้องการเขียนทับไหม? (y/n): "
    if /i not "%overwrite%"=="y" goto main_menu
    rmdir /s /q "%project_path%"
)

mkdir "%project_path%"

REM Download WordPress
echo 📥 ดาวน์โหลด WordPress...
cd /d "%project_path%"

REM Use PowerShell to download WordPress if available
powershell -Command "try { Invoke-WebRequest -Uri 'https://wordpress.org/latest.zip' -OutFile 'wordpress.zip' -UseBasicParsing } catch { exit 1 }" >nul 2>&1

if errorlevel 1 (
    echo ❌ ไม่สามารถดาวน์โหลด WordPress ได้
    echo 💡 กรุณาดาวน์โหลดด้วยตัวเองจาก: https://wordpress.org/download/
    echo    แล้วแตกไฟล์ไปยัง: %project_path%
    echo.
    pause
    goto main_menu
)

REM Extract WordPress
echo 📦 แตกไฟล์ WordPress...
powershell -Command "Expand-Archive -Path 'wordpress.zip' -DestinationPath '.' -Force" >nul 2>&1

REM Move WordPress files to root
if exist "wordpress" (
    xcopy "wordpress\*" "." /E /Y /Q >nul
    rmdir /s /q "wordpress"
    del "wordpress.zip"
)

REM Create wp-config.php
echo ⚙️ สร้างไฟล์การตั้งค่า WordPress...
echo ^<?php > wp-config.php
echo define('DB_NAME', 'pet_food_store'); >> wp-config.php
echo define('DB_USER', 'root'); >> wp-config.php
echo define('DB_PASSWORD', ''); >> wp-config.php
echo define('DB_HOST', 'localhost'); >> wp-config.php
echo define('DB_CHARSET', 'utf8mb4'); >> wp-config.php
echo define('DB_COLLATE', ''); >> wp-config.php
echo. >> wp-config.php
echo define('AUTH_KEY',         'put your unique phrase here'); >> wp-config.php
echo define('SECURE_AUTH_KEY',  'put your unique phrase here'); >> wp-config.php
echo define('LOGGED_IN_KEY',    'put your unique phrase here'); >> wp-config.php
echo define('NONCE_KEY',        'put your unique phrase here'); >> wp-config.php
echo define('AUTH_SALT',        'put your unique phrase here'); >> wp-config.php
echo define('SECURE_AUTH_SALT', 'put your unique phrase here'); >> wp-config.php
echo define('LOGGED_IN_SALT',   'put your unique phrase here'); >> wp-config.php
echo define('NONCE_SALT',       'put your unique phrase here'); >> wp-config.php
echo. >> wp-config.php
echo $table_prefix = 'wp_'; >> wp-config.php
echo. >> wp-config.php
echo define('WP_DEBUG', false); >> wp-config.php
echo. >> wp-config.php
echo if (! defined('ABSPATH')) { >> wp-config.php
echo     define('ABSPATH', __DIR__ . '/'); >> wp-config.php
echo } >> wp-config.php
echo. >> wp-config.php
echo require_once ABSPATH . 'wp-settings.php'; >> wp-config.php

REM Create database
echo 🗄️ สร้างฐานข้อมูล...
echo CREATE DATABASE IF NOT EXISTS pet_food_store CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; > create_db.sql

REM Try to create database using mysql command
"%xampp_path%\mysql\bin\mysql.exe" -u root -e "CREATE DATABASE IF NOT EXISTS pet_food_store CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1

if errorlevel 1 (
    echo ⚠️ ไม่สามารถสร้างฐานข้อมูลอัตโนมัติได้
    echo 💡 กรุณาเปิด phpMyAdmin และสร้างฐานข้อมูล 'pet_food_store' ด้วยตัวเอง
    echo    URL: http://localhost/phpmyadmin
)

del create_db.sql >nul 2>&1

REM Create basic theme
echo 🎨 สร้างธีม Pet Paws...
mkdir "wp-content\themes\pet-paws"

echo /* > "wp-content\themes\pet-paws\style.css"
echo Theme Name: Pet Paws >> "wp-content\themes\pet-paws\style.css"
echo Description: Pet Food Store Theme >> "wp-content\themes\pet-paws\style.css"
echo Version: 1.0 >> "wp-content\themes\pet-paws\style.css"
echo */ >> "wp-content\themes\pet-paws\style.css"
echo. >> "wp-content\themes\pet-paws\style.css"
echo body { font-family: Arial, sans-serif; margin: 0; padding: 20px; } >> "wp-content\themes\pet-paws\style.css"
echo .header { background: #2c3e50; color: white; padding: 20px; text-align: center; } >> "wp-content\themes\pet-paws\style.css"
echo .content { margin: 20px 0; } >> "wp-content\themes\pet-paws\style.css"
echo .footer { background: #34495e; color: white; padding: 10px; text-align: center; margin-top: 40px; } >> "wp-content\themes\pet-paws\style.css"

echo ^<?php > "wp-content\themes\pet-paws\functions.php"
echo add_action('wp_enqueue_scripts', 'pet_paws_scripts'); >> "wp-content\themes\pet-paws\functions.php"
echo function pet_paws_scripts() { >> "wp-content\themes\pet-paws\functions.php"
echo     wp_enqueue_style('pet-paws-style', get_stylesheet_uri()); >> "wp-content\themes\pet-paws\functions.php"
echo } >> "wp-content\themes\pet-paws\functions.php"

echo ^<?php get_header(); ?^> > "wp-content\themes\pet-paws\index.php"
echo ^<div class="content"^> >> "wp-content\themes\pet-paws\index.php"
echo ^<?php if (have_posts()) : while (have_posts()) : the_post(); ?^> >> "wp-content\themes\pet-paws\index.php"
echo     ^<h2^>^<?php the_title(); ?^>^</h2^> >> "wp-content\themes\pet-paws\index.php"
echo     ^<div^>^<?php the_content(); ?^>^</div^> >> "wp-content\themes\pet-paws\index.php"
echo ^<?php endwhile; endif; ?^> >> "wp-content\themes\pet-paws\index.php"
echo ^</div^> >> "wp-content\themes\pet-paws\index.php"
echo ^<?php get_footer(); ?^> >> "wp-content\themes\pet-paws\index.php"

echo ^<!DOCTYPE html^> > "wp-content\themes\pet-paws\header.php"
echo ^<html^> >> "wp-content\themes\pet-paws\header.php"
echo ^<head^> >> "wp-content\themes\pet-paws\header.php"
echo     ^<title^>^<?php bloginfo('name'); ?^>^</title^> >> "wp-content\themes\pet-paws\header.php"
echo     ^<?php wp_head(); ?^> >> "wp-content\themes\pet-paws\header.php"
echo ^</head^> >> "wp-content\themes\pet-paws\header.php"
echo ^<body^> >> "wp-content\themes\pet-paws\header.php"
echo ^<div class="header"^> >> "wp-content\themes\pet-paws\header.php"
echo     ^<h1^>🐾 ^<?php bloginfo('name'); ?^> 🐾^</h1^> >> "wp-content\themes\pet-paws\header.php"
echo ^</div^> >> "wp-content\themes\pet-paws\header.php"

echo ^<div class="footer"^> > "wp-content\themes\pet-paws\footer.php"
echo     ^<p^>^&copy; ^<?php echo date('Y'); ?^> ^<?php bloginfo('name'); ?^>^</p^> >> "wp-content\themes\pet-paws\footer.php"
echo ^</div^> >> "wp-content\themes\pet-paws\footer.php"
echo ^<?php wp_footer(); ?^> >> "wp-content\themes\pet-paws\footer.php"
echo ^</body^> >> "wp-content\themes\pet-paws\footer.php"
echo ^</html^> >> "wp-content\themes\pet-paws\footer.php"

goto xampp_success

:xampp_success
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                    🎉 ติดตั้งสำเร็จ!                          ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo 🌐 เว็บไซต์: http://localhost/pet-food-store
echo 📁 โฟลเดอร์: %project_path%
echo.
echo 🔧 ขั้นตอนต่อไป:
echo    1. เปิด: http://localhost/pet-food-store
echo    2. ทำการติดตั้ง WordPress
echo    3. ติดตั้ง WooCommerce plugin
echo    4. เปิดใช้งานธีม Pet Paws
echo.
echo 🗄️ phpMyAdmin: http://localhost/phpmyadmin
echo    ฐานข้อมูล: pet_food_store
echo.
pause
goto main_menu