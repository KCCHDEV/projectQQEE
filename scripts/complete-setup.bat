@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════╗
echo ║       🚀 Complete Setup - ระบบติดตั้งครบวงจร ║
echo ║         Pet Food Store Complete Setup                 ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,* delims==" %%a in (.env) do set "%%a=%%b"
)

REM Set default values if not in .env
if not defined APP_NAME set APP_NAME=pet-food-store
if not defined WORDPRESS_PORT set WORDPRESS_PORT=8000
if not defined PHPMYADMIN_PORT set PHPMYADMIN_PORT=8080
if not defined MAILHOG_WEB_PORT set MAILHOG_WEB_PORT=8025
if not defined DB_ROOT_PASSWORD set DB_ROOT_PASSWORD=rootpassword
if not defined DB_NAME set DB_NAME=wordpress
if not defined DB_USER set DB_USER=wordpress
if not defined DB_PASSWORD set DB_PASSWORD=wordpress

echo 🎯 เริ่มต้นการติดตั้งระบบร้านอาหารสัตว์เลี้ยงแบบครบวงจร...
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
    echo ✅ คัดลอกรูปภาพตัวอย่าง
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

REM Step 7: Check if theme exists, if not create it
echo.
echo 🎨 ขั้นตอนที่ 7: ตรวจสอบธีม WordPress
echo.

REM Check if theme already exists and is working
for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr wordpress') do set CONTAINER_NAME=%%i
if defined CONTAINER_NAME (
    docker exec %CONTAINER_NAME% wp theme status pet-paws --allow-root >nul 2>&1
    if errorlevel 1 (
        echo ⚠️  ธีม Pet Paws ไม่ทำงาน กำลังแก้ไข...
        call scripts\fix-theme-error-simple.bat
    ) else (
        echo ✅ ธีม Pet Paws ทำงานปกติ
    )
) else (
    echo ⚠️  ไม่พบ WordPress container
)

echo ✅ ตรวจสอบธีมเรียบร้อย

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
REM Check if WordPress container is responding on port 8000
curl -s http://localhost:8000 >nul 2>&1
if errorlevel 1 (
    echo -n .
    ping -n 6 127.0.0.1 >nul
    goto :wait_loop
)

echo.
echo ✅ WordPress พร้อมใช้งาน

REM Step 10: Install WP-CLI
echo.
echo 🔧 ขั้นตอนที่ 10: ติดตั้ง WP-CLI
echo.

echo กำลังติดตั้ง WP-CLI...

REM Get actual container name
for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr wordpress') do set CONTAINER_NAME=%%i

if not defined CONTAINER_NAME (
    echo ❌ ไม่พบ WordPress container!
    echo ตรวจสอบสถานะ containers:
    docker-compose ps
    echo.
    echo รายชื่อ containers ที่รันอยู่:
    docker ps --format "table {{.Names}}\t{{.Status}}"
    pause
    exit /b 1
)

echo ใช้ container: %CONTAINER_NAME%

docker exec %CONTAINER_NAME% curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec %CONTAINER_NAME% chmod +x wp-cli.phar
docker exec %CONTAINER_NAME% mv wp-cli.phar /usr/local/bin/wp
echo ✅ ติดตั้ง WP-CLI เรียบร้อย

REM Step 11: Install and configure WordPress
echo.
echo 🔧 ขั้นตอนที่ 11: ติดตั้งและตั้งค่า WordPress
echo.

REM Check if WordPress is already installed (now WP-CLI is available)
docker exec %CONTAINER_NAME% wp core is-installed --allow-root >nul 2>&1
if errorlevel 1 (
    echo กำลังติดตั้ง WordPress...
    docker exec %CONTAINER_NAME% wp core install --url=http://localhost:8000 --title="Pet Food Store" --admin_user=admin --admin_password=admin123 --admin_email=admin@example.com --allow-root
    echo ✅ ติดตั้ง WordPress เรียบร้อย
) else (
    echo ✅ WordPress ติดตั้งแล้ว
)

REM Step 12: Install WooCommerce
echo.
echo 🛒 ขั้นตอนที่ 12: ติดตั้ง WooCommerce
echo.

docker exec %CONTAINER_NAME% wp plugin install woocommerce --activate --allow-root
echo ✅ ติดตั้ง WooCommerce เรียบร้อย

