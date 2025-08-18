<?php
/**
 * Simple Pet Store Theme Functions
 * เทมเพลตร้านสัตว์เลี้ยงแบบง่าย
 */

// Theme Support
function simple_pet_store_setup() {
    // Add theme support
    add_theme_support('post-thumbnails');
    add_theme_support('woocommerce');
    add_theme_support('wc-product-gallery-zoom');
    add_theme_support('wc-product-gallery-lightbox');
    add_theme_support('wc-product-gallery-slider');
    add_theme_support('title-tag');
    add_theme_support('html5', array('search-form', 'comment-form', 'comment-list', 'gallery', 'caption'));
    
    // Register navigation menu
    register_nav_menus(array(
        'primary' => 'เมนูหลัก',
    ));
}
add_action('after_setup_theme', 'simple_pet_store_setup');

// Enqueue styles and scripts
function simple_pet_store_scripts() {
    wp_enqueue_style('simple-pet-store-style', get_stylesheet_uri(), array(), '1.0.0');
    
    // Add custom CSS for better WooCommerce integration
    $custom_css = "
        .woocommerce .products .product {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .woocommerce .products .product:hover {
            transform: translateY(-5px);
        }
        .woocommerce .products .product img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        .woocommerce .products .product .woocommerce-loop-product__title {
            font-size: 1.2rem;
            margin: 1rem;
            color: #333;
        }
        .woocommerce .products .product .price {
            font-size: 1.3rem;
            font-weight: bold;
            color: #ff6b6b;
            margin: 0 1rem 1rem;
        }
        .woocommerce .products .product .button {
            background: #ff6b6b;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 20px;
            margin: 0 1rem 1rem;
            transition: all 0.3s;
        }
        .woocommerce .products .product .button:hover {
            background: #ff5252;
            transform: translateY(-2px);
        }
        .woocommerce-breadcrumb {
            margin: 2rem 0;
            padding: 1rem;
            background: white;
            border-radius: 10px;
        }
        .woocommerce div.product {
            background: white;
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            margin: 2rem 0;
        }
        .woocommerce div.product .product_title {
            color: #333;
            font-size: 2rem;
        }
        .woocommerce div.product .price {
            color: #ff6b6b;
            font-size: 2rem;
            font-weight: bold;
        }
        .woocommerce div.product .single_add_to_cart_button {
            background: #ff6b6b;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 25px;
            font-size: 1.1rem;
            transition: all 0.3s;
        }
        .woocommerce div.product .single_add_to_cart_button:hover {
            background: #ff5252;
            transform: translateY(-2px);
        }
    ";
    wp_add_inline_style('simple-pet-store-style', $custom_css);
}
add_action('wp_enqueue_scripts', 'simple_pet_store_scripts');

// Fallback menu
function simple_pet_store_fallback_menu() {
    echo '<ul>';
    echo '<li><a href="' . home_url() . '">หน้าแรก</a></li>';
    if (class_exists('WooCommerce')) {
        echo '<li><a href="' . get_permalink(wc_get_page_id('shop')) . '">ร้านค้า</a></li>';
        echo '<li><a href="' . get_permalink(wc_get_page_id('cart')) . '">ตรวจสอบสินค้า</a></li>';
        echo '<li><a href="' . get_permalink(wc_get_page_id('myaccount')) . '">บัญชีของฉัน</a></li>';
    }
    echo '<li><a href="' . get_permalink(get_option('page_for_posts')) . '">บทความ</a></li>';
    echo '</ul>';
}

// Customize WooCommerce
function simple_pet_store_woocommerce_setup() {
    // Remove default WooCommerce styles
    add_filter('woocommerce_enqueue_styles', '__return_empty_array');
    
    // Change number of products per row
    add_filter('loop_shop_columns', function() { return 3; });
    
    // Change number of products per page
    add_filter('loop_shop_per_page', function() { return 12; });
}
add_action('after_setup_theme', 'simple_pet_store_woocommerce_setup');

// Add custom body classes
function simple_pet_store_body_classes($classes) {
    $classes[] = 'simple-pet-store';
    return $classes;
}
add_filter('body_class', 'simple_pet_store_body_classes');

// Customize excerpt length
function simple_pet_store_excerpt_length($length) {
    return 20;
}
add_filter('excerpt_length', 'simple_pet_store_excerpt_length');

// Add custom excerpt more
function simple_pet_store_excerpt_more($more) {
    return '...';
}
add_filter('excerpt_more', 'simple_pet_store_excerpt_more');

// Add widget areas
function simple_pet_store_widgets_init() {
    register_sidebar(array(
        'name'          => 'ไซด์บาร์หลัก',
        'id'            => 'main-sidebar',
        'description'   => 'ไซด์บาร์สำหรับหน้าบทความและหน้าต่างๆ',
        'before_widget' => '<div class="widget">',
        'after_widget'  => '</div>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ));
    
    register_sidebar(array(
        'name'          => 'ฟุตเตอร์ 1',
        'id'            => 'footer-1',
        'description'   => 'พื้นที่ฟุตเตอร์คอลัมน์ที่ 1',
        'before_widget' => '<div class="footer-widget">',
        'after_widget'  => '</div>',
        'before_title'  => '<h3>',
        'after_title'   => '</h3>',
    ));
}
add_action('widgets_init', 'simple_pet_store_widgets_init');

// Auto-install sample data
function simple_pet_store_create_sample_data() {
    // Only run once
    if (get_option('simple_pet_store_sample_data_created')) {
        return;
    }
    
    // Create sample pages
    $pages = array(
        'เกี่ยวกับเรา' => 'ร้านขายอุปกรณ์และอาหารสัตว์เลี้ยงที่มีคุณภาพ เราให้บริการด้วยใจและมีประสบการณ์มากกว่า 10 ปี',
        'ติดต่อเรา' => 'ติดต่อเราได้ที่ โทร: 02-xxx-xxxx อีเมล: info@petstore.com',
        'นโยบายความเป็นส่วนตัว' => 'เราให้ความสำคัญกับความเป็นส่วนตัวของลูกค้า',
        'เงื่อนไขการใช้งาน' => 'เงื่อนไขการใช้งานเว็บไซต์และการสั่งซื้อสินค้า'
    );
    
    foreach ($pages as $title => $content) {
        $page_check = get_page_by_title($title);
        if (!$page_check) {
            wp_insert_post(array(
                'post_title' => $title,
                'post_content' => $content,
                'post_status' => 'publish',
                'post_type' => 'page'
            ));
        }
    }
    
    // Create sample blog posts
    $posts = array(
        'วิธีดูแลสุนัขในหน้าร้อน' => 'คำแนะนำการดูแลสุนัขให้ปลอดภัยในช่วงหน้าร้อน รวมถึงการให้น้ำ การออกกำลังกาย และการป้องกันจากความร้อน',
        'อาหารแมวที่ดีต่อสุขภาพ' => 'การเลือกอาหารแมวที่มีคุณภาพ สารอาหารที่จำเป็น และวิธีการให้อาหารที่ถูกต้อง',
        '5 ของเล่นที่สุนัขชอบ' => 'รวมของเล่นที่สุนัขชอบและช่วยพัฒนาสติปัญญา เหมาะสำหรับสุนัขทุกวัย',
        'การดูแลปลาสวยงาม' => 'เคล็ดลับการดูแลปลาในตู้ปลา การเลือกอาหาร และการรักษาความสะอาดของน้ำ'
    );
    
    foreach ($posts as $title => $content) {
        $post_check = get_page_by_title($title, OBJECT, 'post');
        if (!$post_check) {
            wp_insert_post(array(
                'post_title' => $title,
                'post_content' => $content,
                'post_status' => 'publish',
                'post_type' => 'post',
                'post_category' => array(1) // Default category
            ));
        }
    }
    
    // Create sample product categories if WooCommerce is active
    if (class_exists('WooCommerce')) {
        $categories = array(
            'อาหารสุนัข' => 'อาหารสำหรับสุนัขทุกวัย',
            'อาหารแมว' => 'อาหารสำหรับแมวทุกวัย',
            'ของเล่น' => 'ของเล่นสำหรับสัตว์เลี้ยง',
            'อุปกรณ์ดูแล' => 'อุปกรณ์การดูแลสัตว์เลี้ยง',
            'บ้านและที่นอน' => 'บ้านและที่นอนสำหรับสัตว์เลี้ยง',
            'อาหารปลาและนก' => 'อาหารสำหรับปลาและนก'
        );
        
        foreach ($categories as $name => $description) {
            if (!term_exists($name, 'product_cat')) {
                wp_insert_term($name, 'product_cat', array(
                    'description' => $description,
                ));
            }
        }
    }
    
    // Set flag to prevent running again
    update_option('simple_pet_store_sample_data_created', true);
}
add_action('after_switch_theme', 'simple_pet_store_create_sample_data');

// Customizer settings
function simple_pet_store_customize_register($wp_customize) {
    // Add section
    $wp_customize->add_section('simple_pet_store_settings', array(
        'title' => 'การตั้งค่าร้านสัตว์เลี้ยง',
        'priority' => 30,
    ));
    
    // Hero title
    $wp_customize->add_setting('hero_title', array(
        'default' => 'ร้านขายอุปกรณ์และอาหารสัตว์เลี้ยง',
        'sanitize_callback' => 'sanitize_text_field',
    ));
    
    $wp_customize->add_control('hero_title', array(
        'label' => 'หัวข้อหลัก',
        'section' => 'simple_pet_store_settings',
        'type' => 'text',
    ));
    
    // Hero description
    $wp_customize->add_setting('hero_description', array(
        'default' => 'สินค้าคุณภาพ ราคาดี เพื่อสัตว์เลี้ยงที่คุณรัก',
        'sanitize_callback' => 'sanitize_text_field',
    ));
    
    $wp_customize->add_control('hero_description', array(
        'label' => 'คำอธิบาย',
        'section' => 'simple_pet_store_settings',
        'type' => 'textarea',
    ));
}
add_action('customize_register', 'simple_pet_store_customize_register');
?>