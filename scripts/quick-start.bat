@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🚀 WordPress/WooCommerce Quick Start
echo ====================================
echo.

REM Check if .env exists
if not exist .env (
    echo 📝 Creating environment configuration...
    if exist .env.example (
        copy .env.example .env >nul
    ) else (
        echo APP_NAME=pet-food-store > .env
        echo WORDPRESS_PORT=8000 >> .env
        echo PHPMYADMIN_PORT=8080 >> .env
        echo MAILHOG_WEB_PORT=8025 >> .env
        echo DB_ROOT_PASSWORD=rootpassword >> .env
        echo DB_NAME=wordpress >> .env
        echo DB_USER=wordpress >> .env
        echo DB_PASSWORD=wordpress >> .env
    )
    echo.
    echo ⚠️  IMPORTANT: Please edit the .env file with your settings:
    echo    - Database passwords
    echo    - Site URL
    echo    - Email configuration
    echo.
    echo Opening .env in editor...
    notepad .env
)

REM Create necessary directories
echo 📁 Creating required directories...
if not exist backups\db mkdir backups\db
if not exist backups\files mkdir backups\files
if not exist wp-content\plugins mkdir wp-content\plugins
if not exist wp-content\themes mkdir wp-content\themes
if not exist wp-content\uploads mkdir wp-content\uploads

REM Check Docker installation
echo 🐳 Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed!
    echo Please install Docker Desktop first: https://docs.docker.com/desktop/install/windows/
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not installed!
    echo Please install Docker Desktop first: https://docs.docker.com/desktop/install/windows/
    pause
    exit /b 1
)

echo ✅ Docker is installed

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="WORDPRESS_PORT" set WORDPRESS_PORT=%%B
        if "%%A"=="PHPMYADMIN_PORT" set PHPMYADMIN_PORT=%%B
        if "%%A"=="MAILHOG_WEB_PORT" set MAILHOG_WEB_PORT=%%B
    )
)

REM Set defaults if not found in .env
if "%APP_NAME%"=="" set APP_NAME=pet-food-store
if "%WORDPRESS_PORT%"=="" set WORDPRESS_PORT=8000
if "%PHPMYADMIN_PORT%"=="" set PHPMYADMIN_PORT=8080
if "%MAILHOG_WEB_PORT%"=="" set MAILHOG_WEB_PORT=8025

REM Start containers
echo.
echo 🚀 Starting containers...
docker-compose up -d

REM Wait for services
echo ⏳ Waiting for services to start (30 seconds)...
timeout /t 30 /nobreak >nul

REM Check container status
echo.
echo 📊 Container Status:
docker-compose ps

REM Run setup if WordPress is fresh
echo 📦 Checking WordPress installation...
docker exec %APP_NAME%_wordpress wp core is-installed --allow-root >nul 2>&1
if errorlevel 1 (
    echo 📦 Running initial WordPress setup...
    call scripts\setup-woocommerce.bat
) else (
    echo ✅ WordPress is already installed
)

echo.
echo ✨ Quick start complete!
echo.
echo 🌐 Access your site at: http://localhost:%WORDPRESS_PORT%
echo 📊 phpMyAdmin: http://localhost:%PHPMYADMIN_PORT%
echo 📧 MailHog: http://localhost:%MAILHOG_WEB_PORT%
echo.
echo 📚 Next steps:
echo    1. Visit your site and complete WordPress setup
echo    2. Configure WooCommerce settings
echo    3. Import your products
echo    4. Set up payment methods
echo.
echo 💡 Useful commands:
echo    scripts\backup.bat     - Create a backup
echo    scripts\migrate.bat    - Migration helper
echo    docker-compose logs -f  - View logs
echo    docker-compose down     - Stop all containers

pause
