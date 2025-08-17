@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════╗
echo ║       🚀 Complete Setup - Pet Food Store              ║
echo ║         Automated Installation System                 ║
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

echo 🎯 Starting Pet Food Store Complete Installation...
echo.

REM Step 1: Check system requirements
echo 📋 Step 1: Checking System Requirements
echo.

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed!
    echo.
    echo 📥 Download Docker Desktop:
    echo    https://docs.docker.com/desktop/install/windows/
    echo.
    echo ⚠️  Please install Docker Desktop and restart your computer
    pause
    exit /b 1
)

echo ✅ Docker is ready

REM Check Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not installed!
    pause
    exit /b 1
)

echo ✅ Docker Compose is ready
echo.

REM Step 2: Create project structure
echo 📁 Step 2: Creating Project Structure
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

echo ✅ Main directories created

REM Step 3: Copy template files
echo.
echo 📦 Step 3: Copying Template Files
echo.

REM Copy pet-food-shop-template files
if exist "pet-food-shop-template\docker-compose.yml" (
    copy "pet-food-shop-template\docker-compose.yml" "docker-compose.yml" >nul
    echo ✅ Copied docker-compose.yml
)

if exist "pet-food-shop-template\install.sh" (
    copy "pet-food-shop-template\install.sh" "install-template.sh" >nul
    echo ✅ Copied install.sh
)

if exist "pet-food-shop-template\README.md" (
    copy "pet-food-shop-template\README.md" "README-template.md" >nul
    echo ✅ Copied README.md
)

REM Step 4: Copy example UI images
echo.
echo 🖼️ Step 4: Copying Example Images
echo.

if exist "exampleUi\*.jpg" (
    if not exist "wp-content\uploads\2024\12\example-ui" mkdir "wp-content\uploads\2024\12\example-ui"
    copy "exampleUi\*.jpg" "wp-content\uploads\2024\12\example-ui\" >nul
    echo ✅ Copied example images
)

REM Step 5: Copy rimping UI template
echo.
echo 🎨 Step 5: Copying UI Template
echo.

if exist "rimping-animal-foods" (
    if not exist "dev-workspace\ui-template" mkdir "dev-workspace\ui-template"
    xcopy "rimping-animal-foods\*" "dev-workspace\ui-template\" /E /Y /Q >nul
    echo ✅ Copied UI Template to dev-workspace
)

REM Step 6: Create environment file
echo.
echo ⚙️ Step 6: Creating Environment File
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
    echo ✅ Created .env file
) else (
    echo ✅ .env file already exists
)

REM Step 7: Check if theme exists, if not create it
echo.
echo 🎨 Step 7: Checking WordPress Theme
echo.

REM Check if theme already exists and is working
for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr wordpress') do set CONTAINER_NAME=%%i
if defined CONTAINER_NAME (
    docker exec %CONTAINER_NAME% wp theme status pet-paws --allow-root >nul 2>&1
    if errorlevel 1 (
        echo ⚠️  Pet Paws theme not working, fixing...
        call scripts\fix-theme-error-simple.bat
    ) else (
        echo ✅ Pet Paws theme is working
    )
) else (
    echo ⚠️  WordPress container not found
)

echo ✅ Theme check completed

REM Step 8: Start Docker containers
echo.
echo 🐳 Step 8: Starting Docker Containers
echo.

echo Starting containers...
docker-compose up -d

if errorlevel 1 (
    echo ❌ Failed to start containers
    pause
    exit /b 1
)

echo ✅ Containers started successfully

REM Step 9: Wait for WordPress to be ready
echo.
echo ⏳ Step 9: Waiting for WordPress to be Ready
echo.

echo Waiting for WordPress to be ready...
:wait_loop
REM Check if WordPress container is responding on port 8000
curl -s http://localhost:8000 >nul 2>&1
if errorlevel 1 (
    echo -n .
    ping -n 6 127.0.0.1 >nul
    goto :wait_loop
)

echo.
echo ✅ WordPress is ready

REM Step 10: Install WP-CLI
echo.
echo 🔧 Step 10: Installing WP-CLI
echo.

echo Installing WP-CLI...

REM Get actual container name
for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr wordpress') do set CONTAINER_NAME=%%i

if not defined CONTAINER_NAME (
    echo ❌ WordPress container not found!
    echo Checking container status:
    docker-compose ps
    echo.
    echo Running containers:
    docker ps --format "table {{.Names}}\t{{.Status}}"
    pause
    exit /b 1
)

echo Using container: %CONTAINER_NAME%

docker exec %CONTAINER_NAME% curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec %CONTAINER_NAME% chmod +x wp-cli.phar
docker exec %CONTAINER_NAME% mv wp-cli.phar /usr/local/bin/wp
echo ✅ WP-CLI installed successfully

