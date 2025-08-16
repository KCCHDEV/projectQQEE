# Pet Food Shop - Windows PowerShell Installer
# Run as Administrator for best results

Write-Host "🐾 Pet Food Shop - Windows PowerShell Installer" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check for admin privileges
if (-not (Test-Administrator)) {
    Write-Host "⚠️  Warning: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "For best results, right-click and 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
}

# Check if Docker Desktop is installed
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker Desktop found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Desktop not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 Please install Docker Desktop first:" -ForegroundColor Yellow
    Write-Host "   1. Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor White
    Write-Host "   2. Install and restart your computer" -ForegroundColor White
    Write-Host "   3. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Opening Docker Desktop download page..." -ForegroundColor Blue
    Start-Process "https://www.docker.com/products/docker-desktop"
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "🐳 Starting Docker Desktop..." -ForegroundColor Blue
    Write-Host "Please wait while Docker Desktop starts..." -ForegroundColor Yellow
    
    # Try to start Docker Desktop
    $dockerPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerPath) {
        Start-Process $dockerPath
    } else {
        Write-Host "❌ Could not find Docker Desktop executable" -ForegroundColor Red
        Write-Host "Please start Docker Desktop manually and run this script again" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Wait for Docker to start
    Write-Host "Waiting for Docker to start..." -ForegroundColor Yellow
    do {
        Start-Sleep -Seconds 5
        try {
            docker info | Out-Null
            $dockerRunning = $true
        } catch {
            $dockerRunning = $false
            Write-Host "." -NoNewline
        }
    } while (-not $dockerRunning)
    
    Write-Host ""
    Write-Host "✅ Docker is now running" -ForegroundColor Green
}

Write-Host ""

# Create directories
Write-Host "📁 Creating directories..." -ForegroundColor Blue
$directories = @("backups", "wp-content", "wp-content\uploads", "wp-content\themes", "wp-content\plugins")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Create environment file
Write-Host "⚙️ Setting up configuration..." -ForegroundColor Blue
$envContent = @"
APP_NAME=pet-food-store
APP_URL=http://localhost:8000
WORDPRESS_PORT=8000
PHPMYADMIN_PORT=8080
MAILHOG_WEB_PORT=8025
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=petshop123
DB_ROOT_PASSWORD=petshop456
WORDPRESS_DEBUG=false
WP_MEMORY_LIMIT=256M
DB_HOST=db
REDIS_HOST=redis
SMTP_HOST=mailhog
SMTP_PORT=1025
WC_CURRENCY=THB
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8

# Create Docker Compose file
Write-Host "🐳 Creating Docker setup..." -ForegroundColor Blue
$dockerComposeContent = @"
version: '3.8'
services:
  db:
    image: mysql:8.0
    container_name: pet-food-store_db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: petshop456
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: petshop123
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - wordpress_network

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    container_name: pet-food-store_wordpress
    restart: unless-stopped
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: petshop123
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_HOME', 'http://localhost:8000');
        define('WP_SITEURL', 'http://localhost:8000');
    volumes:
      - wordpress_data:/var/www/html
      - ./wp-content:/var/www/html/wp-content
    networks:
      - wordpress_network

  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin/phpmyadmin:latest
    container_name: pet-food-store_phpmyadmin
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: petshop456
    networks:
      - wordpress_network

  mailhog:
    image: mailhog/mailhog:latest
    container_name: pet-food-store_mailhog
    restart: unless-stopped
    ports:
      - "8025:8025"
    networks:
      - wordpress_network

volumes:
  db_data:
  wordpress_data:

networks:
  wordpress_network:
    driver: bridge
"@

$dockerComposeContent | Out-File -FilePath "docker-compose.yml" -Encoding UTF8

# Create management scripts
Write-Host "📝 Creating management scripts..." -ForegroundColor Blue

# Start script
$startScript = @"
@echo off
echo 🚀 Starting Pet Food Shop...
docker-compose up -d
echo ✅ Shop started at http://localhost:8000
start http://localhost:8000
pause
"@
$startScript | Out-File -FilePath "start.bat" -Encoding UTF8

# Stop script
$stopScript = @"
@echo off
echo 🛑 Stopping Pet Food Shop...
docker-compose down
echo ✅ Shop stopped
pause
"@
$stopScript | Out-File -FilePath "stop.bat" -Encoding UTF8

# Restart script
$restartScript = @"
@echo off
echo 🔄 Restarting Pet Food Shop...
docker-compose restart
echo ✅ Shop restarted
start http://localhost:8000
pause
"@
$restartScript | Out-File -FilePath "restart.bat" -Encoding UTF8

# Start containers
Write-Host "🚀 Starting containers..." -ForegroundColor Blue
docker-compose up -d

Write-Host "⏳ Waiting for containers to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Setup WooCommerce
Write-Host "🛒 Setting up WooCommerce shop..." -ForegroundColor Blue

# Install WP-CLI
docker exec pet-food-store_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec pet-food-store_wordpress chmod +x wp-cli.phar
docker exec pet-food-store_wordpress mv wp-cli.phar /usr/local/bin/wp

# Install WooCommerce and theme
docker exec pet-food-store_wordpress wp plugin install woocommerce --activate --allow-root
docker exec pet-food-store_wordpress wp theme install storefront --activate --allow-root

# Create sample products
$products = @(
    @{title="Dog Food Premium"; content="High quality dog food for adult dogs"; price=450},
    @{title="Cat Food Deluxe"; content="Premium cat food with salmon"; price=380},
    @{title="Pet Toy Ball"; content="Interactive rubber ball with squeaker"; price=280},
    @{title="Pet Bed Comfort"; content="Soft pet bed with memory foam"; price=890},
    @{title="Pet Shampoo Gentle"; content="Gentle hypoallergenic shampoo"; price=320}
)

foreach ($product in $products) {
    docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="$($product.title)" --post_content="$($product.content)" --post_status=publish --allow-root
    $productId = docker exec pet-food-store_wordpress wp post list --post_type=product --post_title="$($product.title)" --format=ids --allow-root
    if ($productId) {
        $productId = $productId.Trim()
        docker exec pet-food-store_wordpress wp post meta update $productId _price $($product.price) --allow-root
        docker exec pet-food-store_wordpress wp post meta update $productId _regular_price $($product.price) --allow-root
        docker exec pet-food-store_wordpress wp post meta update $productId _stock_status instock --allow-root
    }
}

Write-Host ""
Write-Host "✅ Installation Complete!" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Your Pet Food Shop: http://localhost:8000" -ForegroundColor Cyan
Write-Host "🗄️  Database Admin: http://localhost:8080" -ForegroundColor Cyan
Write-Host "📧 Email Testing: http://localhost:8025" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 Default Login:" -ForegroundColor Yellow
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: (set during first visit)" -ForegroundColor White
Write-Host ""
Write-Host "💡 Management Files Created:" -ForegroundColor Yellow
Write-Host "   start.bat    - Start the shop" -ForegroundColor White
Write-Host "   stop.bat     - Stop the shop" -ForegroundColor White
Write-Host "   restart.bat  - Restart the shop" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Opening your shop in browser..." -ForegroundColor Blue
Start-Process "http://localhost:8000"

Read-Host "Press Enter to finish"