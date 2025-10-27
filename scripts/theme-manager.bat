@echo off
REM Pet Food E-commerce Platform - Theme Management Script for Windows
REM Advanced theme management for WordPress/WooCommerce

setlocal enabledelayedexpansion

REM Configuration
set CONTAINER_NAME=pet-food-store_wordpress
set THEMES_DIR=/var/www/html/wp-content/themes
set BACKUP_DIR=/var/www/html/wp-content/themes-backup

REM Get current timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "TIMESTAMP=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

if "%1"=="" goto :show_help
if "%1"=="help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help

REM Check if Docker container is running
docker ps | findstr "%CONTAINER_NAME%" >nul
if errorlevel 1 (
    echo [ERROR] WordPress container is not running. Please start the containers first.
    echo [INFO] Run: docker-compose up -d
    exit /b 1
)

REM Execute command
if "%1"=="list" goto :list_themes
if "%1"=="active" goto :show_active_theme
if "%1"=="activate" goto :activate_theme
if "%1"=="install" goto :install_theme
if "%1"=="install-url" goto :install_theme_url
if "%1"=="backup" goto :backup_theme
if "%1"=="backup-all" goto :backup_all_themes
if "%1"=="restore" goto :restore_theme
if "%1"=="delete" goto :delete_theme
if "%1"=="update" goto :update_theme
if "%1"=="export" goto :export_theme
if "%1"=="gallery" goto :show_gallery
if "%1"=="install-gallery" goto :install_gallery_theme

echo [ERROR] Unknown command: %1
goto :show_help

:show_help
echo Pet Food E-commerce Platform - Theme Manager (Windows)
echo ======================================================
echo.
echo Usage: %0 [COMMAND] [OPTIONS]
echo.
echo Commands:
echo   list                    List all installed themes
echo   active                  Show active theme
echo   activate ^<theme^>        Activate a theme
echo   install ^<file^>          Install theme from zip file
echo   install-url ^<url^>       Install theme from URL
echo   backup ^<theme^>          Backup a specific theme
echo   backup-all              Backup all themes
echo   restore ^<backup^>        Restore theme from backup
echo   delete ^<theme^>          Delete a theme
echo   update ^<theme^>          Update a theme
echo   export ^<theme^>          Export theme as zip
echo   gallery                 Show available pet store themes
echo   install-gallery ^<id^>    Install theme from gallery
echo.
echo Examples:
echo   %0 list
echo   %0 activate petpaws
echo   %0 install C:\path\to\theme.zip
echo   %0 backup petpaws
echo   %0 restore petpaws_2024-01-15.zip
echo.
goto :eof

:list_themes
echo [INFO] Listing installed themes...
docker exec %CONTAINER_NAME% wp theme list --allow-root --format=table
goto :eof

:show_active_theme
echo [INFO] Current active theme:
for /f %%i in ('docker exec %CONTAINER_NAME% wp theme list --status=active --allow-root --format=csv --fields=name') do (
    if not "%%i"=="name" (
        echo Active theme: %%i
        docker exec %CONTAINER_NAME% wp theme get %%i --allow-root
    )
)
goto :eof

:activate_theme
if "%2"=="" (
    echo [ERROR] Theme name is required
    echo Usage: %0 activate ^<theme_name^>
    exit /b 1
)

echo [INFO] Activating theme: %2
docker exec %CONTAINER_NAME% wp theme activate %2 --allow-root
if not errorlevel 1 (
    echo [SUCCESS] Theme '%2' activated successfully
    docker exec %CONTAINER_NAME% wp cache flush --allow-root 2>nul
) else (
    echo [ERROR] Failed to activate theme '%2'
    exit /b 1
)
goto :eof

:install_theme
if "%2"=="" (
    echo [ERROR] Theme file is required
    echo Usage: %0 install ^<theme_file.zip^>
    exit /b 1
)

if not exist "%2" (
    echo [ERROR] Theme file not found: %2
    exit /b 1
)

echo [INFO] Installing theme from: %2

REM Copy theme file to container
docker cp "%2" %CONTAINER_NAME%:/tmp/theme.zip

