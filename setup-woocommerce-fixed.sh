#!/bin/bash

# Load environment variables
set -a
source .env
set +a

echo "🚀 Setting up WooCommerce development environment..."

# Wait for WordPress to be ready
echo "⏳ Waiting for WordPress to be ready..."
sleep 30

# Check if container exists
if ! docker ps | grep -q "${APP_NAME}_wordpress"; then
    echo "❌ WordPress container not found! Please start containers first with 'docker-compose up -d'"
    exit 1
fi

# Install WP-CLI
echo "📦 Installing WP-CLI..."
docker exec ${APP_NAME}_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec ${APP_NAME}_wordpress chmod +x wp-cli.phar
docker exec ${APP_NAME}_wordpress mv wp-cli.phar /usr/local/bin/wp

# Install WooCommerce plugin
echo "🛒 Installing WooCommerce..."
docker exec ${APP_NAME}_wordpress wp plugin install woocommerce --activate --allow-root

# Install WooCommerce Admin
echo "📊 Installing WooCommerce Admin..."
docker exec ${APP_NAME}_wordpress wp plugin install woocommerce-admin --activate --allow-root

# Install Storefront theme (WooCommerce default theme)
echo "🎨 Installing Storefront theme..."
docker exec ${APP_NAME}_wordpress wp theme install storefront --activate --allow-root

# Install additional useful plugins
echo "🔧 Installing additional plugins..."

# Yoast SEO
docker exec ${APP_NAME}_wordpress wp plugin install wordpress-seo --activate --allow-root

# Contact Form 7
docker exec ${APP_NAME}_wordpress wp plugin install contact-form-7 --activate --allow-root

# Configure WooCommerce settings
echo "⚙️ Configuring WooCommerce..."
docker exec ${APP_NAME}_wordpress wp option update woocommerce_currency "THB" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_currency_pos "left" --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_price_thousand_sep "," --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_price_decimal_sep "." --allow-root
docker exec ${APP_NAME}_wordpress wp option update woocommerce_price_num_decimals "2" --allow-root

# Set up pages
echo "📄 Setting up WooCommerce pages..."
docker exec ${APP_NAME}_wordpress wp wc tool run install_pages --user=1 --allow-root

# Create sample products for pet shop
echo "🐕 Creating sample pet products..."

# Create categories first
echo "📂 Creating product categories..."
docker exec ${APP_NAME}_wordpress wp term create product_cat "Dog Food" --slug=dog-food --allow-root
docker exec ${APP_NAME}_wordpress wp term create product_cat "Toys & Games" --slug=toys --allow-root
docker exec ${APP_NAME}_wordpress wp term create product_cat "Grooming" --slug=grooming --allow-root
docker exec ${APP_NAME}_wordpress wp term create product_cat "Beds & Accessories" --slug=accessories --allow-root
docker exec ${APP_NAME}_wordpress wp term create product_cat "Health & Wellness" --slug=health --allow-root
docker exec ${APP_NAME}_wordpress wp term create product_cat "Cat Products" --slug=cat-products --allow-root

# Dog Food Products
echo "🐕 Creating dog food products..."
docker exec ${APP_NAME}_wordpress wp post create --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --post_content="High-quality dog food with real chicken and brown rice. Perfect for adult dogs." --post_status=publish --allow-root
DOG_FOOD_ID=$(docker exec ${APP_NAME}_wordpress wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root | head -n1)
docker exec ${APP_NAME}_wordpress wp post meta update $DOG_FOOD_ID _price 450 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $DOG_FOOD_ID _regular_price 450 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $DOG_FOOD_ID _stock_status instock --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $DOG_FOOD_ID _manage_stock yes --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $DOG_FOOD_ID _stock 100 --allow-root
docker exec ${APP_NAME}_wordpress wp post term set $DOG_FOOD_ID product_cat "Dog Food" --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $DOG_FOOD_ID _featured yes --allow-root

# Dog Toys
echo "🎾 Creating dog toys..."
docker exec ${APP_NAME}_wordpress wp post create --post_type=product --post_title="Interactive Dog Toy Ball" --post_content="Durable rubber ball with squeaker. Perfect for interactive playtime." --post_status=publish --allow-root
TOY_ID=$(docker exec ${APP_NAME}_wordpress wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root | head -n1)
docker exec ${APP_NAME}_wordpress wp post meta update $TOY_ID _price 280 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $TOY_ID _regular_price 280 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $TOY_ID _stock_status instock --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $TOY_ID _manage_stock yes --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $TOY_ID _stock 50 --allow-root
docker exec ${APP_NAME}_wordpress wp post term set $TOY_ID product_cat "Toys & Games" --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $TOY_ID _featured yes --allow-root

