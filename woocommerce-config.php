<?php
/**
 * WooCommerce Development Configuration
 * Add this to wp-config.php or use as a mu-plugin
 */

// WooCommerce specific configurations
if (defined('WP_CLI') || !is_admin()) {
    return;
}

// Increase memory limits for WooCommerce
define('WP_MEMORY_LIMIT', '512M');
define('WP_MAX_MEMORY_LIMIT', '1024M');

// WooCommerce specific settings
add_action('init', function() {
    // Enable WooCommerce debug mode
    if (!defined('WC_DEBUG')) {
        define('WC_DEBUG', true);
    }
    
    // Enable WooCommerce logging
    if (!defined('WC_LOG_DIR')) {
        define('WC_LOG_DIR', WP_CONTENT_DIR . '/logs/');
    }
});

// Optimize WooCommerce for development
add_filter('woocommerce_defer_transactional_emails', '__return_true');
add_filter('woocommerce_email_enabled_customer_completed_order', '__return_false');
add_filter('woocommerce_email_enabled_customer_processing_order', '__return_false');

// Disable WooCommerce admin bar for non-admin users
add_action('after_setup_theme', function() {
    if (!current_user_can('manage_options')) {
        add_filter('woocommerce_disable_admin_bar', '__return_true');
    }
});

// Add custom WooCommerce hooks for development
add_action('woocommerce_init', function() {
    // Log all WooCommerce actions for debugging
    if (defined('WP_DEBUG') && WP_DEBUG) {
        add_action('woocommerce_order_status_changed', function($order_id, $old_status, $new_status) {
            error_log("WooCommerce Order Status Changed: Order #{$order_id} from {$old_status} to {$new_status}");
        }, 10, 3);
    }
});

// Development payment gateway settings
add_filter('woocommerce_payment_gateways', function($gateways) {
    // Ensure test payment gateways are available
    if (!in_array('WC_Gateway_Cheque', $gateways)) {
        $gateways[] = 'WC_Gateway_Cheque';
    }
    return $gateways;
});

// Optimize product queries for development
add_filter('woocommerce_product_query_meta_query', function($meta_query) {
    // Add any custom meta queries here
    return $meta_query;
});

// Development email settings
add_filter('woocommerce_mail_from', function($from_email) {
    return 'dev@localhost';
});

add_filter('woocommerce_mail_from_name', function($from_name) {
    return 'WooCommerce Dev Store';
});

// Disable WooCommerce admin notices in development
add_filter('woocommerce_admin_notices', function($notices) {
    // Remove specific notices for cleaner development experience
    return array_filter($notices, function($notice) {
        return !in_array($notice['type'], ['error', 'warning']);
    });
});

// Enable WooCommerce REST API debugging
add_action('rest_api_init', function() {
    if (defined('WP_DEBUG') && WP_DEBUG) {
        add_filter('woocommerce_rest_prepare_product_object', function($response, $post, $request) {
            error_log("WooCommerce REST API: Product request for ID {$post->get_id()}");
            return $response;
        }, 10, 3);
    }
}); 