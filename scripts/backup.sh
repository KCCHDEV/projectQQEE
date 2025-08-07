#!/bin/bash

# Backup Script for WordPress/WooCommerce
# This script creates backups of both database and files

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Default values if not set in .env
APP_NAME=${APP_NAME:-"wordpress"}
BACKUP_PATH=${BACKUP_PATH:-"./backups"}
BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}

# Create backup directories
mkdir -p "${BACKUP_PATH}/db"
mkdir -p "${BACKUP_PATH}/files"

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔄 Starting backup process..."

# Database Backup
echo "📦 Backing up database..."
docker exec ${APP_NAME}_db mysqldump \
    -u root \
    -p${DB_ROOT_PASSWORD} \
    --single-transaction \
    --routines \
    --triggers \
    --add-drop-table \
    ${DB_NAME} | gzip > "${BACKUP_PATH}/db/db_${TIMESTAMP}.sql.gz"

echo "✅ Database backup completed: db_${TIMESTAMP}.sql.gz"

# WordPress Files Backup
echo "📁 Backing up WordPress files..."

# Create a tar archive of wp-content (themes, plugins, uploads)
tar -czf "${BACKUP_PATH}/files/wp-content_${TIMESTAMP}.tar.gz" \
    -C . \
    wp-content \
    --exclude='wp-content/cache' \
    --exclude='wp-content/backup*' \
    --exclude='*.log'

echo "✅ Files backup completed: wp-content_${TIMESTAMP}.tar.gz"

# Backup Docker configuration files
echo "🐳 Backing up configuration files..."
tar -czf "${BACKUP_PATH}/files/config_${TIMESTAMP}.tar.gz" \
    docker-compose.yml \
    .env \
    uploads.ini \
    woocommerce-config.php \
    setup-woocommerce.sh \
    $(find scripts -name "*.sh" 2>/dev/null || true)

echo "✅ Configuration backup completed: config_${TIMESTAMP}.tar.gz"

# Create a full backup archive
echo "📦 Creating full backup archive..."
cd "${BACKUP_PATH}"
tar -czf "full_backup_${TIMESTAMP}.tar.gz" \
    "db/db_${TIMESTAMP}.sql.gz" \
    "files/wp-content_${TIMESTAMP}.tar.gz" \
    "files/config_${TIMESTAMP}.tar.gz"
cd - > /dev/null

echo "✅ Full backup completed: ${BACKUP_PATH}/full_backup_${TIMESTAMP}.tar.gz"

# Clean up old backups
echo "🧹 Cleaning up old backups (older than ${BACKUP_RETENTION_DAYS} days)..."
find "${BACKUP_PATH}" -name "*.gz" -type f -mtime +${BACKUP_RETENTION_DAYS} -delete

# Generate backup info file
cat > "${BACKUP_PATH}/backup_${TIMESTAMP}.info" <<EOF
Backup Information
==================
Date: $(date)
Timestamp: ${TIMESTAMP}
App Name: ${APP_NAME}
Database: ${DB_NAME}
Files Included:
- Database dump: db_${TIMESTAMP}.sql.gz
- WordPress content: wp-content_${TIMESTAMP}.tar.gz
- Configuration: config_${TIMESTAMP}.tar.gz
- Full backup: full_backup_${TIMESTAMP}.tar.gz

Restore Instructions:
1. Use restore.sh script with the timestamp: ./scripts/restore.sh ${TIMESTAMP}
2. Or manually restore using the individual files

Environment:
- WordPress URL: ${APP_URL}
- Database Host: ${DB_HOST}
- Database Name: ${DB_NAME}
EOF

echo "📄 Backup info saved to: ${BACKUP_PATH}/backup_${TIMESTAMP}.info"
echo "✨ Backup process completed successfully!"
echo ""
echo "To restore this backup, run:"
echo "./scripts/restore.sh ${TIMESTAMP}"