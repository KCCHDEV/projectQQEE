#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         🏪 Pet Food Shop - Universal Installer 🐾            ║"
echo "║    รองรับทั้ง Docker และ XAMPP - ติดตั้งครบในไฟล์เดียว        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# ===== MENU SELECTION =====
main_menu() {
    echo "🚀 เลือกวิธีการติดตั้ง:"
    echo ""
    echo "  1) 🐳 Docker (แนะนำ - ติดตั้งง่าย มีทุกอย่างครบ)"
    echo "  2) 📁 XAMPP/Local Server (ใช้ Apache+MySQL ที่มีอยู่)"
    echo "  3) ❓ ตรวจสอบระบบ"
    echo "  4) 🚪 ออกจากโปรแกรม"
    echo ""
    read -p "👉 เลือก (1-4): " choice

    case $choice in
        1) docker_install ;;
        2) xampp_install ;;
        3) system_check ;;
        4) exit 0 ;;
        *) echo "❌ กรุณาเลือก 1-4"; main_menu ;;
    esac
}

# ===== SYSTEM CHECK =====
system_check() {
    echo ""
    echo "🔍 ตรวจสอบระบบ..."
    echo "═══════════════════════"

    # Check Docker
    if command -v docker &> /dev/null; then
        echo "✅ Docker: พร้อมใช้งาน"
        docker --version
    else
        echo "❌ Docker: ไม่ได้ติดตั้ง"
        echo "   💡 ติดตั้ง: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    fi

    # Check Apache/httpd
    if command -v apache2 &> /dev/null || command -v httpd &> /dev/null; then
        echo "✅ Apache: พร้อมใช้งาน"
    else
        echo "❌ Apache: ไม่ได้ติดตั้ง"
        echo "   💡 Ubuntu: sudo apt install apache2"
        echo "   💡 CentOS: sudo yum install httpd"
        echo "   💡 macOS: brew install httpd"
    fi

    # Check MySQL
    if command -v mysql &> /dev/null; then
        echo "✅ MySQL: พร้อมใช้งาน"
    else
        echo "❌ MySQL: ไม่ได้ติดตั้ง"
        echo "   💡 Ubuntu: sudo apt install mysql-server"
        echo "   💡 macOS: brew install mysql"
    fi

    # Check PHP
    if command -v php &> /dev/null; then
        echo "✅ PHP: พร้อมใช้งาน"
        php --version | head -n1
    else
        echo "❌ PHP: ไม่ได้ติดตั้ง"
        echo "   💡 Ubuntu: sudo apt install php php-mysql"
        echo "   💡 macOS: brew install php"
    fi

    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
    main_menu
}

