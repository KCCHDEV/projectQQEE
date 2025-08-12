<?php
/**
 * Pet Paws Theme Functions
 *
 * @package Pet_Paws
 */

// Theme Setup
function pet_paws_setup() {
    // Add default posts and comments RSS feed links to head
    add_theme_support('automatic-feed-links');
    
    // Let WordPress manage the document title
    add_theme_support('title-tag');
    
    // Enable support for Post Thumbnails
    add_theme_support('post-thumbnails');
    
    // Add theme support for custom logo
    add_theme_support('custom-logo', array(
        'height'      => 60,
        'width'       => 200,
        'flex-height' => true,
        'flex-width'  => true,
    ));
    
    // Add support for WooCommerce
    add_theme_support('woocommerce');
    add_theme_support('wc-product-gallery-zoom');
    add_theme_support('wc-product-gallery-lightbox');
    add_theme_support('wc-product-gallery-slider');
    
    // Register navigation menus
    register_nav_menus(array(
        'primary'   => esc_html__('Primary Menu', 'pet-paws'),
        'footer'    => esc_html__('Footer Menu', 'pet-paws'),
        'mobile'    => esc_html__('Mobile Menu', 'pet-paws'),
    ));
    
    // Switch default core markup to output valid HTML5
    add_theme_support('html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
        'style',
        'script',
    ));
    
    // Set up the WordPress core custom background feature
    add_theme_support('custom-background', apply_filters('pet_paws_custom_background_args', array(
        'default-color' => 'ffffff',
        'default-image' => '',
    )));
}
add_action('after_setup_theme', 'pet_paws_setup');

