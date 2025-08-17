#!/bin/bash

echo "🎨 สร้างไฟล์ธีม WordPress..."

# Create theme directory
mkdir -p "wp-content/themes/pet-paws"

# Copy all theme files from template
if [ -d "templates/pet-paws-theme" ]; then
    if cp -r templates/pet-paws-theme/* "wp-content/themes/pet-paws/" 2>/dev/null; then
        echo "✅ คัดลอกไฟล์ธีมทั้งหมดจาก template"
    else
        echo "❌ ไม่สามารถคัดลอกไฟล์ธีมจาก template ได้"
        echo "สร้างไฟล์ธีมพื้นฐาน..."
        create_basic_theme=true
    fi
else
    echo "❌ ไม่พบโฟลเดอร์ templates/pet-paws-theme"
    echo "สร้างไฟล์ธีมพื้นฐาน..."
    create_basic_theme=true
fi

# Create basic theme files if template not found
if [ "$create_basic_theme" = true ]; then
    # Create basic style.css
    cat > "wp-content/themes/pet-paws/style.css" << 'EOF'
/*
Theme Name: Pet Paws
Description: Custom pet food store theme
Version: 1.0
*/
EOF

    # Create basic functions.php
    cat > "wp-content/themes/pet-paws/functions.php" << 'EOF'
<?php
// Pet Paws Theme Functions
add_action('wp_enqueue_scripts', 'pet_paws_scripts');
function pet_paws_scripts() {
    wp_enqueue_style('pet-paws-style', get_stylesheet_uri());
}
EOF

    # Create basic index.php
    cat > "wp-content/themes/pet-paws/index.php" << 'EOF'
<?php
get_header();
if (have_posts()) : while (have_posts()) : the_post();
    the_title();
    the_content();
endwhile; endif;
get_footer();
EOF

    # Create basic header.php
    cat > "wp-content/themes/pet-paws/header.php" << 'EOF'
<?php
<!DOCTYPE html>
<html>
<head>
    <title><?php bloginfo('name'); ?></title>
    <?php wp_head(); ?>
</head>
<body>
    <h1><?php bloginfo('name'); ?></h1>
EOF

    # Create basic footer.php
    cat > "wp-content/themes/pet-paws/footer.php" << 'EOF'
    <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?></p>
    <?php wp_footer(); ?>
</body>
</html>
EOF

    echo "✅ สร้างไฟล์ธีมพื้นฐาน"
fi

# Copy JavaScript from rimping template if available
if [ -f "dev-workspace/ui-template/script.js" ]; then
    if cp "dev-workspace/ui-template/script.js" "wp-content/themes/pet-paws/script.js" 2>/dev/null; then
        echo "✅ คัดลอก JavaScript จาก rimping template"
    fi
fi

echo "✅ สร้างธีม Pet Paws เรียบร้อย"