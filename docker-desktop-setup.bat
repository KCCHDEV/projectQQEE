@echo off
chcp 65001
cls

echo 🐳 Docker Desktop Setup Helper for Windows
echo ==========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Running as Administrator
) else (
    echo ⚠️  Not running as Administrator
    echo For best results, right-click and 'Run as administrator'
    echo.
)

REM Check if Docker Desktop is already installed
docker --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Docker Desktop is already installed!
    docker --version
    echo.
    goto :check_running
) else (
    echo ❌ Docker Desktop not found
    echo.
    goto :install_docker
)

:install_docker
echo 📥 Docker Desktop Installation Helper
echo ====================================
echo.
echo This script will help you install Docker Desktop:
echo.
echo 1. 🌐 Opening Docker Desktop download page...
start https://www.docker.com/products/docker-desktop/
echo.
echo 2. 📋 Installation Steps:
echo    - Download "Docker Desktop for Windows"
echo    - Run the installer (may require admin rights)
echo    - Follow the installation wizard
echo    - Restart your computer when prompted
echo    - Start Docker Desktop after restart
echo.
echo 3. ⚙️  After installation:
echo    - Look for Docker Desktop in Start menu
echo    - Wait for it to fully start (green status)
echo    - Run this script again to verify
echo.
pause
exit

:check_running
echo 🔍 Checking if Docker is running...
docker info >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Docker is running properly!
    goto :optimize_settings
) else (
    echo ❌ Docker is not running
    echo.
    echo 🐳 Attempting to start Docker Desktop...
    echo.
    
    REM Try to start Docker Desktop
    set "DOCKER_PATH=%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
    if exist "%DOCKER_PATH%" (
        echo Starting Docker Desktop...
        start "" "%DOCKER_PATH%"
        echo.
        echo ⏳ Waiting for Docker to start...
        echo Please wait while Docker Desktop initializes...
        echo This may take 1-3 minutes on first run.
        echo.
        
        REM Wait for Docker to start
        set /a counter=0
        :wait_loop
        timeout /t 10 /nobreak >nul
        set /a counter+=1
        docker info >nul 2>&1
        if %errorlevel% == 0 (
            echo ✅ Docker is now running!
            goto :optimize_settings
        )
        if %counter% lss 18 (
            echo Still waiting... (%counter%/18)
            goto :wait_loop
        )
        
        echo ❌ Docker did not start within 3 minutes
        echo Please start Docker Desktop manually and try again
        pause
        exit
    ) else (
        echo ❌ Docker Desktop executable not found
        echo Please ensure Docker Desktop is properly installed
        pause
        exit
    )
)

:optimize_settings
echo.
echo ⚡ Docker Optimization Recommendations
echo ===================================
echo.
echo For better performance with Pet Food Shop:
echo.
echo 1. 💾 Memory Settings:
echo    - Open Docker Desktop Settings
echo    - Go to Resources ^> Advanced
echo    - Set Memory to at least 4GB (recommended: 6GB)
echo    - Set CPU to at least 2 cores
echo.
echo 2. 💿 Disk Settings:
echo    - Disk image size: at least 60GB
echo    - Enable "Use the WSL 2 based engine" if available
echo.
echo 3. 🔄 Update Settings:
echo    - Enable "Check for updates automatically"
echo    - Enable "Include weekly releases"
echo.
echo 4. 🌐 Network Settings:
echo    - If behind firewall, configure proxy settings
echo    - Ensure ports 8000, 8080, 8025 are available
echo.

REM Check available ports
echo 🔌 Checking required ports...
netstat -an | find ":8000 " >nul
if %errorlevel% == 0 (
    echo ⚠️  Port 8000 is in use
) else (
    echo ✅ Port 8000 is available
)

netstat -an | find ":8080 " >nul
if %errorlevel% == 0 (
    echo ⚠️  Port 8080 is in use
) else (
    echo ✅ Port 8080 is available
)

netstat -an | find ":8025 " >nul
if %errorlevel% == 0 (
    echo ⚠️  Port 8025 is in use
) else (
    echo ✅ Port 8025 is available
)

echo.
echo 🛠️  Quick Docker Commands:
echo ========================
echo.
echo Check Docker status: docker info
echo List containers:     docker ps
echo List images:         docker images
echo Stop all containers: docker stop $(docker ps -q)
echo Remove containers:   docker container prune
echo Remove images:       docker image prune
echo.

echo 🐾 Ready for Pet Food Shop Installation!
echo ========================================
echo.
echo Docker Desktop is properly configured.
echo You can now run the Pet Food Shop installer:
echo.
echo • Double-click "install-windows.bat"
echo • Or run "install-windows.ps1" in PowerShell
echo.
echo The shop will be available at:
echo • Main site: http://localhost:8000
echo • Admin:     http://localhost:8000/wp-admin
echo • Database:  http://localhost:8080
echo.

REM Offer to open Docker Desktop settings
echo.
set /p openSettings="Open Docker Desktop settings now? (y/n): "
if /i "%openSettings%"=="y" (
    start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
)

echo.
echo ✅ Setup complete! Docker Desktop is ready.
pause