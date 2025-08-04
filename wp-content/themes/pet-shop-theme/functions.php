<?php
/**
 * Pet Shop Pro Theme Functions
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Theme Setup
 */
function pet_shop_theme_setup() {
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
    
    // WooCommerce support
    add_theme_support('woocommerce');
    add_theme_support('wc-product-gallery-zoom');
    add_theme_support('wc-product-gallery-lightbox');
    add_theme_support('wc-product-gallery-slider');
    
    // Register navigation menus
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'pet-shop-theme'),
        'footer' => __('Footer Menu', 'pet-shop-theme'),
    ));
}
add_action('after_setup_theme', 'pet_shop_theme_setup');

/**
 * Enqueue scripts and styles
 */
function pet_shop_scripts() {
    // Enqueue main stylesheet
    wp_enqueue_style('pet-shop-style', get_stylesheet_uri(), array(), '1.0.0');
    
    // Enqueue Google Fonts
    wp_enqueue_style('google-fonts', 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap', array(), null);
    
    // Enqueue theme JavaScript
    wp_enqueue_script('pet-shop-script', get_template_directory_uri() . '/js/theme.js', array('jquery'), '1.0.0', true);
    
    // Localize script for AJAX
    wp_localize_script('pet-shop-script', 'pet_shop_ajax', array(
        'ajax_url' => admin_url('admin-ajax.php'),
        'nonce' => wp_create_nonce('pet_shop_nonce'),
    ));
}
add_action('wp_enqueue_scripts', 'pet_shop_scripts');

/**
 * WooCommerce customizations
 */
function pet_shop_woocommerce_setup() {
    // Remove default WooCommerce styles
    add_filter('woocommerce_enqueue_styles', '__return_empty_array');
    
    // Customize WooCommerce settings
    add_filter('woocommerce_product_thumbnails_columns', function() {
        return 4;
    });
    
    // Change number of products per row
    add_filter('loop_shop_columns', function() {
        return 3;
    });
    
    // Change number of products per page
    add_filter('loop_shop_per_page', function() {
        return 12;
    });
}
add_action('after_setup_theme', 'pet_shop_woocommerce_setup');

/**
 * Enhanced Registration and Login
 */
function pet_shop_custom_login_register_forms() {
    if (!is_user_logged_in()) {
        ?>
        <div class="auth-modals">
            <!-- Login Modal -->
            <div id="login-modal" class="auth-modal">
                <div class="auth-content">
                    <button class="auth-close">&times;</button>
                    <div class="auth-header">
                        <h2>🐕 Welcome Back!</h2>
                        <p>Sign in to your Pet Paradise account</p>
                    </div>
                    
                    <form id="login-form" class="auth-form">
                        <div class="form-group">
                            <label for="login-email">Email Address</label>
                            <input type="email" id="login-email" name="email" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="login-password">Password</label>
                            <input type="password" id="login-password" name="password" required>
                        </div>
                        
                        <div class="form-options">
                            <label class="checkbox-label">
                                <input type="checkbox" name="remember">
                                <span>Remember me</span>
                            </label>
                            <a href="#" class="forgot-password">Forgot password?</a>
                        </div>
                        
                        <button type="submit" class="auth-submit">Sign In</button>
                    </form>
                    
                    <div class="social-login">
                        <p>Or sign in with</p>
                        <div class="social-buttons">
                            <button class="social-btn google-btn">Google</button>
                            <button class="social-btn facebook-btn">Facebook</button>
                        </div>
                    </div>
                    
                    <div class="auth-footer">
                        <p>Don't have an account? <a href="#" class="switch-to-register">Sign up</a></p>
                    </div>
                </div>
            </div>
            
            <!-- Register Modal -->
            <div id="register-modal" class="auth-modal">
                <div class="auth-content">
                    <button class="auth-close">&times;</button>
                    <div class="auth-header">
                        <h2>🐕 Join Pet Paradise!</h2>
                        <p>Create your account and start shopping</p>
                    </div>
                    
                    <form id="register-form" class="auth-form">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="register-firstname">First Name</label>
                                <input type="text" id="register-firstname" name="firstname" required>
                            </div>
                            <div class="form-group">
                                <label for="register-lastname">Last Name</label>
                                <input type="text" id="register-lastname" name="lastname" required>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-email">Email Address</label>
                            <input type="email" id="register-email" name="email" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-phone">Phone Number</label>
                            <input type="tel" id="register-phone" name="phone" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-password">Password</label>
                            <input type="password" id="register-password" name="password" required>
                            <div class="password-strength">
                                <div class="strength-bar"></div>
                                <span class="strength-text">Password strength</span>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-confirm-password">Confirm Password</label>
                            <input type="password" id="register-confirm-password" name="confirm_password" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="checkbox-label">
                                <input type="checkbox" name="terms" required>
                                <span>I agree to the <a href="#">Terms & Conditions</a> and <a href="#">Privacy Policy</a></span>
                            </label>
                        </div>
                        
                        <div class="form-group">
                            <label class="checkbox-label">
                                <input type="checkbox" name="newsletter">
                                <span>Subscribe to our newsletter for pet care tips and exclusive offers</span>
                            </label>
                        </div>
                        
                        <button type="submit" class="auth-submit">Create Account</button>
                    </form>
                    
                    <div class="social-login">
                        <p>Or sign up with</p>
                        <div class="social-buttons">
                            <button class="social-btn google-btn">Google</button>
                            <button class="social-btn facebook-btn">Facebook</button>
                        </div>
                    </div>
                    
                    <div class="auth-footer">
                        <p>Already have an account? <a href="#" class="switch-to-login">Sign in</a></p>
                    </div>
                </div>
            </div>
            
            <!-- Forgot Password Modal -->
            <div id="forgot-modal" class="auth-modal">
                <div class="auth-content">
                    <button class="auth-close">&times;</button>
                    <div class="auth-header">
                        <h2>🔑 Reset Password</h2>
                        <p>Enter your email to receive reset instructions</p>
                    </div>
                    
                    <form id="forgot-form" class="auth-form">
                        <div class="form-group">
                            <label for="forgot-email">Email Address</label>
                            <input type="email" id="forgot-email" name="email" required>
                        </div>
                        
                        <button type="submit" class="auth-submit">Send Reset Link</button>
                    </form>
                    
                    <div class="auth-footer">
                        <p>Remember your password? <a href="#" class="switch-to-login">Sign in</a></p>
                    </div>
                </div>
            </div>
        </div>
        <?php
    }
}
add_action('wp_footer', 'pet_shop_custom_login_register_forms');

// AJAX handlers moved to auth-handlers.php to avoid function redeclaration

// AJAX forgot password handler moved to auth-handlers.php to avoid function redeclaration

// Custom user profile fields moved to auth-handlers.php to avoid function redeclaration

/**
 * AJAX handlers
 */
function pet_shop_add_to_cart() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $product_id = intval($_POST['product_id']);
    $quantity = isset($_POST['quantity']) ? intval($_POST['quantity']) : 1;
    
    $result = WC()->cart->add_to_cart($product_id, $quantity);
    
    if ($result) {
        wp_send_json_success(array(
            'message' => 'Product added to cart successfully',
            'cart_count' => WC()->cart->get_cart_contents_count(),
        ));
    } else {
        wp_send_json_error('Failed to add product to cart');
    }
}
add_action('wp_ajax_add_to_cart', 'pet_shop_add_to_cart');
add_action('wp_ajax_nopriv_add_to_cart', 'pet_shop_add_to_cart');

