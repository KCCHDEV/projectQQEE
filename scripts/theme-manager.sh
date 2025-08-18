#!/bin/bash

# Pet Food E-commerce Platform - Theme Management Script
# Advanced theme management for WordPress/WooCommerce

set -euo pipefail

# Configuration
THEMES_DIR="/var/www/html/wp-content/themes"
BACKUP_DIR="/var/www/html/wp-content/themes-backup"
TEMP_DIR="/tmp/theme-manager"
CONTAINER_NAME="pet-food-store_wordpress"

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

# Show help
show_help() {
    echo "Pet Food E-commerce Platform - Theme Manager"
    echo "============================================="
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  list                    List all installed themes"
    echo "  active                  Show active theme"
    echo "  activate <theme>        Activate a theme"
    echo "  install <file>          Install theme from zip file"
    echo "  install-url <url>       Install theme from URL"
    echo "  backup <theme>          Backup a specific theme"
    echo "  backup-all              Backup all themes"
    echo "  restore <backup>        Restore theme from backup"
    echo "  delete <theme>          Delete a theme"
    echo "  update <theme>          Update a theme"
    echo "  customize <theme>       Open theme customizer"
    echo "  export <theme>          Export theme as zip"
    echo "  import <file>           Import theme from zip"
    echo "  gallery                 Show available pet store themes"
    echo "  install-gallery <id>    Install theme from gallery"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 activate petpaws"
    echo "  $0 install /path/to/theme.zip"
    echo "  $0 backup petpaws"
    echo "  $0 restore petpaws_2024-01-15.zip"
    echo ""
}

# Check if Docker container is running
check_container() {
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        log_error "WordPress container is not running. Please start the containers first."
        log_info "Run: docker-compose up -d"
        exit 1
    fi
}

# List all themes
list_themes() {
    log_info "Listing installed themes..."
    
    docker exec "$CONTAINER_NAME" wp theme list --allow-root --format=table
}

# Show active theme
show_active_theme() {
    log_info "Current active theme:"
    
    local active_theme=$(docker exec "$CONTAINER_NAME" wp theme list --status=active --allow-root --format=csv --fields=name | tail -n 1)
    echo "Active theme: $active_theme"
    
    # Show theme details
    docker exec "$CONTAINER_NAME" wp theme get "$active_theme" --allow-root
}

# Activate theme
activate_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        log_error "Theme name is required"
        echo "Usage: $0 activate <theme_name>"
        exit 1
    fi
    
    log_info "Activating theme: $theme_name"
    
    if docker exec "$CONTAINER_NAME" wp theme activate "$theme_name" --allow-root; then
        log_success "Theme '$theme_name' activated successfully"
        
        # Clear cache if available
        docker exec "$CONTAINER_NAME" wp cache flush --allow-root 2>/dev/null || true
    else
        log_error "Failed to activate theme '$theme_name'"
        exit 1
    fi
}

# Install theme from file
install_theme() {
    local theme_file="$1"
    
    if [ -z "$theme_file" ] || [ ! -f "$theme_file" ]; then
        log_error "Valid theme file is required"
        echo "Usage: $0 install <theme_file.zip>"
        exit 1
    fi
    
    log_info "Installing theme from: $theme_file"
    
    # Copy theme file to container
    local container_file="/tmp/theme.zip"
    docker cp "$theme_file" "$CONTAINER_NAME:$container_file"
    
    # Install theme
    if docker exec "$CONTAINER_NAME" wp theme install "$container_file" --allow-root; then
        log_success "Theme installed successfully"
        
        # Clean up
        docker exec "$CONTAINER_NAME" rm "$container_file"
    else
        log_error "Failed to install theme"
        docker exec "$CONTAINER_NAME" rm "$container_file"
        exit 1
    fi
}

