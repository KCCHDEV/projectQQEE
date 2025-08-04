#!/bin/bash

echo "🚀 Setting up WooCommerce development environment..."

# Wait for WordPress to be ready
echo "⏳ Waiting for WordPress to be ready..."
sleep 30

# Install WP-CLI
echo "📦 Installing WP-CLI..."
docker exec wordpress_app curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec wordpress_app chmod +x wp-cli.phar
docker exec wordpress_app mv wp-cli.phar /usr/local/bin/wp

# Install WooCommerce plugin
echo "🛒 Installing WooCommerce..."
docker exec wordpress_app wp plugin install woocommerce --activate --allow-root

# Install WooCommerce Admin
echo "📊 Installing WooCommerce Admin..."
docker exec wordpress_app wp plugin install woocommerce-admin --activate --allow-root

# Install Storefront theme (WooCommerce default theme)
echo "🎨 Installing Storefront theme..."
docker exec wordpress_app wp theme install storefront --activate --allow-root

# Install additional useful plugins
echo "🔧 Installing additional plugins..."

# Yoast SEO
docker exec wordpress_app wp plugin install wordpress-seo --activate --allow-root

# Contact Form 7
docker exec wordpress_app wp plugin install contact-form-7 --activate --allow-root

# WP Rocket (if you have license)
# docker exec wordpress_app wp plugin install wp-rocket --activate --allow-root

# Install WooCommerce sample data
echo "📦 Installing WooCommerce sample data..."
docker exec wordpress_app wp plugin install woocommerce-sample-data --activate --allow-root

# Configure WooCommerce settings
echo "⚙️ Configuring WooCommerce..."
docker exec wordpress_app wp option update woocommerce_currency "THB" --allow-root
docker exec wordpress_app wp option update woocommerce_currency_pos "left" --allow-root
docker exec wordpress_app wp option update woocommerce_price_thousand_sep "," --allow-root
docker exec wordpress_app wp option update woocommerce_price_decimal_sep "." --allow-root
docker exec wordpress_app wp option update woocommerce_price_num_decimals "2" --allow-root

# Set up pages
echo "📄 Setting up WooCommerce pages..."
docker exec wordpress_app wp wc tool run install_pages --user=1 --allow-root

# Import sample products
echo "📦 Importing sample products..."
docker exec wordpress_app wp plugin deactivate woocommerce-sample-data --allow-root
docker exec wordpress_app wp plugin activate woocommerce-sample-data --allow-root

# Activate the custom Pet Shop theme
echo "🎨 Activating Pet Shop Pro theme..."
docker exec wordpress_app wp theme activate pet-shop-theme --allow-root

# Create sample products for pet shop
echo "🐕 Creating sample pet products..."

# Dog Food Products
docker exec wordpress_app wp post create --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --post_content="High-quality dog food with real chicken and brown rice. Perfect for adult dogs." --post_status=publish --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root) _price 450 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root) _regular_price 450 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root) _pet_type "Dog" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root) _age_range "Adult" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root) _size "All Sizes" --allow-root

# Dog Toys
docker exec wordpress_app wp post create --post_type=product --post_title="Interactive Dog Toy Ball" --post_content="Durable rubber ball with squeaker. Perfect for interactive playtime." --post_status=publish --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root) _price 280 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root) _regular_price 280 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root) _pet_type "Dog" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root) _age_range "All Ages" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root) _size "Medium" --allow-root

# Grooming Products
docker exec wordpress_app wp post create --post_type=product --post_title="Professional Dog Shampoo" --post_content="Gentle, hypoallergenic shampoo for sensitive skin. Leaves coat soft and shiny." --post_status=publish --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Professional Dog Shampoo" --format=ids --allow-root) _price 320 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Professional Dog Shampoo" --format=ids --allow-root) _regular_price 320 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Professional Dog Shampoo" --format=ids --allow-root) _pet_type "Dog" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Professional Dog Shampoo" --format=ids --allow-root) _age_range "All Ages" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Professional Dog Shampoo" --format=ids --allow-root) _size "500ml" --allow-root

