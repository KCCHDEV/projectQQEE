@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 🐾 Pet Food Shop - Demo Data Upload
echo ==================================================
echo.

REM Load environment variables
if exist .env (
    for /f "tokens=1,2 delims==" %%A in (.env) do (
        if "%%A"=="APP_NAME" set APP_NAME=%%B
        if "%%A"=="WORDPRESS_DB_HOST" set WORDPRESS_DB_HOST=%%B
        if "%%A"=="WORDPRESS_DB_NAME" set WORDPRESS_DB_NAME=%%B
        if "%%A"=="WORDPRESS_DB_USER" set WORDPRESS_DB_USER=%%B
        if "%%A"=="WORDPRESS_DB_PASSWORD" set WORDPRESS_DB_PASSWORD=%%B
    )
) else (
    echo ⚠️  .env file not found! Using default values.
    set APP_NAME=pet-food-store
    set WORDPRESS_DB_HOST=localhost
    set WORDPRESS_DB_NAME=wordpress
    set WORDPRESS_DB_USER=wordpress
    set WORDPRESS_DB_PASSWORD=wordpress
)

REM Set defaults if not found in .env
if "%APP_NAME%"=="" set APP_NAME=pet-food-store
if "%WORDPRESS_DB_HOST%"=="" set WORDPRESS_DB_HOST=localhost
if "%WORDPRESS_DB_NAME%"=="" set WORDPRESS_DB_NAME=wordpress
if "%WORDPRESS_DB_USER%"=="" set WORDPRESS_DB_USER=wordpress
if "%WORDPRESS_DB_PASSWORD%"=="" set WORDPRESS_DB_PASSWORD=wordpress

REM Check if WordPress container is running
echo ℹ️  Checking WordPress container status...
docker ps --format "table {{.Names}}" | findstr "%APP_NAME%-wordpress" >nul 2>&1
if errorlevel 1 (
    echo ❌ WordPress container is not running!
    echo ℹ️  Please start your WordPress environment first:
    echo    ./scripts/quick-start.sh
    pause
    exit /b 1
)
echo ✅ WordPress container is running

REM Wait for WordPress to be ready
echo ℹ️  Waiting for WordPress to be ready...
set /a attempts=0
:wait_loop
set /a attempts+=1
curl -s -o nul -w "%%{http_code}" http://localhost:8080 | findstr "200 302" >nul 2>&1
if not errorlevel 1 goto wordpress_ready
if %attempts% geq 30 (
    echo ❌ WordPress did not become ready in time
    pause
    exit /b 1
)
echo Attempt %attempts%/30...
timeout /t 2 /nobreak >nul
goto wait_loop

:wordpress_ready
echo ✅ WordPress is ready!

REM Ensure WP-CLI is available
echo ℹ️  Ensuring WP-CLI is available...
docker exec %APP_NAME%-wordpress wp --version >nul 2>&1
if errorlevel 1 (
    echo ℹ️  Installing WP-CLI in WordPress container...
    docker exec %APP_NAME%-wordpress bash -c "curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/utils/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp"
)
echo ✅ WP-CLI is ready

echo.
echo ℹ️  Starting demo data upload...
echo.

REM Create product categories
echo ℹ️  Creating product categories...

REM Dog Food category
docker exec %APP_NAME%-wordpress wp term create product_cat "Dog Food" --description="Food for dogs of all ages" --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created category: Dog Food

REM Cat Food category
docker exec %APP_NAME%-wordpress wp term create product_cat "Cat Food" --description="Nutritious food for cats" --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created category: Cat Food

REM Bird Food category
docker exec %APP_NAME%-wordpress wp term create product_cat "Bird Food" --description="Healthy seeds and pellets for birds" --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created category: Bird Food

REM Fish Food category
docker exec %APP_NAME%-wordpress wp term create product_cat "Fish Food" --description="Quality food for aquarium fish" --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created category: Fish Food

REM Small Pet Food category
docker exec %APP_NAME%-wordpress wp term create product_cat "Small Pet Food" --description="Food for rabbits, hamsters, and other small pets" --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created category: Small Pet Food

REM Pet Treats category
docker exec %APP_NAME%-wordpress wp term create product_cat "Pet Treats" --description="Delicious treats and snacks" --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created category: Pet Treats

REM Pet Supplements category
docker exec %APP_NAME%-wordpress wp term create product_cat "Pet Supplements" --description="Health supplements for pets" --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created category: Pet Supplements

echo.
echo ℹ️  Creating demo products...

REM Create demo products
call :create_product "Royal Canin Adult Dog Food" "royal-canin-dog" "Premium nutrition for adult dogs" "1250.00" "Dog Food" "10"
call :create_product "Whiskas Cat Food Tuna" "whiskas-cat-tuna" "Delicious tuna flavor for cats" "285.00" "Cat Food" "25"
call :create_product "Hill's Science Diet Puppy" "hills-puppy" "Scientific nutrition for growing puppies" "1890.00" "Dog Food" "8"
call :create_product "Purina Pro Plan Cat Indoor" "purina-cat-indoor" "Specially formulated for indoor cats" "950.00" "Cat Food" "15"
call :create_product "Tropical Fish Flakes" "tropical-fish-flakes" "High-quality flakes for tropical fish" "125.00" "Fish Food" "30"
call :create_product "Kaytee Parakeet Food" "kaytee-parakeet" "Premium seeds for parakeets" "185.00" "Bird Food" "20"
call :create_product "Oxbow Timothy Hay" "oxbow-timothy" "Essential hay for rabbits and guinea pigs" "320.00" "Small Pet Food" "12"
call :create_product "Greenies Dog Treats" "greenies-treats" "Dental treats for healthy teeth" "450.00" "Pet Treats" "18"
call :create_product "Nutri-Vet Hip & Joint" "nutri-vet-joint" "Joint support supplement for dogs" "780.00" "Pet Supplements" "6"
call :create_product "Felix Cat Treats Chicken" "felix-treats" "Tasty chicken treats for cats" "95.00" "Pet Treats" "35"

