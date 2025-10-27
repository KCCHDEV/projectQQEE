#!/bin/bash
set -euo pipefail

# Custom Docker entrypoint for Pet Food E-commerce Platform

# Function to wait for database
wait_for_db() {
    echo "Waiting for database connection..."
    while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
        echo "Database not ready, waiting..."
        sleep 2
    done
    echo "Database connection established!"
}

# Function to setup WordPress if not already installed
setup_wordpress() {
    if ! wp core is-installed --allow-root; then
        echo "Setting up WordPress..."
        
        # Download WordPress core if not present
        if [ ! -f wp-config.php ]; then
            wp core download --allow-root --force
        fi
        
        # Create wp-config.php
        wp config create \
            --dbname="$WORDPRESS_DB_NAME" \
            --dbuser="$WORDPRESS_DB_USER" \
            --dbpass="$WORDPRESS_DB_PASSWORD" \
            --dbhost="$WORDPRESS_DB_HOST" \
            --allow-root \
            --force
        
        # Add custom configuration
        wp config set WP_DEBUG true --raw --allow-root
        wp config set WP_DEBUG_LOG true --raw --allow-root
        wp config set WP_DEBUG_DISPLAY false --raw --allow-root
        wp config set WP_MEMORY_LIMIT '512M' --allow-root
        wp config set WP_MAX_MEMORY_LIMIT '1024M' --allow-root
        
        # Install WordPress
        wp core install \
            --url="${WORDPRESS_URL:-http://localhost:8000}" \
            --title="${WORDPRESS_TITLE:-Pet Food Store}" \
            --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
            --admin_password="${WORDPRESS_ADMIN_PASSWORD:-admin123}" \
            --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@localhost}" \
            --allow-root
        
        echo "WordPress installed successfully!"
    else
        echo "WordPress already installed, skipping setup..."
    fi
}

# Function to setup WooCommerce
setup_woocommerce() {
    echo "Setting up WooCommerce..."
    
    # Install and activate WooCommerce if not already active
    if ! wp plugin is-active woocommerce --allow-root; then
        wp plugin install woocommerce --activate --allow-root || true
    fi
    
    # Install other essential plugins
    wp plugin install wordpress-seo --activate --allow-root || true
    wp plugin install contact-form-7 --activate --allow-root || true
    
    # Activate custom theme if present
    if wp theme is-installed petpaws --allow-root; then
        wp theme activate petpaws --allow-root
        echo "Custom theme activated!"
    fi
    
    # Set up WooCommerce basic settings
    wp option update woocommerce_store_address "123 Pet Street" --allow-root || true
    wp option update woocommerce_store_city "Bangkok" --allow-root || true
    wp option update woocommerce_default_country "TH" --allow-root || true
    wp option update woocommerce_store_postcode "10100" --allow-root || true
    wp option update woocommerce_currency "THB" --allow-root || true
    wp option update woocommerce_price_thousand_sep "," --allow-root || true
    wp option update woocommerce_price_decimal_sep "." --allow-root || true
    wp option update woocommerce_price_num_decimals "2" --allow-root || true
    
    echo "WooCommerce setup completed!"
}

# Function to import demo data if present
import_demo_data() {
    if [ -f "/var/www/html/wp-content/demo-data.sql" ]; then
        echo "Importing demo data..."
        wp db import /var/www/html/wp-content/demo-data.sql --allow-root || true
        echo "Demo data imported!"
    fi
}

# Main execution
main() {
    echo "Starting Pet Food E-commerce Platform setup..."
    
    # Wait for database
    if [ -n "${WORDPRESS_DB_HOST:-}" ]; then
        wait_for_db
    fi
    
    # Setup WordPress
    setup_wordpress
    
    # Setup WooCommerce
    setup_woocommerce
    
    # Import demo data
    import_demo_data
    
    # Set proper permissions
    chown -R www-data:www-data /var/www/html/wp-content
    chmod -R 755 /var/www/html/wp-content
    
    echo "Setup completed! Starting Apache..."
    
    # Execute the original entrypoint
    exec docker-entrypoint.sh "$@"
}

# Run main function if script is executed directly
if [ "${1:-}" != "apache2-foreground" ] && [ "${1:-}" != "php-fpm" ]; then
    exec "$@"
else
    main "$@"
fi