#!/bin/bash

# Pet Food Shop - One-Click Deployment Script
# This script sets up the complete shop environment on any server

set -e

echo "🐾 Pet Food Shop - One-Click Deployment"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "This script should not be run as root for security reasons"
        echo "Please run as a regular user with sudo privileges"
        exit 1
    fi
}

# Install Docker if not present
install_docker() {
    if ! command -v docker &> /dev/null; then
        print_info "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        print_status "Docker installed successfully"
        print_warning "Please log out and log back in to apply Docker group membership"
        print_warning "Or run: newgrp docker"
    else
        print_status "Docker is already installed"
    fi
}

# Start Docker service
start_docker() {
    if ! docker info &> /dev/null; then
        print_info "Starting Docker service..."
        sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null || {
            print_info "Starting Docker daemon manually..."
            sudo dockerd > /tmp/docker.log 2>&1 &
            sleep 5
            
            # Set socket permissions
            sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
        }
        
        # Test Docker
        if docker info &> /dev/null; then
            print_status "Docker is running"
        else
            print_error "Failed to start Docker"
            exit 1
        fi
    else
        print_status "Docker is already running"
    fi
}

# Create project directory structure
setup_directories() {
    print_info "Setting up project directories..."
    
    # Create main directories
    mkdir -p backups/db
    mkdir -p backups/files
    mkdir -p wp-content/plugins
    mkdir -p wp-content/themes
    mkdir -p wp-content/uploads
    mkdir -p admin-dashboard
    
    print_status "Directories created"
}

# Set up environment configuration
setup_environment() {
    print_info "Setting up environment configuration..."
    
    if [[ ! -f .env ]]; then
        print_info "Creating .env file..."
        read -p "Enter your domain name (e.g., localhost, mydomain.com): " DOMAIN
        read -p "Enter WordPress port (default: 8000): " WP_PORT
        read -p "Enter phpMyAdmin port (default: 8080): " PMA_PORT
        
        # Set defaults
        WP_PORT=${WP_PORT:-8000}
        PMA_PORT=${PMA_PORT:-8080}
        
        # Generate secure passwords
        DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        DB_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        
        cat > .env << EOF
# WordPress/WooCommerce Environment Configuration
APP_NAME=pet-food-store
APP_URL=http://${DOMAIN}:${WP_PORT}
APP_ENV=production

# Port Configuration
WORDPRESS_PORT=${WP_PORT}
PHPMYADMIN_PORT=${PMA_PORT}
MAILHOG_SMTP_PORT=1025
MAILHOG_WEB_PORT=8025
REDIS_PORT=6379

# Database Configuration
DB_HOST=db
DB_PORT=3306
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=${DB_PASSWORD}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}

# WordPress Configuration
WORDPRESS_TABLE_PREFIX=wp_
WORDPRESS_DEBUG=false
WORDPRESS_DEBUG_LOG=false
WORDPRESS_DEBUG_DISPLAY=false

# Memory Limits
WP_MEMORY_LIMIT=256M
WP_MAX_MEMORY_LIMIT=512M

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# Email Configuration
SMTP_HOST=mailhog
SMTP_PORT=1025
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM_EMAIL=noreply@${DOMAIN}
SMTP_FROM_NAME=Pet Food Store

# Backup Configuration
BACKUP_RETENTION_DAYS=30
BACKUP_PATH=./backups

# File Upload Limits
UPLOAD_MAX_FILESIZE=64M
POST_MAX_SIZE=64M
MAX_EXECUTION_TIME=300
MAX_INPUT_TIME=300

# SSL Configuration
SSL_ENABLED=false
SSL_CERT_PATH=
SSL_KEY_PATH=

# WooCommerce Configuration
WC_CURRENCY=THB
WC_CURRENCY_POS=left
WC_PRICE_THOUSAND_SEP=,
WC_PRICE_DECIMAL_SEP=.
WC_PRICE_NUM_DECIMALS=2
EOF
        
        print_status "Environment configuration created"
        print_info "Database passwords have been automatically generated"
    else
        print_status "Using existing .env configuration"
    fi
}

