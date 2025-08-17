@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🎨 สร้างไฟล์ธีม WordPress...

REM Create theme directory
if not exist "wp-content\themes\pet-paws" mkdir "wp-content\themes\pet-paws"

REM Copy all theme files from template
if exist "templates\pet-paws-theme" (
    xcopy "templates\pet-paws-theme\*" "wp-content\themes\pet-paws\" /E /Y /Q >nul
    echo ✅ คัดลอกไฟล์ธีมทั้งหมดจาก template
) else (
    echo ❌ ไม่พบโฟลเดอร์ templates\pet-paws-theme
    echo สร้างไฟล์ธีมพื้นฐาน...
    
    REM Create basic style.css
    echo /* > "wp-content\themes\pet-paws\style.css"
    echo Theme Name: Pet Paws >> "wp-content\themes\pet-paws\style.css"
    echo Description: Custom pet food store theme >> "wp-content\themes\pet-paws\style.css"
    echo Version: 1.0 >> "wp-content\themes\pet-paws\style.css"
    echo */ >> "wp-content\themes\pet-paws\style.css"
    
    REM Create basic functions.php
    echo // Pet Paws Theme Functions > "wp-content\themes\pet-paws\functions.php"
    echo add_action('wp_enqueue_scripts', 'pet_paws_scripts'); >> "wp-content\themes\pet-paws\functions.php"
    echo function pet_paws_scripts() { >> "wp-content\themes\pet-paws\functions.php"
    echo     wp_enqueue_style('pet-paws-style', get_stylesheet_uri()); >> "wp-content\themes\pet-paws\functions.php"
    echo } >> "wp-content\themes\pet-paws\functions.php"
    
    REM Create basic index.php
    echo get_header(); > "wp-content\themes\pet-paws\index.php"
    echo if (have_posts()) : while (have_posts()) : the_post(); >> "wp-content\themes\pet-paws\index.php"
    echo     the_title(); >> "wp-content\themes\pet-paws\index.php"
    echo     the_content(); >> "wp-content\themes\pet-paws\index.php"
    echo endwhile; endif; >> "wp-content\themes\pet-paws\index.php"
    echo get_footer(); >> "wp-content\themes\pet-paws\index.php"
    
    REM Create basic header.php
    echo !DOCTYPE html > "wp-content\themes\pet-paws\header.php"
    echo html >> "wp-content\themes\pet-paws\header.php"
    echo head >> "wp-content\themes\pet-paws\header.php"
    echo     title bloginfo('name'); /title >> "wp-content\themes\pet-paws\header.php"
    echo     wp_head(); >> "wp-content\themes\pet-paws\header.php"
    echo /head >> "wp-content\themes\pet-paws\header.php"
    echo body >> "wp-content\themes\pet-paws\header.php"
    echo     h1 bloginfo('name'); /h1 >> "wp-content\themes\pet-paws\header.php"
    
    REM Create basic footer.php
    echo     p &copy; echo date('Y'); bloginfo('name'); /p >> "wp-content\themes\pet-paws\footer.php"
    echo     wp_footer(); >> "wp-content\themes\pet-paws\footer.php"
    echo /body >> "wp-content\themes\pet-paws\footer.php"
    echo /html >> "wp-content\themes\pet-paws\footer.php"
    
    echo ✅ สร้างไฟล์ธีมพื้นฐาน
)

REM Copy JavaScript from rimping template if available
if exist "dev-workspace\ui-template\script.js" (
    copy "dev-workspace\ui-template\script.js" "wp-content\themes\pet-paws\script.js" >nul
    echo ✅ คัดลอก JavaScript จาก rimping template
)

echo ✅ สร้างธีม Pet Paws เรียบร้อย