echo.
echo ℹ️  Configuring WooCommerce settings...

REM Set currency to Thai Baht
docker exec %APP_NAME%-wordpress wp option update woocommerce_currency "THB" --allow-root >nul 2>&1

REM Set currency position
docker exec %APP_NAME%-wordpress wp option update woocommerce_currency_pos "left" --allow-root >nul 2>&1

REM Set thousand separator
docker exec %APP_NAME%-wordpress wp option update woocommerce_price_thousand_sep "," --allow-root >nul 2>&1

REM Set decimal separator
docker exec %APP_NAME%-wordpress wp option update woocommerce_price_decimal_sep "." --allow-root >nul 2>&1

REM Set number of decimals
docker exec %APP_NAME%-wordpress wp option update woocommerce_price_num_decimals "2" --allow-root >nul 2>&1

REM Enable taxes
docker exec %APP_NAME%-wordpress wp option update woocommerce_calc_taxes "yes" --allow-root >nul 2>&1

REM Set default country
docker exec %APP_NAME%-wordpress wp option update woocommerce_default_country "TH" --allow-root >nul 2>&1

REM Enable guest checkout
docker exec %APP_NAME%-wordpress wp option update woocommerce_enable_guest_checkout "yes" --allow-root >nul 2>&1

echo ✅ WooCommerce settings configured

echo.
echo ℹ️  Creating sample pages...

REM Create About Us page
set "about_content=<h2>เกี่ยวกับเรา (About Us)</h2><p>ยินดีต้อนรับสู่ร้านอาหารสัตว์เลี้ยงของเรา! เรามุ่งมั่นที่จะให้อาหารคุณภาพดีที่สุดสำหรับสัตว์เลี้ยงที่คุณรัก</p><p>Welcome to our pet food store! We are committed to providing the highest quality food for your beloved pets.</p><h3>ผลิตภัณฑ์ของเรา (Our Products)</h3><ul><li>อาหารสุนัขและแมวคุณภาพพรีเมียม</li><li>อาหารสัตว์เลี้ยงขนาดเล็ก</li><li>ขนมและของเล่นสำหรับสัตว์เลี้ยง</li><li>วิตามินและอาหารเสริม</li></ul>"

docker exec %APP_NAME%-wordpress wp post create --post_type=page --post_title="About Us | เกี่ยวกับเรา" --post_content="!about_content!" --post_status=publish --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created About Us page

REM Create Contact page
set "contact_content=<h2>ติดต่อเรา (Contact Us)</h2><p><strong>ที่อยู่:</strong> 123 ถนนเพชรบุรี กรุงเทพฯ 10400</p><p><strong>โทรศัพท์:</strong> 02-123-4567</p><p><strong>อีเมล:</strong> info@petfoodshop.com</p><p><strong>เวลาทำการ:</strong> จันทร์-อาทิตย์ 9:00-20:00</p><h3>Follow Us</h3><p>Facebook: @PetFoodShopTH<br>Instagram: @petfoodshop_th<br>Line: @petfoodshop</p>"

docker exec %APP_NAME%-wordpress wp post create --post_type=page --post_title="Contact Us | ติดต่อเรา" --post_content="!contact_content!" --post_status=publish --porcelain --allow-root >nul 2>&1
if not errorlevel 1 echo ✅ Created Contact page

echo.
echo ✅ Demo data upload completed successfully!
echo ℹ️  You can now visit your store at: http://localhost:8080
echo ℹ️  Admin panel: http://localhost:8080/wp-admin
echo ℹ️  Default admin credentials: admin / admin
echo.
pause
goto :eof

REM Function to create a product
:create_product
set "product_name=%~1"
set "product_slug=%~2"
set "product_desc=%~3"
set "product_price=%~4"
set "product_category=%~5"
set "stock_qty=%~6"

for /f %%i in ('docker exec %APP_NAME%-wordpress wp wc product create --name="%product_name%" --slug="%product_slug%" --type=simple --status=publish --description="%product_desc%" --short_description="%product_desc%" --regular_price="%product_price%" --manage_stock=true --stock_quantity="%stock_qty%" --stock_status="in-stock" --porcelain --allow-root 2^>nul') do set product_id=%%i

if defined product_id (
    REM Get category ID and assign it
    for /f %%j in ('docker exec %APP_NAME%-wordpress wp term list product_cat --name="%product_category%" --field=term_id --allow-root 2^>nul') do set cat_id=%%j
    if defined cat_id (
        docker exec %APP_NAME%-wordpress wp wc product update "!product_id!" --categories="[{\"id\":!cat_id!}]" --allow-root >nul 2>&1
    )
    echo ✅ Created product: %product_name% (ID: !product_id!, Price: ฿%product_price%)
) else (
    echo ⚠️  Failed to create product: %product_name%
)

timeout /t 1 /nobreak >nul
goto :eof