# Pet Beds
docker exec wordpress_app wp post create --post_type=product --post_title="Comfortable Pet Bed" --post_content="Soft, orthopedic pet bed with memory foam. Perfect for dogs and cats." --post_status=publish --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root) _price 890 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root) _regular_price 890 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root) _pet_type "Dog, Cat" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root) _age_range "All Ages" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root) _size "Large" --allow-root

# Health Supplements
docker exec wordpress_app wp post create --post_type=product --post_title="Joint Health Supplement" --post_content="Natural joint support supplement with glucosamine and chondroitin." --post_status=publish --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Joint Health Supplement" --format=ids --allow-root) _price 650 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Joint Health Supplement" --format=ids --allow-root) _regular_price 650 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Joint Health Supplement" --format=ids --allow-root) _pet_type "Dog" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Joint Health Supplement" --format=ids --allow-root) _age_range "Senior" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Joint Health Supplement" --format=ids --allow-root) _size "60 tablets" --allow-root

# Cat Products
docker exec wordpress_app wp post create --post_type=product --post_title="Premium Cat Food - Salmon" --post_content="Grain-free cat food with real salmon. Rich in omega-3 fatty acids." --post_status=publish --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Cat Food - Salmon" --format=ids --allow-root) _price 380 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Cat Food - Salmon" --format=ids --allow-root) _regular_price 380 --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Cat Food - Salmon" --format=ids --allow-root) _pet_type "Cat" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Cat Food - Salmon" --format=ids --allow-root) _age_range "Adult" --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Cat Food - Salmon" --format=ids --allow-root) _size "2kg" --allow-root

# Assign products to categories
echo "📂 Assigning products to categories..."
docker exec wordpress_app wp term create product_cat "Dog Food" --slug=dog-food --allow-root
docker exec wordpress_app wp term create product_cat "Toys & Games" --slug=toys --allow-root
docker exec wordpress_app wp term create product_cat "Grooming" --slug=grooming --allow-root
docker exec wordpress_app wp term create product_cat "Beds & Accessories" --slug=accessories --allow-root
docker exec wordpress_app wp term create product_cat "Health & Wellness" --slug=health --allow-root
docker exec wordpress_app wp term create product_cat "Cat Products" --slug=cat-products --allow-root

# Assign products to categories
docker exec wordpress_app wp post term set $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root) product_cat "Dog Food" --allow-root
docker exec wordpress_app wp post term set $(docker exec wordpress_app wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root) product_cat "Toys & Games" --allow-root
docker exec wordpress_app wp post term set $(docker exec wordpress_app wp post list --post_type=product --post_title="Professional Dog Shampoo" --format=ids --allow-root) product_cat "Grooming" --allow-root
docker exec wordpress_app wp post term set $(docker exec wordpress_app wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root) product_cat "Beds & Accessories" --allow-root
docker exec wordpress_app wp post term set $(docker exec wordpress_app wp post list --post_type=product --post_title="Joint Health Supplement" --format=ids --allow-root) product_cat "Health & Wellness" --allow-root
docker exec wordpress_app wp post term set $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Cat Food - Salmon" --format=ids --allow-root) product_cat "Cat Products" --allow-root

# Set featured products
echo "⭐ Setting featured products..."
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Premium Dog Food - Chicken & Rice" --format=ids --allow-root) _featured yes --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Interactive Dog Toy Ball" --format=ids --allow-root) _featured yes --allow-root
docker exec wordpress_app wp post meta update $(docker exec wordpress_app wp post list --post_type=product --post_title="Comfortable Pet Bed" --format=ids --allow-root) _featured yes --allow-root

echo "✅ WooCommerce setup complete!"
echo ""
echo "🌐 Access your pet shop at: http://localhost:8000"
echo "📧 Email testing at: http://localhost:8025"
echo "🗄️ Database at: http://localhost:8080"
echo ""
echo "🔑 Default admin credentials:"
echo "   Username: admin"
echo "   Password: (set during WordPress installation)"
echo ""
echo "🎨 Theme: Pet Shop Pro (custom theme activated)"
echo ""
echo "💡 Next steps:"
echo "   1. Complete WordPress installation at http://localhost:8000"
echo "   2. Configure WooCommerce settings in WordPress admin"
echo "   3. Add product images and customize the store"
echo "   4. Set up payment gateways and shipping methods"
echo "   5. Customize the theme colors and branding" 