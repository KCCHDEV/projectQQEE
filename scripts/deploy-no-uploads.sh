#!/bin/bash

# Deployment Script for Code-Only Updates (No WordPress Content Uploads)
# This script deploys only your custom code/themes/plugins without uploading WP content

set -e

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

echo "🚀 Code-Only Deployment (No WP Content Uploads)"
echo "================================================"
echo ""

# Load environment variables
if [[ -f .env ]]; then
    set -a
    source .env
    set +a
    APP_NAME=${APP_NAME:-pet-food-store}
else
    print_error ".env file not found!"
    exit 1
fi

# Function to create deployment package without WP content
create_code_package() {
    local package_name="code-deploy-$(date +%Y%m%d-%H%M%S)"
    local temp_dir="/tmp/$package_name"
    
    print_info "Creating code-only deployment package..."
    
    # Create temporary directory
    mkdir -p "$temp_dir"
    
    # Copy only code files, exclude WP content uploads
    print_info "Copying code files (excluding uploads)..."
    
    # Copy scripts
    if [[ -d "scripts" ]]; then
        cp -r scripts "$temp_dir/"
        print_status "Scripts copied"
    fi
    
    # Copy themes (but exclude uploads within themes)
    if [[ -d "wp-content/themes" ]]; then
        mkdir -p "$temp_dir/wp-content/themes"
        find wp-content/themes -type f \( -name "*.php" -o -name "*.css" -o -name "*.js" -o -name "*.json" -o -name "*.txt" -o -name "*.md" \) \
            -not -path "*/node_modules/*" \
            -not -path "*/vendor/*" \
            -not -path "*/cache/*" \
            -not -path "*/logs/*" \
            -exec cp --parents {} "$temp_dir/" \;
        print_status "Theme code files copied"
    fi
    
    # Copy plugins (but exclude cache/logs)
    if [[ -d "wp-content/plugins" ]]; then
        mkdir -p "$temp_dir/wp-content/plugins"
        find wp-content/plugins -type f \( -name "*.php" -o -name "*.css" -o -name "*.js" -o -name "*.json" -o -name "*.txt" -o -name "*.md" \) \
            -not -path "*/cache/*" \
            -not -path "*/logs/*" \
            -not -path "*/tmp/*" \
            -exec cp --parents {} "$temp_dir/" \;
        print_status "Plugin code files copied"
    fi
    
    # Copy development workspace if it exists
    if [[ -d "dev-workspace" ]]; then
        cp -r dev-workspace "$temp_dir/"
        print_status "Development workspace copied"
    fi
    
    # Copy configuration files
    for file in docker-compose.yml .env.example uploads.ini woocommerce-config.php; do
        if [[ -f "$file" ]]; then
            cp "$file" "$temp_dir/"
        fi
    done
    print_status "Configuration files copied"
    
    # Create deployment info
    cat > "$temp_dir/DEPLOYMENT_INFO.txt" << EOF
Code-Only Deployment Package
Created: $(date)
Package: $package_name
Type: Code/Scripts/Themes/Plugins only (NO uploads)

Contents:
- Scripts and utilities
- Theme code files (.php, .css, .js, .json)
- Plugin code files (.php, .css, .js, .json)
- Configuration files
- Development workspace (if exists)

Excluded:
- wp-content/uploads/
- Cache files
- Log files
- Temporary files
- Node modules
- Vendor directories
- Database dumps

To deploy this package:
1. Extract on target server
2. Run: ./scripts/deploy-no-uploads.sh apply
3. Restart containers if needed

EOF
    
    # Create tarball
    cd /tmp
    tar -czf "${package_name}.tar.gz" "$package_name"
    mv "${package_name}.tar.gz" "$OLDPWD/"
    rm -rf "$temp_dir"
    
    print_status "Code deployment package created: ${package_name}.tar.gz"
    echo ""
    echo "📦 Package contains:"
    echo "   - Scripts and utilities"
    echo "   - Theme code files"
    echo "   - Plugin code files"
    echo "   - Configuration files"
    echo "   - Development workspace"
    echo ""
    echo "🚫 Package excludes:"
    echo "   - WordPress uploads"
    echo "   - Cache files"
    echo "   - Database content"
    echo "   - Temporary files"
}

