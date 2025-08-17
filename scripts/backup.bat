@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Backup Script for WordPress/WooCommerce
REM This script creates backups of both database and files

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="DB_ROOT_PASSWORD" set DB_ROOT_PASSWORD=%%B
        if "%%A"=="DB_NAME" set DB_NAME=%%B
        if "%%A"=="APP_URL" set APP_URL=%%B
        if "%%A"=="DB_HOST" set DB_HOST=%%B
    )
)

REM Default values if not set in .env
if "%APP_NAME%"=="" set APP_NAME=wordpress
if "%BACKUP_PATH%"=="" set BACKUP_PATH=.\backups
if "%BACKUP_RETENTION_DAYS%"=="" set BACKUP_RETENTION_DAYS=30

REM Create backup directories
if not exist "%BACKUP_PATH%\db" mkdir "%BACKUP_PATH%\db"
if not exist "%BACKUP_PATH%\files" mkdir "%BACKUP_PATH%\files"

REM Generate timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TIMESTAMP=%dt:~0,8%_%dt:~8,6%"

echo 🔄 Starting backup process...

REM Database Backup
echo 📦 Backing up database...
docker exec %APP_NAME%_db mysqldump -u root -p%DB_ROOT_PASSWORD% --single-transaction --routines --triggers --add-drop-table %DB_NAME% > "%BACKUP_PATH%\db\db_%TIMESTAMP%.sql"

REM Compress database backup using PowerShell
powershell -Command "Compress-Archive -Path '%BACKUP_PATH%\db\db_%TIMESTAMP%.sql' -DestinationPath '%BACKUP_PATH%\db\db_%TIMESTAMP%.sql.zip' -Force"
del "%BACKUP_PATH%\db\db_%TIMESTAMP%.sql"

echo ✅ Database backup completed: db_%TIMESTAMP%.sql.zip

REM WordPress Files Backup
echo 📁 Backing up WordPress files...

REM Create a zip archive of wp-content (themes, plugins, uploads)
powershell -Command "Compress-Archive -Path 'wp-content' -DestinationPath '%BACKUP_PATH%\files\wp-content_%TIMESTAMP%.zip' -Force"

echo ✅ Files backup completed: wp-content_%TIMESTAMP%.zip

REM Backup Docker configuration files
echo 🐳 Backing up configuration files...
powershell -Command "Compress-Archive -Path 'docker-compose.yml', '.env', 'uploads.ini', 'woocommerce-config.php', 'setup-woocommerce.sh' -DestinationPath '%BACKUP_PATH%\files\config_%TIMESTAMP%.zip' -Force"

REM Add scripts directory
if exist scripts (
    powershell -Command "Compress-Archive -Path 'scripts' -DestinationPath '%BACKUP_PATH%\files\scripts_%TIMESTAMP%.zip' -Force"
)

echo ✅ Configuration backup completed: config_%TIMESTAMP%.zip

REM Create a full backup archive
echo 📦 Creating full backup archive...
powershell -Command "Compress-Archive -Path '%BACKUP_PATH%\db\db_%TIMESTAMP%.sql.zip', '%BACKUP_PATH%\files\wp-content_%TIMESTAMP%.zip', '%BACKUP_PATH%\files\config_%TIMESTAMP%.zip' -DestinationPath '%BACKUP_PATH%\full_backup_%TIMESTAMP%.zip' -Force"

echo ✅ Full backup completed: %BACKUP_PATH%\full_backup_%TIMESTAMP%.zip

REM Clean up old backups (older than BACKUP_RETENTION_DAYS days)
echo 🧹 Cleaning up old backups (older than %BACKUP_RETENTION_DAYS% days)...
powershell -Command "Get-ChildItem '%BACKUP_PATH%' -Recurse -Include '*.zip' | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-%BACKUP_RETENTION_DAYS%)} | Remove-Item -Force"

REM Generate backup info file
echo Backup Information > "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo ================== >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo Date: %date% %time% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo Timestamp: %TIMESTAMP% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo App Name: %APP_NAME% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo Database: %DB_NAME% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo. >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo Files Included: >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo - Database dump: db_%TIMESTAMP%.sql.zip >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo - WordPress content: wp-content_%TIMESTAMP%.zip >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo - Configuration: config_%TIMESTAMP%.zip >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo - Full backup: full_backup_%TIMESTAMP%.zip >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo. >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo Restore Instructions: >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo 1. Use restore.bat script with the timestamp: scripts\restore.bat %TIMESTAMP% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo 2. Or manually restore using the individual files >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo. >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo Environment: >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo - WordPress URL: %APP_URL% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo - Database Host: %DB_HOST% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"
echo - Database Name: %DB_NAME% >> "%BACKUP_PATH%\backup_%TIMESTAMP%.info"

echo 📄 Backup info saved to: %BACKUP_PATH%\backup_%TIMESTAMP%.info
echo ✨ Backup process completed successfully!
echo.
echo To restore this backup, run:
echo scripts\restore.bat %TIMESTAMP%

pause
