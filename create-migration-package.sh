#!/bin/bash

# Create Migration Package Script
# This script creates a complete package for migrating the shop to another server

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "📦 Creating Pet Food Shop Migration Package"
echo "============================================"
echo ""

# Source environment variables
if [[ -f .env ]]; then
    source .env
else
    print_warning "No .env file found, using defaults"
    APP_NAME="pet-food-store"
fi

# Create timestamp for package
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PACKAGE_NAME="pet-food-shop-migration-${TIMESTAMP}"
TEMP_DIR="/tmp/${PACKAGE_NAME}"

print_info "Creating migration package: ${PACKAGE_NAME}"

# Create temporary directory
mkdir -p "${TEMP_DIR}"

# Function to backup database
backup_database() {
    print_info "Backing up database..."
    
    if docker ps | grep -q "${APP_NAME}_db"; then
        # Create database backup
        docker exec ${APP_NAME}_db mysqldump -u root -p${DB_ROOT_PASSWORD} ${DB_NAME} > "${TEMP_DIR}/database_backup.sql"
        print_status "Database backed up successfully"
    else
        print_warning "Database container not running, skipping database backup"
        echo "# No database backup - container not running" > "${TEMP_DIR}/database_backup.sql"
    fi
}

# Function to copy essential files
copy_files() {
    print_info "Copying essential files..."
    
    # Copy core files
    cp docker-compose.yml "${TEMP_DIR}/"
    cp .env.example "${TEMP_DIR}/"
    cp setup-woocommerce.sh "${TEMP_DIR}/"
    cp deploy-shop.sh "${TEMP_DIR}/"
    cp create-migration-package.sh "${TEMP_DIR}/"
    
    # Copy documentation
    cp README.md "${TEMP_DIR}/" 2>/dev/null || echo "# Pet Food Shop" > "${TEMP_DIR}/README.md"
    cp MIGRATION.md "${TEMP_DIR}/" 2>/dev/null || true
    cp ADMIN-GUIDE.md "${TEMP_DIR}/" 2>/dev/null || true
    cp LICENSE "${TEMP_DIR}/" 2>/dev/null || true
    
    # Copy scripts directory
    if [[ -d scripts ]]; then
        cp -r scripts "${TEMP_DIR}/"
    fi
    
    # Copy WordPress content (if exists)
    if [[ -d wp-content ]]; then
        print_info "Copying WordPress content..."
        cp -r wp-content "${TEMP_DIR}/"
    fi
    
    # Copy admin dashboard (if exists)
    if [[ -d admin-dashboard ]]; then
        cp -r admin-dashboard "${TEMP_DIR}/"
    fi
    
    # Copy uploads.ini and other config files
    cp uploads.ini "${TEMP_DIR}/" 2>/dev/null || true
    cp woocommerce-config.php "${TEMP_DIR}/" 2>/dev/null || true
    
    print_status "Files copied successfully"
}

# Function to create restoration script
create_restore_script() {
    print_info "Creating restoration script..."
    
    cat > "${TEMP_DIR}/restore-on-new-server.sh" << 'EOF'
#!/bin/bash

# Pet Food Shop - Restoration Script
# Run this script on the new server to restore the shop

set -e

echo "🔄 Restoring Pet Food Shop on New Server"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Make scripts executable
chmod +x *.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

# Run deployment script
print_info "Running deployment script..."
if [[ -f deploy-shop.sh ]]; then
    ./deploy-shop.sh
else
    print_warning "Deployment script not found, please run setup manually"
    exit 1
fi

# Wait for containers to be ready
print_info "Waiting for containers to be fully ready..."
sleep 30

# Source environment variables
if [[ -f .env ]]; then
    source .env
else
    print_warning "No .env file found"
    exit 1
fi

# Restore database if backup exists
if [[ -f database_backup.sql ]] && [[ -s database_backup.sql ]]; then
    print_info "Restoring database from backup..."
    
    # Check if backup has content
    if grep -q "CREATE TABLE\|INSERT INTO" database_backup.sql; then
        docker exec -i ${APP_NAME}_db mysql -u root -p${DB_ROOT_PASSWORD} ${DB_NAME} < database_backup.sql
        print_status "Database restored successfully"
    else
        print_warning "Database backup appears to be empty, skipping restore"
    fi
else
    print_warning "No database backup found, you'll need to set up WordPress manually"
fi

# Set proper permissions for WordPress files
print_info "Setting proper file permissions..."
docker exec ${APP_NAME}_wordpress chown -R www-data:www-data /var/www/html/wp-content 2>/dev/null || true

print_status "Restoration completed!"
echo ""
echo "🌐 Your shop should now be available at: ${APP_URL}"
echo "🔧 Visit the site to complete any remaining configuration"
echo ""
echo "📝 Post-restoration checklist:"
echo "   1. Update site URL in WordPress admin if domain changed"
echo "   2. Test all functionality"
echo "   3. Update any hardcoded URLs"
echo "   4. Configure payment gateways with new credentials"
echo "   5. Test email functionality"
echo "   6. Set up SSL certificates if needed"
echo "   7. Configure backups for the new server"
EOF

    chmod +x "${TEMP_DIR}/restore-on-new-server.sh"
    print_status "Restoration script created"
}

