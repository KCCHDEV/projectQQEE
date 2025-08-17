@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Development Workflow Script for External UI/Script Editing
REM This script helps you develop outside WordPress and deploy only what you need

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="APP_URL" set APP_URL=%%B
    )
)

if "%APP_NAME%"=="" set APP_NAME=pet-food-store

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

REM Create development workspace
:create_dev_workspace
call :print_info "Creating development workspace..."

REM Create development directories
if not exist "dev-workspace" mkdir dev-workspace
if not exist "dev-workspace\themes" mkdir dev-workspace\themes
if not exist "dev-workspace\plugins" mkdir dev-workspace\plugins
if not exist "dev-workspace\scripts" mkdir dev-workspace\scripts
if not exist "dev-workspace\assets" mkdir dev-workspace\assets
if not exist "dev-workspace\themes\custom" mkdir dev-workspace\themes\custom
if not exist "dev-workspace\assets\css" mkdir dev-workspace\assets\css
if not exist "dev-workspace\assets\js" mkdir dev-workspace\assets\js
if not exist "dev-workspace\assets\images" mkdir dev-workspace\assets\images
if not exist "dev-workspace\scripts\deployment" mkdir dev-workspace\scripts\deployment
if not exist "dev-workspace\scripts\utilities" mkdir dev-workspace\scripts\utilities

REM Create a sample custom theme structure if it doesn't exist
if not exist "dev-workspace\themes\custom\my-theme" (
    mkdir dev-workspace\themes\custom\my-theme
    mkdir dev-workspace\themes\custom\my-theme\assets
    mkdir dev-workspace\themes\custom\my-theme\assets\css
    mkdir dev-workspace\themes\custom\my-theme\assets\js
    mkdir dev-workspace\themes\custom\my-theme\assets\images
    mkdir dev-workspace\themes\custom\my-theme\templates
    mkdir dev-workspace\themes\custom\my-theme\includes
    
    REM Create basic theme files
    echo /* > "dev-workspace\themes\custom\my-theme\style.css"
    echo Theme Name: My Custom Theme >> "dev-workspace\themes\custom\my-theme\style.css"
    echo Description: Custom theme for external development >> "dev-workspace\themes\custom\my-theme\style.css"
    echo Version: 1.0.0 >> "dev-workspace\themes\custom\my-theme\style.css"
    echo Author: Your Name >> "dev-workspace\themes\custom\my-theme\style.css"
    echo */ >> "dev-workspace\themes\custom\my-theme\style.css"
    echo. >> "dev-workspace\themes\custom\my-theme\style.css"
    echo /* Add your custom CSS here */ >> "dev-workspace\themes\custom\my-theme\style.css"
    echo body { >> "dev-workspace\themes\custom\my-theme\style.css"
    echo     font-family: Arial, sans-serif; >> "dev-workspace\themes\custom\my-theme\style.css"
    echo } >> "dev-workspace\themes\custom\my-theme\style.css"

    echo ^<?php > "dev-workspace\themes\custom\my-theme\index.php"
    echo /** >> "dev-workspace\themes\custom\my-theme\index.php"
    echo  * Custom Theme Index Template >> "dev-workspace\themes\custom\my-theme\index.php"
    echo  */ >> "dev-workspace\themes\custom\my-theme\index.php"
    echo get_header(); ?^> >> "dev-workspace\themes\custom\my-theme\index.php"
    echo. >> "dev-workspace\themes\custom\my-theme\index.php"
    echo ^<div class="main-content"^> >> "dev-workspace\themes\custom\my-theme\index.php"
    echo     ^<h1^>Custom Theme^</h1^> >> "dev-workspace\themes\custom\my-theme\index.php"
    echo     ^<p^>This is your custom theme developed externally.^</p^> >> "dev-workspace\themes\custom\my-theme\index.php"
    echo ^</div^> >> "dev-workspace\themes\custom\my-theme\index.php"
    echo. >> "dev-workspace\themes\custom\my-theme\index.php"
    echo ^<?php get_footer(); ?^> >> "dev-workspace\themes\custom\my-theme\index.php"

    echo ^<?php > "dev-workspace\themes\custom\my-theme\functions.php"
    echo /** >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo  * Theme Functions >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo  */ >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo. >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo // Enqueue styles and scripts >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo function my_theme_scripts() { >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo     wp_enqueue_style('my-theme-style', get_stylesheet_uri()); >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo     wp_enqueue_script('my-theme-script', get_template_directory_uri() . '/assets/js/main.js', array('jquery'), '1.0.0', true); >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo } >> "dev-workspace\themes\custom\my-theme\functions.php"
    echo add_action('wp_enqueue_scripts', 'my_theme_scripts'); >> "dev-workspace\themes\custom\my-theme\functions.php"

    echo // Custom JavaScript for your theme > "dev-workspace\themes\custom\my-theme\assets\js\main.js"
    echo document.addEventListener('DOMContentLoaded', function() { >> "dev-workspace\themes\custom\my-theme\assets\js\main.js"
    echo     console.log('Custom theme loaded!'); >> "dev-workspace\themes\custom\my-theme\assets\js\main.js"
    echo }); >> "dev-workspace\themes\custom\my-theme\assets\js\main.js"
)

