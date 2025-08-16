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
