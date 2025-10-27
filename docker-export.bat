@echo off
REM Pet Food E-commerce Platform - Docker Export Script for Windows
REM This script builds and exports the Docker image for deployment on other machines

setlocal enabledelayedexpansion

REM Configuration
set IMAGE_NAME=pet-food-store
set IMAGE_TAG=latest
set EXPORT_DIR=docker-export
set BACKUP_DIR=backups
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

echo Pet Food E-commerce Platform - Docker Export (Windows)
echo =====================================================
echo.

REM Check if Docker is running
echo [INFO] Checking Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo [SUCCESS] Docker is running

REM Create export directory
echo [INFO] Creating export directory...
if exist "%EXPORT_DIR%" (
    echo [WARNING] Export directory exists. Creating backup...
    if exist "%EXPORT_DIR%_backup_%TIMESTAMP%" rmdir /s /q "%EXPORT_DIR%_backup_%TIMESTAMP%"
    move "%EXPORT_DIR%" "%EXPORT_DIR%_backup_%TIMESTAMP%" >nul
)

mkdir "%EXPORT_DIR%" 2>nul
mkdir "%BACKUP_DIR%" 2>nul
echo [SUCCESS] Created export directory: %EXPORT_DIR%

REM Build the Docker image
echo [INFO] Building Docker image...
docker build -t "%IMAGE_NAME%:%IMAGE_TAG%" .
if errorlevel 1 (
    echo [ERROR] Failed to build Docker image
    pause
    exit /b 1
)
echo [SUCCESS] Docker image built successfully: %IMAGE_NAME%:%IMAGE_TAG%

REM Export the Docker image
echo [INFO] Exporting Docker image...
set EXPORT_FILE=%EXPORT_DIR%\%IMAGE_NAME%_%IMAGE_TAG%_%TIMESTAMP%.tar

docker save -o "%EXPORT_FILE%" "%IMAGE_NAME%:%IMAGE_TAG%"
if errorlevel 1 (
    echo [ERROR] Failed to export Docker image
    pause
    exit /b 1
)
echo [SUCCESS] Docker image exported to: %EXPORT_FILE%

REM Compress the image using PowerShell
echo [INFO] Compressing exported image...
powershell -Command "Compress-Archive -Path '%EXPORT_FILE%' -DestinationPath '%EXPORT_FILE%.zip' -Force"
if exist "%EXPORT_FILE%.zip" (
    del "%EXPORT_FILE%"
    echo [SUCCESS] Image compressed: %EXPORT_FILE%.zip
    for %%A in ("%EXPORT_FILE%.zip") do echo Exported file size: %%~zA bytes
) else (
    echo [WARNING] Failed to compress image, but export was successful
)

REM Export database if containers are running
echo [INFO] Checking for running database container...
docker ps --format "table {{.Names}}" | findstr "pet-food-store_db" >nul
if not errorlevel 1 (
    echo [INFO] Exporting database...
    set DB_EXPORT_FILE=%BACKUP_DIR%\database_%TIMESTAMP%.sql
    
    docker exec pet-food-store_db mysqldump -u wordpress -ppetshop123 wordpress > "!DB_EXPORT_FILE!"
    if not errorlevel 1 (
        echo [SUCCESS] Database exported to: !DB_EXPORT_FILE!
        copy "!DB_EXPORT_FILE!" "%EXPORT_DIR%\" >nul
        echo [SUCCESS] Database backup copied to export directory
    ) else (
        echo [WARNING] Failed to export database. The image will work but without existing data.
    )
) else (
    echo [WARNING] Database container not running. Skipping database export.
    echo [INFO] To export database later, run: scripts\backup.bat
)

REM Copy configuration files
echo [INFO] Copying configuration files...
copy docker-compose.yml "%EXPORT_DIR%\" >nul
copy docker-import.bat "%EXPORT_DIR%\" >nul
copy docker-import.ps1 "%EXPORT_DIR%\" >nul

REM Create README for the export
(
echo Pet Food E-commerce Platform - Docker Export Package
echo Generated on: %date% %time%
echo.
echo Contents:
echo - %IMAGE_NAME%_%IMAGE_TAG%_%TIMESTAMP%.tar.zip: Docker image
echo - docker-compose.yml: Docker Compose configuration  
echo - docker-import.bat: Import script for Windows
echo - docker-import.ps1: PowerShell import script
echo - database_%TIMESTAMP%.sql: Database backup ^(if available^)
echo.
echo To import on another Windows machine:
echo 1. Install Docker Desktop
echo 2. Run: docker-import.bat
echo 3. Access the site at http://localhost:8000
echo.
echo For more information, see the main project documentation.
) > "%EXPORT_DIR%\README.txt"

echo [SUCCESS] Configuration files and documentation copied

REM Display summary
echo.
echo [SUCCESS] Export completed successfully!
echo.
echo Export package location: %EXPORT_DIR%
echo Contents:
dir /b "%EXPORT_DIR%"
echo.
echo To deploy on another machine:
echo 1. Copy the entire '%EXPORT_DIR%' folder to the target machine
echo 2. Run: cd %EXPORT_DIR% ^&^& docker-import.bat
echo.
echo The exported package includes:
echo - Complete Docker image with WordPress, WooCommerce, and custom theme
echo - Database backup ^(if available^)
echo - Configuration files
echo - Import scripts for easy deployment
echo.
pause