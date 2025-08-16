#!/bin/bash

# Auto-sync script for WordPress wp-content development
# Monitors dev-workspace for changes and syncs to WordPress container

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

print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "🔄 WordPress Auto-Sync - Development Monitor"
    echo "=================================================="
    echo -e "${NC}"
}

# Load environment variables
load_env() {
    if [[ -f .env ]]; then
        set -a
        source .env
        set +a
        APP_NAME=${APP_NAME:-pet-food-store}
    else
        print_warning ".env file not found! Using default values."
        APP_NAME="pet-food-store"
    fi
}

# Check if required tools are installed
check_dependencies() {
    print_info "Checking dependencies..."
    
    # Check if inotifywait is available
    if ! command -v inotifywait &> /dev/null; then
        print_warning "inotifywait not found. Installing inotify-tools..."
        
        # Try to install inotify-tools
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y inotify-tools
        elif command -v yum &> /dev/null; then
            sudo yum install -y inotify-tools
        elif command -v pacman &> /dev/null; then
            sudo pacman -S inotify-tools
        elif command -v brew &> /dev/null; then
            brew install fswatch
            USE_FSWATCH=true
        else
            print_error "Cannot install inotify-tools. Please install manually."
            exit 1
        fi
    fi
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found! Please install Docker."
        exit 1
    fi
    
    print_status "All dependencies are available"
}

# Check if WordPress container is running
check_wordpress_status() {
    print_info "Checking WordPress container status..."
    
    if docker ps --format "table {{.Names}}" | grep -q "${APP_NAME}-wordpress"; then
        print_status "WordPress container is running"
        return 0
    else
        print_error "WordPress container is not running!"
        print_info "Please start your WordPress environment first:"
        print_info "  ./scripts/quick-start.sh"
        exit 1
    fi
}

# Setup development workspace
setup_dev_workspace() {
    print_info "Setting up development workspace..."
    
    # Create development directories if they don't exist
    mkdir -p dev-workspace/{themes,plugins,uploads}
    mkdir -p dev-workspace/themes/custom
    mkdir -p dev-workspace/plugins/custom
    
    # Create example files if they don't exist
    if [[ ! -f dev-workspace/themes/custom/README.md ]]; then
        cat > dev-workspace/themes/custom/README.md << 'EOF'
# Custom Themes Development

Place your custom theme files here. They will be automatically synced to:
`pet-food-shop-template/wp-content/themes/`

## Structure:
```
dev-workspace/themes/custom/
├── your-theme-name/
│   ├── style.css
│   ├── index.php
│   ├── functions.php
│   └── ...
```

Files are monitored and synced automatically when you save them in VSCode.
EOF
    fi
    
    if [[ ! -f dev-workspace/plugins/custom/README.md ]]; then
        cat > dev-workspace/plugins/custom/README.md << 'EOF'
# Custom Plugins Development

Place your custom plugin files here. They will be automatically synced to:
`pet-food-shop-template/wp-content/plugins/`

## Structure:
```
dev-workspace/plugins/custom/
├── your-plugin-name/
│   ├── your-plugin-name.php
│   ├── includes/
│   ├── assets/
│   └── ...
```

Files are monitored and synced automatically when you save them in VSCode.
EOF
    fi
    
    print_status "Development workspace ready at: ./dev-workspace/"
}

# Sync a single file or directory
sync_file() {
    local source_path="$1"
    local relative_path="${source_path#dev-workspace/}"
    local dest_path="pet-food-shop-template/wp-content/${relative_path}"
    
    # Create destination directory if it doesn't exist
    local dest_dir=$(dirname "$dest_path")
    mkdir -p "$dest_dir"
    
    # Copy file/directory to local wp-content
    if [[ -d "$source_path" ]]; then
        cp -r "$source_path" "$dest_dir/"
        print_info "📁 Synced directory: $relative_path"
    else
        cp "$source_path" "$dest_path"
        print_info "📄 Synced file: $relative_path"
    fi
    
    # Copy to WordPress container
    if docker ps --format "table {{.Names}}" | grep -q "${APP_NAME}-wordpress"; then
        if [[ -d "$source_path" ]]; then
            docker cp "$dest_path" "${APP_NAME}-wordpress:/var/www/html/wp-content/$(dirname "$relative_path")/"
        else
            docker cp "$dest_path" "${APP_NAME}-wordpress:/var/www/html/wp-content/$relative_path"
        fi
        print_status "🚀 Deployed to container: $relative_path"
    else
        print_warning "WordPress container not running, only local sync completed"
    fi
}