# Function to create instructions
create_instructions() {
    print_info "Creating migration instructions..."
    
    cat > "${TEMP_DIR}/MIGRATION_INSTRUCTIONS.md" << EOF
# Pet Food Shop Migration Instructions

This package contains everything needed to migrate your Pet Food Shop to a new server.

## Package Contents

- \`docker-compose.yml\` - Container configuration
- \`.env.example\` - Environment configuration template
- \`deploy-shop.sh\` - One-click deployment script
- \`restore-on-new-server.sh\` - Restoration script for new server
- \`database_backup.sql\` - Database backup (if available)
- \`wp-content/\` - WordPress content and customizations
- \`scripts/\` - Management and utility scripts
- Documentation files

## Migration Steps

### On New Server:

1. **Upload this package to your new server**
   \`\`\`bash
   # Extract the package
   tar -xzf ${PACKAGE_NAME}.tar.gz
   cd ${PACKAGE_NAME}
   \`\`\`

2. **Run the restoration script**
   \`\`\`bash
   chmod +x restore-on-new-server.sh
   ./restore-on-new-server.sh
   \`\`\`

3. **Follow the prompts to configure your new environment**
   - Enter your new domain name
   - Choose ports (or use defaults)
   - The script will handle the rest automatically

### Alternative Manual Method:

If you prefer manual setup:

1. **Install Docker**
   \`\`\`bash
   ./deploy-shop.sh --docker-only
   \`\`\`

2. **Set up environment**
   \`\`\`bash
   cp .env.example .env
   # Edit .env with your settings
   \`\`\`

3. **Deploy containers**
   \`\`\`bash
   docker-compose up -d
   \`\`\`

4. **Restore database** (if backup exists)
   \`\`\`bash
   # Wait for containers to start
   sleep 60
   
   # Import database
   source .env
   docker exec -i \${APP_NAME}_db mysql -u root -p\${DB_ROOT_PASSWORD} \${DB_NAME} < database_backup.sql
   \`\`\`

## Post-Migration Checklist

- [ ] Verify site is accessible
- [ ] Update WordPress site URL if domain changed
- [ ] Test WooCommerce functionality
- [ ] Configure payment gateways
- [ ] Test email delivery
- [ ] Set up SSL certificates (for production)
- [ ] Configure automatic backups
- [ ] Update DNS records (if applicable)
- [ ] Test all custom functionality

## Troubleshooting

### Common Issues:

1. **Port conflicts**: Edit .env file to change ports
2. **Permission issues**: Run \`docker exec \${APP_NAME}_wordpress chown -R www-data:www-data /var/www/html\`
3. **Database connection issues**: Check database passwords in .env
4. **Site URL issues**: Update WordPress site URL in wp-admin

### Getting Help:

- Check container logs: \`docker-compose logs -f\`
- Restart containers: \`docker-compose restart\`
- Full reset: \`docker-compose down -v && docker-compose up -d\`

## Security Notes

- Change all default passwords
- Update WordPress and plugins
- Configure SSL for production
- Set up regular backups
- Restrict database access

---

Package created: $(date)
Original server migration package for Pet Food Shop
EOF

    print_status "Migration instructions created"
}

# Main execution
main() {
    # Create package components
    backup_database
    copy_files
    create_restore_script
    create_instructions
    
    # Create tarball
    print_info "Creating compressed package..."
    cd /tmp
    tar -czf "${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}"
    
    # Move to original directory
    mv "${PACKAGE_NAME}.tar.gz" "${OLDPWD}/"
    
    # Cleanup
    rm -rf "${TEMP_DIR}"
    
    print_status "Migration package created successfully!"
    echo ""
    echo "📦 Package: ${PACKAGE_NAME}.tar.gz"
    echo "📏 Size: $(du -h "${PACKAGE_NAME}.tar.gz" | cut -f1)"
    echo ""
    echo "🚀 To migrate to a new server:"
    echo "   1. Copy ${PACKAGE_NAME}.tar.gz to your new server"
    echo "   2. Extract: tar -xzf ${PACKAGE_NAME}.tar.gz"
    echo "   3. Run: cd ${PACKAGE_NAME} && ./restore-on-new-server.sh"
    echo ""
    echo "📖 See MIGRATION_INSTRUCTIONS.md in the package for detailed steps"
}

# Run main function
main