function pet_shop_get_cart_count() {
    wp_send_json_success(array(
        'count' => WC()->cart->get_cart_contents_count(),
    ));
}
add_action('wp_ajax_get_cart_count', 'pet_shop_get_cart_count');
add_action('wp_ajax_nopriv_get_cart_count', 'pet_shop_get_cart_count');

/**
 * Wishlist functionality
 */
function pet_shop_add_to_wishlist() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $product_id = intval($_POST['product_id']);
    $user_id = get_current_user_id();
    
    if (!$user_id) {
        wp_send_json_error('Please login to add items to wishlist');
        return;
    }
    
    $wishlist = get_user_meta($user_id, 'pet_shop_wishlist', true);
    if (!is_array($wishlist)) {
        $wishlist = array();
    }
    
    if (!in_array($product_id, $wishlist)) {
        $wishlist[] = $product_id;
        update_user_meta($user_id, 'pet_shop_wishlist', $wishlist);
        wp_send_json_success('Product added to wishlist');
    } else {
        wp_send_json_error('Product already in wishlist');
    }
}
add_action('wp_ajax_add_to_wishlist', 'pet_shop_add_to_wishlist');

function pet_shop_remove_from_wishlist() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $product_id = intval($_POST['product_id']);
    $user_id = get_current_user_id();
    
    $wishlist = get_user_meta($user_id, 'pet_shop_wishlist', true);
    if (is_array($wishlist)) {
        $wishlist = array_diff($wishlist, array($product_id));
        update_user_meta($user_id, 'pet_shop_wishlist', $wishlist);
        wp_send_json_success('Product removed from wishlist');
    }
}
add_action('wp_ajax_remove_from_wishlist', 'pet_shop_remove_from_wishlist');

