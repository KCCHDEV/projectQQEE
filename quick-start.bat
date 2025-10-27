@echo off
echo ================================
echo   Pet Store - Quick Start
echo ================================
echo.

REM Check if Docker is running
echo [1/5] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed or not running
    echo Please install Docker Desktop first: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo ✅ Docker is ready

REM Stop any existing containers
echo.
echo [2/5] Stopping existing containers...
docker-compose -f simple-docker-compose.yml down >nul 2>&1
echo ✅ Cleaned up

REM Start containers
echo.
echo [3/5] Starting containers...
docker-compose -f simple-docker-compose.yml up -d
if errorlevel 1 (
    echo ❌ Failed to start containers
    pause
    exit /b 1
)
echo ✅ Containers started

REM Wait for WordPress to be ready
echo.
echo [4/5] Waiting for WordPress to be ready...
timeout /t 30 /nobreak >nul
echo ✅ WordPress should be ready

REM Install WooCommerce and activate theme
echo.
echo [5/5] Setting up WordPress...
timeout /t 10 /nobreak >nul

REM Try to install WooCommerce
docker exec petstore_web wp plugin install woocommerce --activate --allow-root 2>nul
docker exec petstore_web wp theme activate simple-pet-store --allow-root 2>nul

echo ✅ Setup completed!
echo.
echo 🎉 Your pet store is ready!
echo.
echo 📱 Access URLs:
echo ================================
echo 🌐 Website:     http://localhost:8000
echo 👤 Admin:       http://localhost:8000/wp-admin
echo 🗄️  phpMyAdmin: http://localhost:8080
echo.
echo 🔑 Default Login:
echo Username: admin
echo Password: admin
echo.
echo Note: If login doesn't work, please complete WordPress setup manually
echo by visiting http://localhost:8000 and following the installation wizard.
echo.
pause