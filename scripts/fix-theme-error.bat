@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🔧 แก้ไขปัญหา Theme Error
echo.

REM Get container name
for /f "tokens=*" %%i in ('docker ps --format "{{.Names}}" ^| findstr wordpress') do set CONTAINER_NAME=%%i

if not defined CONTAINER_NAME (
    echo ❌ ไม่พบ WordPress container!
    pause
    exit /b 1
)

echo ใช้ container: %CONTAINER_NAME%
echo.

echo 🗑️ ลบธีม Pet Paws เก่า...
docker exec %CONTAINER_NAME% rm -rf /var/www/html/wp-content/themes/pet-paws
echo ✅ ลบธีมเก่าเรียบร้อย

echo.
echo 📁 สร้างธีมใหม่...
if exist "templates\pet-paws-theme" (
    docker exec %CONTAINER_NAME% mkdir -p /var/www/html/wp-content/themes/pet-paws
    for %%f in (templates\pet-paws-theme\*) do (
        docker cp "%%f" %CONTAINER_NAME%:/var/www/html/wp-content/themes/pet-paws/
    )
    echo ✅ คัดลอกธีมจาก template
) else (
    echo ❌ ไม่พบโฟลเดอร์ templates\pet-paws-theme
    echo สร้างธีมพื้นฐาน...
    
    REM Create basic functions.php
    docker exec %CONTAINER_NAME% bash -c "cat > /var/www/html/wp-content/themes/pet-paws/functions.php << 'EOF'
<?php
// Pet Paws Theme Functions
function pet_paws_scripts() {
    wp_enqueue_style('pet-paws-style', get_stylesheet_uri());
}
add_action('wp_enqueue_scripts', 'pet_paws_scripts');
EOF"
    
    REM Create basic style.css
    docker exec %CONTAINER_NAME% bash -c "cat > /var/www/html/wp-content/themes/pet-paws/style.css << 'EOF'
/*
Theme Name: Pet Paws
Description: Custom pet food store theme
Version: 1.0
*/
EOF"
    
    REM Create basic index.php
    docker exec %CONTAINER_NAME% bash -c "cat > /var/www/html/wp-content/themes/pet-paws/index.php << 'EOF'
<?php get_header(); ?>
<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
    <?php the_title(); ?>
    <?php the_content(); ?>
<?php endwhile; endif; ?>
<?php get_footer(); ?>
EOF"
    
    echo ✅ สร้างธีมพื้นฐาน
)

echo.
echo 🎨 เปิดใช้งานธีม...
docker exec %CONTAINER_NAME% wp theme activate pet-paws --allow-root
echo ✅ เปิดใช้งานธีมเรียบร้อย

echo.
echo 🧪 ทดสอบธีม...
docker exec %CONTAINER_NAME% wp theme status --allow-root
echo.

echo ✅ แก้ไขปัญหา Theme Error เรียบร้อย!
pause