REM Create development configuration
echo { > "dev-workspace\dev-config.json"
echo     "projectName": "%APP_NAME%", >> "dev-workspace\dev-config.json"
echo     "wordpressUrl": "%APP_URL%", >> "dev-workspace\dev-config.json"
echo     "developmentMode": true, >> "dev-workspace\dev-config.json"
echo     "excludeUploads": true, >> "dev-workspace\dev-config.json"
echo     "syncPaths": { >> "dev-workspace\dev-config.json"
echo         "themes": "wp-content/themes", >> "dev-workspace\dev-config.json"
echo         "plugins": "wp-content/plugins", >> "dev-workspace\dev-config.json"
echo         "assets": "wp-content/uploads/dev-assets" >> "dev-workspace\dev-config.json"
echo     }, >> "dev-workspace\dev-config.json"
echo     "buildCommands": { >> "dev-workspace\dev-config.json"
echo         "css": "npm run build:css", >> "dev-workspace\dev-config.json"
echo         "js": "npm run build:js" >> "dev-workspace\dev-config.json"
echo     } >> "dev-workspace\dev-config.json"
echo } >> "dev-workspace\dev-config.json"

call :print_status "Development workspace created at dev-workspace/"
goto :eof

REM Sync development files to WordPress
:sync_to_wp
set sync_type=%~1
if "%sync_type%"=="" set sync_type=all

call :print_info "Syncing development files to WordPress..."

if "%sync_type%"=="themes" (
    call :print_info "Syncing themes..."
    if exist "dev-workspace\themes" (
        xcopy "dev-workspace\themes" "wp-content\themes" /E /Y /Q
        call :print_status "Themes synced"
    )
) else if "%sync_type%"=="plugins" (
    call :print_info "Syncing plugins..."
    if exist "dev-workspace\plugins" (
        xcopy "dev-workspace\plugins" "wp-content\plugins" /E /Y /Q
        call :print_status "Plugins synced"
    )
) else if "%sync_type%"=="assets" (
    call :print_info "Syncing assets..."
    if exist "dev-workspace\assets" (
        if not exist "wp-content\uploads\dev-assets" mkdir "wp-content\uploads\dev-assets"
        xcopy "dev-workspace\assets" "wp-content\uploads\dev-assets" /E /Y /Q
        call :print_status "Assets synced"
    )
) else if "%sync_type%"=="all" (
    call :sync_to_wp "themes"
    call :sync_to_wp "plugins"
    call :sync_to_wp "assets"
) else (
    call :print_error "Unknown sync type: %sync_type%"
    call :print_info "Available types: themes, plugins, assets, all"
    pause
    exit /b 1
)
goto :eof

REM Deploy only specific changes to WordPress container
:deploy_changes
set deploy_type=%~1
if "%deploy_type%"=="" set deploy_type=themes

call :print_info "Deploying %deploy_type% to WordPress container..."

REM Ensure WordPress container is running
docker ps | findstr "%APP_NAME%_wordpress" >nul 2>&1
if errorlevel 1 (
    call :print_error "WordPress container is not running!"
    call :print_info "Start it with: docker-compose up -d"
    pause
    exit /b 1
)

if "%deploy_type%"=="themes" (
    if exist "dev-workspace\themes" (
        REM Copy themes to container
        docker exec %APP_NAME%_wordpress mkdir -p /var/www/html/wp-content/themes
        docker cp dev-workspace\themes\. %APP_NAME%_wordpress:/var/www/html/wp-content/themes/
        docker exec %APP_NAME%_wordpress chown -R www-data:www-data /var/www/html/wp-content/themes
        call :print_status "Themes deployed to container"
    )
) else if "%deploy_type%"=="plugins" (
    if exist "dev-workspace\plugins" (
        docker cp dev-workspace\plugins\. %APP_NAME%_wordpress:/var/www/html/wp-content/plugins/
        docker exec %APP_NAME%_wordpress chown -R www-data:www-data /var/www/html/wp-content/plugins
        call :print_status "Plugins deployed to container"
    )
) else if "%deploy_type%"=="assets" (
    if exist "dev-workspace\assets" (
        docker exec %APP_NAME%_wordpress mkdir -p /var/www/html/wp-content/uploads/dev-assets
        docker cp dev-workspace\assets\. %APP_NAME%_wordpress:/var/www/html/wp-content/uploads/dev-assets/
        docker exec %APP_NAME%_wordpress chown -R www-data:www-data /var/www/html/wp-content/uploads/dev-assets
        call :print_status "Assets deployed to container"
    )
) else if "%deploy_type%"=="all" (
    call :deploy_changes "themes"
    call :deploy_changes "plugins"
    call :deploy_changes "assets"
) else (
    call :print_error "Unknown deploy type: %deploy_type%"
    call :print_info "Available types: themes, plugins, assets, all"
    pause
    exit /b 1
)
goto :eof

