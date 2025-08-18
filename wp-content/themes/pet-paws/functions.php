<?php
// Pet Paws Theme Functions

// Theme Setup
function pet_paws_setup() {
    // Add theme support for various features
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('custom-logo');
    add_theme_support('html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
    ));
    
    // Add WooCommerce support
    add_theme_support('woocommerce');
    add_theme_support('wc-product-gallery-zoom');
    add_theme_support('wc-product-gallery-lightbox');
    add_theme_support('wc-product-gallery-slider');
    
    // Register navigation menus
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'pet-paws'),
        'footer' => __('Footer Menu', 'pet-paws'),
    ));
}
add_action('after_setup_theme', 'pet_paws_setup');

// Enqueue scripts and styles
function pet_paws_scripts() {
    // Enqueue main stylesheet
    wp_enqueue_style('pet-paws-style', get_stylesheet_uri(), array(), '1.0.0');
    
    // Enqueue custom JavaScript
    wp_enqueue_script('pet-paws-script', get_template_directory_uri() . '/script.js', array('jquery'), '1.0.0', true);
    
    // Localize script for AJAX
    wp_localize_script('pet-paws-script', 'pet_paws_ajax', array(
        'ajax_url' => admin_url('admin-ajax.php'),
        'nonce' => wp_create_nonce('pet_paws_nonce'),
    ));
}
add_action('wp_enqueue_scripts', 'pet_paws_scripts');

// Register widget areas
function pet_paws_widgets_init() {
    register_sidebar(array(
        'name' => __('Sidebar', 'pet-paws'),
        'id' => 'sidebar-1',
        'description' => __('Add widgets here.', 'pet-paws'),
        'before_widget' => '<section id="%1$s" class="widget %2$s">',
        'after_widget' => '</section>',
        'before_title' => '<h2 class="widget-title">',
        'after_title' => '</h2>',
    ));
    
    register_sidebar(array(
        'name' => __('Footer Widget Area', 'pet-paws'),
        'id' => 'footer-1',
        'description' => __('Add widgets here.', 'pet-paws'),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget' => '</div>',
        'before_title' => '<h3 class="widget-title">',
        'after_title' => '</h3>',
    ));
}
add_action('widgets_init', 'pet_paws_widgets_init');

// Customize WooCommerce
function pet_paws_woocommerce_setup() {
    // Remove default WooCommerce styles
    add_filter('woocommerce_enqueue_styles', '__return_empty_array');
    
    // Customize WooCommerce product loop
    remove_action('woocommerce_before_shop_loop_item', 'woocommerce_template_loop_product_link_open', 10);
    remove_action('woocommerce_after_shop_loop_item', 'woocommerce_template_loop_product_link_close', 5);
    remove_action('woocommerce_shop_loop_item_title', 'woocommerce_template_loop_product_title', 10);
    remove_action('woocommerce_after_shop_loop_item_title', 'woocommerce_template_loop_rating', 5);
    remove_action('woocommerce_after_shop_loop_item_title', 'woocommerce_template_loop_price', 10);
    remove_action('woocommerce_after_shop_loop_item', 'woocommerce_template_loop_add_to_cart', 10);
    
    // Add custom product loop structure
    add_action('woocommerce_before_shop_loop_item', 'pet_paws_product_card_start', 10);
    add_action('woocommerce_shop_loop_item_title', 'pet_paws_product_title', 10);
    add_action('woocommerce_after_shop_loop_item_title', 'pet_paws_product_price', 10);
    add_action('woocommerce_after_shop_loop_item', 'pet_paws_product_card_end', 10);
}
add_action('after_setup_theme', 'pet_paws_woocommerce_setup');

// Custom product card functions
function pet_paws_product_card_start() {
    echo '<div class="product-card">';
    echo '<div class="product-image">';
}

function pet_paws_product_title() {
    echo '<h3 class="product-title">' . get_the_title() . '</h3>';
}

function pet_paws_product_price() {
    global $product;
    if ($product) {
        echo '<div class="product-price">' . $product->get_price_html() . '</div>';
    }
}

function pet_paws_product_card_end() {
    echo '</div>'; // Close product-image
    echo '</div>'; // Close product-card
}

// Custom excerpt length
function pet_paws_excerpt_length($length) {
    return 20;
}
add_filter('excerpt_length', 'pet_paws_excerpt_length');

// Custom excerpt more
function pet_paws_excerpt_more($more) {
    return '...';
}
add_filter('excerpt_more', 'pet_paws_excerpt_more');

// Add custom image sizes
add_image_size('product-thumbnail', 300, 300, true);
add_image_size('hero-image', 1200, 500, true);

// Customize login page
function pet_paws_login_logo() {
    echo '<style type="text/css">
        #login h1 a {
            background-image: url(' . get_template_directory_uri() . '/logo.png) !important;
            background-size: contain !important;
            width: 300px !important;
            height: 100px !important;
        }
    </style>';
}
add_action('login_head', 'pet_paws_login_logo');

// Add custom post types for pet products
function pet_paws_custom_post_types() {
    // Pet Products
    register_post_type('pet_product', array(
        'labels' => array(
            'name' => 'Pet Products',
            'singular_name' => 'Pet Product',
        ),
        'public' => true,
        'has_archive' => true,
        'supports' => array('title', 'editor', 'thumbnail', 'excerpt'),
        'menu_icon' => 'dashicons-pets',
    ));
}
add_action('init', 'pet_paws_custom_post_types');

