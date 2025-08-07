#!/bin/bash

# Restore Script for WordPress/WooCommerce
# This script restores database and files from backup

set -e

# Check if timestamp parameter is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide a backup timestamp"
    echo "Usage: $0 <timestamp>"
    echo ""
    echo "Available backups:"
    ls -1 backups/*.info 2>/dev/null | sed 's/.*backup_//;s/.info//' || echo "No backups found"
    exit 1
fi

TIMESTAMP=$1

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Default values if not set in .env
APP_NAME=${APP_NAME:-"wordpress"}
BACKUP_PATH=${BACKUP_PATH:-"./backups"}

# Check if backup exists
if [ ! -f "${BACKUP_PATH}/backup_${TIMESTAMP}.info" ]; then
    echo "❌ Error: Backup with timestamp ${TIMESTAMP} not found"
    echo ""
    echo "Available backups:"
    ls -1 ${BACKUP_PATH}/*.info 2>/dev/null | sed 's/.*backup_//;s/.info//' || echo "No backups found"
    exit 1
fi

echo "🔄 Starting restore process from backup: ${TIMESTAMP}"
echo ""

# Display backup info
echo "📄 Backup Information:"
cat "${BACKUP_PATH}/backup_${TIMESTAMP}.info"
echo ""

# Confirm restore
read -p "⚠️  WARNING: This will overwrite current data. Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

# Stop containers during restore
echo "🛑 Stopping containers..."
docker-compose stop wordpress

# Restore database
if [ -f "${BACKUP_PATH}/db/db_${TIMESTAMP}.sql.gz" ]; then
    echo "📦 Restoring database..."
    
    # Drop existing database and recreate
    docker exec ${APP_NAME}_db mysql -u root -p${DB_ROOT_PASSWORD} -e "DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME};"
    
    # Import database dump
    gunzip -c "${BACKUP_PATH}/db/db_${TIMESTAMP}.sql.gz" | docker exec -i ${APP_NAME}_db mysql -u root -p${DB_ROOT_PASSWORD} ${DB_NAME}
    
    echo "✅ Database restored successfully"
else
    echo "⚠️  Database backup not found, skipping database restore"
fi

# Restore WordPress files
if [ -f "${BACKUP_PATH}/files/wp-content_${TIMESTAMP}.tar.gz" ]; then
    echo "📁 Restoring WordPress files..."
    
    # Backup current wp-content (just in case)
    if [ -d "wp-content" ]; then
        mv wp-content wp-content.old.$(date +%s)
    fi
    
    # Extract wp-content
    tar -xzf "${BACKUP_PATH}/files/wp-content_${TIMESTAMP}.tar.gz" -C .
    
    # Set proper permissions
    docker exec ${APP_NAME}_wordpress chown -R www-data:www-data /var/www/html/wp-content
    
    echo "✅ WordPress files restored successfully"
else
    echo "⚠️  Files backup not found, skipping files restore"
fi

# Restore configuration files
if [ -f "${BACKUP_PATH}/files/config_${TIMESTAMP}.tar.gz" ]; then
    echo "🐳 Restoring configuration files..."
    
    # Extract configuration files to a temporary directory
    mkdir -p temp_config
    tar -xzf "${BACKUP_PATH}/files/config_${TIMESTAMP}.tar.gz" -C temp_config
    
    # Ask user if they want to restore configuration
    read -p "Do you want to restore configuration files? This will overwrite current configs (yes/no): " restore_config
    if [ "$restore_config" = "yes" ]; then
        cp -f temp_config/* . 2>/dev/null || true
        cp -rf temp_config/scripts . 2>/dev/null || true
        echo "✅ Configuration files restored"
    else
        echo "⏭️  Skipping configuration restore"
    fi
    
    # Clean up
    rm -rf temp_config
fi

# Update WordPress URLs if needed
echo "🔧 Updating WordPress URLs..."
read -p "Enter the new site URL (current: ${APP_URL}): " new_url
if [ ! -z "$new_url" ] && [ "$new_url" != "${APP_URL}" ]; then
    # Update URLs in database
    docker exec ${APP_NAME}_wordpress wp search-replace "${APP_URL}" "${new_url}" --allow-root
    
    # Update .env file
    sed -i "s|APP_URL=.*|APP_URL=${new_url}|" .env
    
    echo "✅ URLs updated to: ${new_url}"
fi

# Clear caches
echo "🧹 Clearing caches..."
docker exec ${APP_NAME}_wordpress wp cache flush --allow-root 2>/dev/null || true
docker exec ${APP_NAME}_redis redis-cli FLUSHALL 2>/dev/null || true

# Start containers
echo "🚀 Starting containers..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Run WordPress maintenance tasks
echo "🔧 Running maintenance tasks..."
docker exec ${APP_NAME}_wordpress wp cron event run --all --allow-root
docker exec ${APP_NAME}_wordpress wp rewrite flush --allow-root

echo "✨ Restore completed successfully!"
echo ""
echo "🌐 Your site should now be accessible at: ${new_url:-$APP_URL}"
echo "📊 phpMyAdmin: http://localhost:${PHPMYADMIN_PORT}"
echo ""
echo "⚠️  Note: You may need to:"
echo "1. Update your DNS settings if you changed the domain"
echo "2. Configure SSL certificates for the new host"
echo "3. Update any external integrations with the new URL"