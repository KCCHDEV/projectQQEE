#!/bin/bash

# Pet Food E-commerce Platform - Docker Import Script
# This script imports and runs the exported Docker image on a new machine

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check system requirements
check_requirements() {
    log_info "Checking system requirements..."
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    log_success "All requirements met"
}

# Find and import Docker image
import_image() {
    log_info "Looking for Docker image file..."
    
    # Find the image file
    local image_file=""
    for file in *.tar.gz *.tar; do
        if [[ -f "$file" && "$file" == *"pet-food-store"* ]]; then
            image_file="$file"
            break
        fi
    done
    
    if [ -z "$image_file" ]; then
        log_error "No Docker image file found. Expected file like 'pet-food-store_*.tar.gz'"
        log_info "Please ensure you copied the complete export package."
        exit 1
    fi
    
    log_info "Found image file: $image_file"
    
    # Import the image
    log_info "Importing Docker image (this may take a few minutes)..."
    
    if [[ "$image_file" == *.gz ]]; then
        # Decompress and load
        if gunzip -c "$image_file" | docker load; then
            log_success "Docker image imported successfully"
        else
            log_error "Failed to import Docker image"
            exit 1
        fi
    else
        # Load directly
        if docker load -i "$image_file"; then
            log_success "Docker image imported successfully"
        else
            log_error "Failed to import Docker image"
            exit 1
        fi
    fi
}

# Setup environment
setup_environment() {
    log_info "Setting up environment..."
    
    # Create necessary directories
    mkdir -p backups
    mkdir -p logs
    
    # Set permissions for current user
    if [ "$(id -u)" != "0" ]; then
        # Not root, create directories with current user permissions
        log_info "Setting up directories for current user"
    fi
    
    log_success "Environment setup completed"
}

# Import database if available
import_database() {
    log_info "Checking for database backup..."
    
    local db_file=""
    for file in *.sql database_*.sql; do
        if [[ -f "$file" ]]; then
            db_file="$file"
            break
        fi
    done
    
    if [ -n "$db_file" ]; then
        log_info "Found database backup: $db_file"
        log_info "Database will be imported after containers start"
        
        # Move database file to backups directory for later import
        cp "$db_file" "./backups/"
        echo "$db_file" > "./backups/.import_on_start"
        log_success "Database backup prepared for import"
    else
        log_info "No database backup found. Starting with fresh installation."
    fi
}

# Start containers
start_containers() {
    log_info "Starting Docker containers..."
    
    # Stop any existing containers with the same names
    docker-compose down 2>/dev/null || true
    
    # Start the containers
    if docker-compose up -d; then
        log_success "Containers started successfully"
    else
        log_error "Failed to start containers"
        exit 1
    fi
    
    # Wait for containers to be healthy
    log_info "Waiting for containers to be ready..."
    sleep 10
    
    # Check container status
    if docker-compose ps | grep -q "Up"; then
        log_success "Containers are running"
    else
        log_warning "Some containers may not be running properly"
        docker-compose ps
    fi
}

# Import database after containers are running
import_database_post_start() {
    if [ -f "./backups/.import_on_start" ]; then
        local db_file=$(cat "./backups/.import_on_start")
        log_info "Importing database backup..."
        
        # Wait for database to be ready
        sleep 15
        
        if docker exec pet-food-store_db mysql -u wordpress -ppetshop123 wordpress < "./backups/$db_file"; then
            log_success "Database imported successfully"
            rm "./backups/.import_on_start"
        else
            log_warning "Failed to import database. You can import it manually later."
        fi
    fi
}

# Display access information
display_access_info() {
    log_success "Pet Food E-commerce Platform is now running!"
    echo ""
    echo "Access URLs:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌐 Website:      http://localhost:8000"
    echo "👤 Admin Panel:  http://localhost:8000/wp-admin"
    echo "🗄️  phpMyAdmin:  http://localhost:8080"
    echo "📧 MailHog:      http://localhost:8025"
    echo ""
    echo "Default Credentials:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "WordPress Admin:"
    echo "  Username: admin"
    echo "  Password: admin123"
    echo ""
    echo "Database:"
    echo "  Host: localhost:3306"
    echo "  Username: wordpress"
    echo "  Password: petshop123"
    echo "  Database: wordpress"
    echo ""
    echo "Useful Commands:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Stop:     docker-compose down"
    echo "Start:    docker-compose up -d"
    echo "Logs:     docker-compose logs -f"
    echo "Restart:  docker-compose restart"
    echo ""
    echo "🎉 Installation completed successfully!"
}

# Main execution
main() {
    echo "Pet Food E-commerce Platform - Docker Import"
    echo "============================================="
    echo ""
    
    check_requirements
    import_image
    setup_environment
    import_database
    start_containers
    import_database_post_start
    display_access_info
}

# Handle cleanup on exit
cleanup() {
    if [ $? -ne 0 ]; then
        log_error "Import failed. Cleaning up..."
        docker-compose down 2>/dev/null || true
    fi
}

trap cleanup EXIT

# Run main function
main "$@"