// Add custom meta boxes
function pet_paws_add_meta_boxes() {
    add_meta_box(
        'pet_product_details',
        'Product Details',
        'pet_paws_product_details_callback',
        'pet_product',
        'normal',
        'high'
    );
}
add_action('add_meta_boxes', 'pet_paws_add_meta_boxes');

function pet_paws_product_details_callback($post) {
    wp_nonce_field('pet_paws_save_meta_box_data', 'pet_paws_meta_box_nonce');
    
    $price = get_post_meta($post->ID, '_pet_product_price', true);
    $category = get_post_meta($post->ID, '_pet_product_category', true);
    
    echo '<table class="form-table">';
    echo '<tr><th><label for="pet_product_price">Price (฿)</label></th>';
    echo '<td><input type="number" id="pet_product_price" name="pet_product_price" value="' . esc_attr($price) . '" step="0.01" /></td></tr>';
    echo '<tr><th><label for="pet_product_category">Category</label></th>';
    echo '<td><select id="pet_product_category" name="pet_product_category">';
    echo '<option value="">Select Category</option>';
    echo '<option value="dog-food"' . selected($category, 'dog-food', false) . '>Dog Food</option>';
    echo '<option value="cat-food"' . selected($category, 'cat-food', false) . '>Cat Food</option>';
    echo '<option value="toys"' . selected($category, 'toys', false) . '>Pet Toys</option>';
    echo '</select></td></tr>';
    echo '</table>';
}

function pet_paws_save_meta_box_data($post_id) {
    if (!isset($_POST['pet_paws_meta_box_nonce'])) {
        return;
    }
    
    if (!wp_verify_nonce($_POST['pet_paws_meta_box_nonce'], 'pet_paws_save_meta_box_data')) {
        return;
    }
    
    if (defined('DOING_AUTOSAVE') && DOING_AUTOSAVE) {
        return;
    }
    
    if (isset($_POST['post_type']) && 'pet_product' == $_POST['post_type']) {
        if (!current_user_can('edit_post', $post_id)) {
            return;
        }
    }
    
    if (isset($_POST['pet_product_price'])) {
        update_post_meta($post_id, '_pet_product_price', sanitize_text_field($_POST['pet_product_price']));
    }
    
    if (isset($_POST['pet_product_category'])) {
        update_post_meta($post_id, '_pet_product_category', sanitize_text_field($_POST['pet_product_category']));
    }
}
add_action('save_post', 'pet_paws_save_meta_box_data');

// Add theme customizer options
function pet_paws_customize_register($wp_customize) {
    // Hero Section
    $wp_customize->add_section('pet_paws_hero', array(
        'title' => __('Hero Section', 'pet-paws'),
        'priority' => 30,
    ));
    
    $wp_customize->add_setting('hero_title', array(
        'default' => 'Welcome to Pet Food Store',
        'sanitize_callback' => 'sanitize_text_field',
    ));
    
    $wp_customize->add_control('hero_title', array(
        'label' => __('Hero Title', 'pet-paws'),
        'section' => 'pet_paws_hero',
        'type' => 'text',
    ));
    
    $wp_customize->add_setting('hero_subtitle', array(
        'default' => 'Premium pet food and supplies for your beloved companions',
        'sanitize_callback' => 'sanitize_text_field',
    ));
    
    $wp_customize->add_control('hero_subtitle', array(
        'label' => __('Hero Subtitle', 'pet-paws'),
        'section' => 'pet_paws_hero',
        'type' => 'textarea',
    ));
}
add_action('customize_register', 'pet_paws_customize_register');

// Add custom shortcodes
function pet_paws_product_grid_shortcode($atts) {
    $atts = shortcode_atts(array(
        'category' => '',
        'limit' => 6,
    ), $atts);
    
    $args = array(
        'post_type' => 'pet_product',
        'posts_per_page' => $atts['limit'],
        'post_status' => 'publish',
    );
    
    if (!empty($atts['category'])) {
        $args['meta_query'] = array(
            array(
                'key' => '_pet_product_category',
                'value' => $atts['category'],
                'compare' => '=',
            ),
        );
    }
    
    $products = new WP_Query($args);
    
    ob_start();
    if ($products->have_posts()) {
        echo '<div class="products-grid">';
        while ($products->have_posts()) {
            $products->the_post();
            $price = get_post_meta(get_the_ID(), '_pet_product_price', true);
            $category = get_post_meta(get_the_ID(), '_pet_product_category', true);
            
            echo '<article class="product-card" data-category="' . esc_attr($category) . '">';
            echo '<div class="product-image">';
            if (has_post_thumbnail()) {
                the_post_thumbnail('product-thumbnail');
            } else {
                echo '<div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 3rem;">🐕</div>';
            }
            echo '</div>';
            echo '<div class="product-info">';
            echo '<h3 class="product-title">' . get_the_title() . '</h3>';
            echo '<p class="product-description">' . get_the_excerpt() . '</p>';
            echo '<div class="product-price">฿' . number_format($price, 2) . '</div>';
            echo '<button class="add-to-cart">Add to Cart</button>';
            echo '</div>';
            echo '</article>';
        }
        echo '</div>';
    }
    wp_reset_postdata();
    
    return ob_get_clean();
}
add_shortcode('pet_products', 'pet_paws_product_grid_shortcode');
function pet_paws_scripts() { 
    wp_enqueue_style('pet-paws-style', get_stylesheet_uri()); 
} 
