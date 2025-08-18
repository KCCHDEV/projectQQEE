@echo off
REM Pet Food E-commerce Platform - Docker Import Script for Windows
REM This script imports and runs the exported Docker image on a new machine

setlocal enabledelayedexpansion

echo Pet Food E-commerce Platform - Docker Import (Windows)
echo =====================================================
echo.

REM Check system requirements
echo [INFO] Checking system requirements...

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/windows/
    pause
    exit /b 1
)

REM Check Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Docker Compose is not available. Please install Docker Desktop.
        pause
        exit /b 1
    )
)

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo [SUCCESS] All requirements met

REM Find and import Docker image
echo [INFO] Looking for Docker image file...

set IMAGE_FILE=
for %%f in (*.tar.zip *.tar) do (
    echo %%f | findstr "pet-food-store" >nul
    if not errorlevel 1 (
        set IMAGE_FILE=%%f
        goto :found_image
    )
)

:found_image
if "%IMAGE_FILE%"=="" (
    echo [ERROR] No Docker image file found. Expected file like 'pet-food-store_*.tar.zip'
    echo [INFO] Please ensure you copied the complete export package.
    pause
    exit /b 1
)

echo [INFO] Found image file: %IMAGE_FILE%

REM Import the image
echo [INFO] Importing Docker image ^(this may take a few minutes^)...

echo %IMAGE_FILE% | findstr ".zip" >nul
if not errorlevel 1 (
    REM Decompress and load
    echo [INFO] Extracting compressed image...
    powershell -Command "Expand-Archive -Path '%IMAGE_FILE%' -DestinationPath '.' -Force"
    for %%f in (*.tar) do (
        echo %%f | findstr "pet-food-store" >nul
        if not errorlevel 1 (
            docker load -i "%%f"
            if not errorlevel 1 (
                echo [SUCCESS] Docker image imported successfully
                del "%%f"
            ) else (
                echo [ERROR] Failed to import Docker image
                pause
                exit /b 1
            )
        )
    )
) else (
    REM Load directly
    docker load -i "%IMAGE_FILE%"
    if not errorlevel 1 (
        echo [SUCCESS] Docker image imported successfully
    ) else (
        echo [ERROR] Failed to import Docker image
        pause
        exit /b 1
    )
)

REM Setup environment
echo [INFO] Setting up environment...
mkdir backups 2>nul
mkdir logs 2>nul
echo [SUCCESS] Environment setup completed

REM Import database if available
echo [INFO] Checking for database backup...

set DB_FILE=
for %%f in (*.sql database_*.sql) do (
    if exist "%%f" (
        set DB_FILE=%%f
        goto :found_db
    )
)

:found_db
if not "%DB_FILE%"=="" (
    echo [INFO] Found database backup: %DB_FILE%
    echo [INFO] Database will be imported after containers start
    
    copy "%DB_FILE%" "backups\" >nul
    echo %DB_FILE% > "backups\.import_on_start"
    echo [SUCCESS] Database backup prepared for import
) else (
    echo [INFO] No database backup found. Starting with fresh installation.
)

REM Start containers
echo [INFO] Starting Docker containers...

REM Stop any existing containers with the same names
docker-compose down >nul 2>&1

REM Start the containers
docker-compose up -d
if not errorlevel 1 (
    echo [SUCCESS] Containers started successfully
) else (
    echo [ERROR] Failed to start containers
    pause
    exit /b 1
)

REM Wait for containers to be healthy
echo [INFO] Waiting for containers to be ready...
timeout /t 10 /nobreak >nul

REM Check container status
docker-compose ps | findstr "Up" >nul
if not errorlevel 1 (
    echo [SUCCESS] Containers are running
) else (
    echo [WARNING] Some containers may not be running properly
    docker-compose ps
)

REM Import database after containers are running
if exist "backups\.import_on_start" (
    set /p DB_FILE_TO_IMPORT=<"backups\.import_on_start"
    echo [INFO] Importing database backup...
    
    REM Wait for database to be ready
    timeout /t 15 /nobreak >nul
    
    docker exec -i pet-food-store_db mysql -u wordpress -ppetshop123 wordpress < "backups\!DB_FILE_TO_IMPORT!"
    if not errorlevel 1 (
        echo [SUCCESS] Database imported successfully
        del "backups\.import_on_start"
    ) else (
        echo [WARNING] Failed to import database. You can import it manually later.
    )
)

REM Display access information
echo.
echo [SUCCESS] Pet Food E-commerce Platform is now running!
echo.
echo Access URLs:
echo ================================================
echo 🌐 Website:      http://localhost:8000
echo 👤 Admin Panel:  http://localhost:8000/wp-admin
echo 🗄️  phpMyAdmin:  http://localhost:8080
echo 📧 MailHog:      http://localhost:8025
echo.
echo Default Credentials:
echo ================================================
echo WordPress Admin:
echo   Username: admin
echo   Password: admin123
echo.
echo Database:
echo   Host: localhost:3306
echo   Username: wordpress
echo   Password: petshop123
echo   Database: wordpress
echo.
echo Useful Commands:
echo ================================================
echo Stop:     docker-compose down
echo Start:    docker-compose up -d
echo Logs:     docker-compose logs -f
echo Restart:  docker-compose restart
echo.
echo 🎉 Installation completed successfully!
echo.
pause