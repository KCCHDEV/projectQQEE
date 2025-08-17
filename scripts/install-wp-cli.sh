#!/bin/bash

# Load environment variables
if [ -f ".env" ]; then
    export $(cat .env | xargs)
fi

APP_NAME=${APP_NAME:-pet-food-store}

echo "📥 กำลังติดตั้ง WP-CLI..."

# Check if WP-CLI is already installed
if docker exec ${APP_NAME}_wordpress wp --info --allow-root &>/dev/null; then
    echo "✅ WP-CLI ติดตั้งแล้ว"
    exit 0
fi

# Download and install WP-CLI
docker exec ${APP_NAME}_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec ${APP_NAME}_wordpress chmod +x wp-cli.phar
docker exec ${APP_NAME}_wordpress mv wp-cli.phar /usr/local/bin/wp

# Verify installation
if docker exec ${APP_NAME}_wordpress wp --info --allow-root &>/dev/null; then
    echo "✅ ติดตั้ง WP-CLI เรียบร้อย"
else
    echo "❌ ไม่สามารถติดตั้ง WP-CLI ได้"
    exit 1
fi