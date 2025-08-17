@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Migration Helper Script for WordPress/WooCommerce
REM This script helps migrate the application to a new host

echo 🚀 WordPress/WooCommerce Migration Helper
echo ========================================
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="WORDPRESS_PORT" set WORDPRESS_PORT=%%B
        if "%%A"=="PHPMYADMIN_PORT" set PHPMYADMIN_PORT=%%B
        if "%%A"=="REDIS_PORT" set REDIS_PORT=%%B
        if "%%A"=="APP_URL" set APP_URL=%%B
    )
)

REM Function to display menu
:show_menu
echo What would you like to do?
echo 1) Prepare for migration (create full backup)
echo 2) Deploy to new host (restore from backup)
echo 3) Check migration requirements
echo 4) Export migration package
echo 5) Import migration package
echo 6) Exit
echo.
goto :main_loop

REM Function to check requirements
:check_requirements
echo 🔍 Checking migration requirements...
echo.

REM Check Docker
docker --version >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=3" %%i in ('docker --version') do echo ✅ Docker installed: %%i
) else (
    echo ❌ Docker not installed
)

REM Check Docker Compose
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=3" %%i in ('docker-compose --version') do echo ✅ Docker Compose installed: %%i
) else (
    echo ❌ Docker Compose not installed
)

REM Check disk space
echo 💾 Disk space:
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq (Get-Location).Drive} | Select-Object DeviceID, @{Name='Size(GB)';Expression={[math]::Round($_.Size/1GB,2)}}, @{Name='FreeSpace(GB)';Expression={[math]::Round($_.FreeSpace/1GB,2)}} | Format-Table -AutoSize"

REM Check current containers
echo.
echo 🐳 Current containers:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
goto :eof

REM Function to prepare for migration
:prepare_migration
echo 📦 Preparing for migration...
echo.

REM Run backup script
if exist "scripts\backup.bat" (
    call scripts\backup.bat
) else (
    echo ❌ Backup script not found!
    pause
    exit /b 1
)

echo.
echo ✅ Migration preparation complete!
echo.
echo Next steps:
echo 1. Copy the entire project directory to your new host
echo 2. Run 'scripts\migrate.bat' and select option 2 on the new host
goto :eof

REM Function to export migration package
:export_package
echo 📦 Creating migration package...

REM Create temporary directory
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TEMP_DIR=migration_%dt:~0,8%_%dt:~8,6%"
mkdir "%TEMP_DIR%"

REM Run backup first
call scripts\backup.bat

REM Get latest backup
for /f %%f in ('dir /b /o-d backups\full_backup_*.zip 2^>nul') do (
    set "LATEST_BACKUP=backups\%%f"
    goto :backup_found
)

echo ❌ No backup found!
rmdir /s /q "%TEMP_DIR%"
pause
exit /b 1

:backup_found
REM Copy essential files
copy "%LATEST_BACKUP%" "%TEMP_DIR%\"
copy docker-compose.yml "%TEMP_DIR%\"
if exist .env.example copy .env.example "%TEMP_DIR%\"
xcopy scripts "%TEMP_DIR%\scripts\" /E /Y /Q
if exist uploads.ini copy uploads.ini "%TEMP_DIR%\"
if exist woocommerce-config.php copy woocommerce-config.php "%TEMP_DIR%\"

REM Create deployment script
echo @echo off > "%TEMP_DIR%\deploy.bat"
echo chcp 65001 >> "%TEMP_DIR%\deploy.bat"
echo echo 🚀 Deploying WordPress/WooCommerce... >> "%TEMP_DIR%\deploy.bat"
echo. >> "%TEMP_DIR%\deploy.bat"
echo REM Create .env from example >> "%TEMP_DIR%\deploy.bat"
echo if not exist .env ^( >> "%TEMP_DIR%\deploy.bat"
echo     copy .env.example .env >> "%TEMP_DIR%\deploy.bat"
echo     echo ⚠️  Please edit .env file with your host-specific settings >> "%TEMP_DIR%\deploy.bat"
echo     echo Press Enter when ready... >> "%TEMP_DIR%\deploy.bat"
echo     pause >> "%TEMP_DIR%\deploy.bat"
echo ^) >> "%TEMP_DIR%\deploy.bat"
echo. >> "%TEMP_DIR%\deploy.bat"
echo REM Extract backup >> "%TEMP_DIR%\deploy.bat"
echo echo 📦 Extracting backup... >> "%TEMP_DIR%\deploy.bat"
echo if not exist backups mkdir backups >> "%TEMP_DIR%\deploy.bat"
echo powershell -Command "Expand-Archive -Path 'full_backup_*.zip' -DestinationPath 'backups\' -Force" >> "%TEMP_DIR%\deploy.bat"
echo. >> "%TEMP_DIR%\deploy.bat"
echo REM Start deployment >> "%TEMP_DIR%\deploy.bat"
echo docker-compose up -d >> "%TEMP_DIR%\deploy.bat"
echo. >> "%TEMP_DIR%\deploy.bat"
echo echo ✅ Deployment started! >> "%TEMP_DIR%\deploy.bat"
echo echo Run 'scripts\restore.bat ^<timestamp^>' to restore data >> "%TEMP_DIR%\deploy.bat"
echo pause >> "%TEMP_DIR%\deploy.bat"

