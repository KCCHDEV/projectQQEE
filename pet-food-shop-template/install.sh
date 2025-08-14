#!/bin/bash

# 🐾 Pet Food Shop - Easy Install Script
# Just run: bash install.sh

echo "🐾 Pet Food Shop - Easy Installer"
echo "=================================="
echo ""

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Start Docker
echo "🐳 Starting Docker..."
sudo service docker start 2>/dev/null || sudo systemctl start docker 2>/dev/null || {
    sudo dockerd > /tmp/docker.log 2>&1 &
    sleep 5
    sudo chmod 666 /var/run/docker.sock
}

# Create directories
echo "📁 Creating directories..."
mkdir -p backups wp-content/uploads

# Create environment file
echo "⚙️ Setting up configuration..."
cat > .env << EOF
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
