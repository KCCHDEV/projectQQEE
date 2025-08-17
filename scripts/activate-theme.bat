@echo off
chcp 65001
setlocal enabledelayedexpansion

REM Activate Pet Paws Theme Script

echo 🎨 Activating Pet Paws Theme...
echo ================================

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="APP_URL" set APP_URL=%%B
    )
)

if "%APP_NAME%"=="" set APP_NAME=pet-food-store

REM Wait for WordPress to be ready
echo ⏳ Waiting for WordPress...
:wait_loop
docker exec %APP_NAME%_wordpress wp core is-installed --allow-root >nul 2>&1
if errorlevel 1 (
    echo -n .
    timeout /t 5 /nobreak >nul
    goto :wait_loop
)
echo.

REM Create assets directories if they don't exist
echo 📁 Creating theme directories...
docker exec %APP_NAME%_wordpress mkdir -p /var/www/html/wp-content/themes/pet-paws/assets/js
docker exec %APP_NAME%_wordpress mkdir -p /var/www/html/wp-content/themes/pet-paws/assets/css
docker exec %APP_NAME%_wordpress mkdir -p /var/www/html/wp-content/themes/pet-paws/assets/images

REM Set proper permissions
echo 🔒 Setting permissions...
docker exec %APP_NAME%_wordpress chown -R www-data:www-data /var/www/html/wp-content/themes/pet-paws

REM Activate the theme
echo 🎨 Activating Pet Paws theme...
docker exec %APP_NAME%_wordpress wp theme activate pet-paws --allow-root

REM Create sample pages if they don't exist
echo 📄 Creating sample pages...

REM About page
docker exec %APP_NAME%_wordpress wp post create --post_type=page --post_title="About Us" --post_content="<h2>Welcome to Pet Paws</h2><p>We are passionate about providing the best products for your beloved pets. Our mission is to ensure every pet lives a happy, healthy life with premium nutrition and care.</p>" --post_status=publish --allow-root >nul 2>&1 || echo About page already exists

REM Contact page
docker exec %APP_NAME%_wordpress wp post create --post_type=page --post_title="Contact" --post_content="<h2>Get in Touch</h2><p>We'd love to hear from you! Contact us for any questions about our products or services.</p>" --post_status=publish --allow-root >nul 2>&1 || echo Contact page already exists

REM Create menus
echo 🍔 Creating navigation menus...

REM Create primary menu
docker exec %APP_NAME%_wordpress wp menu create "Primary Menu" --allow-root >nul 2>&1 || echo Primary menu already exists

REM Add items to primary menu
docker exec %APP_NAME%_wordpress wp menu item add-custom "Primary Menu" "Home" "/" --allow-root >nul 2>&1
docker exec %APP_NAME%_wordpress wp menu item add-post "Primary Menu" $(docker exec %APP_NAME%_wordpress wp post list --post_type=page --name=shop --field=ID --allow-root) --allow-root >nul 2>&1
docker exec %APP_NAME%_wordpress wp menu item add-post "Primary Menu" $(docker exec %APP_NAME%_wordpress wp post list --post_type=page --name=about-us --field=ID --allow-root) --allow-root >nul 2>&1
docker exec %APP_NAME%_wordpress wp menu item add-post "Primary Menu" $(docker exec %APP_NAME%_wordpress wp post list --post_type=page --name=contact --field=ID --allow-root) --allow-root >nul 2>&1

REM Assign menu to location
docker exec %APP_NAME%_wordpress wp menu location assign "Primary Menu" primary --allow-root >nul 2>&1

REM Set homepage
echo 🏠 Setting homepage...
docker exec %APP_NAME%_wordpress wp option update show_on_front "page" --allow-root
docker exec %APP_NAME%_wordpress wp option update page_on_front $(docker exec %APP_NAME%_wordpress wp post list --post_type=page --name=home --field=ID --allow-root || echo "0") --allow-root

REM Set theme options
echo ⚙️ Setting theme options...
docker exec %APP_NAME%_wordpress wp option update pet_paws_phone "02-123-4567" --allow-root
docker exec %APP_NAME%_wordpress wp option update pet_paws_email "info@petpaws.co.th" --allow-root
docker exec %APP_NAME%_wordpress wp option update pet_paws_facebook "https://facebook.com/petpaws" --allow-root
docker exec %APP_NAME%_wordpress wp option update pet_paws_instagram "https://instagram.com/petpaws" --allow-root

REM Clear cache
echo 🧹 Clearing cache...
docker exec %APP_NAME%_wordpress wp cache flush --allow-root >nul 2>&1

echo.
echo ✅ Pet Paws theme activated successfully!
echo.
echo 📌 Theme Features:
echo    - Beautiful modern design
echo    - Fully responsive
echo    - WooCommerce ready
echo    - Thai language support
echo    - SEO optimized
echo.
if not "%APP_URL%"=="" (
    echo 🌐 Visit your site: %APP_URL%
    echo 👤 Admin panel: %APP_URL%/wp-admin
) else (
    echo 🌐 Visit your site: http://localhost:8000
    echo 👤 Admin panel: http://localhost:8000/wp-admin
)
echo.
echo 💡 To customize the theme:
echo    - Go to Appearance ^> Customize
echo    - Upload your logo
echo    - Set your colors
echo    - Configure social links

pause
