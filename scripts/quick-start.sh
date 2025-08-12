#!/bin/bash

# Quick Start Script for WordPress/WooCommerce
# This script provides a quick way to get started

set -e

echo "🚀 WordPress/WooCommerce Quick Start"
echo "===================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating environment configuration..."
    cp .env.example .env
    echo ""
    echo "⚠️  IMPORTANT: Please edit the .env file with your settings:"
    echo "   - Database passwords"
    echo "   - Site URL"
    echo "   - Email configuration"
    echo ""
    echo "Opening .env in editor..."
    ${EDITOR:-nano} .env
fi

# Make all scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh

# Create necessary directories
echo "📁 Creating required directories..."
mkdir -p backups/db
mkdir -p backups/files
mkdir -p wp-content/plugins
mkdir -p wp-content/themes
mkdir -p wp-content/uploads

# Check Docker installation
echo "🐳 Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker is installed"

# Start containers
echo ""
echo "🚀 Starting containers..."
docker-compose up -d

# Wait for services
echo "⏳ Waiting for services to start (30 seconds)..."
sleep 30

# Check container status
echo ""
echo "📊 Container Status:"
docker-compose ps

# Run setup if WordPress is fresh
if docker exec ${APP_NAME:-pet-food-store}_wordpress wp core is-installed --allow-root 2>/dev/null; then
    echo "✅ WordPress is already installed"
else
    echo "📦 Running initial WordPress setup..."
    ./setup-woocommerce.sh
fi

echo ""
echo "✨ Quick start complete!"
echo ""
echo "🌐 Access your site at: http://localhost:${WORDPRESS_PORT:-8000}"
echo "📊 phpMyAdmin: http://localhost:${PHPMYADMIN_PORT:-8080}"
echo "📧 MailHog: http://localhost:${MAILHOG_WEB_PORT:-8025}"
echo ""
echo "📚 Next steps:"
echo "   1. Visit your site and complete WordPress setup"
echo "   2. Configure WooCommerce settings"
echo "   3. Import your products"
echo "   4. Set up payment methods"
echo ""
echo "💡 Useful commands:"
echo "   ./scripts/backup.sh     - Create a backup"
echo "   ./scripts/migrate.sh    - Migration helper"
echo "   docker-compose logs -f  - View logs"
echo "   docker-compose down     - Stop all containers"