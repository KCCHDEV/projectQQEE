#!/bin/bash

# Migration Helper Script for WordPress/WooCommerce
# This script helps migrate the application to a new host

set -e

echo "🚀 WordPress/WooCommerce Migration Helper"
echo "========================================"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Function to display menu
show_menu() {
    echo "What would you like to do?"
    echo "1) Prepare for migration (create full backup)"
    echo "2) Deploy to new host (restore from backup)"
    echo "3) Check migration requirements"
    echo "4) Export migration package"
    echo "5) Import migration package"
    echo "6) Exit"
    echo ""
}

# Function to check requirements
check_requirements() {
    echo "🔍 Checking migration requirements..."
    echo ""
    
    # Check Docker
    if command -v docker &> /dev/null; then
        echo "✅ Docker installed: $(docker --version)"
    else
        echo "❌ Docker not installed"
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        echo "✅ Docker Compose installed: $(docker-compose --version)"
    else
        echo "❌ Docker Compose not installed"
    fi
    
    # Check disk space
    echo "💾 Disk space:"
    df -h . | tail -1
    
    # Check current containers
    echo ""
    echo "🐳 Current containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
}

# Function to prepare for migration
prepare_migration() {
    echo "📦 Preparing for migration..."
    echo ""
    
    # Run backup script
    if [ -f "./scripts/backup.sh" ]; then
        ./scripts/backup.sh
    else
        echo "❌ Backup script not found!"
        exit 1
    fi
    
    echo ""
    echo "✅ Migration preparation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Copy the entire project directory to your new host"
    echo "2. Run './scripts/migrate.sh' and select option 2 on the new host"
}

# Function to export migration package
export_package() {
    echo "📦 Creating migration package..."
    
    # Create temporary directory
    TEMP_DIR="migration_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$TEMP_DIR"
    
    # Run backup first
    ./scripts/backup.sh
    
    # Get latest backup
    LATEST_BACKUP=$(ls -t backups/full_backup_*.tar.gz | head -1)
    
    if [ -z "$LATEST_BACKUP" ]; then
        echo "❌ No backup found!"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Copy essential files
    cp "$LATEST_BACKUP" "$TEMP_DIR/"
    cp docker-compose.yml "$TEMP_DIR/"
    cp .env.example "$TEMP_DIR/"
    cp -r scripts "$TEMP_DIR/"
    cp uploads.ini "$TEMP_DIR/"
    cp woocommerce-config.php "$TEMP_DIR/"
    
    # Create deployment script
    cat > "$TEMP_DIR/deploy.sh" <<'EOF'
#!/bin/bash
echo "🚀 Deploying WordPress/WooCommerce..."

# Create .env from example
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Please edit .env file with your host-specific settings"
    echo "Press Enter when ready..."
    read
fi

# Extract backup
echo "📦 Extracting backup..."
mkdir -p backups
tar -xzf full_backup_*.tar.gz -C backups/

# Make scripts executable
chmod +x scripts/*.sh

# Start deployment
docker-compose up -d

echo "✅ Deployment started!"
echo "Run './scripts/restore.sh <timestamp>' to restore data"
EOF
    
    chmod +x "$TEMP_DIR/deploy.sh"
    
    # Create README
    cat > "$TEMP_DIR/README.md" <<EOF
# WordPress/WooCommerce Migration Package

This package contains everything needed to deploy your WordPress/WooCommerce application to a new host.

## Contents
- Full backup (database + files)
- Docker configuration
- Deployment scripts
- Environment configuration template

## Deployment Steps

1. **Extract this package** on your new host
2. **Run the deployment script**: \`./deploy.sh\`
3. **Edit the .env file** with your host-specific settings
4. **Restore the backup** using the timestamp from the backup file

## Requirements
- Docker
- Docker Compose
- At least 2GB free disk space
- Ports: ${WORDPRESS_PORT}, ${PHPMYADMIN_PORT}, ${REDIS_PORT}

## Support
For issues, check the logs:
\`\`\`bash
docker-compose logs -f
\`\`\`
EOF
    
    # Create the package
    PACKAGE_NAME="migration_package_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$PACKAGE_NAME" "$TEMP_DIR"
    rm -rf "$TEMP_DIR"
    
    echo "✅ Migration package created: $PACKAGE_NAME"
    echo ""
    echo "📋 Package size: $(du -h $PACKAGE_NAME | cut -f1)"
    echo ""
    echo "Transfer this file to your new host and extract it to deploy."
}

# Function to deploy to new host
deploy_new_host() {
    echo "🚀 Deploying to new host..."
    echo ""
    
    # Check if .env exists
    if [ ! -f .env ]; then
        echo "⚠️  No .env file found. Creating from template..."
        cp .env.example .env
        echo ""
        echo "Please edit the .env file with your new host settings:"
        echo "- APP_URL (your new domain)"
        echo "- Database passwords"
        echo "- Port numbers (if defaults are taken)"
        echo "- Email settings"
        echo ""
        read -p "Press Enter when you've updated .env file..."
    fi
    
    # Start containers
    echo "🐳 Starting Docker containers..."
    docker-compose up -d
    
    # Wait for services
    echo "⏳ Waiting for services to start..."
    sleep 20
    
    # Check if there are backups to restore
    if ls backups/*.info &> /dev/null; then
        echo ""
        echo "📦 Available backups:"
        ls -1 backups/*.info | sed 's/.*backup_//;s/.info//'
        echo ""
        read -p "Enter backup timestamp to restore (or press Enter to skip): " timestamp
        
        if [ ! -z "$timestamp" ]; then
            ./scripts/restore.sh "$timestamp"
        fi
    else
        echo "ℹ️  No backups found. Starting with fresh installation."
    fi
    
    echo ""
    echo "✅ Deployment complete!"
    echo ""
    echo "🌐 Access your site at: ${APP_URL}"
    echo "📊 phpMyAdmin: http://localhost:${PHPMYADMIN_PORT}"
    echo ""
}

# Main menu loop
while true; do
    show_menu
    read -p "Select an option (1-6): " choice
    echo ""
    
    case $choice in
        1)
            prepare_migration
            ;;
        2)
            deploy_new_host
            ;;
        3)
            check_requirements
            ;;
        4)
            export_package
            ;;
        5)
            echo "📦 To import a migration package:"
            echo "1. Extract the migration package tar.gz file"
            echo "2. Run ./deploy.sh from the extracted directory"
            echo ""
            ;;
        6)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please try again."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    echo ""
done