function pet_shop_get_wishlist_count() {
    $user_id = get_current_user_id();
    if ($user_id) {
        $wishlist = get_user_meta($user_id, 'pet_shop_wishlist', true);
        $count = is_array($wishlist) ? count($wishlist) : 0;
        wp_send_json_success(array('count' => $count));
    } else {
        wp_send_json_success(array('count' => 0));
    }
}
add_action('wp_ajax_get_wishlist_count', 'pet_shop_get_wishlist_count');
add_action('wp_ajax_nopriv_get_wishlist_count', 'pet_shop_get_wishlist_count');

/**
 * Product comparison functionality
 */
function pet_shop_add_to_compare() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $product_id = intval($_POST['product_id']);
    $compare_list = isset($_SESSION['pet_shop_compare']) ? $_SESSION['pet_shop_compare'] : array();
    
    if (!in_array($product_id, $compare_list)) {
        if (count($compare_list) < 4) { // Limit to 4 products
            $compare_list[] = $product_id;
            $_SESSION['pet_shop_compare'] = $compare_list;
            wp_send_json_success('Product added to comparison');
        } else {
            wp_send_json_error('Maximum 4 products can be compared');
        }
    } else {
        wp_send_json_error('Product already in comparison');
    }
}
add_action('wp_ajax_add_to_compare', 'pet_shop_add_to_compare');
add_action('wp_ajax_nopriv_add_to_compare', 'pet_shop_add_to_compare');

function pet_shop_remove_from_compare() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $product_id = intval($_POST['product_id']);
    $compare_list = isset($_SESSION['pet_shop_compare']) ? $_SESSION['pet_shop_compare'] : array();
    
    $compare_list = array_diff($compare_list, array($product_id));
    $_SESSION['pet_shop_compare'] = $compare_list;
    wp_send_json_success('Product removed from comparison');
}
add_action('wp_ajax_remove_from_compare', 'pet_shop_remove_from_compare');
add_action('wp_ajax_nopriv_remove_from_compare', 'pet_shop_remove_from_compare');

/**
 * Advanced product filtering
 */
function pet_shop_add_product_filters() {
    $pet_types = array('Dog', 'Cat', 'Bird', 'Fish', 'Rabbit', 'Hamster');
    $age_ranges = array('Puppy/Kitten', 'Adult', 'Senior');
    $sizes = array('Small', 'Medium', 'Large', 'All Sizes');
    
    echo '<div class="product-filters">';
    echo '<h3>Filter Products</h3>';
    
    // Pet Type Filter
    echo '<div class="filter-group">';
    echo '<label>Pet Type:</label>';
    echo '<select id="pet-type-filter">';
    echo '<option value="">All Pets</option>';
    foreach ($pet_types as $type) {
        echo '<option value="' . $type . '">' . $type . '</option>';
    }
    echo '</select>';
    echo '</div>';
    
    // Age Range Filter
    echo '<div class="filter-group">';
    echo '<label>Age Range:</label>';
    echo '<select id="age-range-filter">';
    echo '<option value="">All Ages</option>';
    foreach ($age_ranges as $age) {
        echo '<option value="' . $age . '">' . $age . '</option>';
    }
    echo '</select>';
    echo '</div>';
    
    // Price Range Filter
    echo '<div class="filter-group">';
    echo '<label>Price Range:</label>';
    echo '<div class="price-slider">';
    echo '<input type="range" id="price-min" min="0" max="2000" value="0">';
    echo '<input type="range" id="price-max" min="0" max="2000" value="2000">';
    echo '<span id="price-display">฿0 - ฿2000</span>';
    echo '</div>';
    echo '</div>';
    
    // Size Filter
    echo '<div class="filter-group">';
    echo '<label>Size:</label>';
    echo '<select id="size-filter">';
    echo '<option value="">All Sizes</option>';
    foreach ($sizes as $size) {
        echo '<option value="' . $size . '">' . $size . '</option>';
    }
    echo '</select>';
    echo '</div>';
    
    echo '<button id="apply-filters" class="filter-btn">Apply Filters</button>';
    echo '<button id="clear-filters" class="filter-btn">Clear All</button>';
    echo '</div>';
}
add_action('woocommerce_before_shop_loop', 'pet_shop_add_product_filters', 20);

