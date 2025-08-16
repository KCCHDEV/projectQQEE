#!/bin/bash

# Development Workflow Script for External UI/Script Editing
# This script helps you develop outside WordPress and deploy only what you need

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

# Create development workspace
create_dev_workspace() {
    print_info "Creating development workspace..."
    
    # Create development directories
    mkdir -p dev-workspace/{themes,plugins,scripts,assets}
    mkdir -p dev-workspace/themes/custom
    mkdir -p dev-workspace/assets/{css,js,images}
    mkdir -p dev-workspace/scripts/{deployment,utilities}
    
    # Create a sample custom theme structure if it doesn't exist
    if [[ ! -d "dev-workspace/themes/custom/my-theme" ]]; then
        mkdir -p dev-workspace/themes/custom/my-theme/{assets/{css,js,images},templates,includes}
        
        # Create basic theme files
        cat > dev-workspace/themes/custom/my-theme/style.css << 'EOF'
/*
Theme Name: My Custom Theme
Description: Custom theme for external development
Version: 1.0.0
Author: Your Name
*/

/* Add your custom CSS here */
body {
    font-family: Arial, sans-serif;
}
EOF

        cat > dev-workspace/themes/custom/my-theme/index.php << 'EOF'
<?php
/**
 * Custom Theme Index Template
 */
get_header(); ?>

<div class="main-content">
    <h1>Custom Theme</h1>
    <p>This is your custom theme developed externally.</p>
</div>

<?php get_footer(); ?>
EOF

        cat > dev-workspace/themes/custom/my-theme/functions.php << 'EOF'
<?php
/**
 * Theme Functions
 */

// Enqueue styles and scripts
function my_theme_scripts() {
    wp_enqueue_style('my-theme-style', get_stylesheet_uri());
    wp_enqueue_script('my-theme-script', get_template_directory_uri() . '/assets/js/main.js', array('jquery'), '1.0.0', true);
}
add_action('wp_enqueue_scripts', 'my_theme_scripts');
EOF

        cat > dev-workspace/themes/custom/my-theme/assets/js/main.js << 'EOF'
// Custom JavaScript for your theme
document.addEventListener('DOMContentLoaded', function() {
    console.log('Custom theme loaded!');
});
EOF
    fi
    
    # Create development configuration
    cat > dev-workspace/dev-config.json << EOF
{
    "projectName": "${APP_NAME}",
    "wordpressUrl": "${APP_URL}",
    "developmentMode": true,
    "excludeUploads": true,
    "syncPaths": {
        "themes": "wp-content/themes",
        "plugins": "wp-content/plugins",
        "assets": "wp-content/uploads/dev-assets"
    },
    "buildCommands": {
        "css": "npm run build:css",
        "js": "npm run build:js"
    }
}
EOF
    
    print_status "Development workspace created at dev-workspace/"
}

# Sync development files to WordPress
sync_to_wp() {
    local sync_type=${1:-all}
    
    print_info "Syncing development files to WordPress..."
    
    case $sync_type in
        "themes")
            print_info "Syncing themes..."
            if [[ -d "dev-workspace/themes" ]]; then
                rsync -av --delete dev-workspace/themes/ wp-content/themes/
                print_status "Themes synced"
            fi
            ;;
        "plugins")
            print_info "Syncing plugins..."
            if [[ -d "dev-workspace/plugins" ]]; then
                rsync -av dev-workspace/plugins/ wp-content/plugins/
                print_status "Plugins synced"
            fi
            ;;
        "assets")
            print_info "Syncing assets..."
            if [[ -d "dev-workspace/assets" ]]; then
                mkdir -p wp-content/uploads/dev-assets
                rsync -av dev-workspace/assets/ wp-content/uploads/dev-assets/
                print_status "Assets synced"
            fi
            ;;
        "all")
            sync_to_wp "themes"
            sync_to_wp "plugins"
            sync_to_wp "assets"
            ;;
        *)
            print_error "Unknown sync type: $sync_type"
            print_info "Available types: themes, plugins, assets, all"
            exit 1
            ;;
    esac
}

# Deploy only specific changes to WordPress container
deploy_changes() {
    local deploy_type=${1:-themes}
    
    print_info "Deploying $deploy_type to WordPress container..."
    
    # Ensure WordPress container is running
    if ! docker ps | grep -q "${APP_NAME}_wordpress"; then
        print_error "WordPress container is not running!"
        print_info "Start it with: docker-compose up -d"
        exit 1
    fi
    
    case $deploy_type in
        "themes")
            if [[ -d "dev-workspace/themes" ]]; then
                # Copy themes to container
                docker exec ${APP_NAME}_wordpress mkdir -p /var/www/html/wp-content/themes
                docker cp dev-workspace/themes/. ${APP_NAME}_wordpress:/var/www/html/wp-content/themes/
                docker exec ${APP_NAME}_wordpress chown -R www-data:www-data /var/www/html/wp-content/themes
                print_status "Themes deployed to container"
            fi
            ;;
        "plugins")
            if [[ -d "dev-workspace/plugins" ]]; then
                docker cp dev-workspace/plugins/. ${APP_NAME}_wordpress:/var/www/html/wp-content/plugins/
                docker exec ${APP_NAME}_wordpress chown -R www-data:www-data /var/www/html/wp-content/plugins
                print_status "Plugins deployed to container"
            fi
            ;;
        "assets")
            if [[ -d "dev-workspace/assets" ]]; then
                docker exec ${APP_NAME}_wordpress mkdir -p /var/www/html/wp-content/uploads/dev-assets
                docker cp dev-workspace/assets/. ${APP_NAME}_wordpress:/var/www/html/wp-content/uploads/dev-assets/
                docker exec ${APP_NAME}_wordpress chown -R www-data:www-data /var/www/html/wp-content/uploads/dev-assets
                print_status "Assets deployed to container"
            fi
            ;;
        "all")
            deploy_changes "themes"
            deploy_changes "plugins"
            deploy_changes "assets"
            ;;
        *)
            print_error "Unknown deploy type: $deploy_type"
            print_info "Available types: themes, plugins, assets, all"
            exit 1
            ;;
    esac
}