# Install theme from URL
install_theme_url() {
    local theme_url="$1"
    
    if [ -z "$theme_url" ]; then
        log_error "Theme URL is required"
        echo "Usage: $0 install-url <theme_url>"
        exit 1
    fi
    
    log_info "Installing theme from URL: $theme_url"
    
    if docker exec "$CONTAINER_NAME" wp theme install "$theme_url" --allow-root; then
        log_success "Theme installed successfully from URL"
    else
        log_error "Failed to install theme from URL"
        exit 1
    fi
}

# Backup theme
backup_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        log_error "Theme name is required"
        echo "Usage: $0 backup <theme_name>"
        exit 1
    fi
    
    log_info "Backing up theme: $theme_name"
    
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local backup_file="$theme_name-$timestamp.zip"
    
    # Create backup directory in container
    docker exec "$CONTAINER_NAME" mkdir -p "$BACKUP_DIR"
    
    # Create zip backup
    if docker exec "$CONTAINER_NAME" bash -c "cd $THEMES_DIR && zip -r $BACKUP_DIR/$backup_file $theme_name"; then
        log_success "Theme backup created: $backup_file"
        
        # Copy backup to host
        mkdir -p "./backups/themes"
        docker cp "$CONTAINER_NAME:$BACKUP_DIR/$backup_file" "./backups/themes/"
        
        log_success "Backup copied to: ./backups/themes/$backup_file"
    else
        log_error "Failed to create theme backup"
        exit 1
    fi
}

# Backup all themes
backup_all_themes() {
    log_info "Backing up all themes..."
    
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local backup_file="all-themes-$timestamp.zip"
    
    # Create backup directory in container
    docker exec "$CONTAINER_NAME" mkdir -p "$BACKUP_DIR"
    
    # Create zip backup of all themes
    if docker exec "$CONTAINER_NAME" bash -c "cd $THEMES_DIR && zip -r $BACKUP_DIR/$backup_file ."; then
        log_success "All themes backup created: $backup_file"
        
        # Copy backup to host
        mkdir -p "./backups/themes"
        docker cp "$CONTAINER_NAME:$BACKUP_DIR/$backup_file" "./backups/themes/"
        
        log_success "Backup copied to: ./backups/themes/$backup_file"
    else
        log_error "Failed to create themes backup"
        exit 1
    fi
}

# Restore theme from backup
restore_theme() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        log_error "Backup file is required"
        echo "Usage: $0 restore <backup_file>"
        exit 1
    fi
    
    # Check if backup file exists locally
    if [ -f "./backups/themes/$backup_file" ]; then
        backup_file="./backups/themes/$backup_file"
    elif [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    log_info "Restoring theme from backup: $backup_file"
    
    # Copy backup to container
    local container_backup="/tmp/theme_backup.zip"
    docker cp "$backup_file" "$CONTAINER_NAME:$container_backup"
    
    # Extract backup
    if docker exec "$CONTAINER_NAME" bash -c "cd $THEMES_DIR && unzip -o $container_backup"; then
        log_success "Theme restored successfully"
        
        # Clean up
        docker exec "$CONTAINER_NAME" rm "$container_backup"
        
        # Clear cache
        docker exec "$CONTAINER_NAME" wp cache flush --allow-root 2>/dev/null || true
    else
        log_error "Failed to restore theme"
        docker exec "$CONTAINER_NAME" rm "$container_backup"
        exit 1
    fi
}

# Delete theme
delete_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        log_error "Theme name is required"
        echo "Usage: $0 delete <theme_name>"
        exit 1
    fi
    
    # Confirm deletion
    echo -n "Are you sure you want to delete theme '$theme_name'? (y/N): "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Theme deletion cancelled"
        exit 0
    fi
    
    log_info "Deleting theme: $theme_name"
    
    if docker exec "$CONTAINER_NAME" wp theme delete "$theme_name" --allow-root; then
        log_success "Theme '$theme_name' deleted successfully"
    else
        log_error "Failed to delete theme '$theme_name'"
        exit 1
    fi
}

