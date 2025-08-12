#!/bin/bash

# Activate Pet Paws Theme Script

set -e

echo "🎨 Activating Pet Paws Theme..."
echo "================================"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

APP_NAME=${APP_NAME:-"pet-food-store"}

# Wait for WordPress to be ready
echo "⏳ Waiting for WordPress..."
until docker exec ${APP_NAME}_wordpress wp core is-installed --allow-root 2>/dev/null; do
    echo -n "."
    sleep 5
done
echo ""

# Create assets directories if they don't exist
echo "📁 Creating theme directories..."
docker exec ${APP_NAME}_wordpress mkdir -p /var/www/html/wp-content/themes/pet-paws/assets/js
docker exec ${APP_NAME}_wordpress mkdir -p /var/www/html/wp-content/themes/pet-paws/assets/css
docker exec ${APP_NAME}_wordpress mkdir -p /var/www/html/wp-content/themes/pet-paws/assets/images

# Set proper permissions
echo "🔒 Setting permissions..."
docker exec ${APP_NAME}_wordpress chown -R www-data:www-data /var/www/html/wp-content/themes/pet-paws

# Activate the theme
echo "🎨 Activating Pet Paws theme..."
docker exec ${APP_NAME}_wordpress wp theme activate pet-paws --allow-root

# Create sample pages if they don't exist
echo "📄 Creating sample pages..."

# About page
docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=page \
    --post_title="About Us" \
    --post_content="<h2>Welcome to Pet Paws</h2><p>We are passionate about providing the best products for your beloved pets. Our mission is to ensure every pet lives a happy, healthy life with premium nutrition and care.</p>" \
    --post_status=publish \
    --allow-root || echo "About page already exists"

# Contact page
docker exec ${APP_NAME}_wordpress wp post create \
    --post_type=page \
    --post_title="Contact" \
    --post_content="<h2>Get in Touch</h2><p>We'd love to hear from you! Contact us for any questions about our products or services.</p>" \
    --post_status=publish \
    --allow-root || echo "Contact page already exists"

# Create menus
echo "🍔 Creating navigation menus..."

# Create primary menu
docker exec ${APP_NAME}_wordpress wp menu create "Primary Menu" --allow-root || echo "Primary menu already exists"

# Add items to primary menu
docker exec ${APP_NAME}_wordpress wp menu item add-custom "Primary Menu" "Home" "/" --allow-root || true
docker exec ${APP_NAME}_wordpress wp menu item add-post "Primary Menu" $(docker exec ${APP_NAME}_wordpress wp post list --post_type=page --name=shop --field=ID --allow-root) --allow-root || true
docker exec ${APP_NAME}_wordpress wp menu item add-post "Primary Menu" $(docker exec ${APP_NAME}_wordpress wp post list --post_type=page --name=about-us --field=ID --allow-root) --allow-root || true
docker exec ${APP_NAME}_wordpress wp menu item add-post "Primary Menu" $(docker exec ${APP_NAME}_wordpress wp post list --post_type=page --name=contact --field=ID --allow-root) --allow-root || true

# Assign menu to location
docker exec ${APP_NAME}_wordpress wp menu location assign "Primary Menu" primary --allow-root || true

# Set homepage
echo "🏠 Setting homepage..."
docker exec ${APP_NAME}_wordpress wp option update show_on_front "page" --allow-root
docker exec ${APP_NAME}_wordpress wp option update page_on_front $(docker exec ${APP_NAME}_wordpress wp post list --post_type=page --name=home --field=ID --allow-root || echo "0") --allow-root

# Set theme options
echo "⚙️ Setting theme options..."
docker exec ${APP_NAME}_wordpress wp option update pet_paws_phone "02-123-4567" --allow-root
docker exec ${APP_NAME}_wordpress wp option update pet_paws_email "info@petpaws.co.th" --allow-root
docker exec ${APP_NAME}_wordpress wp option update pet_paws_facebook "https://facebook.com/petpaws" --allow-root
docker exec ${APP_NAME}_wordpress wp option update pet_paws_instagram "https://instagram.com/petpaws" --allow-root

# Clear cache
echo "🧹 Clearing cache..."
docker exec ${APP_NAME}_wordpress wp cache flush --allow-root || true

echo ""
echo "✅ Pet Paws theme activated successfully!"
echo ""
echo "📌 Theme Features:"
echo "   - Beautiful modern design"
echo "   - Fully responsive"
echo "   - WooCommerce ready"
echo "   - Thai language support"
echo "   - SEO optimized"
echo ""
echo "🌐 Visit your site: ${APP_URL:-http://localhost:8000}"
echo "👤 Admin panel: ${APP_URL:-http://localhost:8000}/wp-admin"
echo ""
echo "💡 To customize the theme:"
echo "   - Go to Appearance > Customize"
echo "   - Upload your logo"
echo "   - Set your colors"
echo "   - Configure social links"