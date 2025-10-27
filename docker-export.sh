#!/bin/bash

# Pet Food E-commerce Platform - Docker Export Script
# This script builds and exports the Docker image for deployment on other machines

set -euo pipefail

# Configuration
IMAGE_NAME="pet-food-store"
IMAGE_TAG="latest"
EXPORT_DIR="./docker-export"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

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

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    log_success "Docker is running"
}

# Create export directory
create_export_dir() {
    if [ -d "$EXPORT_DIR" ]; then
        log_warning "Export directory exists. Creating backup..."
        mv "$EXPORT_DIR" "${EXPORT_DIR}_backup_${TIMESTAMP}"
    fi
    
    mkdir -p "$EXPORT_DIR"
    mkdir -p "$BACKUP_DIR"
    log_success "Created export directory: $EXPORT_DIR"
}

# Build the Docker image
build_image() {
    log_info "Building Docker image..."
    
    # Build the image
    if docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .; then
        log_success "Docker image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
}

# Export the Docker image
export_image() {
    log_info "Exporting Docker image..."
    
    local export_file="${EXPORT_DIR}/${IMAGE_NAME}_${IMAGE_TAG}_${TIMESTAMP}.tar"
    
    if docker save -o "$export_file" "${IMAGE_NAME}:${IMAGE_TAG}"; then
        log_success "Docker image exported to: $export_file"
        
        # Compress the image
        log_info "Compressing exported image..."
        if gzip "$export_file"; then
            log_success "Image compressed: ${export_file}.gz"
            echo "Exported file size: $(du -h "${export_file}.gz" | cut -f1)"
        else
            log_warning "Failed to compress image, but export was successful"
        fi
    else
        log_error "Failed to export Docker image"
        exit 1
    fi
}

# Export database if containers are running
export_database() {
    log_info "Checking for running database container..."
    
    if docker ps --format "table {{.Names}}" | grep -q "pet-food-store_db"; then
        log_info "Exporting database..."
        
        local db_export_file="${BACKUP_DIR}/database_${TIMESTAMP}.sql"
        
        if docker exec pet-food-store_db mysqldump -u wordpress -ppetshop123 wordpress > "$db_export_file"; then
            log_success "Database exported to: $db_export_file"
            
            # Copy to export directory
            cp "$db_export_file" "${EXPORT_DIR}/"
            log_success "Database backup copied to export directory"
        else
            log_warning "Failed to export database. The image will work but without existing data."
        fi
    else
        log_warning "Database container not running. Skipping database export."
        log_info "To export database later, run: ./scripts/backup.sh"
    fi
}

# Copy configuration files
copy_configs() {
    log_info "Copying configuration files..."
    
    # Copy essential files
    cp docker-compose.yml "$EXPORT_DIR/"
    cp docker-import.sh "$EXPORT_DIR/"
    
    # Create a simple README for the export
    cat > "${EXPORT_DIR}/README.txt" << EOF
Pet Food E-commerce Platform - Docker Export Package
Generated on: $(date)

Contents:
- ${IMAGE_NAME}_${IMAGE_TAG}_${TIMESTAMP}.tar.gz: Docker image
- docker-compose.yml: Docker Compose configuration
- docker-import.sh: Import script for other machines
- database_${TIMESTAMP}.sql: Database backup (if available)

To import on another machine:
1. Install Docker and Docker Compose
2. Run: chmod +x docker-import.sh
3. Run: ./docker-import.sh
4. Access the site at http://localhost:8000

For more information, see the main project documentation.
EOF
    
    log_success "Configuration files and documentation copied"
}

# Create import script
create_import_script() {
    log_info "Creating import script..."
    
    # The import script is already created separately
    chmod +x docker-import.sh
    log_success "Import script is ready"
}

# Display summary
display_summary() {
    log_success "Export completed successfully!"
    echo ""
    echo "Export package location: $EXPORT_DIR"
    echo "Contents:"
    ls -la "$EXPORT_DIR"
    echo ""
    echo "To deploy on another machine:"
    echo "1. Copy the entire '$EXPORT_DIR' folder to the target machine"
    echo "2. Run: cd $EXPORT_DIR && ./docker-import.sh"
    echo ""
    echo "The exported package includes:"
    echo "- Complete Docker image with WordPress, WooCommerce, and custom theme"
    echo "- Database backup (if available)"
    echo "- Configuration files"
    echo "- Import script for easy deployment"
}

# Main execution
main() {
    echo "Pet Food E-commerce Platform - Docker Export"
    echo "============================================="
    echo ""
    
    check_docker
    create_export_dir
    build_image
    export_image
    export_database
    copy_configs
    create_import_script
    display_summary
}

# Run main function
main "$@"