# Update theme
update_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        log_error "Theme name is required"
        echo "Usage: $0 update <theme_name>"
        exit 1
    fi
    
    log_info "Updating theme: $theme_name"
    
    if docker exec "$CONTAINER_NAME" wp theme update "$theme_name" --allow-root; then
        log_success "Theme '$theme_name' updated successfully"
        
        # Clear cache
        docker exec "$CONTAINER_NAME" wp cache flush --allow-root 2>/dev/null || true
    else
        log_error "Failed to update theme '$theme_name'"
        exit 1
    fi
}

# Show pet store theme gallery
show_gallery() {
    log_info "Pet Store Theme Gallery"
    echo "======================="
    echo ""
    echo "1. Pet Paws Pro - Professional pet store theme"
    echo "2. Animal Care - Modern pet care services theme"
    echo "3. Pet Shop Express - Fast e-commerce theme"
    echo "4. Veterinary Clinic - Vet services theme"
    echo "5. Pet Grooming - Pet grooming services theme"
    echo ""
    echo "To install a theme from gallery:"
    echo "$0 install-gallery <theme_id>"
}

# Install theme from gallery
install_gallery_theme() {
    local theme_id="$1"
    
    if [ -z "$theme_id" ]; then
        log_error "Theme ID is required"
        echo "Usage: $0 install-gallery <theme_id>"
        show_gallery
        exit 1
    fi
    
    local theme_urls=(
        ""  # placeholder for index 0
        "https://github.com/pet-themes/pet-paws-pro/archive/main.zip"
        "https://github.com/pet-themes/animal-care/archive/main.zip"
        "https://github.com/pet-themes/pet-shop-express/archive/main.zip"
        "https://github.com/pet-themes/veterinary-clinic/archive/main.zip"
        "https://github.com/pet-themes/pet-grooming/archive/main.zip"
    )
    
    if [ "$theme_id" -lt 1 ] || [ "$theme_id" -gt 5 ]; then
        log_error "Invalid theme ID. Must be between 1 and 5."
        show_gallery
        exit 1
    fi
    
    local theme_url="${theme_urls[$theme_id]}"
    log_info "Installing gallery theme ID $theme_id from: $theme_url"
    
    install_theme_url "$theme_url"
}

# Export theme
export_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        log_error "Theme name is required"
        echo "Usage: $0 export <theme_name>"
        exit 1
    fi
    
    log_info "Exporting theme: $theme_name"
    
    local export_file="$theme_name-export-$(date +%Y%m%d).zip"
    local export_dir="./exports/themes"
    
    mkdir -p "$export_dir"
    
    # Create export zip
    if docker exec "$CONTAINER_NAME" bash -c "cd $THEMES_DIR && zip -r /tmp/$export_file $theme_name"; then
        # Copy export to host
        docker cp "$CONTAINER_NAME:/tmp/$export_file" "$export_dir/"
        
        # Clean up container
        docker exec "$CONTAINER_NAME" rm "/tmp/$export_file"
        
        log_success "Theme exported to: $export_dir/$export_file"
    else
        log_error "Failed to export theme"
        exit 1
    fi
}

# Main execution
main() {
    local command="${1:-help}"
    
    case "$command" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "list")
            check_container
            list_themes
            ;;
        "active")
            check_container
            show_active_theme
            ;;
        "activate")
            check_container
            activate_theme "${2:-}"
            ;;
        "install")
            check_container
            install_theme "${2:-}"
            ;;
        "install-url")
            check_container
            install_theme_url "${2:-}"
            ;;
        "backup")
            check_container
            backup_theme "${2:-}"
            ;;
        "backup-all")
            check_container
            backup_all_themes
            ;;
        "restore")
            check_container
            restore_theme "${2:-}"
            ;;
        "delete")
            check_container
            delete_theme "${2:-}"
            ;;
        "update")
            check_container
            update_theme "${2:-}"
            ;;
        "export")
            check_container
            export_theme "${2:-}"
            ;;
        "gallery")
            show_gallery
            ;;
        "install-gallery")
            check_container
            install_gallery_theme "${2:-}"
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"