REM Step 11: Install and configure WordPress
echo.
echo 🔧 Step 11: Installing and Configuring WordPress
echo.

REM Check if WordPress is already installed (now WP-CLI is available)
docker exec %CONTAINER_NAME% wp core is-installed --allow-root >nul 2>&1
if errorlevel 1 (
    echo Installing WordPress...
    docker exec %CONTAINER_NAME% wp core install --url=http://localhost:8000 --title="Pet Food Store" --admin_user=admin --admin_password=admin123 --admin_email=admin@example.com --allow-root
    echo ✅ WordPress installed successfully
) else (
    echo ✅ WordPress already installed
)

REM Step 12: Install WooCommerce
echo.
echo 🛒 Step 12: Installing WooCommerce
echo.

docker exec %CONTAINER_NAME% wp plugin install woocommerce --activate --allow-root
echo ✅ WooCommerce installed successfully

REM Step 13: Configure WooCommerce
echo.
echo ⚙️ Step 13: Configuring WooCommerce
echo.

REM Set currency to Thai Baht
docker exec %CONTAINER_NAME% wp option update woocommerce_currency THB --allow-root

REM Set default country to Thailand
docker exec %CONTAINER_NAME% wp option update woocommerce_default_country TH --allow-root

REM Set timezone
docker exec %CONTAINER_NAME% wp option update timezone_string Asia/Bangkok --allow-root

REM Set date format
docker exec %CONTAINER_NAME% wp option update date_format d/m/Y --allow-root

echo ✅ WooCommerce configured successfully

REM Step 14: Activate custom theme
echo.
echo 🎨 Step 14: Activating Pet Paws Theme
echo.

docker exec %CONTAINER_NAME% wp theme activate pet-paws --allow-root
echo ✅ Pet Paws theme activated successfully

REM Step 15: Create sample pages
echo.
echo 📄 Step 15: Creating Sample Pages
echo.

REM Create About Us page
docker exec %CONTAINER_NAME% wp post create --post_type=page --post_title="About Us" --post_content="Premium pet food store dedicated to providing the best care for your beloved companions" --post_status=publish --allow-root

REM Create Contact page
docker exec %CONTAINER_NAME% wp post create --post_type=page --post_title="Contact Us" --post_content="Phone: 02-123-4567 | Email: info@petfoodstore.com" --post_status=publish --allow-root

echo ✅ Sample pages created successfully

REM Step 16: Import sample products
echo.
echo 🐕 Step 16: Adding Sample Products
echo.

REM Create product categories
docker exec %CONTAINER_NAME% wp term create product_cat "Dog Food" --description="High quality food for dogs" --allow-root
docker exec %CONTAINER_NAME% wp term create product_cat "Cat Food" --description="High quality food for cats" --allow-root
docker exec %CONTAINER_NAME% wp term create product_cat "Pet Toys" --description="Fun toys for pets" --allow-root

REM Create sample products
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="Premium Dog Food" --post_content="High quality food for dogs of all ages" --post_status=publish --allow-root
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="Premium Cat Food" --post_content="High quality food for cats of all ages" --post_status=publish --allow-root
docker exec %CONTAINER_NAME% wp post create --post_type=product --post_title="Dog Ball Toy" --post_content="High quality rubber ball for dogs" --post_status=publish --allow-root

echo ✅ Sample products added successfully

REM Step 17: Set up navigation menu
echo.
echo 🧭 Step 17: Setting up Navigation Menu
echo.

REM Create primary menu
docker exec %CONTAINER_NAME% wp menu create "Primary Menu" --allow-root

REM Add pages to menu
docker exec %CONTAINER_NAME% wp menu item add-post "Primary Menu" 1 --allow-root
docker exec %CONTAINER_NAME% wp menu item add-post "Primary Menu" 2 --allow-root

REM Assign menu to primary location
docker exec %CONTAINER_NAME% wp menu location assign "Primary Menu" primary --allow-root

echo ✅ Navigation menu set up successfully

REM Step 18: Final configuration
echo.
echo 🔧 Step 18: Final Configuration
echo.

REM Set homepage to show posts
docker exec %CONTAINER_NAME% wp option update show_on_front posts --allow-root

REM Clear cache
docker exec %CONTAINER_NAME% wp cache flush --allow-root

echo ✅ Final configuration completed

REM Step 19: Display final information
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║                    🎉 Installation Complete!          ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 📋 Login Information:
echo    🌐 Website: http://localhost:8000
echo    🔧 Admin Panel: http://localhost:8000/wp-admin
echo    👤 Username: admin
echo    🔑 Password: admin123
echo.
echo 📊 Additional Information:
echo    🗄️  phpMyAdmin: http://localhost:8080
echo    📧  MailHog: http://localhost:8025
echo.
echo 🚀 Ready to use!
echo.
pause