# Make scripts executable
setup_permissions() {
    print_info "Setting up script permissions..."
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x *.sh 2>/dev/null || true
    print_status "Permissions set"
}

# Deploy containers
deploy_containers() {
    print_info "Deploying Docker containers..."
    
    # Pull images
    docker-compose pull
    
    # Start containers
    docker-compose up -d
    
    print_status "Containers deployed"
    
    # Wait for services
    print_info "Waiting for services to start (60 seconds)..."
    sleep 60
    
    # Check container status
    print_info "Container status:"
    docker-compose ps
}

# Install and configure WordPress/WooCommerce
setup_wordpress() {
    print_info "Setting up WordPress and WooCommerce..."
    
    # Source environment variables
    set -a
    source .env
    set +a
    
    # Check if WordPress is already installed
    if docker exec ${APP_NAME}_wordpress wp core is-installed --allow-root 2>/dev/null; then
        print_status "WordPress is already installed"
        return
    fi
    
    # Run the setup script
    if [[ -f setup-woocommerce.sh ]]; then
        ./setup-woocommerce.sh
    else
        print_warning "WooCommerce setup script not found, skipping automatic setup"
    fi
}

# Show completion information
show_completion_info() {
    # Source environment for variables
    set -a
    source .env 2>/dev/null || true
    set +a
    
    echo ""
    echo "🎉 Deployment Complete!"
    echo "======================="
    echo ""
    echo "🌐 Your pet food shop is ready at:"
    echo "   Main Site: ${APP_URL:-http://localhost:8000}"
    echo "   Admin: ${APP_URL:-http://localhost:8000}/wp-admin"
    echo ""
    echo "🛠️  Management Tools:"
    echo "   phpMyAdmin: http://localhost:${PHPMYADMIN_PORT:-8080}"
    echo "   MailHog: http://localhost:${MAILHOG_WEB_PORT:-8025}"
    echo "   Admin Dashboard: http://localhost:8888"
    echo ""
    echo "🔑 Database Information:"
    echo "   Database: ${DB_NAME:-wordpress}"
    echo "   Username: ${DB_USER:-wordpress}"
    echo "   Password: ${DB_PASSWORD:-[check .env file]}"
    echo ""
    echo "📝 Next Steps:"
    echo "   1. Visit your site to complete WordPress installation"
    echo "   2. Set up your admin user account"
    echo "   3. Configure WooCommerce settings"
    echo "   4. Add your products and customize the store"
    echo ""
    echo "🛡️  Security Notes:"
    echo "   - Change default passwords immediately"
    echo "   - Configure SSL for production use"
    echo "   - Set up regular backups"
    echo ""
    echo "📚 Useful Commands:"
    echo "   - Backup: ./scripts/backup.sh"
    echo "   - Restore: ./scripts/restore.sh <timestamp>"
    echo "   - Migrate: ./scripts/migrate.sh"
    echo "   - View logs: docker-compose logs -f"
    echo "   - Stop: docker-compose down"
    echo "   - Restart: docker-compose restart"
}

# Main deployment function
main() {
    check_root
    
    print_info "Starting Pet Food Shop deployment..."
    
    install_docker
    start_docker
    setup_directories
    setup_environment
    setup_permissions
    deploy_containers
    setup_wordpress
    show_completion_info
    
    print_status "Deployment completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    "--help"|"-h")
        echo "Pet Food Shop Deployment Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --docker-only  Only install and start Docker"
        echo "  --setup-only   Only run environment setup"
        echo "  --deploy-only  Only deploy containers (skip setup)"
        echo ""
        echo "Default: Run complete deployment"
        ;;
    "--docker-only")
        check_root
        install_docker
        start_docker
        ;;
    "--setup-only")
        setup_directories
        setup_environment
        setup_permissions
        ;;
    "--deploy-only")
        start_docker
        deploy_containers
        setup_wordpress
        show_completion_info
        ;;
    *)
        main
        ;;
esac