REM Extract theme from WordPress for editing
:extract_theme
set theme_name=%~1

if "%theme_name%"=="" (
    call :print_error "Theme name required!"
    call :print_info "Usage: %0 extract-theme ^<theme-name^>"
    pause
    exit /b 1
)

call :print_info "Extracting theme '%theme_name%' for external editing..."

if exist "wp-content\themes\%theme_name%" (
    if not exist "dev-workspace\themes\extracted" mkdir "dev-workspace\themes\extracted"
    xcopy "wp-content\themes\%theme_name%" "dev-workspace\themes\extracted\%theme_name%" /E /Y /Q
    call :print_status "Theme '%theme_name%' extracted to dev-workspace\themes\extracted\%theme_name%"
    call :print_info "You can now edit it externally and use 'deploy-changes themes' to update"
) else (
    call :print_error "Theme '%theme_name%' not found in wp-content\themes\"
)
goto :eof

REM Build assets (if build tools are available)
:build_assets
call :print_info "Building assets..."

for /d %%d in (dev-workspace\themes\*) do (
    if exist "%%d\package.json" (
        call :print_info "Building assets for %%~nxd..."
        cd /d "%%d"
        npm install >nul 2>&1
        npm run build >nul 2>&1
        cd /d "%~dp0"
    )
)

call :print_status "Asset building completed"
goto :eof

REM Show development status
:show_dev_status
echo.
echo 🚀 Development Environment Status
echo =================================
echo.

REM Check if development workspace exists
if exist "dev-workspace" (
    call :print_status "Development workspace: Ready"
    set /a theme_files=0
    for /r "dev-workspace\themes" %%f in (*.php) do set /a theme_files+=1
    echo    📁 Themes: %theme_files% PHP files
    
    set /a asset_files=0
    for /r "dev-workspace\assets" %%f in (*) do set /a asset_files+=1
    echo    📁 Assets: %asset_files% asset files
    
    set /a plugin_files=0
    for /r "dev-workspace\plugins" %%f in (*.php) do set /a plugin_files+=1
    echo    📁 Plugins: %plugin_files% plugin files
) else (
    call :print_warning "Development workspace: Not created"
    call :print_info "Run: %0 init"
)

REM Check WordPress container status
docker ps | findstr "%APP_NAME%_wordpress" >nul 2>&1
if not errorlevel 1 (
    call :print_status "WordPress container: Running"
    echo    🌐 URL: %APP_URL%
) else (
    call :print_warning "WordPress container: Not running"
)

echo.
echo 📝 Available Commands:
echo    %0 init                    - Create development workspace
echo    %0 sync [themes^|plugins^|assets^|all] - Sync files to WordPress
echo    %0 deploy [themes^|plugins^|assets^|all] - Deploy to container
echo    %0 extract-theme ^<name^>    - Extract theme for editing
echo    %0 build                   - Build assets
echo    %0 status                  - Show this status
echo.
goto :eof

REM Main command handler
set command=%~1
if "%command%"=="" set command=status

if "%command%"=="init" (
    call :create_dev_workspace
) else if "%command%"=="sync" (
    call :sync_to_wp "%~2"
) else if "%command%"=="deploy" (
    call :deploy_changes "%~2"
) else if "%command%"=="deploy-changes" (
    call :deploy_changes "%~2"
) else if "%command%"=="extract-theme" (
    call :extract_theme "%~2"
) else if "%command%"=="build" (
    call :build_assets
) else if "%command%"=="status" (
    call :show_dev_status
) else if "%command%"=="--help" (
    echo Development Workflow Script
    echo.
    echo This script helps you develop WordPress themes/plugins externally
    echo and deploy only the changes you want, excluding WordPress content uploads.
    echo.
    call :show_dev_status
) else if "%command%"=="-h" (
    echo Development Workflow Script
    echo.
    echo This script helps you develop WordPress themes/plugins externally
    echo and deploy only the changes you want, excluding WordPress content uploads.
    echo.
    call :show_dev_status
) else (
    call :print_error "Unknown command: %command%"
    echo.
    call :show_dev_status
)

pause