REM Step 13: Configure WooCommerce
echo.
echo ⚙️ ขั้นตอนที่ 13: ตั้งค่า WooCommerce
echo.

REM Set currency to Thai Baht
docker exec %CONTAINER_NAME% wp option update woocommerce_currency THB --allow-root

REM Set default country to Thailand
docker exec %CONTAINER_NAME% wp option update woocommerce_default_country TH --allow-root

REM Set timezone
docker exec %CONTAINER_NAME% wp option update timezone_string Asia/Bangkok --allow-root

REM Set date format
docker exec %CONTAINER_NAME% wp option update date_format d/m/Y --allow-root

echo ✅ ตั้งค่า WooCommerce เรียบร้อย

REM Step 14: Activate custom theme
echo.
echo 🎨 ขั้นตอนที่ 14: เปิดใช้งานธีม Pet Paws
echo.

docker exec %CONTAINER_NAME% wp theme activate pet-paws --allow-root
echo ✅ เปิดใช้งานธีม Pet Paws เรียบร้อย

REM Step 15: Create sample pages
echo.
echo 📄 ขั้นตอนที่ 15: สร้างหน้าตัวอย่าง
echo.

REM Create About Us page
docker exec %CONTAINER_NAME% wp post create --post_type=page --post_title="เกี่ยวกับเรา" --post_content="ร้านอาหารสัตว์เลี้ยงคุณภาพสูง ดูแลสัตว์เลี้ยงของคุณด้วยความรัก" --post_status=publish --allow-root

REM Create Contact page
docker exec %CONTAINER_NAME% wp post create --post_type=page --post_title="ติดต่อเรา" --post_content="โทร: 02-123-4567 | อีเมล: info@petfoodstore.com" --post_status=publish --allow-root

echo ✅ สร้างหน้าตัวอย่างเรียบร้อย

REM Step 16: Import sample products
echo.
echo 🐕 ขั้นตอนที่ 16: เพิ่มสินค้าตัวอย่าง
echo.

REM Create product categories
docker exec %CONTAINER_NAME% wp term create product_cat "อาหารสุนัข" --description="อาหารคุณภาพสูงสำหรับสุนัข" --allow-root
docker exec %CONTAINER_NAME% wp term create product_cat "อาหารแมว" --description="อาหารคุณภาพสูงสำหรับแมว" --allow-root
docker exec %CONTAINER_NAME% wp term create product_cat "ของเล่นสัตว์เลี้ยง" --description="ของเล่นสนุกสำหรับสัตว์เลี้ยง" --allow-root

REM Create sample products
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="อาหารสุนัขพรีเมียม" --post_content="อาหารคุณภาพสูงสำหรับสุนัขทุกวัย" --post_status=publish --allow-root
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="อาหารแมวพรีเมียม" --post_content="อาหารคุณภาพสูงสำหรับแมวทุกวัย" --post_status=publish --allow-root
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="ลูกบอลของเล่นสุนัข" --post_content="ลูกบอลยางคุณภาพสูงสำหรับสุนัข" --post_status=publish --allow-root

echo ✅ เพิ่มสินค้าตัวอย่างเรียบร้อย

REM Step 17: Set up navigation menu
echo.
echo 🧭 ขั้นตอนที่ 17: ตั้งค่าเมนูนำทาง
echo.

REM Create primary menu
docker exec %CONTAINER_NAME% wp menu create "Primary Menu" --allow-root

REM Add pages to menu
docker exec %CONTAINER_NAME% wp menu item add-post "Primary Menu" 1 --allow-root
docker exec %CONTAINER_NAME% wp menu item add-post "Primary Menu" 2 --allow-root

REM Assign menu to primary location
docker exec %CONTAINER_NAME% wp menu location assign "Primary Menu" primary --allow-root

echo ✅ ตั้งค่าเมนูนำทางเรียบร้อย

REM Step 18: Final configuration
echo.
echo 🔧 ขั้นตอนที่ 18: การตั้งค่าสุดท้าย
echo.

REM Set homepage to show posts
docker exec %CONTAINER_NAME% wp option update show_on_front posts --allow-root

REM Clear cache
docker exec %CONTAINER_NAME% wp cache flush --allow-root

echo ✅ การตั้งค่าสุดท้ายเรียบร้อย

REM Step 19: Display final information
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
