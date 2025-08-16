#!/bin/bash

# Demo Data Upload Script for Pet Food Shop
# Uploads demo products, categories, and sample data to WooCommerce

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
    echo "🐾 Pet Food Shop - Demo Data Upload"
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
        WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST:-localhost}
        WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME:-wordpress}
        WORDPRESS_DB_USER=${WORDPRESS_DB_USER:-wordpress}
        WORDPRESS_DB_PASSWORD=${WORDPRESS_DB_PASSWORD:-wordpress}
    else
        print_error ".env file not found! Using default values."
        APP_NAME="pet-food-store"
        WORDPRESS_DB_HOST="localhost"
        WORDPRESS_DB_NAME="wordpress"
        WORDPRESS_DB_USER="wordpress"
        WORDPRESS_DB_PASSWORD="wordpress"
    fi
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

# Wait for WordPress to be ready
wait_for_wordpress() {
    print_info "Waiting for WordPress to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|302"; then
            print_status "WordPress is ready!"
            return 0
        fi
        
        echo -ne "\rAttempt $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done
    
    print_error "WordPress did not become ready in time"
    exit 1
}

# Install WP-CLI if not available in container
ensure_wp_cli() {
    print_info "Ensuring WP-CLI is available..."
    
    if ! docker exec ${APP_NAME}-wordpress wp --version >/dev/null 2>&1; then
        print_info "Installing WP-CLI in WordPress container..."
        docker exec ${APP_NAME}-wordpress bash -c "
            curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/utils/wp-cli.phar &&
            chmod +x wp-cli.phar &&
            mv wp-cli.phar /usr/local/bin/wp
        "
    fi
    
    print_status "WP-CLI is ready"
}

# Create demo product categories
create_categories() {
    print_info "Creating product categories..."
    
    # Define categories
    categories=(
        "Dog Food|อาหารสุนัข|Food for dogs of all ages"
        "Cat Food|อาหารแมว|Nutritious food for cats"
        "Bird Food|อาหารนก|Healthy seeds and pellets for birds"
        "Fish Food|อาหารปลา|Quality food for aquarium fish"
        "Small Pet Food|อาหารสัตว์เล็ก|Food for rabbits, hamsters, and other small pets"
        "Pet Treats|ขนมสัตว์เลี้ยง|Delicious treats and snacks"
        "Pet Supplements|วิตามินสัตว์เลี้ยง|Health supplements for pets"
    )
    
    for category in "${categories[@]}"; do
        IFS='|' read -ra CAT_INFO <<< "$category"
        name="${CAT_INFO[0]}"
        name_th="${CAT_INFO[1]}"
        description="${CAT_INFO[2]}"
        
        # Create category
        cat_id=$(docker exec ${APP_NAME}-wordpress wp term create product_cat "$name" --description="$description" --porcelain --allow-root 2>/dev/null || echo "")
        
        if [ -n "$cat_id" ]; then
            print_status "Created category: $name (ID: $cat_id)"
        else
            print_warning "Category '$name' may already exist"
        fi
    done
}

# Create demo products
create_demo_products() {
    print_info "Creating demo products..."
    
    # Demo products data
    products=(
        "Royal Canin Adult Dog Food|royal-canin-dog|อาหารสุนัขโตรอยัลคานิน|Premium nutrition for adult dogs|1250.00|Dog Food|in-stock|10"
        "Whiskas Cat Food Tuna|whiskas-cat-tuna|วิสกัสแมวปลาทูน่า|Delicious tuna flavor for cats|285.00|Cat Food|in-stock|25"
        "Hill's Science Diet Puppy|hills-puppy|ฮิลล์ไซเอนซ์ไดเอทลูกสุนัข|Scientific nutrition for growing puppies|1890.00|Dog Food|in-stock|8"
        "Purina Pro Plan Cat Indoor|purina-cat-indoor|พูริน่าแมวเลี้ยงในบ้าน|Specially formulated for indoor cats|950.00|Cat Food|in-stock|15"
        "Tropical Fish Flakes|tropical-fish-flakes|อาหารปลาเกล็ด|High-quality flakes for tropical fish|125.00|Fish Food|in-stock|30"
        "Kaytee Parakeet Food|kaytee-parakeet|เคที่อาหารนกแก้ว|Premium seeds for parakeets|185.00|Bird Food|in-stock|20"
        "Oxbow Timothy Hay|oxbow-timothy|ออกซ์โบว์หญ้าทิโมธี|Essential hay for rabbits and guinea pigs|320.00|Small Pet Food|in-stock|12"
        "Greenies Dog Treats|greenies-treats|กรีนีส์ขนมสุนัข|Dental treats for healthy teeth|450.00|Pet Treats|in-stock|18"
        "Nutri-Vet Hip & Joint|nutri-vet-joint|นูทริเวทข้อและกระดูก|Joint support supplement for dogs|780.00|Pet Supplements|in-stock|6"
        "Felix Cat Treats Chicken|felix-treats|ฟีลิกซ์ขนมแมวไก่|Tasty chicken treats for cats|95.00|Pet Treats|in-stock|35"
    )
    
    for product in "${products[@]}"; do
        IFS='|' read -ra PROD_INFO <<< "$product"
        name="${PROD_INFO[0]}"
        slug="${PROD_INFO[1]}"
        name_th="${PROD_INFO[2]}"
        description="${PROD_INFO[3]}"
        price="${PROD_INFO[4]}"
        category="${PROD_INFO[5]}"
        stock_status="${PROD_INFO[6]}"
        stock_qty="${PROD_INFO[7]}"
        
        # Create product
        product_id=$(docker exec ${APP_NAME}-wordpress wp wc product create \
            --name="$name" \
            --slug="$slug" \
            --type=simple \
            --status=publish \
            --featured=false \
            --catalog_visibility=visible \
            --description="$description" \
            --short_description="$description" \
            --regular_price="$price" \
            --manage_stock=true \
            --stock_quantity="$stock_qty" \
            --stock_status="$stock_status" \
            --porcelain \
            --allow-root 2>/dev/null || echo "")
        
        if [ -n "$product_id" ]; then
            # Assign category
            cat_id=$(docker exec ${APP_NAME}-wordpress wp term list product_cat --name="$category" --field=term_id --allow-root 2>/dev/null || echo "")
            if [ -n "$cat_id" ]; then
                docker exec ${APP_NAME}-wordpress wp wc product update "$product_id" --categories="[{\"id\":$cat_id}]" --allow-root >/dev/null 2>&1
            fi
            
            print_status "Created product: $name (ID: $product_id, Price: ฿$price)"
        else
            print_warning "Failed to create product: $name"
        fi
        
        # Small delay to avoid overwhelming the system
        sleep 0.5
    done
}

