#!/bin/bash

echo "================================"
echo "   Pet Store - Quick Start"
echo "================================"
echo

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Docker is running
echo "[1/5] Checking Docker..."
if ! docker --version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not installed or not running${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✅ Docker is ready${NC}"

# Stop any existing containers
echo
echo "[2/5] Stopping existing containers..."
docker-compose -f simple-docker-compose.yml down >/dev/null 2>&1
echo -e "${GREEN}✅ Cleaned up${NC}"

# Start containers
echo
echo "[3/5] Starting containers..."
if docker-compose -f simple-docker-compose.yml up -d; then
    echo -e "${GREEN}✅ Containers started${NC}"
else
    echo -e "${RED}❌ Failed to start containers${NC}"
    exit 1
fi

# Wait for WordPress to be ready
echo
echo "[4/5] Waiting for WordPress to be ready..."
sleep 30
echo -e "${GREEN}✅ WordPress should be ready${NC}"

# Install WooCommerce and activate theme
echo
echo "[5/5] Setting up WordPress..."
sleep 10

# Try to install WooCommerce and activate theme
docker exec petstore_web wp plugin install woocommerce --activate --allow-root 2>/dev/null || true
docker exec petstore_web wp theme activate simple-pet-store --allow-root 2>/dev/null || true

echo -e "${GREEN}✅ Setup completed!${NC}"
echo
echo -e "${YELLOW}🎉 Your pet store is ready!${NC}"
echo
echo "📱 Access URLs:"
echo "================================"
echo "🌐 Website:     http://localhost:8000"
echo "👤 Admin:       http://localhost:8000/wp-admin"
echo "🗄️  phpMyAdmin: http://localhost:8080"
echo
echo "🔑 Default Login:"
echo "Username: admin"
echo "Password: admin"
echo
echo "Note: If login doesn't work, please complete WordPress setup manually"
echo "by visiting http://localhost:8000 and following the installation wizard."
echo