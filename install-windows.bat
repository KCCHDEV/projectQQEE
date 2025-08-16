@echo off
chcp 65001
cls

echo 🐾 Pet Food Shop - Windows Installer
echo =====================================
echo.

REM Check if Docker Desktop is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Desktop not found!
    echo.
    echo 📥 Please install Docker Desktop first:
    echo    1. Download from: https://www.docker.com/products/docker-desktop
    echo    2. Install and restart your computer
    echo    3. Run this script again
    echo.
    pause
    exit /b 1
)

echo ✅ Docker Desktop found
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo 🐳 Starting Docker Desktop...
    echo Please wait while Docker Desktop starts...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    echo Waiting for Docker to start...
    :wait_docker
    timeout /t 5 /nobreak >nul
    docker info >nul 2>&1
    if %errorlevel% neq 0 goto wait_docker
)

echo ✅ Docker is running
echo.

REM Create directories
echo 📁 Creating directories...
if not exist backups mkdir backups
if not exist wp-content mkdir wp-content
if not exist wp-content\uploads mkdir wp-content\uploads
if not exist wp-content\themes mkdir wp-content\themes
if not exist wp-content\plugins mkdir wp-content\plugins

REM Create environment file
echo ⚙️ Setting up configuration...
(
echo APP_NAME=pet-food-store
echo APP_URL=http://localhost:8000
echo WORDPRESS_PORT=8000
echo PHPMYADMIN_PORT=8080
echo MAILHOG_WEB_PORT=8025
echo DB_NAME=wordpress
echo DB_USER=wordpress
echo DB_PASSWORD=petshop123
echo DB_ROOT_PASSWORD=petshop456
echo WORDPRESS_DEBUG=false
echo WP_MEMORY_LIMIT=256M
echo DB_HOST=db
echo REDIS_HOST=redis
echo SMTP_HOST=mailhog
echo SMTP_PORT=1025
echo WC_CURRENCY=THB
) > .env

REM Create Docker Compose file
echo 🐳 Creating Docker setup...
(
echo version: '3.8'
echo services:
echo   db:
echo     image: mysql:8.0
echo     container_name: pet-food-store_db
echo     restart: unless-stopped
echo     environment:
echo       MYSQL_ROOT_PASSWORD: petshop456
echo       MYSQL_DATABASE: wordpress
echo       MYSQL_USER: wordpress
echo       MYSQL_PASSWORD: petshop123
echo     volumes:
echo       - db_data:/var/lib/mysql
echo     networks:
echo       - wordpress_network
echo.
echo   wordpress:
echo     depends_on:
echo       - db
echo     image: wordpress:latest
echo     container_name: pet-food-store_wordpress
echo     restart: unless-stopped
echo     ports:
echo       - "8000:80"
echo     environment:
echo       WORDPRESS_DB_HOST: db:3306
echo       WORDPRESS_DB_USER: wordpress
echo       WORDPRESS_DB_PASSWORD: petshop123
echo       WORDPRESS_DB_NAME: wordpress
echo       WORDPRESS_CONFIG_EXTRA: ^|
echo         define('WP_HOME', 'http://localhost:8000'^);
echo         define('WP_SITEURL', 'http://localhost:8000'^);
echo     volumes:
echo       - wordpress_data:/var/www/html
echo       - ./wp-content:/var/www/html/wp-content
echo     networks:
echo       - wordpress_network
echo.
echo   phpmyadmin:
echo     depends_on:
echo       - db
echo     image: phpmyadmin/phpmyadmin:latest
echo     container_name: pet-food-store_phpmyadmin
echo     restart: unless-stopped
echo     ports:
echo       - "8080:80"
echo     environment:
echo       PMA_HOST: db
echo       PMA_USER: root
echo       PMA_PASSWORD: petshop456
echo     networks:
echo       - wordpress_network
echo.
echo   mailhog:
echo     image: mailhog/mailhog:latest
echo     container_name: pet-food-store_mailhog
echo     restart: unless-stopped
echo     ports:
echo       - "8025:8025"
echo     networks:
echo       - wordpress_network
echo.
echo volumes:
echo   db_data:
echo   wordpress_data:
echo.
echo networks:
echo   wordpress_network:
echo     driver: bridge
) > docker-compose.yml

REM Create shop setup script
echo 🛒 Creating shop setup...
(
echo @echo off
echo echo 🛒 Setting up WooCommerce shop...
echo.
echo timeout /t 30 /nobreak ^>nul
echo.
echo docker exec pet-food-store_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
echo docker exec pet-food-store_wordpress chmod +x wp-cli.phar
echo docker exec pet-food-store_wordpress mv wp-cli.phar /usr/local/bin/wp
echo.
echo docker exec pet-food-store_wordpress wp plugin install woocommerce --activate --allow-root
echo docker exec pet-food-store_wordpress wp theme install storefront --activate --allow-root
echo.
echo docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Dog Food Premium" --post_content="High quality dog food for adult dogs" --post_status=publish --allow-root
echo docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Cat Food Deluxe" --post_content="Premium cat food with salmon" --post_status=publish --allow-root
echo docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Pet Toy Ball" --post_content="Interactive rubber ball with squeaker" --post_status=publish --allow-root
echo docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Pet Bed Comfort" --post_content="Soft pet bed with memory foam" --post_status=publish --allow-root
echo docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Pet Shampoo Gentle" --post_content="Gentle hypoallergenic shampoo" --post_status=publish --allow-root
echo.
echo echo ✅ Shop setup complete!
) > setup-shop.bat

REM Start containers
echo 🚀 Starting containers...
docker-compose up -d

echo ⏳ Waiting for containers to start...
timeout /t 20 /nobreak >nul

REM Setup WooCommerce
echo 🛒 Setting up shop...
call setup-shop.bat

echo.
echo ✅ Installation Complete!
echo =========================
echo.
echo 🌐 Your Pet Food Shop: http://localhost:8000
echo 🗄️  Database Admin: http://localhost:8080
echo 📧 Email Testing: http://localhost:8025
echo.
echo 🔑 Default Login:
echo    Username: admin
echo    Password: (set during first visit)
echo.
echo 💡 Management Commands:
echo    Start:   docker-compose up -d
echo    Stop:    docker-compose down
echo    Restart: docker-compose restart
echo.
echo 🌐 Opening your shop in browser...
start http://localhost:8000

pause