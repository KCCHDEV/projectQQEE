<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php wp_title('|', true, 'right'); ?><?php bloginfo('name'); ?></title>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>

<!-- Header -->
<header class="site-header">
    <div class="header-container">
        <a href="<?php echo home_url(); ?>" class="site-title">
            🐾 <?php bloginfo('name'); ?>
        </a>
        
        <nav class="main-nav">
            <?php
            wp_nav_menu(array(
                'theme_location' => 'primary',
                'container' => false,
                'fallback_cb' => 'simple_pet_store_fallback_menu'
            ));
            ?>
        </nav>
    </div>
</header>

<!-- Hero Section -->
<section class="hero-section">
    <div class="hero-content">
        <h1>ร้านขายอุปกรณ์และอาหารสัตว์เลี้ยง</h1>
        <p>สินค้าคุณภาพ ราคาดี เพื่อสัตว์เลี้ยงที่คุณรัก</p>
        <a href="<?php echo get_permalink(wc_get_page_id('shop')); ?>" class="btn">เลือกซื้อสินค้า</a>
    </div>
</section>

<!-- Main Content -->
<main class="main-content">
    
    <!-- Categories Section -->
    <section class="categories-section">
        <h2 class="section-title">หมวดหมู่สินค้า</h2>
        <div class="categories-grid">
            <?php
            $categories = get_terms(array(
                'taxonomy' => 'product_cat',
                'hide_empty' => false,
                'number' => 6
            ));
            
            $category_icons = array(
                '🐕', '🐱', '🐦', '🐠', '🐹', '🦎'
            );
            
            if ($categories && !is_wp_error($categories)) {
                foreach ($categories as $index => $category) {
                    $icon = isset($category_icons[$index]) ? $category_icons[$index] : '🐾';
                    echo '<a href="' . get_term_link($category) . '" class="category-card">';
                    echo '<div class="category-icon">' . $icon . '</div>';
                    echo '<div class="category-name">' . $category->name . '</div>';
                    echo '</a>';
                }
            } else {
                // Default categories if none exist
                $default_categories = array(
                    array('name' => 'อาหารสุนัข', 'icon' => '🐕'),
                    array('name' => 'อาหารแมว', 'icon' => '🐱'),
                    array('name' => 'ของเล่น', 'icon' => '🎾'),
                    array('name' => 'อุปกรณ์ดูแล', 'icon' => '🧴'),
                    array('name' => 'บ้านและที่นอน', 'icon' => '🏠'),
                    array('name' => 'ปลาและนก', 'icon' => '🐠')
                );
                
                foreach ($default_categories as $category) {
                    echo '<div class="category-card">';
                    echo '<div class="category-icon">' . $category['icon'] . '</div>';
                    echo '<div class="category-name">' . $category['name'] . '</div>';
                    echo '</div>';
                }
            }
            ?>
        </div>
    </section>

    <!-- Featured Products -->
    <section class="products-section">
        <h2 class="section-title">สินค้าแนะนำ</h2>
        <div class="products-grid">
            <?php
            if (class_exists('WooCommerce')) {
                $featured_products = wc_get_featured_product_ids();
                $args = array(
                    'post_type' => 'product',
                    'posts_per_page' => 6,
                    'post__in' => !empty($featured_products) ? $featured_products : array(),
                    'meta_query' => WC()->query->get_meta_query()
                );
                
                if (empty($featured_products)) {
                    // If no featured products, get latest products
                    $args = array(
                        'post_type' => 'product',
                        'posts_per_page' => 6,
                        'meta_query' => WC()->query->get_meta_query()
                    );
                }
                
                $products = new WP_Query($args);
                
                if ($products->have_posts()) {
                    while ($products->have_posts()) {
                        $products->the_post();
                        global $product;
                        ?>
                        <div class="product-card">
                            <a href="<?php the_permalink(); ?>">
                                <?php if (has_post_thumbnail()) : ?>
                                    <?php the_post_thumbnail('medium', array('class' => 'product-image')); ?>
                                <?php else : ?>
                                    <img src="https://via.placeholder.com/280x200/667eea/white?text=<?php echo urlencode(get_the_title()); ?>" class="product-image" alt="<?php the_title(); ?>">
                                <?php endif; ?>
                            </a>
                            
                            <div class="product-info">
                                <h3 class="product-title">
                                    <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                                </h3>
                                
                                <div class="product-price">
                                    <?php echo $product->get_price_html(); ?>
                                </div>
                                
                                <div class="product-description">
                                    <?php echo wp_trim_words(get_the_excerpt(), 15); ?>
                                </div>
                                
                                <a href="<?php the_permalink(); ?>" class="btn">ดูรายละเอียด</a>
                            </div>
                        </div>
                        <?php
                    }
                    wp_reset_postdata();
                } else {
                    // Show sample products if no products exist
                    $sample_products = array(
                        array('name' => 'อาหารสุนัขพรีเมียม', 'price' => '฿450', 'image' => 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=280&h=200&fit=crop'),
                        array('name' => 'ของเล่นลูกบอล', 'price' => '฿89', 'image' => 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=280&h=200&fit=crop'),
                        array('name' => 'อาหารแมวเปียก', 'price' => '฿35', 'image' => 'https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=280&h=200&fit=crop'),
                        array('name' => 'บ้านสุนัขไม้', 'price' => '฿1,200', 'image' => 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=280&h=200&fit=crop'),
                        array('name' => 'ปลาอาหารแห้ง', 'price' => '฿180', 'image' => 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=280&h=200&fit=crop'),
                        array('name' => 'ที่นอนแมวนุ่ม', 'price' => '฿650', 'image' => 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=280&h=200&fit=crop')
                    );
                    
                    foreach ($sample_products as $product) {
                        echo '<div class="product-card">';
                        echo '<img src="' . $product['image'] . '" class="product-image" alt="' . $product['name'] . '">';
                        echo '<div class="product-info">';
                        echo '<h3 class="product-title">' . $product['name'] . '</h3>';
                        echo '<div class="product-price">' . $product['price'] . '</div>';
                        echo '<div class="product-description">สินค้าคุณภาพดี เหมาะสำหรับสัตว์เลี้ยงของคุณ</div>';
                        echo '<a href="#" class="btn">ดูรายละเอียด</a>';
                        echo '</div>';
                        echo '</div>';
                    }
                }
            } else {
                // Show sample products if WooCommerce is not active
                $sample_products = array(
                    array('name' => 'อาหารสุนัขพรีเมียม', 'price' => '฿450', 'image' => 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=280&h=200&fit=crop'),
                    array('name' => 'ของเล่นลูกบอล', 'price' => '฿89', 'image' => 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=280&h=200&fit=crop'),
                    array('name' => 'อาหารแมวเปียก', 'price' => '฿35', 'image' => 'https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=280&h=200&fit=crop'),
                    array('name' => 'บ้านสุนัขไม้', 'price' => '฿1,200', 'image' => 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=280&h=200&fit=crop')
                );
                
                foreach ($sample_products as $product) {
                    echo '<div class="product-card">';
                    echo '<img src="' . $product['image'] . '" class="product-image" alt="' . $product['name'] . '">';
                    echo '<div class="product-info">';
                    echo '<h3 class="product-title">' . $product['name'] . '</h3>';
                    echo '<div class="product-price">' . $product['price'] . '</div>';
                    echo '<div class="product-description">สินค้าคุณภาพดี เหมาะสำหรับสัตว์เลี้ยงของคุณ</div>';
                    echo '<a href="#" class="btn">ดูรายละเอียด</a>';
                    echo '</div>';
                    echo '</div>';
                }
            }
            ?>
        </div>
    </section>
    
</main>

<!-- Footer -->
<footer class="site-footer">
    <div class="footer-content">
        <div class="footer-section">
            <h3>เกี่ยวกับเรา</h3>
            <p>ร้านขายอุปกรณ์และอาหารสัตว์เลี้ยงคุณภาพ มีสินค้าหลากหลายสำหรับสัตว์เลี้ยงทุกชนิด</p>
        </div>
        
        <div class="footer-section">
            <h3>ติดต่อเรา</h3>
            <ul>
                <li>📞 โทร: 02-xxx-xxxx</li>
                <li>📧 อีเมล: info@petstore.com</li>
                <li>📍 ที่อยู่: กรุงเทพมหานคร</li>
            </ul>
        </div>
        
        <div class="footer-section">
            <h3>บริการ</h3>
            <ul>
                <li><a href="#">จัดส่งฟรี</a></li>
                <li><a href="#">รับประกันสินค้า</a></li>
                <li><a href="#">คำแนะนำการเลี้ยง</a></li>
                <li><a href="#">บริการหลังการขาย</a></li>
            </ul>
        </div>
        
        <div class="footer-section">
            <h3>ติดตามเรา</h3>
            <ul>
                <li><a href="#">📘 Facebook</a></li>
                <li><a href="#">📷 Instagram</a></li>
                <li><a href="#">🐦 Twitter</a></li>
                <li><a href="#">📺 YouTube</a></li>
            </ul>
        </div>
    </div>
    
    <div class="footer-bottom">
        <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?>. สงวนลิขสิทธิ์.</p>
    </div>
</footer>

<?php wp_footer(); ?>
</body>
</html>