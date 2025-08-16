#!/bin/bash

# Create Web Template Package
# This creates a clean template that can be copied to any server

echo "📦 Creating Pet Food Shop Web Template"
echo "======================================"

# Create template directory
TEMPLATE_DIR="pet-food-shop-template"
rm -rf "$TEMPLATE_DIR"
mkdir -p "$TEMPLATE_DIR"

echo "📁 Creating template structure..."

# Create the install script
cat > "$TEMPLATE_DIR/install.sh" << 'EOF'
#!/bin/bash

# 🐾 Pet Food Shop - Easy Install Script
# Just run: bash install.sh

echo "🐾 Pet Food Shop - Easy Installer"
echo "=================================="
echo ""

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Start Docker
echo "🐳 Starting Docker..."
sudo service docker start 2>/dev/null || sudo systemctl start docker 2>/dev/null || {
    sudo dockerd > /tmp/docker.log 2>&1 &
    sleep 5
    sudo chmod 666 /var/run/docker.sock
}

# Create directories
echo "📁 Creating directories..."
mkdir -p backups wp-content/uploads

# Create environment file
echo "⚙️ Setting up configuration..."
cat > .env << EOF
APP_NAME=pet-food-store
APP_URL=http://localhost:8000
WORDPRESS_PORT=8000
PHPMYADMIN_PORT=8080
MAILHOG_WEB_PORT=8025
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=petshop123
DB_ROOT_PASSWORD=petshop456
WORDPRESS_DEBUG=false
WP_MEMORY_LIMIT=256M
DB_HOST=db
REDIS_HOST=redis
SMTP_HOST=mailhog
SMTP_PORT=1025
WC_CURRENCY=THB
EOF

# Start containers
echo "🚀 Starting containers..."
docker-compose up -d

echo "⏳ Waiting for containers to start..."
sleep 20

# Setup WooCommerce
echo "🛒 Setting up shop..."
./setup-shop.sh

echo ""
echo "✅ Installation Complete!"
echo "========================="
echo ""
echo "🌐 Your Pet Food Shop: http://localhost:8000"
echo "🗄️  Database Admin: http://localhost:8080"
echo "📧 Email Testing: http://localhost:8025"
echo ""
echo "🔑 Default Login:"
echo "   Username: admin"
echo "   Password: (set during first visit)"
echo ""
echo "💡 To copy to another server:"
echo "   1. Copy this entire folder"
echo "   2. Run: bash install.sh"
echo ""
echo "🛑 To stop: docker-compose down"
echo "🔄 To restart: docker-compose up -d"
EOF

# Create Docker Compose file
cat > "$TEMPLATE_DIR/docker-compose.yml" << 'EOF'
version: '3.8'
services:
  db:
    image: mysql:8.0
    container_name: pet-food-store_db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: petshop456
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: petshop123
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - wordpress_network

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    container_name: pet-food-store_wordpress
    restart: unless-stopped
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: petshop123
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_HOME', 'http://localhost:8000');
        define('WP_SITEURL', 'http://localhost:8000');
    volumes:
      - wordpress_data:/var/www/html
      - ./wp-content:/var/www/html/wp-content
    networks:
      - wordpress_network

  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin/phpmyadmin:latest
    container_name: pet-food-store_phpmyadmin
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: petshop456
    networks:
      - wordpress_network

  mailhog:
    image: mailhog/mailhog:latest
    container_name: pet-food-store_mailhog
    restart: unless-stopped
    ports:
      - "8025:8025"
    networks:
      - wordpress_network

volumes:
  db_data:
  wordpress_data:

networks:
  wordpress_network:
    driver: bridge
EOF

# Create shop setup script
cat > "$TEMPLATE_DIR/setup-shop.sh" << 'EOF'
#!/bin/bash
echo "🛒 Setting up WooCommerce shop..."

# Wait for WordPress
sleep 30

# Install WP-CLI
docker exec pet-food-store_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec pet-food-store_wordpress chmod +x wp-cli.phar
docker exec pet-food-store_wordpress mv wp-cli.phar /usr/local/bin/wp

# Install WooCommerce
docker exec pet-food-store_wordpress wp plugin install woocommerce --activate --allow-root
docker exec pet-food-store_wordpress wp theme install storefront --activate --allow-root

# Create sample products
docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Dog Food Premium" --post_content="High quality dog food for adult dogs. Made with real chicken and rice." --post_status=publish --allow-root
docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Cat Food Deluxe" --post_content="Premium cat food with salmon. Rich in omega-3 fatty acids." --post_status=publish --allow-root
docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Pet Toy Ball" --post_content="Interactive rubber ball with squeaker. Perfect for playtime." --post_status=publish --allow-root
docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Pet Bed Comfort" --post_content="Soft, comfortable pet bed with memory foam. Perfect for dogs and cats." --post_status=publish --allow-root
docker exec pet-food-store_wordpress wp post create --post_type=product --post_title="Pet Shampoo Gentle" --post_content="Gentle, hypoallergenic shampoo for sensitive skin." --post_status=publish --allow-root