# ===== DOCKER INSTALLATION =====
docker_install() {
    echo ""
    echo "🐳 การติดตั้งด้วย Docker"
    echo "═════════════════════════"

    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker ไม่ได้ติดตั้ง!"
        echo ""
        echo "📥 ติดตั้ง Docker:"
        echo "   curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
        echo ""
        read -p "กด Enter เพื่อกลับเมนูหลัก..."
        main_menu
        return
    fi

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "❌ Docker Compose ไม่ได้ติดตั้ง!"
        echo "   💡 Ubuntu: sudo apt install docker-compose"
        echo "   💡 หรือ: pip install docker-compose"
        read -p "กด Enter เพื่อกลับเมนูหลัก..."
        main_menu
        return
    fi

    echo "✅ Docker พร้อมใช้งาน"
    echo ""

    # Create project structure
    echo "📁 สร้างโครงสร้างโปรเจค..."
    mkdir -p wp-content/{themes,plugins,uploads} backups

    # Create .env file
    echo "⚙️ สร้างไฟล์การตั้งค่า..."
    cat > .env << EOF
APP_NAME=pet-food-store
WORDPRESS_PORT=8000
PHPMYADMIN_PORT=8080
MAILHOG_WEB_PORT=8025
DB_ROOT_PASSWORD=petshop456
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=petshop123
APP_URL=http://localhost:8000
WC_CURRENCY=THB
EOF

    # Create docker-compose.yml
    echo "🐳 สร้างไฟล์ Docker..."
    cat > docker-compose.yml << 'EOF'
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

volumes:
  db_data:
  wordpress_data:

networks:
  wordpress_network:
    driver: bridge
EOF

    # Start Docker containers
    echo "🚀 เริ่มต้น Docker containers..."
    if docker-compose up -d; then
        echo "✅ เริ่มต้น containers เรียบร้อย"
    else
        echo "❌ ไม่สามารถเริ่มต้น containers ได้"
        read -p "กด Enter เพื่อกลับเมนูหลัก..."
        main_menu
        return
    fi

    # Wait for WordPress
    echo "⏳ รอให้ WordPress พร้อมใช้งาน (อาจใช้เวลา 1-2 นาที)..."
    sleep 30

    # Install WP-CLI and setup
    echo "🔧 ติดตั้ง WP-CLI และตั้งค่า WordPress..."
    docker exec pet-food-store_wordpress curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &>/dev/null
    docker exec pet-food-store_wordpress chmod +x wp-cli.phar &>/dev/null
    docker exec pet-food-store_wordpress mv wp-cli.phar /usr/local/bin/wp &>/dev/null

    # Wait a bit more and install WordPress
    sleep 15
    docker exec pet-food-store_wordpress wp core install \
        --url=http://localhost:8000 \
        --title="Pet Food Store" \
        --admin_user=admin \
        --admin_password=admin123 \
        --admin_email=admin@petshop.com \
        --allow-root &>/dev/null

    # Install WooCommerce
    echo "🛒 ติดตั้ง WooCommerce..."
    docker exec pet-food-store_wordpress wp plugin install woocommerce --activate --allow-root &>/dev/null

    # Configure WooCommerce for Thailand
    docker exec pet-food-store_wordpress wp option update woocommerce_currency THB --allow-root &>/dev/null
    docker exec pet-food-store_wordpress wp option update woocommerce_default_country TH --allow-root &>/dev/null

    # Create sample products
    echo "🛍️ สร้างสินค้าตัวอย่าง..."
    docker exec pet-food-store_wordpress wp post create \
        --post_type=product \
        --post_title="อาหารสุนัขพรีเมียม" \
        --post_content="อาหารสุนัขคุณภาพสูง" \
        --post_status=publish \
        --allow-root &>/dev/null
    
    docker exec pet-food-store_wordpress wp post create \
        --post_type=product \
        --post_title="อาหารแมวดีลักซ์" \
        --post_content="อาหารแมวพรีเมียม" \
        --post_status=publish \
        --allow-root &>/dev/null

    docker_success
}

docker_success() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 ติดตั้งสำเร็จ!                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🌐 เว็บไซต์: http://localhost:8000"
    echo "🔐 Admin: http://localhost:8000/wp-admin"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo ""
    echo "🗄️ phpMyAdmin: http://localhost:8080"
    echo "   Username: root"
    echo "   Password: petshop456"
    echo ""
    echo "🛑 หยุดระบบ: docker-compose down"
    echo "🔄 รีสตาร์ท: docker-compose restart"
    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
    main_menu
}