# Initial sync of all files
initial_sync() {
    print_info "Performing initial sync..."
    
    if [[ -d "dev-workspace" ]]; then
        # Sync themes
        if [[ -d "dev-workspace/themes" ]]; then
            for theme_dir in dev-workspace/themes/*/; do
                if [[ -d "$theme_dir" && "$(basename "$theme_dir")" != "custom" ]]; then
                    sync_file "$theme_dir"
                fi
            done
            
            if [[ -d "dev-workspace/themes/custom" ]]; then
                for custom_theme in dev-workspace/themes/custom/*/; do
                    if [[ -d "$custom_theme" ]]; then
                        sync_file "$custom_theme"
                    fi
                done
            fi
        fi
        
        # Sync plugins
        if [[ -d "dev-workspace/plugins" ]]; then
            for plugin_dir in dev-workspace/plugins/*/; do
                if [[ -d "$plugin_dir" && "$(basename "$plugin_dir")" != "custom" ]]; then
                    sync_file "$plugin_dir"
                fi
            done
            
            if [[ -d "dev-workspace/plugins/custom" ]]; then
                for custom_plugin in dev-workspace/plugins/custom/*/; do
                    if [[ -d "$custom_plugin" ]]; then
                        sync_file "$custom_plugin"
                    fi
                done
            fi
        fi
        
        print_status "Initial sync completed"
    fi
}

# Start file monitoring
start_monitoring() {
    print_info "Starting file monitoring..."
    print_info "Monitoring: ./dev-workspace/"
    print_info "Press Ctrl+C to stop monitoring"
    echo
    
    if [[ "$USE_FSWATCH" == "true" ]]; then
        # macOS with fswatch
        fswatch -r dev-workspace/ | while read file; do
            if [[ "$file" =~ dev-workspace/ ]] && [[ ! "$file" =~ \.git/ ]] && [[ ! "$file" =~ README\.md$ ]]; then
                sync_file "$file"
            fi
        done
    else
        # Linux with inotifywait
        inotifywait -m -r -e modify,create,delete,move dev-workspace/ --format '%w%f %e' | while read file event; do
            # Skip hidden files, git files, and README files
            if [[ ! "$file" =~ /\. ]] && [[ ! "$file" =~ \.git/ ]] && [[ ! "$file" =~ README\.md$ ]]; then
                if [[ "$event" =~ (MODIFY|CREATE|MOVE) ]]; then
                    sync_file "$file"
                elif [[ "$event" =~ DELETE ]]; then
                    local relative_path="${file#dev-workspace/}"
                    local dest_path="pet-food-shop-template/wp-content/${relative_path}"
                    
                    # Remove from local wp-content
                    if [[ -f "$dest_path" ]] || [[ -d "$dest_path" ]]; then
                        rm -rf "$dest_path"
                        print_info "🗑️  Deleted: $relative_path"
                    fi
                    
                    # Remove from container
                    if docker ps --format "table {{.Names}}" | grep -q "${APP_NAME}-wordpress"; then
                        docker exec "${APP_NAME}-wordpress" rm -rf "/var/www/html/wp-content/$relative_path" 2>/dev/null || true
                        print_status "🗑️  Removed from container: $relative_path"
                    fi
                fi
            fi
        done
    fi
}

# Cleanup function
cleanup() {
    print_info "Stopping file monitoring..."
    print_status "Auto-sync stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Show usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --setup-only   Only setup workspace, don't start monitoring"
    echo "  --sync-only    Perform initial sync only, don't start monitoring"
    echo
    echo "Development Structure:"
    echo "  dev-workspace/"
    echo "  ├── themes/"
    echo "  │   └── custom/          # Custom themes go here"
    echo "  │       └── my-theme/"
    echo "  └── plugins/"
    echo "      └── custom/          # Custom plugins go here"
    echo "          └── my-plugin/"
    echo
    echo "Files are automatically synced to:"
    echo "  - pet-food-shop-template/wp-content/"
    echo "  - WordPress container wp-content/"
}

# Main function
main() {
    # Parse command line arguments
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --setup-only)
            print_header
            load_env
            check_dependencies
            setup_dev_workspace
            print_status "Workspace setup completed"
            exit 0
            ;;
        --sync-only)
            print_header
            load_env
            check_wordpress_status
            initial_sync
            exit 0
            ;;
    esac
    
    print_header
    
    load_env
    check_dependencies
    check_wordpress_status
    setup_dev_workspace
    initial_sync
    
    echo
    print_info "🎯 Ready for development!"
    print_info "Edit files in ./dev-workspace/ and they will be auto-synced"
    print_info "WordPress site: http://localhost:8080"
    print_info "Admin: http://localhost:8080/wp-admin"
    echo
    
    start_monitoring
}

# Run main function
main "$@"