# Set prices
PRODUCT1=$(docker exec pet-food-store_wordpress wp post list --post_type=product --post_title="Dog Food Premium" --format=ids --allow-root | head -n1)
PRODUCT2=$(docker exec pet-food-store_wordpress wp post list --post_type=product --post_title="Cat Food Deluxe" --format=ids --allow-root | head -n1)
PRODUCT3=$(docker exec pet-food-store_wordpress wp post list --post_type=product --post_title="Pet Toy Ball" --format=ids --allow-root | head -n1)
PRODUCT4=$(docker exec pet-food-store_wordpress wp post list --post_type=product --post_title="Pet Bed Comfort" --format=ids --allow-root | head -n1)
PRODUCT5=$(docker exec pet-food-store_wordpress wp post list --post_type=product --post_title="Pet Shampoo Gentle" --format=ids --allow-root | head -n1)

docker exec pet-food-store_wordpress wp post meta update $PRODUCT1 _price 450 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT1 _regular_price 450 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT1 _stock_status instock --allow-root

docker exec pet-food-store_wordpress wp post meta update $PRODUCT2 _price 380 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT2 _regular_price 380 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT2 _stock_status instock --allow-root

docker exec pet-food-store_wordpress wp post meta update $PRODUCT3 _price 280 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT3 _regular_price 280 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT3 _stock_status instock --allow-root

docker exec pet-food-store_wordpress wp post meta update $PRODUCT4 _price 890 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT4 _regular_price 890 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT4 _stock_status instock --allow-root

docker exec pet-food-store_wordpress wp post meta update $PRODUCT5 _price 320 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT5 _regular_price 320 --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT5 _stock_status instock --allow-root

# Set featured products
docker exec pet-food-store_wordpress wp post meta update $PRODUCT1 _featured yes --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT2 _featured yes --allow-root
docker exec pet-food-store_wordpress wp post meta update $PRODUCT4 _featured yes --allow-root

echo "✅ Shop setup complete with sample products!"
EOF

# Create README file
cat > "$TEMPLATE_DIR/README.md" << 'EOF'
# 🐾 Pet Food Shop Template

Easy-to-install WordPress + WooCommerce pet food shop template.

## Quick Install

1. Copy this folder to your server
2. Run one command:
   ```bash
   bash install.sh
   ```
3. Visit http://localhost:8000

## What You Get

- ✅ WordPress + WooCommerce
- ✅ Pet-themed sample products
- ✅ Database management (phpMyAdmin)
- ✅ Email testing (MailHog)
- ✅ Professional storefront theme
- ✅ Ready to customize

## Access Points

- **Shop**: http://localhost:8000
- **Admin**: http://localhost:8000/wp-admin
- **Database**: http://localhost:8080
- **Email**: http://localhost:8025

## Management

- **Start**: `docker-compose up -d`
- **Stop**: `docker-compose down`
- **Logs**: `docker-compose logs -f`

## Customization

1. Add your products in WooCommerce admin
2. Upload your logo and customize colors
3. Configure payment methods
4. Set up shipping options

## Requirements

- Linux/Mac/Windows with Docker support
- 2GB+ RAM
- 5GB+ free disk space

## Support

This template includes:
- Sample pet products
- WooCommerce setup
- Professional theme
- All necessary plugins

Perfect for pet stores, animal food shops, and pet supply businesses!
EOF

# Create start/stop scripts
cat > "$TEMPLATE_DIR/start.sh" << 'EOF'
#!/bin/bash
echo "🚀 Starting Pet Food Shop..."
docker-compose up -d
echo "✅ Shop started at http://localhost:8000"
EOF

cat > "$TEMPLATE_DIR/stop.sh" << 'EOF'
#!/bin/bash
echo "🛑 Stopping Pet Food Shop..."
docker-compose down
echo "✅ Shop stopped"
EOF

# Create wp-content directory structure
mkdir -p "$TEMPLATE_DIR/wp-content/uploads"
mkdir -p "$TEMPLATE_DIR/wp-content/themes"
mkdir -p "$TEMPLATE_DIR/wp-content/plugins"

# Create empty gitkeep files
touch "$TEMPLATE_DIR/wp-content/uploads/.gitkeep"
touch "$TEMPLATE_DIR/wp-content/themes/.gitkeep"
touch "$TEMPLATE_DIR/wp-content/plugins/.gitkeep"

# Make scripts executable
chmod +x "$TEMPLATE_DIR"/*.sh

echo "✅ Template created: $TEMPLATE_DIR"
echo ""
echo "📦 To package for distribution:"
echo "   tar -czf pet-food-shop-template.tar.gz $TEMPLATE_DIR"
echo ""
echo "🚀 To test locally:"
echo "   cd $TEMPLATE_DIR && bash install.sh"
echo ""
echo "📁 Template contents:"
ls -la "$TEMPLATE_DIR"