# Watch for changes and auto-sync
watch_changes() {
    print_info "Starting file watcher for automatic syncing..."
    print_warning "Press Ctrl+C to stop watching"
    
    if ! command -v inotifywait &> /dev/null; then
        print_warning "inotifywait not found. Installing inotify-tools..."
        # Try to install inotify-tools
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y inotify-tools
        elif command -v yum &> /dev/null; then
            sudo yum install -y inotify-tools
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y inotify-tools
        else
            print_error "Could not install inotify-tools. Please install it manually."
            exit 1
        fi
    fi
    
    while inotifywait -r -e modify,create,delete dev-workspace/; do
        echo "$(date): Changes detected, syncing..."
        sync_to_wp "all"
        deploy_changes "all"
    done
}

# Extract theme from WordPress for editing
extract_theme() {
    local theme_name=${1}
    
    if [[ -z "$theme_name" ]]; then
        print_error "Theme name required!"
        print_info "Usage: $0 extract-theme <theme-name>"
        exit 1
    fi
    
    print_info "Extracting theme '$theme_name' for external editing..."
    
    if [[ -d "wp-content/themes/$theme_name" ]]; then
        mkdir -p dev-workspace/themes/extracted
        cp -r wp-content/themes/$theme_name dev-workspace/themes/extracted/
        print_status "Theme '$theme_name' extracted to dev-workspace/themes/extracted/$theme_name"
        print_info "You can now edit it externally and use 'deploy-changes themes' to update"
    else
        print_error "Theme '$theme_name' not found in wp-content/themes/"
    fi
}

# Build assets (if build tools are available)
build_assets() {
    print_info "Building assets..."
    
    for theme_dir in dev-workspace/themes/*/; do
        if [[ -f "$theme_dir/package.json" ]]; then
            print_info "Building assets for $(basename "$theme_dir")..."
            (cd "$theme_dir" && npm install && npm run build 2>/dev/null || true)
        fi
    done
    
    print_status "Asset building completed"
}

# Show development status
show_dev_status() {
    echo ""
    echo "🚀 Development Environment Status"
    echo "================================="
    echo ""
    
    # Check if development workspace exists
    if [[ -d "dev-workspace" ]]; then
        print_status "Development workspace: Ready"
        echo "   📁 Themes: $(find dev-workspace/themes -name "*.php" | wc -l) PHP files"
        echo "   📁 Assets: $(find dev-workspace/assets -type f | wc -l) asset files"
        echo "   📁 Plugins: $(find dev-workspace/plugins -name "*.php" 2>/dev/null | wc -l) plugin files"
    else
        print_warning "Development workspace: Not created"
        print_info "Run: $0 init"
    fi
    
    # Check WordPress container status
    if docker ps | grep -q "${APP_NAME}_wordpress"; then
        print_status "WordPress container: Running"
        echo "   🌐 URL: ${APP_URL}"
    else
        print_warning "WordPress container: Not running"
    fi
    
    echo ""
    echo "📝 Available Commands:"
    echo "   $0 init                    - Create development workspace"
    echo "   $0 sync [themes|plugins|assets|all] - Sync files to WordPress"
    echo "   $0 deploy [themes|plugins|assets|all] - Deploy to container"
    echo "   $0 watch                   - Watch for changes and auto-sync"
    echo "   $0 extract-theme <name>    - Extract theme for editing"
    echo "   $0 build                   - Build assets"
    echo "   $0 status                  - Show this status"
    echo ""
}

# Main command handler
case "${1:-status}" in
    "init")
        create_dev_workspace
        ;;
    "sync")
        sync_to_wp "${2:-all}"
        ;;
    "deploy"|"deploy-changes")
        deploy_changes "${2:-themes}"
        ;;
    "watch")
        watch_changes
        ;;
    "extract-theme")
        extract_theme "$2"
        ;;
    "build")
        build_assets
        ;;
    "status")
        show_dev_status
        ;;
    "--help"|"-h")
        echo "Development Workflow Script"
        echo ""
        echo "This script helps you develop WordPress themes/plugins externally"
        echo "and deploy only the changes you want, excluding WordPress content uploads."
        echo ""
        show_dev_status
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_dev_status
        ;;
esac