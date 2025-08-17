@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🔧 แก้ไขปัญหา Theme Error - แบบง่าย
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
docker exec %CONTAINER_NAME% mkdir -p /var/www/html/wp-content/themes/pet-paws

echo.
echo 📝 สร้างไฟล์ functions.php...
docker exec %CONTAINER_NAME% bash -c "echo '<?php' > /var/www/html/wp-content/themes/pet-paws/functions.php"
docker exec %CONTAINER_NAME% bash -c "echo '// Pet Paws Theme Functions' >> /var/www/html/wp-content/themes/pet-paws/functions.php"
docker exec %CONTAINER_NAME% bash -c "echo 'function pet_paws_scripts() {' >> /var/www/html/wp-content/themes/pet-paws/functions.php"
docker exec %CONTAINER_NAME% bash -c "echo '    wp_enqueue_style(\"pet-paws-style\", get_stylesheet_uri());' >> /var/www/html/wp-content/themes/pet-paws/functions.php"
docker exec %CONTAINER_NAME% bash -c "echo '}' >> /var/www/html/wp-content/themes/pet-paws/functions.php"
docker exec %CONTAINER_NAME% bash -c "echo 'add_action(\"wp_enqueue_scripts\", \"pet_paws_scripts\");' >> /var/www/html/wp-content/themes/pet-paws/functions.php"

echo.
echo 📝 สร้างไฟล์ style.css...
docker exec %CONTAINER_NAME% bash -c "echo '/*' > /var/www/html/wp-content/themes/pet-paws/style.css"
docker exec %CONTAINER_NAME% bash -c "echo 'Theme Name: Pet Paws' >> /var/www/html/wp-content/themes/pet-paws/style.css"
docker exec %CONTAINER_NAME% bash -c "echo 'Description: Custom pet food store theme' >> /var/www/html/wp-content/themes/pet-paws/style.css"
docker exec %CONTAINER_NAME% bash -c "echo 'Version: 1.0' >> /var/www/html/wp-content/themes/pet-paws/style.css"
docker exec %CONTAINER_NAME% bash -c "echo '*/' >> /var/www/html/wp-content/themes/pet-paws/style.css"

echo.
echo 📝 สร้างไฟล์ index.php...
docker exec %CONTAINER_NAME% bash -c "echo '<?php get_header(); ?>' > /var/www/html/wp-content/themes/pet-paws/index.php"
docker exec %CONTAINER_NAME% bash -c "echo '<?php if (have_posts()) : while (have_posts()) : the_post(); ?>' >> /var/www/html/wp-content/themes/pet-paws/index.php"
docker exec %CONTAINER_NAME% bash -c "echo '    <?php the_title(); ?>' >> /var/www/html/wp-content/themes/pet-paws/index.php"
docker exec %CONTAINER_NAME% bash -c "echo '    <?php the_content(); ?>' >> /var/www/html/wp-content/themes/pet-paws/index.php"
docker exec %CONTAINER_NAME% bash -c "echo '<?php endwhile; endif; ?>' >> /var/www/html/wp-content/themes/pet-paws/index.php"
docker exec %CONTAINER_NAME% bash -c "echo '<?php get_footer(); ?>' >> /var/www/html/wp-content/themes/pet-paws/index.php"

echo.
echo 📝 สร้างไฟล์ header.php...
docker exec %CONTAINER_NAME% bash -c "echo '<!DOCTYPE html>' > /var/www/html/wp-content/themes/pet-paws/header.php"
docker exec %CONTAINER_NAME% bash -c "echo '<html>' >> /var/www/html/wp-content/themes/pet-paws/header.php"
docker exec %CONTAINER_NAME% bash -c "echo '<head>' >> /var/www/html/wp-content/themes/pet-paws/header.php"
docker exec %CONTAINER_NAME% bash -c "echo '    <title><?php bloginfo(\"name\"); ?></title>' >> /var/www/html/wp-content/themes/pet-paws/header.php"
docker exec %CONTAINER_NAME% bash -c "echo '    <?php wp_head(); ?>' >> /var/www/html/wp-content/themes/pet-paws/header.php"
docker exec %CONTAINER_NAME% bash -c "echo '</head>' >> /var/www/html/wp-content/themes/pet-paws/header.php"
docker exec %CONTAINER_NAME% bash -c "echo '<body>' >> /var/www/html/wp-content/themes/pet-paws/header.php"
docker exec %CONTAINER_NAME% bash -c "echo '    <h1><?php bloginfo(\"name\"); ?></h1>' >> /var/www/html/wp-content/themes/pet-paws/header.php"

echo.
echo 📝 สร้างไฟล์ footer.php...
docker exec %CONTAINER_NAME% bash -c "echo '    <p>&copy; <?php echo date(\"Y\"); ?> <?php bloginfo(\"name\"); ?></p>' > /var/www/html/wp-content/themes/pet-paws/footer.php"
docker exec %CONTAINER_NAME% bash -c "echo '    <?php wp_footer(); ?>' >> /var/www/html/wp-content/themes/pet-paws/footer.php"
docker exec %CONTAINER_NAME% bash -c "echo '</body>' >> /var/www/html/wp-content/themes/pet-paws/footer.php"
docker exec %CONTAINER_NAME% bash -c "echo '</html>' >> /var/www/html/wp-content/themes/pet-paws/footer.php"

echo ✅ สร้างธีมพื้นฐานเรียบร้อย

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