REM Create README
echo # WordPress/WooCommerce Migration Package > "%TEMP_DIR%\README.md"
echo. >> "%TEMP_DIR%\README.md"
echo This package contains everything needed to deploy your WordPress/WooCommerce application to a new host. >> "%TEMP_DIR%\README.md"
echo. >> "%TEMP_DIR%\README.md"
echo ## Contents >> "%TEMP_DIR%\README.md"
echo - Full backup (database + files) >> "%TEMP_DIR%\README.md"
echo - Docker configuration >> "%TEMP_DIR%\README.md"
echo - Deployment scripts >> "%TEMP_DIR%\README.md"
echo - Environment configuration template >> "%TEMP_DIR%\README.md"
echo. >> "%TEMP_DIR%\README.md"
echo ## Deployment Steps >> "%TEMP_DIR%\README.md"
echo. >> "%TEMP_DIR%\README.md"
echo 1. **Extract this package** on your new host >> "%TEMP_DIR%\README.md"
echo 2. **Run the deployment script**: `deploy.bat` >> "%TEMP_DIR%\README.md"
echo 3. **Edit the .env file** with your host-specific settings >> "%TEMP_DIR%\README.md"
echo 4. **Restore the backup** using the timestamp from the backup file >> "%TEMP_DIR%\README.md"
echo. >> "%TEMP_DIR%\README.md"
echo ## Requirements >> "%TEMP_DIR%\README.md"
echo - Docker >> "%TEMP_DIR%\README.md"
echo - Docker Compose >> "%TEMP_DIR%\README.md"
echo - At least 2GB free disk space >> "%TEMP_DIR%\README.md"
echo - Ports: %WORDPRESS_PORT%, %PHPMYADMIN_PORT%, %REDIS_PORT% >> "%TEMP_DIR%\README.md"
echo. >> "%TEMP_DIR%\README.md"
echo ## Support >> "%TEMP_DIR%\README.md"
echo For issues, check the logs: >> "%TEMP_DIR%\README.md"
echo ```bash >> "%TEMP_DIR%\README.md"
echo docker-compose logs -f >> "%TEMP_DIR%\README.md"
echo ``` >> "%TEMP_DIR%\README.md"

REM Create the package
set "PACKAGE_NAME=migration_package_%dt:~0,8%_%dt:~8,6%.zip"
powershell -Command "Compress-Archive -Path '%TEMP_DIR%' -DestinationPath '%PACKAGE_NAME%' -Force"
rmdir /s /q "%TEMP_DIR%"

echo ✅ Migration package created: %PACKAGE_NAME%
echo.
for %%f in (%PACKAGE_NAME%) do echo 📋 Package size: %%~zf bytes
echo.
echo Transfer this file to your new host and extract it to deploy.
goto :eof

REM Function to deploy to new host
:deploy_new_host
echo 🚀 Deploying to new host...
echo.

REM Check if .env exists
if not exist .env (
    echo ⚠️  No .env file found. Creating from template...
    if exist .env.example (
        copy .env.example .env
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
    echo Please edit the .env file with your new host settings:
    echo - APP_URL (your new domain)
    echo - Database passwords
    echo - Port numbers (if defaults are taken)
    echo - Email settings
    echo.
    pause
)

REM Start containers
echo 🐳 Starting Docker containers...
docker-compose up -d

REM Wait for services
echo ⏳ Waiting for services to start...
timeout /t 20 /nobreak >nul

REM Check if there are backups to restore
if exist backups\*.info (
    echo.
    echo 📦 Available backups:
    for %%f in (backups\*.info) do (
        set "filename=%%~nf"
        echo !filename:backup_=!
    )
    echo.
    set /p timestamp="Enter backup timestamp to restore (or press Enter to skip): "
    
    if not "!timestamp!"=="" (
        call scripts\restore.bat "!timestamp!"
    )
) else (
    echo ℹ️  No backups found. Starting with fresh installation.
)

echo.
echo ✅ Deployment complete!
echo.
echo 🌐 Access your site at: %APP_URL%
echo 📊 phpMyAdmin: http://localhost:%PHPMYADMIN_PORT%
echo.
goto :eof

REM Main menu loop
:main_loop
set /p choice="Select an option (1-6): "
echo.

if "%choice%"=="1" (
    call :prepare_migration
) else if "%choice%"=="2" (
    call :deploy_new_host
) else if "%choice%"=="3" (
    call :check_requirements
) else if "%choice%"=="4" (
    call :export_package
) else if "%choice%"=="5" (
    echo 📦 To import a migration package:
    echo 1. Extract the migration package zip file
    echo 2. Run deploy.bat from the extracted directory
    echo.
) else if "%choice%"=="6" (
    echo 👋 Goodbye!
    pause
    exit /b 0
) else (
    echo ❌ Invalid option. Please try again.
)

echo.
pause
echo.
goto :show_menu
