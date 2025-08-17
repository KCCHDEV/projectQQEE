@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Restore Script for WordPress/WooCommerce
REM This script restores database and files from backup

REM Check if timestamp parameter is provided
if "%1"=="" (
    echo ❌ Error: Please provide a backup timestamp
    echo Usage: %0 ^<timestamp^>
    echo.
    echo Available backups:
    if exist backups\*.info (
        for %%f in (backups\*.info) do (
            set "filename=%%~nf"
            echo !filename:backup_=!
        )
    ) else (
        echo No backups found
    )
    pause
    exit /b 1
)

set TIMESTAMP=%1

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="DB_ROOT_PASSWORD" set DB_ROOT_PASSWORD=%%B
        if "%%A"=="DB_NAME" set DB_NAME=%%B
        if "%%A"=="APP_URL" set APP_URL=%%B
        if "%%A"=="PHPMYADMIN_PORT" set PHPMYADMIN_PORT=%%B
    )
)

REM Default values if not set in .env
if "%APP_NAME%"=="" set APP_NAME=wordpress
if "%BACKUP_PATH%"=="" set BACKUP_PATH=.\backups

REM Check if backup exists
if not exist "%BACKUP_PATH%\backup_%TIMESTAMP%.info" (
    echo ❌ Error: Backup with timestamp %TIMESTAMP% not found
    echo.
    echo Available backups:
    if exist backups\*.info (
        for %%f in (backups\*.info) do (
            set "filename=%%~nf"
            echo !filename:backup_=!
        )
    ) else (
        echo No backups found
    )
    pause
    exit /b 1
)

echo 🔄 Starting restore process from backup: %TIMESTAMP%
echo.

REM Display backup info
echo 📄 Backup Information:
type "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo.

REM Confirm restore
set /p confirm="⚠️  WARNING: This will overwrite current data. Continue? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo ❌ Restore cancelled
    pause
    exit /b 0
)

REM Stop containers during restore
echo 🛑 Stopping containers...
docker-compose stop wordpress

REM Restore database
if exist "%BACKUP_PATH%\db\db_%TIMESTAMP%.sql.zip" (
    echo 📦 Restoring database...
    
    REM Extract database dump
    powershell -Command "Expand-Archive -Path '%BACKUP_PATH%\db\db_%TIMESTAMP%.sql.zip' -DestinationPath '%BACKUP_PATH%\db\' -Force"
    
    REM Drop existing database and recreate
    docker exec %APP_NAME%_db mysql -u root -p%DB_ROOT_PASSWORD% -e "DROP DATABASE IF EXISTS %DB_NAME%; CREATE DATABASE %DB_NAME%;"
    
    REM Import database dump
    docker exec -i %APP_NAME%_db mysql -u root -p%DB_ROOT_PASSWORD% %DB_NAME% ^< "%BACKUP_PATH%\db\db_%TIMESTAMP%.sql"
    
    REM Clean up extracted file
    del "%BACKUP_PATH%\db\db_%TIMESTAMP%.sql"
    
    echo ✅ Database restored successfully
) else (
    echo ⚠️  Database backup not found, skipping database restore
)

REM Restore WordPress files
if exist "%BACKUP_PATH%\files\wp-content_%TIMESTAMP%.zip" (
    echo 📁 Restoring WordPress files...
    
    REM Backup current wp-content (just in case)
    if exist "wp-content" (
        ren wp-content wp-content.old.%random%
    )
    
    REM Extract wp-content
    powershell -Command "Expand-Archive -Path '%BACKUP_PATH%\files\wp-content_%TIMESTAMP%.zip' -DestinationPath '.' -Force"
    
    REM Set proper permissions
    docker exec %APP_NAME%_wordpress chown -R www-data:www-data /var/www/html/wp-content
    
    echo ✅ WordPress files restored successfully
) else (
    echo ⚠️  Files backup not found, skipping files restore
)

REM Restore configuration files
if exist "%BACKUP_PATH%\files\config_%TIMESTAMP%.zip" (
    echo 🐳 Restoring configuration files...
    
    REM Extract configuration files to a temporary directory
    if not exist "temp_config" mkdir temp_config
    powershell -Command "Expand-Archive -Path '%BACKUP_PATH%\files\config_%TIMESTAMP%.zip' -DestinationPath 'temp_config' -Force"
    
    REM Ask user if they want to restore configuration
    set /p restore_config="Do you want to restore configuration files? This will overwrite current configs (yes/no): "
    if /i "%restore_config%"=="yes" (
        copy temp_config\* . >nul 2>&1
        if exist temp_config\scripts xcopy temp_config\scripts . /E /Y /Q >nul 2>&1
        echo ✅ Configuration files restored
    ) else (
        echo ⏭️  Skipping configuration restore
    )
    
    REM Clean up
    rmdir /s /q temp_config
)

REM Update WordPress URLs if needed
echo 🔧 Updating WordPress URLs...
set /p new_url="Enter the new site URL (current: %APP_URL%): "
if not "%new_url%"=="" if not "%new_url%"=="%APP_URL%" (
    REM Update URLs in database
    docker exec %APP_NAME%_wordpress wp search-replace "%APP_URL%" "%new_url%" --allow-root
    
    REM Update .env file
    powershell -Command "(Get-Content .env) -replace 'APP_URL=.*', 'APP_URL=%new_url%' | Set-Content .env"
    
    echo ✅ URLs updated to: %new_url%
)

REM Clear caches
echo 🧹 Clearing caches...
docker exec %APP_NAME%_wordpress wp cache flush --allow-root >nul 2>&1
docker exec %APP_NAME%_redis redis-cli FLUSHALL >nul 2>&1

REM Start containers
echo 🚀 Starting containers...
docker-compose up -d

REM Wait for services to be ready
echo ⏳ Waiting for services to be ready...
timeout /t 10 /nobreak >nul

REM Run WordPress maintenance tasks
echo 🔧 Running maintenance tasks...
docker exec %APP_NAME%_wordpress wp cron event run --all --allow-root
docker exec %APP_NAME%_wordpress wp rewrite flush --allow-root

echo ✨ Restore completed successfully!
echo.
if not "%new_url%"=="" (
    echo 🌐 Your site should now be accessible at: %new_url%
) else (
    echo 🌐 Your site should now be accessible at: %APP_URL%
)
echo 📊 phpMyAdmin: http://localhost:%PHPMYADMIN_PORT%
echo.
echo ⚠️  Note: You may need to:
echo 1. Update your DNS settings if you changed the domain
echo 2. Configure SSL certificates for the new host
echo 3. Update any external integrations with the new URL

pause