/**
 * Quick view functionality
 */
function pet_shop_quick_view() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $product_id = intval($_POST['product_id']);
    $product = wc_get_product($product_id);
    
    if ($product) {
        ob_start();
        ?>
        <div class="quick-view-content">
            <div class="quick-view-image">
                <?php echo $product->get_image('medium'); ?>
            </div>
            <div class="quick-view-details">
                <h3><?php echo $product->get_name(); ?></h3>
                <div class="price"><?php echo $product->get_price_html(); ?></div>
                <div class="description"><?php echo wp_trim_words($product->get_description(), 20); ?></div>
                <div class="actions">
                    <button class="add-to-cart-btn" onclick="addToCart(<?php echo $product_id; ?>)">Add to Cart</button>
                    <button class="wishlist-btn" onclick="addToWishlist(<?php echo $product_id; ?>)">❤️</button>
                    <button class="compare-btn" onclick="addToCompare(<?php echo $product_id; ?>)">⚖️</button>
                </div>
            </div>
        </div>
        <?php
        $content = ob_get_clean();
        wp_send_json_success($content);
    } else {
        wp_send_json_error('Product not found');
    }
}
add_action('wp_ajax_quick_view', 'pet_shop_quick_view');
add_action('wp_ajax_nopriv_quick_view', 'pet_shop_quick_view');

/**
 * Product recommendations
 */
function pet_shop_product_recommendations() {
    global $product;
    
    if (!$product) return;
    
    $product_id = $product->get_id();
    $category_ids = $product->get_category_ids();
    
    $args = array(
        'post_type' => 'product',
        'posts_per_page' => 4,
        'post__not_in' => array($product_id),
        'tax_query' => array(
            array(
                'taxonomy' => 'product_cat',
                'field' => 'term_id',
                'terms' => $category_ids,
            ),
        ),
    );
    
    $related_products = new WP_Query($args);
    
    if ($related_products->have_posts()) {
        echo '<div class="product-recommendations">';
        echo '<h3>You might also like</h3>';
        echo '<div class="recommendations-grid">';
        
        while ($related_products->have_posts()) {
            $related_products->the_post();
            global $product;
            ?>
            <div class="recommendation-item">
                <a href="<?php the_permalink(); ?>">
                    <?php echo $product->get_image('thumbnail'); ?>
                    <h4><?php the_title(); ?></h4>
                    <div class="price"><?php echo $product->get_price_html(); ?></div>
                </a>
            </div>
            <?php
        }
        
        echo '</div>';
        echo '</div>';
        
        wp_reset_postdata();
    }
}
add_action('woocommerce_after_single_product', 'pet_shop_product_recommendations', 10);

/**
 * Enhanced product search
 */
function pet_shop_enhanced_search($query) {
    if (!is_admin() && $query->is_main_query() && $query->is_search()) {
        $query->set('post_type', array('product', 'post'));
        
        // Search in product meta fields
        $meta_query = array(
            'relation' => 'OR',
            array(
                'key' => '_pet_type',
                'value' => $query->get('s'),
                'compare' => 'LIKE'
            ),
            array(
                'key' => '_age_range',
                'value' => $query->get('s'),
                'compare' => 'LIKE'
            ),
            array(
                'key' => '_size',
                'value' => $query->get('s'),
                'compare' => 'LIKE'
            )
        );
        
        $query->set('meta_query', $meta_query);
    }
}
add_action('pre_get_posts', 'pet_shop_enhanced_search');