# ===== XAMPP/LOCAL SERVER INSTALLATION =====
xampp_install() {
    echo ""
    echo "📁 การติดตั้งด้วย Local Server"
    echo "═══════════════════════════════════"

    # Find web directory
    web_dir=""
    if [ -d "/var/www/html" ]; then
        web_dir="/var/www/html"
    elif [ -d "/Applications/XAMPP/htdocs" ]; then
        web_dir="/Applications/XAMPP/htdocs"
    elif [ -d "/opt/lampp/htdocs" ]; then
        web_dir="/opt/lampp/htdocs"
    else
        echo "❌ ไม่พบโฟลเดอร์ web server!"
        echo ""
        echo "💡 กรุณาระบุ path ของ web directory:"
        read -p "   เช่น /var/www/html หรือ /Applications/XAMPP/htdocs: " web_dir
        
        if [ ! -d "$web_dir" ]; then
            echo "❌ โฟลเดอร์ไม่พบ!"
            read -p "กด Enter เพื่อกลับเมนูหลัก..."
            main_menu
            return
        fi
    fi

    echo "✅ พบ web directory ที่: $web_dir"

    # Check services
    echo "🔍 ตรวจสอบ services..."
    
    if ! command -v mysql &> /dev/null; then
        echo "❌ MySQL ไม่พบ - กรุณาติดตั้งและเริ่มต้น MySQL"
        read -p "กด Enter เพื่อกลับเมนูหลัก..."
        main_menu
        return
    fi

    if ! command -v php &> /dev/null; then
        echo "❌ PHP ไม่พบ - กรุณาติดตั้ง PHP"
        read -p "กด Enter เพื่อกลับเมนูหลัก..."
        main_menu
        return
    fi

    # Create project directory
    project_path="$web_dir/pet-food-store"
    echo "📁 สร้างโปรเจคที่: $project_path"

    if [ -d "$project_path" ]; then
        echo "⚠️ โฟลเดอร์ $project_path มีอยู่แล้ว"
        read -p "ต้องการเขียนทับไหม? (y/n): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            main_menu
            return
        fi
        rm -rf "$project_path"
    fi

    mkdir -p "$project_path"
    cd "$project_path"

    # Download WordPress
    echo "📥 ดาวน์โหลด WordPress..."
    if command -v curl &> /dev/null; then
        curl -O https://wordpress.org/latest.tar.gz
    elif command -v wget &> /dev/null; then
        wget https://wordpress.org/latest.tar.gz
    else
        echo "❌ ไม่พบ curl หรือ wget"
        echo "💡 กรุณาดาวน์โหลด WordPress ด้วยตัวเอง"
        read -p "กด Enter เพื่อกลับเมนูหลัก..."
        main_menu
        return
    fi

    # Extract WordPress
    echo "📦 แตกไฟล์ WordPress..."
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz

    # Create wp-config.php
    echo "⚙️ สร้างไฟล์การตั้งค่า WordPress..."
    cat > wp-config.php << 'EOF'
<?php
define('DB_NAME', 'pet_food_store');
define('DB_USER', 'root');
define('DB_PASSWORD', '');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

$table_prefix = 'wp_';
define('WP_DEBUG', false);

if (! defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

    # Create database
    echo "🗄️ สร้างฐานข้อมูล..."
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS pet_food_store CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

    if [ $? -ne 0 ]; then
        echo "⚠️ ไม่สามารถสร้างฐานข้อมูลอัตโนมัติได้"
        echo "💡 กรุณาสร้างฐานข้อมูล 'pet_food_store' ด้วยตัวเอง"
    fi

    # Create basic theme
    echo "🎨 สร้างธีม Pet Paws..."
    mkdir -p "wp-content/themes/pet-paws"

    cat > "wp-content/themes/pet-paws/style.css" << 'EOF'
/*
Theme Name: Pet Paws
Description: Pet Food Store Theme
Version: 1.0
*/

body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
.header { background: #2c3e50; color: white; padding: 20px; text-align: center; }
.content { margin: 20px 0; }
.footer { background: #34495e; color: white; padding: 10px; text-align: center; margin-top: 40px; }
EOF

    cat > "wp-content/themes/pet-paws/functions.php" << 'EOF'
<?php
add_action('wp_enqueue_scripts', 'pet_paws_scripts');
function pet_paws_scripts() {
    wp_enqueue_style('pet-paws-style', get_stylesheet_uri());
}
EOF

    cat > "wp-content/themes/pet-paws/index.php" << 'EOF'
<?php get_header(); ?>
<div class="content">
<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
    <h2><?php the_title(); ?></h2>
    <div><?php the_content(); ?></div>
<?php endwhile; endif; ?>
</div>
<?php get_footer(); ?>
EOF

    cat > "wp-content/themes/pet-paws/header.php" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title><?php bloginfo('name'); ?></title>
    <?php wp_head(); ?>
</head>
<body>
<div class="header">
    <h1>🐾 <?php bloginfo('name'); ?> 🐾</h1>
</div>
EOF

    cat > "wp-content/themes/pet-paws/footer.php" << 'EOF'
<div class="footer">
    <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?></p>
</div>
<?php wp_footer(); ?>
</body>
</html>
EOF

    xampp_success "$project_path"
}

xampp_success() {
    local project_path=$1
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 ติดตั้งสำเร็จ!                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🌐 เว็บไซต์: http://localhost/pet-food-store"
    echo "📁 โฟลเดอร์: $project_path"
    echo ""
    echo "🔧 ขั้นตอนต่อไป:"
    echo "   1. เปิด: http://localhost/pet-food-store"
    echo "   2. ทำการติดตั้ง WordPress"
    echo "   3. ติดตั้ง WooCommerce plugin"
    echo "   4. เปิดใช้งานธีม Pet Paws"
    echo ""
    echo "🗄️ phpMyAdmin: http://localhost/phpmyadmin"
    echo "   ฐานข้อมูล: pet_food_store"
    echo ""
    read -p "กด Enter เพื่อกลับเมนูหลัก..."
    main_menu
}

# Make script executable and start
chmod +x "$0"
main_menu