REM Install theme
docker exec %CONTAINER_NAME% wp theme install /tmp/theme.zip --allow-root
if not errorlevel 1 (
    echo [SUCCESS] Theme installed successfully
    docker exec %CONTAINER_NAME% rm /tmp/theme.zip
) else (
    echo [ERROR] Failed to install theme
    docker exec %CONTAINER_NAME% rm /tmp/theme.zip
    exit /b 1
)
goto :eof

:install_theme_url
if "%2"=="" (
    echo [ERROR] Theme URL is required
    echo Usage: %0 install-url ^<theme_url^>
    exit /b 1
)

echo [INFO] Installing theme from URL: %2
docker exec %CONTAINER_NAME% wp theme install "%2" --allow-root
if not errorlevel 1 (
    echo [SUCCESS] Theme installed successfully from URL
) else (
    echo [ERROR] Failed to install theme from URL
    exit /b 1
)
goto :eof

:backup_theme
if "%2"=="" (
    echo [ERROR] Theme name is required
    echo Usage: %0 backup ^<theme_name^>
    exit /b 1
)

echo [INFO] Backing up theme: %2

set BACKUP_FILE=%2-%TIMESTAMP%.zip

REM Create backup directory in container
docker exec %CONTAINER_NAME% mkdir -p %BACKUP_DIR%

REM Create zip backup
docker exec %CONTAINER_NAME% bash -c "cd %THEMES_DIR% && zip -r %BACKUP_DIR%/%BACKUP_FILE% %2"
if not errorlevel 1 (
    echo [SUCCESS] Theme backup created: %BACKUP_FILE%
    
    REM Copy backup to host
    if not exist "backups\themes" mkdir "backups\themes"
    docker cp %CONTAINER_NAME%:%BACKUP_DIR%/%BACKUP_FILE% "backups\themes\"
    
    echo [SUCCESS] Backup copied to: backups\themes\%BACKUP_FILE%
) else (
    echo [ERROR] Failed to create theme backup
    exit /b 1
)
goto :eof

:backup_all_themes
echo [INFO] Backing up all themes...

set BACKUP_FILE=all-themes-%TIMESTAMP%.zip

REM Create backup directory in container
docker exec %CONTAINER_NAME% mkdir -p %BACKUP_DIR%

REM Create zip backup of all themes
docker exec %CONTAINER_NAME% bash -c "cd %THEMES_DIR% && zip -r %BACKUP_DIR%/%BACKUP_FILE% ."
if not errorlevel 1 (
    echo [SUCCESS] All themes backup created: %BACKUP_FILE%
    
    REM Copy backup to host
    if not exist "backups\themes" mkdir "backups\themes"
    docker cp %CONTAINER_NAME%:%BACKUP_DIR%/%BACKUP_FILE% "backups\themes\"
    
    echo [SUCCESS] Backup copied to: backups\themes\%BACKUP_FILE%
) else (
    echo [ERROR] Failed to create themes backup
    exit /b 1
)
goto :eof

:restore_theme
if "%2"=="" (
    echo [ERROR] Backup file is required
    echo Usage: %0 restore ^<backup_file^>
    exit /b 1
)

set BACKUP_FILE=%2

REM Check if backup file exists locally
if exist "backups\themes\%2" (
    set BACKUP_FILE=backups\themes\%2
) else if not exist "%2" (
    echo [ERROR] Backup file not found: %2
    exit /b 1
)

echo [INFO] Restoring theme from backup: %BACKUP_FILE%

REM Copy backup to container
docker cp "%BACKUP_FILE%" %CONTAINER_NAME%:/tmp/theme_backup.zip

REM Extract backup
docker exec %CONTAINER_NAME% bash -c "cd %THEMES_DIR% && unzip -o /tmp/theme_backup.zip"
if not errorlevel 1 (
    echo [SUCCESS] Theme restored successfully
    docker exec %CONTAINER_NAME% rm /tmp/theme_backup.zip
    docker exec %CONTAINER_NAME% wp cache flush --allow-root 2>nul
) else (
    echo [ERROR] Failed to restore theme
    docker exec %CONTAINER_NAME% rm /tmp/theme_backup.zip
    exit /b 1
)
goto :eof

