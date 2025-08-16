@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🔄 WordPress Auto-Sync - Development Monitor
echo ==================================================
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
    )
) else (
    echo ⚠️  .env file not found! Using default values.
    set APP_NAME=pet-food-store
)

REM Set defaults if not found in .env
if "%APP_NAME%"=="" set APP_NAME=pet-food-store

REM Check if Docker is available
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker not found! Please install Docker Desktop.
    pause
    exit /b 1
)

REM Check if WordPress container is running
echo ℹ️  Checking WordPress container status...
docker ps --format "table {{.Names}}" | findstr "%APP_NAME%-wordpress" >nul 2>&1
if errorlevel 1 (
    echo ❌ WordPress container is not running!
    echo ℹ️  Please start your WordPress environment first:
    echo    ./scripts/quick-start.sh
    pause
    exit /b 1
)
echo ✅ WordPress container is running

REM Setup development workspace
echo ℹ️  Setting up development workspace...

if not exist "dev-workspace" mkdir dev-workspace
if not exist "dev-workspace\themes" mkdir dev-workspace\themes
if not exist "dev-workspace\plugins" mkdir dev-workspace\plugins
if not exist "dev-workspace\themes\custom" mkdir dev-workspace\themes\custom
if not exist "dev-workspace\plugins\custom" mkdir dev-workspace\plugins\custom

REM Create README files if they don't exist
if not exist "dev-workspace\themes\custom\README.md" (
    echo # Custom Themes Development > "dev-workspace\themes\custom\README.md"
    echo. >> "dev-workspace\themes\custom\README.md"
    echo Place your custom theme files here. They will be automatically synced to: >> "dev-workspace\themes\custom\README.md"
    echo `pet-food-shop-template/wp-content/themes/` >> "dev-workspace\themes\custom\README.md"
    echo. >> "dev-workspace\themes\custom\README.md"
    echo ## Structure: >> "dev-workspace\themes\custom\README.md"
    echo ``` >> "dev-workspace\themes\custom\README.md"
    echo dev-workspace/themes/custom/ >> "dev-workspace\themes\custom\README.md"
    echo ├── your-theme-name/ >> "dev-workspace\themes\custom\README.md"
    echo │   ├── style.css >> "dev-workspace\themes\custom\README.md"
    echo │   ├── index.php >> "dev-workspace\themes\custom\README.md"
    echo │   ├── functions.php >> "dev-workspace\themes\custom\README.md"
    echo │   └── ... >> "dev-workspace\themes\custom\README.md"
    echo ``` >> "dev-workspace\themes\custom\README.md"
    echo. >> "dev-workspace\themes\custom\README.md"
    echo Files are monitored and synced automatically when you save them in VSCode. >> "dev-workspace\themes\custom\README.md"
)

if not exist "dev-workspace\plugins\custom\README.md" (
    echo # Custom Plugins Development > "dev-workspace\plugins\custom\README.md"
    echo. >> "dev-workspace\plugins\custom\README.md"
    echo Place your custom plugin files here. They will be automatically synced to: >> "dev-workspace\plugins\custom\README.md"
    echo `pet-food-shop-template/wp-content/plugins/` >> "dev-workspace\plugins\custom\README.md"
    echo. >> "dev-workspace\plugins\custom\README.md"
    echo ## Structure: >> "dev-workspace\plugins\custom\README.md"
    echo ``` >> "dev-workspace\plugins\custom\README.md"
    echo dev-workspace/plugins/custom/ >> "dev-workspace\plugins\custom\README.md"
    echo ├── your-plugin-name/ >> "dev-workspace\plugins\custom\README.md"
    echo │   ├── your-plugin-name.php >> "dev-workspace\plugins\custom\README.md"
    echo │   ├── includes/ >> "dev-workspace\plugins\custom\README.md"
    echo │   ├── assets/ >> "dev-workspace\plugins\custom\README.md"
    echo │   └── ... >> "dev-workspace\plugins\custom\README.md"
    echo ``` >> "dev-workspace\plugins\custom\README.md"
    echo. >> "dev-workspace\plugins\custom\README.md"
    echo Files are monitored and synced automatically when you save them in VSCode. >> "dev-workspace\plugins\custom\README.md"
)