/**
 * Custom product categories
 */
function pet_shop_create_product_categories() {
    $categories = array(
        'dog-food' => array(
            'name' => 'Dog Food',
            'description' => 'Premium nutrition for your canine companion',
            'icon' => '🦴'
        ),
        'toys' => array(
            'name' => 'Toys & Games',
            'description' => 'Fun and engaging toys for playtime',
            'icon' => '🧸'
        ),
        'grooming' => array(
            'name' => 'Grooming',
            'description' => 'Keep your pet clean and healthy',
            'icon' => '🛁'
        ),
        'accessories' => array(
            'name' => 'Beds & Accessories',
            'description' => 'Comfortable homes and accessories',
            'icon' => '🏠'
        ),
        'health' => array(
            'name' => 'Health & Wellness',
            'description' => 'Supplements and health products',
            'icon' => '💊'
        ),
        'cat-products' => array(
            'name' => 'Cat Products',
            'description' => 'Everything for your feline friends',
            'icon' => '🐱'
        ),
    );
    
    foreach ($categories as $slug => $category) {
        if (!term_exists($slug, 'product_cat')) {
            wp_insert_term($category['name'], 'product_cat', array(
                'slug' => $slug,
                'description' => $category['description'],
            ));
        }
    }
}
add_action('after_switch_theme', 'pet_shop_create_product_categories');

/**
 * Customize WooCommerce product loop
 */
function pet_shop_product_loop_start() {
    echo '<div class="products-grid">';
}
add_action('woocommerce_before_shop_loop', 'pet_shop_product_loop_start', 40);

function pet_shop_product_loop_end() {
    echo '</div>';
}
add_action('woocommerce_after_shop_loop', 'pet_shop_product_loop_end', 5);

/**
 * Customize product card
 */
function pet_shop_product_card() {
    global $product;
    ?>
    <div class="product-card" data-product-id="<?php echo $product->get_id(); ?>">
        <div class="product-actions">
            <button class="quick-view-btn" onclick="quickView(<?php echo $product->get_id(); ?>)" title="Quick View">👁️</button>
            <button class="wishlist-btn" onclick="addToWishlist(<?php echo $product->get_id(); ?>)" title="Add to Wishlist">❤️</button>
            <button class="compare-btn" onclick="addToCompare(<?php echo $product->get_id(); ?>)" title="Add to Compare">⚖️</button>
        </div>
        
        <a href="<?php the_permalink(); ?>" class="product-link">
            <?php if (has_post_thumbnail()) : ?>
                <?php the_post_thumbnail('medium', array('class' => 'product-image')); ?>
            <?php else : ?>
                <img src="<?php echo get_template_directory_uri(); ?>/assets/placeholder.jpg" alt="<?php the_title(); ?>" class="product-image">
            <?php endif; ?>
        </a>
        
        <div class="product-content">
            <h3 class="product-title">
                <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
            </h3>
            
            <div class="product-meta">
                <span class="pet-type"><?php echo get_post_meta($product->get_id(), '_pet_type', true); ?></span>
                <span class="age-range"><?php echo get_post_meta($product->get_id(), '_age_range', true); ?></span>
            </div>
            
            <div class="product-price">
                <?php echo $product->get_price_html(); ?>
            </div>
            
            <?php if ($product->is_in_stock()) : ?>
                <button class="add-to-cart-btn" onclick="addToCart(<?php echo $product->get_id(); ?>)">
                    Add to Cart
                </button>
            <?php else : ?>
                <button class="add-to-cart-btn" disabled>Out of Stock</button>
            <?php endif; ?>
        </div>
    </div>
    <?php
}

/**
 * Remove default WooCommerce hooks
 */
function pet_shop_remove_woocommerce_hooks() {
    remove_action('woocommerce_before_shop_loop_item', 'woocommerce_template_loop_product_link_open', 10);
    remove_action('woocommerce_after_shop_loop_item', 'woocommerce_template_loop_product_link_close', 5);
    remove_action('woocommerce_shop_loop_item_title', 'woocommerce_template_loop_product_title', 10);
    remove_action('woocommerce_after_shop_loop_item_title', 'woocommerce_template_loop_rating', 5);
    remove_action('woocommerce_after_shop_loop_item_title', 'woocommerce_template_loop_price', 10);
    remove_action('woocommerce_after_shop_loop_item', 'woocommerce_template_loop_add_to_cart', 10);
}
add_action('init', 'pet_shop_remove_woocommerce_hooks');