// Register widget areas
function pet_paws_widgets_init() {
    register_sidebar(array(
        'name'          => esc_html__('Sidebar', 'pet-paws'),
        'id'            => 'sidebar-1',
        'description'   => esc_html__('Add widgets here.', 'pet-paws'),
        'before_widget' => '<section id="%1$s" class="widget %2$s">',
        'after_widget'  => '</section>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ));
    
    register_sidebar(array(
        'name'          => esc_html__('Footer Widget Area 1', 'pet-paws'),
        'id'            => 'footer-1',
        'description'   => esc_html__('Add widgets here.', 'pet-paws'),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h4 class="widget-title">',
        'after_title'   => '</h4>',
    ));
    
    register_sidebar(array(
        'name'          => esc_html__('Footer Widget Area 2', 'pet-paws'),
        'id'            => 'footer-2',
        'description'   => esc_html__('Add widgets here.', 'pet-paws'),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h4 class="widget-title">',
        'after_title'   => '</h4>',
    ));
    
    register_sidebar(array(
        'name'          => esc_html__('Footer Widget Area 3', 'pet-paws'),
        'id'            => 'footer-3',
        'description'   => esc_html__('Add widgets here.', 'pet-paws'),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h4 class="widget-title">',
        'after_title'   => '</h4>',
    ));
}
add_action('widgets_init', 'pet_paws_widgets_init');

// Enqueue scripts and styles
function pet_paws_scripts() {
    // Google Fonts
    wp_enqueue_style('pet-paws-fonts', 'https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&family=Prompt:wght@300;400;500;600;700&family=Sarabun:wght@300;400;500;600;700&display=swap', array(), null);
    
    // Font Awesome
    wp_enqueue_style('font-awesome', 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css', array(), '6.5.1');
    
    // Theme stylesheet
    wp_enqueue_style('pet-paws-style', get_stylesheet_uri(), array(), '1.0.0');
    
    // Custom JavaScript
    wp_enqueue_script('pet-paws-scripts', get_template_directory_uri() . '/assets/js/scripts.js', array('jquery'), '1.0.0', true);
    
    // Localize script for AJAX
    wp_localize_script('pet-paws-scripts', 'pet_paws_ajax', array(
        'ajax_url' => admin_url('admin-ajax.php'),
        'nonce'    => wp_create_nonce('pet_paws_nonce'),
    ));
    
    // Comment reply script
    if (is_singular() && comments_open() && get_option('thread_comments')) {
        wp_enqueue_script('comment-reply');
    }
}
add_action('wp_enqueue_scripts', 'pet_paws_scripts');

// Custom image sizes
add_image_size('pet-paws-hero', 1200, 600, true);
add_image_size('pet-paws-product', 400, 400, true);
add_image_size('pet-paws-blog', 800, 500, true);

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

// WooCommerce customizations
// Remove WooCommerce styles
add_filter('woocommerce_enqueue_styles', '__return_empty_array');

// Change number of products per row
add_filter('loop_shop_columns', 'pet_paws_loop_columns', 999);
function pet_paws_loop_columns() {
    return 4;
}

// Change number of products per page
add_filter('loop_shop_per_page', 'pet_paws_products_per_page', 20);
function pet_paws_products_per_page($cols) {
    return 12;
}

// Add custom product categories widget
class Pet_Paws_Product_Categories_Widget extends WP_Widget {
    function __construct() {
        parent::__construct(
            'pet_paws_product_categories',
            __('Pet Paws Product Categories', 'pet-paws'),
            array('description' => __('Display product categories with icons', 'pet-paws'))
        );
    }
    
    public function widget($args, $instance) {
        echo $args['before_widget'];
        
        if (!empty($instance['title'])) {
            echo $args['before_title'] . apply_filters('widget_title', $instance['title']) . $args['after_title'];
        }
        
        $categories = get_terms(array(
            'taxonomy'   => 'product_cat',
            'hide_empty' => false,
            'parent'     => 0,
        ));
        
        if ($categories) {
            echo '<ul class="pet-categories-widget">';
            foreach ($categories as $category) {
                $icon = get_term_meta($category->term_id, 'category_icon', true);
                echo '<li>';
                echo '<a href="' . get_term_link($category) . '">';
                if ($icon) {
                    echo '<i class="' . esc_attr($icon) . '"></i> ';
                }
                echo esc_html($category->name);
                echo ' <span class="count">(' . $category->count . ')</span>';
                echo '</a>';
                echo '</li>';
            }
            echo '</ul>';
        }
        
        echo $args['after_widget'];
    }
    
    public function form($instance) {
        $title = !empty($instance['title']) ? $instance['title'] : __('Product Categories', 'pet-paws');
        ?>
        <p>
            <label for="<?php echo $this->get_field_id('title'); ?>"><?php _e('Title:', 'pet-paws'); ?></label>
            <input class="widefat" id="<?php echo $this->get_field_id('title'); ?>" name="<?php echo $this->get_field_name('title'); ?>" type="text" value="<?php echo esc_attr($title); ?>">
        </p>
        <?php
    }
    
    public function update($new_instance, $old_instance) {
        $instance = array();
        $instance['title'] = (!empty($new_instance['title'])) ? strip_tags($new_instance['title']) : '';
        return $instance;
    }
}

// Register custom widget
function pet_paws_register_widgets() {
    register_widget('Pet_Paws_Product_Categories_Widget');
}
add_action('widgets_init', 'pet_paws_register_widgets');

// Add theme customizer options
function pet_paws_customize_register($wp_customize) {
    // Add Pet Paws section
    $wp_customize->add_section('pet_paws_options', array(
        'title'    => __('Pet Paws Options', 'pet-paws'),
        'priority' => 30,
    ));
    
    // Top bar phone
    $wp_customize->add_setting('pet_paws_phone', array(
        'default'           => '02-123-4567',
        'sanitize_callback' => 'sanitize_text_field',
    ));
    
    $wp_customize->add_control('pet_paws_phone', array(
        'label'    => __('Phone Number', 'pet-paws'),
        'section'  => 'pet_paws_options',
        'type'     => 'text',
    ));
    
    // Top bar email
    $wp_customize->add_setting('pet_paws_email', array(
        'default'           => 'info@petpaws.com',
        'sanitize_callback' => 'sanitize_email',
    ));
    
    $wp_customize->add_control('pet_paws_email', array(
        'label'    => __('Email Address', 'pet-paws'),
        'section'  => 'pet_paws_options',
        'type'     => 'email',
    ));
    
    // Social media links
    $social_networks = array('facebook', 'twitter', 'instagram', 'youtube', 'line');
    
    foreach ($social_networks as $network) {
        $wp_customize->add_setting('pet_paws_' . $network, array(
            'default'           => '',
            'sanitize_callback' => 'esc_url_raw',
        ));
        
        $wp_customize->add_control('pet_paws_' . $network, array(
            'label'    => ucfirst($network) . ' URL',
            'section'  => 'pet_paws_options',
            'type'     => 'url',
        ));
    }
}
add_action('customize_register', 'pet_paws_customize_register');

// Helper function to get social links
function pet_paws_get_social_links() {
    $social_networks = array(
        'facebook'  => 'fab fa-facebook-f',
        'twitter'   => 'fab fa-twitter',
        'instagram' => 'fab fa-instagram',
        'youtube'   => 'fab fa-youtube',
        'line'      => 'fab fa-line',
    );
    
    $output = '';
    
    foreach ($social_networks as $network => $icon) {
        $url = get_theme_mod('pet_paws_' . $network);
        if ($url) {
            $output .= '<a href="' . esc_url($url) . '" class="social-link" target="_blank" rel="noopener noreferrer">';
            $output .= '<i class="' . esc_attr($icon) . '"></i>';
            $output .= '</a>';
        }
    }
    
    return $output;
}

// Add body classes
function pet_paws_body_classes($classes) {
    if (is_front_page()) {
        $classes[] = 'front-page';
    }
    
    if (class_exists('WooCommerce') && is_shop()) {
        $classes[] = 'woocommerce-shop';
    }
    
    return $classes;
}
add_filter('body_class', 'pet_paws_body_classes');

// Custom product query for homepage
function pet_paws_get_featured_products($number = 8) {
    $args = array(
        'post_type'      => 'product',
        'posts_per_page' => $number,
        'meta_key'       => '_featured',
        'meta_value'     => 'yes',
    );
    
    return new WP_Query($args);
}

// Get best selling products
function pet_paws_get_best_sellers($number = 8) {
    $args = array(
        'post_type'      => 'product',
        'posts_per_page' => $number,
        'meta_key'       => 'total_sales',
        'orderby'        => 'meta_value_num',
        'order'          => 'DESC',
    );
    
    return new WP_Query($args);
}

// Get new products
function pet_paws_get_new_products($number = 8) {
    $args = array(
        'post_type'      => 'product',
        'posts_per_page' => $number,
        'orderby'        => 'date',
        'order'          => 'DESC',
    );
    
    return new WP_Query($args);
}

// Add AJAX handler for quick view
add_action('wp_ajax_pet_paws_quick_view', 'pet_paws_quick_view');
add_action('wp_ajax_nopriv_pet_paws_quick_view', 'pet_paws_quick_view');

function pet_paws_quick_view() {
    if (!isset($_POST['product_id'])) {
        wp_die();
    }
    
    $product_id = intval($_POST['product_id']);
    $product = wc_get_product($product_id);
    
    if (!$product) {
        wp_die();
    }
    
    // Output quick view content
    ?>
    <div class="quick-view-content">
        <div class="quick-view-image">
            <?php echo $product->get_image('large'); ?>
        </div>
        <div class="quick-view-info">
            <h2><?php echo $product->get_name(); ?></h2>
            <div class="price"><?php echo $product->get_price_html(); ?></div>
            <div class="description"><?php echo $product->get_short_description(); ?></div>
            <a href="<?php echo $product->get_permalink(); ?>" class="btn btn-primary">View Details</a>
        </div>
    </div>
    <?php
    
    wp_die();
}