echo ✅ Development workspace ready at: .\dev-workspace\

REM Initial sync of existing files
echo ℹ️  Performing initial sync...
call :sync_all_files
echo ✅ Initial sync completed

echo.
echo ℹ️  🎯 Ready for development!
echo ℹ️  Edit files in .\dev-workspace\ and they will be auto-synced
echo ℹ️  WordPress site: http://localhost:8080
echo ℹ️  Admin: http://localhost:8080/wp-admin
echo.
echo ℹ️  Starting file monitoring...
echo ℹ️  Monitoring: .\dev-workspace\
echo ℹ️  Press Ctrl+C to stop monitoring
echo.

REM Start continuous monitoring
:monitor_loop
timeout /t 2 /nobreak >nul

REM Check for changes and sync
call :sync_all_files

goto monitor_loop

REM Function to sync all files
:sync_all_files
REM Sync themes
if exist "dev-workspace\themes\custom\" (
    for /d %%D in ("dev-workspace\themes\custom\*") do (
        if exist "%%D\" (
            call :sync_directory "%%D" "themes\custom\%%~nxD"
        )
    )
)

REM Sync plugins
if exist "dev-workspace\plugins\custom\" (
    for /d %%D in ("dev-workspace\plugins\custom\*") do (
        if exist "%%D\" (
            call :sync_directory "%%D" "plugins\custom\%%~nxD"
        )
    )
)

REM Sync individual files
for /r "dev-workspace" %%F in (*.*) do (
    if not "%%~nxF"=="README.md" (
        call :sync_file "%%F"
    )
)
goto :eof

REM Function to sync a single file
:sync_file
set "source_file=%~1"
set "relative_path=!source_file:dev-workspace\=!"
set "dest_path=pet-food-shop-template\wp-content\!relative_path!"

REM Create destination directory if it doesn't exist
for %%F in ("!dest_path!") do (
    if not exist "%%~dpF" mkdir "%%~dpF"
)

REM Copy file to local wp-content
copy "!source_file!" "!dest_path!" >nul 2>&1
if not errorlevel 1 (
    echo ℹ️  📄 Synced file: !relative_path!
    
    REM Copy to WordPress container
    docker ps --format "table {{.Names}}" | findstr "%APP_NAME%-wordpress" >nul 2>&1
    if not errorlevel 1 (
        docker cp "!dest_path!" "%APP_NAME%-wordpress:/var/www/html/wp-content/!relative_path!" >nul 2>&1
        if not errorlevel 1 (
            echo ✅ 🚀 Deployed to container: !relative_path!
        )
    )
)
goto :eof

REM Function to sync a directory
:sync_directory
set "source_dir=%~1"
set "relative_path=%~2"
set "dest_path=pet-food-shop-template\wp-content\!relative_path!"

REM Create destination directory if it doesn't exist
if not exist "!dest_path!" mkdir "!dest_path!"

REM Copy directory contents to local wp-content
xcopy "!source_dir!" "!dest_path!" /E /Y /Q >nul 2>&1
if not errorlevel 1 (
    echo ℹ️  📁 Synced directory: !relative_path!
    
    REM Copy to WordPress container
    docker ps --format "table {{.Names}}" | findstr "%APP_NAME%-wordpress" >nul 2>&1
    if not errorlevel 1 (
        docker cp "!dest_path!" "%APP_NAME%-wordpress:/var/www/html/wp-content/" >nul 2>&1
        if not errorlevel 1 (
            echo ✅ 🚀 Deployed to container: !relative_path!
        )
    )
)
goto :eof