# Set up WooCommerce settings
setup_woocommerce_settings() {
    print_info "Configuring WooCommerce settings..."
    
    # Set currency to Thai Baht
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_currency 'THB' --allow-root
    
    # Set currency position
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_currency_pos 'left' --allow-root
    
    # Set thousand separator
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_price_thousand_sep ',' --allow-root
    
    # Set decimal separator
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_price_decimal_sep '.' --allow-root
    
    # Set number of decimals
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_price_num_decimals '2' --allow-root
    
    # Enable taxes
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_calc_taxes 'yes' --allow-root
    
    # Set default country
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_default_country 'TH' --allow-root
    
    # Enable guest checkout
    docker exec ${APP_NAME}-wordpress wp option update woocommerce_enable_guest_checkout 'yes' --allow-root
    
    print_status "WooCommerce settings configured"
}

# Create sample pages
create_sample_pages() {
    print_info "Creating sample pages..."
    
    # About Us page
    about_content="<h2>เกี่ยวกับเรา (About Us)</h2>
<p>ยินดีต้อนรับสู่ร้านอาหารสัตว์เลี้ยงของเรา! เรามุ่งมั่นที่จะให้อาหารคุณภาพดีที่สุดสำหรับสัตว์เลี้ยงที่คุณรัก</p>
<p>Welcome to our pet food store! We are committed to providing the highest quality food for your beloved pets.</p>

<h3>ผลิตภัณฑ์ของเรา (Our Products)</h3>
<ul>
<li>อาหารสุนัขและแมวคุณภาพพรีเมียม</li>
<li>อาหารสัตว์เลี้ยงขนาดเล็ก</li>
<li>ขนมและของเล่นสำหรับสัตว์เลี้ยง</li>
<li>วิตามินและอาหารเสริม</li>
</ul>"
    
    about_id=$(docker exec ${APP_NAME}-wordpress wp post create \
        --post_type=page \
        --post_title="About Us | เกี่ยวกับเรา" \
        --post_content="$about_content" \
        --post_status=publish \
        --porcelain \
        --allow-root 2>/dev/null || echo "")
    
    if [ -n "$about_id" ]; then
        print_status "Created About Us page (ID: $about_id)"
    fi
    
    # Contact page
    contact_content="<h2>ติดต่อเรา (Contact Us)</h2>
<p><strong>ที่อยู่:</strong> 123 ถนนเพชรบุรี กรุงเทพฯ 10400</p>
<p><strong>โทรศัพท์:</strong> 02-123-4567</p>
<p><strong>อีเมล:</strong> info@petfoodshop.com</p>
<p><strong>เวลาทำการ:</strong> จันทร์-อาทิตย์ 9:00-20:00</p>

<h3>Follow Us</h3>
<p>Facebook: @PetFoodShopTH<br>
Instagram: @petfoodshop_th<br>
Line: @petfoodshop</p>"
    
    contact_id=$(docker exec ${APP_NAME}-wordpress wp post create \
        --post_type=page \
        --post_title="Contact Us | ติดต่อเรา" \
        --post_content="$contact_content" \
        --post_status=publish \
        --porcelain \
        --allow-root 2>/dev/null || echo "")
    
    if [ -n "$contact_id" ]; then
        print_status "Created Contact page (ID: $contact_id)"
    fi
}

# Main function
main() {
    print_header
    
    load_env
    check_wordpress_status
    wait_for_wordpress
    ensure_wp_cli
    
    print_info "Starting demo data upload..."
    echo
    
    create_categories
    echo
    
    create_demo_products
    echo
    
    setup_woocommerce_settings
    echo
    
    create_sample_pages
    echo
    
    print_status "Demo data upload completed successfully!"
    print_info "You can now visit your store at: http://localhost:8080"
    print_info "Admin panel: http://localhost:8080/wp-admin"
    print_info "Default admin credentials: admin / admin"
    echo
}

# Run main function
main "$@"