/**
 * Add custom product card
 */
function pet_shop_add_product_card() {
    pet_shop_product_card();
}
add_action('woocommerce_shop_loop_item', 'pet_shop_add_product_card');

/**
 * Customize WooCommerce messages
 */
function pet_shop_woocommerce_messages($message) {
    return str_replace('has been added to your cart', 'has been added to your cart! 🎉', $message);
}
add_filter('wc_add_to_cart_message', 'pet_shop_woocommerce_messages');

/**
 * Add custom fields to product
 */
function pet_shop_add_product_fields() {
    global $post;
    
    echo '<div class="product-meta">';
    echo '<p><strong>Pet Type:</strong> ' . get_post_meta($post->ID, '_pet_type', true) . '</p>';
    echo '<p><strong>Age Range:</strong> ' . get_post_meta($post->ID, '_age_range', true) . '</p>';
    echo '<p><strong>Size:</strong> ' . get_post_meta($post->ID, '_size', true) . '</p>';
    echo '</div>';
}
add_action('woocommerce_single_product_summary', 'pet_shop_add_product_fields', 25);

/**
 * Customize checkout fields
 */
function pet_shop_customize_checkout_fields($fields) {
    $fields['billing']['billing_pet_name'] = array(
        'label' => 'Pet Name',
        'placeholder' => 'Enter your pet\'s name',
        'required' => false,
        'class' => array('form-row-wide'),
        'clear' => true,
        'priority' => 25,
    );
    
    return $fields;
}
add_filter('woocommerce_checkout_fields', 'pet_shop_customize_checkout_fields');

/**
 * Theme customizer
 */
function pet_shop_customize_register($wp_customize) {
    // Add section for theme options
    $wp_customize->add_section('pet_shop_options', array(
        'title' => __('Pet Shop Options', 'pet-shop-theme'),
        'priority' => 30,
    ));
    
    // Hero title
    $wp_customize->add_setting('hero_title', array(
        'default' => '🐕 Pet Paradise',
        'sanitize_callback' => 'sanitize_text_field',
    ));
    
    $wp_customize->add_control('hero_title', array(
        'label' => __('Hero Title', 'pet-shop-theme'),
        'section' => 'pet_shop_options',
        'type' => 'text',
    ));
    
    // Hero subtitle
    $wp_customize->add_setting('hero_subtitle', array(
        'default' => 'Everything your furry friends need for a happy, healthy life',
        'sanitize_callback' => 'sanitize_text_field',
    ));
    
    $wp_customize->add_control('hero_subtitle', array(
        'label' => __('Hero Subtitle', 'pet-shop-theme'),
        'section' => 'pet_shop_options',
        'type' => 'textarea',
    ));
}
add_action('customize_register', 'pet_shop_customize_register');

/**
 * Security enhancements
 */
function pet_shop_security_headers() {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('X-XSS-Protection: 1; mode=block');
}
add_action('send_headers', 'pet_shop_security_headers');

/**
 * Performance optimizations
 */
function pet_shop_performance_optimizations() {
    // Remove unnecessary WordPress features
    remove_action('wp_head', 'wp_generator');
    remove_action('wp_head', 'wlwmanifest_link');
    remove_action('wp_head', 'rsd_link');
    remove_action('wp_head', 'wp_shortlink_wp_head');
    
    // Disable emojis
    remove_action('wp_head', 'print_emoji_detection_script', 7);
    remove_action('wp_print_styles', 'print_emoji_styles');
}
add_action('init', 'pet_shop_performance_optimizations');

/**
 * Start session for comparison functionality
 */
function pet_shop_start_session() {
    if (!session_id()) {
        session_start();
    }
}
add_action('init', 'pet_shop_start_session');

/**
 * Include Authentication Files
 */
if (file_exists(get_template_directory() . '/auth-handlers.php')) {
    require_once get_template_directory() . '/auth-handlers.php';
} 