# Function to apply code deployment (extract and deploy)
apply_code_deployment() {
    local package_file=${1}
    
    if [[ -z "$package_file" ]]; then
        # Find the latest code deployment package
        package_file=$(ls -t code-deploy-*.tar.gz 2>/dev/null | head -1)
        if [[ -z "$package_file" ]]; then
            print_error "No deployment package found!"
            print_info "Usage: $0 apply <package-file>"
            exit 1
        fi
    fi
    
    if [[ ! -f "$package_file" ]]; then
        print_error "Package file not found: $package_file"
        exit 1
    fi
    
    print_info "Applying code deployment from: $package_file"
    
    # Create backup of current code
    backup_dir="backup-$(date +%Y%m%d-%H%M%S)"
    print_info "Creating backup of current code..."
    mkdir -p "$backup_dir"
    
    # Backup current themes and plugins
    if [[ -d "wp-content/themes" ]]; then
        cp -r wp-content/themes "$backup_dir/"
    fi
    if [[ -d "wp-content/plugins" ]]; then
        cp -r wp-content/plugins "$backup_dir/"
    fi
    if [[ -d "scripts" ]]; then
        cp -r scripts "$backup_dir/"
    fi
    
    print_status "Backup created in: $backup_dir"
    
    # Extract and apply
    print_info "Extracting deployment package..."
    tar -xzf "$package_file"
    
    package_dir=$(basename "$package_file" .tar.gz)
    
    if [[ ! -d "$package_dir" ]]; then
        print_error "Failed to extract package!"
        exit 1
    fi
    
    # Apply the code changes
    print_info "Applying code changes..."
    
    # Copy scripts
    if [[ -d "$package_dir/scripts" ]]; then
        cp -r "$package_dir/scripts/"* scripts/ 2>/dev/null || true
        chmod +x scripts/*.sh 2>/dev/null || true
        print_status "Scripts updated"
    fi
    
    # Copy themes
    if [[ -d "$package_dir/wp-content/themes" ]]; then
        mkdir -p wp-content/themes
        cp -r "$package_dir/wp-content/themes/"* wp-content/themes/ 2>/dev/null || true
        print_status "Themes updated"
    fi
    
    # Copy plugins
    if [[ -d "$package_dir/wp-content/plugins" ]]; then
        mkdir -p wp-content/plugins
        cp -r "$package_dir/wp-content/plugins/"* wp-content/plugins/ 2>/dev/null || true
        print_status "Plugins updated"
    fi
    
    # Copy development workspace
    if [[ -d "$package_dir/dev-workspace" ]]; then
        cp -r "$package_dir/dev-workspace" ./
        print_status "Development workspace updated"
    fi
    
    # Update configuration files (but don't overwrite .env)
    for file in docker-compose.yml uploads.ini woocommerce-config.php; do
        if [[ -f "$package_dir/$file" ]]; then
            cp "$package_dir/$file" ./
            print_status "$file updated"
        fi
    done
    
    # Clean up
    rm -rf "$package_dir"
    
    print_status "Code deployment applied successfully!"
    print_info "Backup available in: $backup_dir"
    
    # Restart containers if running
    if docker ps | grep -q "${APP_NAME}_wordpress"; then
        print_info "Restarting WordPress container to apply changes..."
        docker-compose restart wordpress
        print_status "Container restarted"
    fi
    
    echo ""
    echo "🎉 Deployment Complete!"
    echo "======================"
    echo "✅ Code files updated"
    echo "✅ Themes updated"
    echo "✅ Plugins updated"
    echo "🔄 Container restarted"
    echo "💾 Backup saved in: $backup_dir"
}

# Function to sync only code to remote server
sync_code_to_remote() {
    local remote_host=${1}
    local remote_path=${2:-"/var/www/html"}
    
    if [[ -z "$remote_host" ]]; then
        print_error "Remote host required!"
        print_info "Usage: $0 sync-remote <user@host> [remote-path]"
        exit 1
    fi
    
    print_info "Syncing code to remote server: $remote_host"
    
    # Sync themes (exclude uploads)
    if [[ -d "wp-content/themes" ]]; then
        print_info "Syncing themes..."
        rsync -av --delete \
            --include="*/" \
            --include="*.php" \
            --include="*.css" \
            --include="*.js" \
            --include="*.json" \
            --include="*.txt" \
            --include="*.md" \
            --exclude="*/node_modules/*" \
            --exclude="*/vendor/*" \
            --exclude="*/cache/*" \
            --exclude="*/logs/*" \
            wp-content/themes/ "${remote_host}:${remote_path}/wp-content/themes/"
        print_status "Themes synced"
    fi
    
    # Sync plugins (exclude cache/logs)
    if [[ -d "wp-content/plugins" ]]; then
        print_info "Syncing plugins..."
        rsync -av --delete \
            --include="*/" \
            --include="*.php" \
            --include="*.css" \
            --include="*.js" \
            --include="*.json" \
            --include="*.txt" \
            --include="*.md" \
            --exclude="*/cache/*" \
            --exclude="*/logs/*" \
            --exclude="*/tmp/*" \
            wp-content/plugins/ "${remote_host}:${remote_path}/wp-content/plugins/"
        print_status "Plugins synced"
    fi
    
    # Sync scripts
    if [[ -d "scripts" ]]; then
        rsync -av scripts/ "${remote_host}:${remote_path}/scripts/"
        ssh "$remote_host" "chmod +x ${remote_path}/scripts/*.sh"
        print_status "Scripts synced"
    fi
    
    print_status "Code sync to remote server completed!"
}

# Show deployment status
show_deployment_status() {
    echo ""
    echo "📋 Deployment Status"
    echo "==================="
    echo ""
    
    # Check for deployment packages
    packages=$(ls code-deploy-*.tar.gz 2>/dev/null | wc -l)
    if [[ $packages -gt 0 ]]; then
        print_status "Available deployment packages: $packages"
        echo "   Latest: $(ls -t code-deploy-*.tar.gz 2>/dev/null | head -1)"
    else
        print_warning "No deployment packages found"
    fi
    
    # Check for backups
    backups=$(ls -d backup-* 2>/dev/null | wc -l)
    if [[ $backups -gt 0 ]]; then
        print_status "Available backups: $backups"
        echo "   Latest: $(ls -td backup-* 2>/dev/null | head -1)"
    else
        print_warning "No backups found"
    fi
    
    # Check WordPress container
    if docker ps | grep -q "${APP_NAME}_wordpress"; then
        print_status "WordPress container: Running"
    else
        print_warning "WordPress container: Not running"
    fi
    
    echo ""
    echo "📝 Available Commands:"
    echo "   $0 package                    - Create code deployment package"
    echo "   $0 apply [package-file]       - Apply code deployment"
    echo "   $0 sync-remote <host> [path]  - Sync code to remote server"
    echo "   $0 status                     - Show deployment status"
    echo ""
}

# Main command handler
case "${1:-status}" in
    "package"|"create")
        create_code_package
        ;;
    "apply"|"deploy")
        apply_code_deployment "$2"
        ;;
    "sync-remote")
        sync_code_to_remote "$2" "$3"
        ;;
    "status")
        show_deployment_status
        ;;
    "--help"|"-h")
        echo "Code-Only Deployment Script"
        echo ""
        echo "This script creates and applies deployments that contain only"
        echo "your code files (themes, plugins, scripts) without WordPress"
        echo "content uploads, cache, or database content."
        echo ""
        show_deployment_status
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_deployment_status
        ;;
esac