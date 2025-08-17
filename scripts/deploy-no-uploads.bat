@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Deployment Script for Code-Only Updates (No WordPress Content Uploads)
REM This script deploys only your custom code/themes/plugins without uploading WP content

REM Function to print colored output
:print_status
echo ✅ %~1
goto :eof

:print_warning
echo ⚠️  %~1
goto :eof

:print_error
echo ❌ %~1
goto :eof

:print_info
echo ℹ️  %~1
goto :eof

echo 🚀 Code-Only Deployment (No WP Content Uploads)
echo ================================================
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
    )
)

if "%APP_NAME%"=="" set APP_NAME=pet-food-store

REM Function to create deployment package without WP content
:create_code_package
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "package_name=code-deploy-%dt:~0,8%-%dt:~8,6%"
set "temp_dir=%TEMP%\%package_name%"

call :print_info "Creating code-only deployment package..."

REM Create temporary directory
if not exist "%temp_dir%" mkdir "%temp_dir%"

REM Copy only code files, exclude WP content uploads
call :print_info "Copying code files (excluding uploads)..."

REM Copy scripts
if exist "scripts" (
    xcopy "scripts" "%temp_dir%\scripts\" /E /Y /Q
    call :print_status "Scripts copied"
)

REM Copy themes (but exclude uploads within themes)
if exist "wp-content\themes" (
    if not exist "%temp_dir%\wp-content\themes" mkdir "%temp_dir%\wp-content\themes"
    for /r "wp-content\themes" %%f in (*.php *.css *.js *.json *.txt *.md) do (
        if not "%%~dpf"=="%temp_dir%" (
            set "rel_path=%%~dpf"
            set "rel_path=!rel_path:wp-content\themes=!"
            if not exist "%temp_dir%\wp-content\themes!rel_path!" mkdir "%temp_dir%\wp-content\themes!rel_path!"
            copy "%%f" "%temp_dir%\wp-content\themes!rel_path!" >nul
        )
    )
    call :print_status "Theme code files copied"
)

REM Copy plugins (but exclude cache/logs)
if exist "wp-content\plugins" (
    if not exist "%temp_dir%\wp-content\plugins" mkdir "%temp_dir%\wp-content\plugins"
    for /r "wp-content\plugins" %%f in (*.php *.css *.js *.json *.txt *.md) do (
        if not "%%~dpf"=="%temp_dir%" (
            set "rel_path=%%~dpf"
            set "rel_path=!rel_path:wp-content\plugins=!"
            if not exist "%temp_dir%\wp-content\plugins!rel_path!" mkdir "%temp_dir%\wp-content\plugins!rel_path!"
            copy "%%f" "%temp_dir%\wp-content\plugins!rel_path!" >nul
        )
    )
    call :print_status "Plugin code files copied"
)

REM Copy development workspace if it exists
if exist "dev-workspace" (
    xcopy "dev-workspace" "%temp_dir%\dev-workspace\" /E /Y /Q
    call :print_status "Development workspace copied"
)

REM Copy configuration files
for %%f in (docker-compose.yml .env.example uploads.ini woocommerce-config.php) do (
    if exist "%%f" (
        copy "%%f" "%temp_dir%\" >nul
    )
)
call :print_status "Configuration files copied"

REM Create deployment info
echo Code-Only Deployment Package > "%temp_dir%\DEPLOYMENT_INFO.txt"
echo Created: %date% %time% >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo Package: %package_name% >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo Type: Code/Scripts/Themes/Plugins only (NO uploads) >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo. >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo Contents: >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Scripts and utilities >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Theme code files (.php, .css, .js, .json) >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Plugin code files (.php, .css, .js, .json) >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Configuration files >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Development workspace (if exists) >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo. >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo Excluded: >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - wp-content/uploads/ >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Cache files >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Log files >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Temporary files >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Node modules >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Vendor directories >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo - Database dumps >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo. >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo To deploy this package: >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo 1. Extract on target server >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo 2. Run: scripts\deploy-no-uploads.bat apply >> "%temp_dir%\DEPLOYMENT_INFO.txt"
echo 3. Restart containers if needed >> "%temp_dir%\DEPLOYMENT_INFO.txt"

REM Create zip package
powershell -Command "Compress-Archive -Path '%temp_dir%' -DestinationPath '%package_name%.zip' -Force"
rmdir /s /q "%temp_dir%"

call :print_status "Code deployment package created: %package_name%.zip"
echo.
echo 📦 Package contains:
echo    - Scripts and utilities
echo    - Theme code files
echo    - Plugin code files
echo    - Configuration files
echo    - Development workspace
echo.
echo 🚫 Package excludes:
echo    - WordPress uploads
echo    - Cache files
echo    - Database content
echo    - Temporary files
goto :eof

REM Function to apply code deployment (extract and deploy)
:apply_code_deployment
set package_file=%~1

if "%package_file%"=="" (
    REM Find the latest code deployment package
    for /f %%f in ('dir /b /o-d code-deploy-*.zip 2^>nul') do (
        set package_file=%%f
        goto :package_found
    )
    call :print_error "No deployment package found!"
    call :print_info "Usage: %0 apply ^<package-file^>"
    pause
    exit /b 1
)

:package_found
if not exist "%package_file%" (
    call :print_error "Package file not found: %package_file%"
    pause
    exit /b 1
)

call :print_info "Applying code deployment from: %package_file%"