# Grooming Products
echo "🛁 Creating grooming products..."
docker exec ${APP_NAME}_wordpress wp post create --post_type=product --post_title="Professional Dog Shampoo" --post_content="Gentle, hypoallergenic shampoo for sensitive skin. Leaves coat soft and shiny." --post_status=publish --allow-root
SHAMPOO_ID=$(docker exec ${APP_NAME}_wordpress wp post list --post_type=product --post_title="Professional Dog Shampoo" --format=ids --allow-root | head -n1)
docker exec ${APP_NAME}_wordpress wp post meta update $SHAMPOO_ID _price 320 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SHAMPOO_ID _regular_price 320 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SHAMPOO_ID _stock_status instock --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SHAMPOO_ID _manage_stock yes --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SHAMPOO_ID _stock 30 --allow-root
docker exec ${APP_NAME}_wordpress wp post term set $SHAMPOO_ID product_cat "Grooming" --allow-root

# Pet Beds
echo "🛏️ Creating pet beds..."
docker exec ${APP_NAME}_wordpress wp post create --post_type=product --post_title="Comfortable Pet Bed" --post_content="Soft, orthopedic pet bed with memory foam. Perfect for dogs and cats." --post_status=publish --allow-root
BED_ID=$(docker exec ${APP_NAME}_wordpress wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root | head -n1)
docker exec ${APP_NAME}_wordpress wp post meta update $BED_ID _price 890 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $BED_ID _regular_price 890 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $BED_ID _stock_status instock --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $BED_ID _manage_stock yes --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $BED_ID _stock 25 --allow-root
docker exec ${APP_NAME}_wordpress wp post term set $BED_ID product_cat "Beds & Accessories" --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $BED_ID _featured yes --allow-root

# Health Supplements
echo "💊 Creating health supplements..."
docker exec ${APP_NAME}_wordpress wp post create --post_type=product --post_title="Joint Health Supplement" --post_content="Natural joint support supplement with glucosamine and chondroitin." --post_status=publish --allow-root
SUPPLEMENT_ID=$(docker exec ${APP_NAME}_wordpress wp post list --post_type=product --post_title="Joint Health Supplement" --format=ids --allow-root | head -n1)
docker exec ${APP_NAME}_wordpress wp post meta update $SUPPLEMENT_ID _price 650 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SUPPLEMENT_ID _regular_price 650 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SUPPLEMENT_ID _stock_status instock --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SUPPLEMENT_ID _manage_stock yes --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $SUPPLEMENT_ID _stock 20 --allow-root
docker exec ${APP_NAME}_wordpress wp post term set $SUPPLEMENT_ID product_cat "Health & Wellness" --allow-root

# Cat Products
echo "🐱 Creating cat products..."
docker exec ${APP_NAME}_wordpress wp post create --post_type=product --post_title="Premium Cat Food - Salmon" --post_content="Grain-free cat food with real salmon. Rich in omega-3 fatty acids." --post_status=publish --allow-root
CAT_FOOD_ID=$(docker exec ${APP_NAME}_wordpress wp post list --post_type=product --post_title="Premium Cat Food - Salmon" --format=ids --allow-root | head -n1)
docker exec ${APP_NAME}_wordpress wp post meta update $CAT_FOOD_ID _price 380 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $CAT_FOOD_ID _regular_price 380 --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $CAT_FOOD_ID _stock_status instock --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $CAT_FOOD_ID _manage_stock yes --allow-root
docker exec ${APP_NAME}_wordpress wp post meta update $CAT_FOOD_ID _stock 75 --allow-root
docker exec ${APP_NAME}_wordpress wp post term set $CAT_FOOD_ID product_cat "Cat Products" --allow-root

echo "✅ WooCommerce setup complete!"
echo ""
echo "🌐 Access your pet shop at: ${APP_URL}"
echo "📧 Email testing at: http://localhost:${MAILHOG_WEB_PORT}"
echo "🗄️ Database at: http://localhost:${PHPMYADMIN_PORT}"
echo ""
echo "🔑 Default admin credentials:"
echo "   Username: admin"
echo "   Password: (set during WordPress installation)"
echo ""
echo "🎨 Theme: Storefront (WooCommerce default theme activated)"
echo ""
echo "💡 Next steps:"
echo "   1. Complete WordPress installation at ${APP_URL}"
echo "   2. Configure WooCommerce settings in WordPress admin"
echo "   3. Add product images and customize the store"
echo "   4. Set up payment gateways and shipping methods"
echo "   5. Customize the theme colors and branding"