:delete_theme
if "%2"=="" (
    echo [ERROR] Theme name is required
    echo Usage: %0 delete ^<theme_name^>
    exit /b 1
)

echo Are you sure you want to delete theme '%2'? (y/N):
set /p confirm=
if /i not "%confirm%"=="y" (
    echo [INFO] Theme deletion cancelled
    exit /b 0
)

echo [INFO] Deleting theme: %2
docker exec %CONTAINER_NAME% wp theme delete %2 --allow-root
if not errorlevel 1 (
    echo [SUCCESS] Theme '%2' deleted successfully
) else (
    echo [ERROR] Failed to delete theme '%2'
    exit /b 1
)
goto :eof

:update_theme
if "%2"=="" (
    echo [ERROR] Theme name is required
    echo Usage: %0 update ^<theme_name^>
    exit /b 1
)

echo [INFO] Updating theme: %2
docker exec %CONTAINER_NAME% wp theme update %2 --allow-root
if not errorlevel 1 (
    echo [SUCCESS] Theme '%2' updated successfully
    docker exec %CONTAINER_NAME% wp cache flush --allow-root 2>nul
) else (
    echo [ERROR] Failed to update theme '%2'
    exit /b 1
)
goto :eof

:export_theme
if "%2"=="" (
    echo [ERROR] Theme name is required
    echo Usage: %0 export ^<theme_name^>
    exit /b 1
)

echo [INFO] Exporting theme: %2

set EXPORT_FILE=%2-export-%YYYY%%MM%%DD%.zip
set EXPORT_DIR=exports\themes

if not exist "%EXPORT_DIR%" mkdir "%EXPORT_DIR%"

REM Create export zip
docker exec %CONTAINER_NAME% bash -c "cd %THEMES_DIR% && zip -r /tmp/%EXPORT_FILE% %2"
if not errorlevel 1 (
    REM Copy export to host
    docker cp %CONTAINER_NAME%:/tmp/%EXPORT_FILE% "%EXPORT_DIR%\"
    
    REM Clean up container
    docker exec %CONTAINER_NAME% rm /tmp/%EXPORT_FILE%
    
    echo [SUCCESS] Theme exported to: %EXPORT_DIR%\%EXPORT_FILE%
) else (
    echo [ERROR] Failed to export theme
    exit /b 1
)
goto :eof

:show_gallery
echo [INFO] Pet Store Theme Gallery
echo ===============================
echo.
echo 1. Pet Paws Pro - Professional pet store theme
echo 2. Animal Care - Modern pet care services theme  
echo 3. Pet Shop Express - Fast e-commerce theme
echo 4. Veterinary Clinic - Vet services theme
echo 5. Pet Grooming - Pet grooming services theme
echo.
echo To install a theme from gallery:
echo %0 install-gallery ^<theme_id^>
goto :eof

:install_gallery_theme
if "%2"=="" (
    echo [ERROR] Theme ID is required
    echo Usage: %0 install-gallery ^<theme_id^>
    call :show_gallery
    exit /b 1
)

set THEME_ID=%2

if %THEME_ID% LSS 1 (
    echo [ERROR] Invalid theme ID. Must be between 1 and 5.
    call :show_gallery
    exit /b 1
)

if %THEME_ID% GTR 5 (
    echo [ERROR] Invalid theme ID. Must be between 1 and 5.
    call :show_gallery
    exit /b 1
)

REM Define theme URLs
if %THEME_ID%==1 set THEME_URL=https://github.com/pet-themes/pet-paws-pro/archive/main.zip
if %THEME_ID%==2 set THEME_URL=https://github.com/pet-themes/animal-care/archive/main.zip
if %THEME_ID%==3 set THEME_URL=https://github.com/pet-themes/pet-shop-express/archive/main.zip
if %THEME_ID%==4 set THEME_URL=https://github.com/pet-themes/veterinary-clinic/archive/main.zip
if %THEME_ID%==5 set THEME_URL=https://github.com/pet-themes/pet-grooming/archive/main.zip

echo [INFO] Installing gallery theme ID %THEME_ID% from: !THEME_URL!
call :install_theme_url "!THEME_URL!"
goto :eof

:eof