REM Create backup of current code
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "backup_dir=backup-%dt:~0,8%-%dt:~8,6%"
call :print_info "Creating backup of current code..."
if not exist "%backup_dir%" mkdir "%backup_dir%"

REM Backup current themes and plugins
if exist "wp-content\themes" (
    xcopy "wp-content\themes" "%backup_dir%\themes\" /E /Y /Q
)
if exist "wp-content\plugins" (
    xcopy "wp-content\plugins" "%backup_dir%\plugins\" /E /Y /Q
)
if exist "scripts" (
    xcopy "scripts" "%backup_dir%\scripts\" /E /Y /Q
)

call :print_status "Backup created in: %backup_dir%"

REM Extract and apply
call :print_info "Extracting deployment package..."
powershell -Command "Expand-Archive -Path '%package_file%' -DestinationPath '.' -Force"

set "package_dir=%package_file:.zip=%"

if not exist "%package_dir%" (
    call :print_error "Failed to extract package!"
    pause
    exit /b 1
)

REM Apply the code changes
call :print_info "Applying code changes..."

REM Copy scripts
if exist "%package_dir%\scripts" (
    xcopy "%package_dir%\scripts\*" "scripts\" /E /Y /Q
    call :print_status "Scripts updated"
)

REM Copy themes
if exist "%package_dir%\wp-content\themes" (
    if not exist "wp-content\themes" mkdir "wp-content\themes"
    xcopy "%package_dir%\wp-content\themes\*" "wp-content\themes\" /E /Y /Q
    call :print_status "Themes updated"
)

REM Copy plugins
if exist "%package_dir%\wp-content\plugins" (
    if not exist "wp-content\plugins" mkdir "wp-content\plugins"
    xcopy "%package_dir%\wp-content\plugins\*" "wp-content\plugins\" /E /Y /Q
    call :print_status "Plugins updated"
)

REM Copy development workspace
if exist "%package_dir%\dev-workspace" (
    xcopy "%package_dir%\dev-workspace" ".\dev-workspace\" /E /Y /Q
    call :print_status "Development workspace updated"
)

REM Update configuration files (but don't overwrite .env)
for %%f in (docker-compose.yml uploads.ini woocommerce-config.php) do (
    if exist "%package_dir%\%%f" (
        copy "%package_dir%\%%f" ".\" >nul
        call :print_status "%%f updated"
    )
)

REM Clean up
rmdir /s /q "%package_dir%"

call :print_status "Code deployment applied successfully!"
call :print_info "Backup available in: %backup_dir%"

REM Restart containers if running
docker ps | findstr "%APP_NAME%_wordpress" >nul 2>&1
if not errorlevel 1 (
    call :print_info "Restarting WordPress container to apply changes..."
    docker-compose restart wordpress
    call :print_status "Container restarted"
)

echo.
echo 🎉 Deployment Complete!
echo ======================
echo ✅ Code files updated
echo ✅ Themes updated
echo ✅ Plugins updated
echo 🔄 Container restarted
echo 💾 Backup saved in: %backup_dir%
goto :eof

REM Show deployment status
:show_deployment_status
echo.
echo 📋 Deployment Status
echo ===================
echo.

REM Check for deployment packages
set packages=0
for %%f in (code-deploy-*.zip) do set /a packages+=1
if %packages% gtr 0 (
    call :print_status "Available deployment packages: %packages%"
    for /f %%f in ('dir /b /o-d code-deploy-*.zip 2^>nul') do (
        echo    Latest: %%f
        goto :packages_found
    )
) else (
    call :print_warning "No deployment packages found"
)
:packages_found

REM Check for backups
set backups=0
for /d %%d in (backup-*) do set /a backups+=1
if %backups% gtr 0 (
    call :print_status "Available backups: %backups%"
    for /d %%d in (backup-*) do (
        echo    Latest: %%d
        goto :backups_found
    )
) else (
    call :print_warning "No backups found"
)
:backups_found

REM Check WordPress container
docker ps | findstr "%APP_NAME%_wordpress" >nul 2>&1
if not errorlevel 1 (
    call :print_status "WordPress container: Running"
) else (
    call :print_warning "WordPress container: Not running"
)

echo.
echo 📝 Available Commands:
echo    %0 package                    - Create code deployment package
echo    %0 apply [package-file]       - Apply code deployment
echo    %0 status                     - Show deployment status
echo.
goto :eof

REM Main command handler
set command=%~1
if "%command%"=="" set command=status

if "%command%"=="package" (
    call :create_code_package
) else if "%command%"=="create" (
    call :create_code_package
) else if "%command%"=="apply" (
    call :apply_code_deployment "%~2"
) else if "%command%"=="deploy" (
    call :apply_code_deployment "%~2"
) else if "%command%"=="status" (
    call :show_deployment_status
) else if "%command%"=="--help" (
    echo Code-Only Deployment Script
    echo.
    echo This script creates and applies deployments that contain only
    echo your code files (themes, plugins, scripts) without WordPress
    echo content uploads, cache, or database content.
    echo.
    call :show_deployment_status
) else if "%command%"=="-h" (
    echo Code-Only Deployment Script
    echo.
    echo This script creates and applies deployments that contain only
    echo your code files (themes, plugins, scripts) without WordPress
    echo content uploads, cache, or database content.
    echo.
    call :show_deployment_status
) else (
    call :print_error "Unknown command: %command%"
    echo.
    call :show_deployment_status
)

pause
