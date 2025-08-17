<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php wp_title('|', true, 'right'); ?></title>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>

<!-- Header Top Bar -->
<div class="header-top">
    <div class="container">
        <span>Currency switcher not available</span> | 
        <span>Translator not available</span>
    </div>
</div>

<!-- Main Header -->
<header class="site-header">
    <div class="header-main">
        <!-- Site Title -->
        <a href="<?php echo esc_url(home_url('/')); ?>" class="site-title">
            <?php bloginfo('name'); ?>
        </a>

        <!-- Navigation -->
        <nav class="main-navigation">
            <ul class="nav-menu">
                <li><a href="<?php echo esc_url(home_url('/shop')); ?>">SHOP</a></li>
                <li><a href="<?php echo esc_url(home_url('/cart')); ?>">CART</a></li>
                <li><a href="<?php echo esc_url(home_url('/checkout')); ?>">CHECKOUT</a></li>
                <li><a href="<?php echo esc_url(home_url('/my-account')); ?>">MY ACCOUNT</a></li>
            </ul>
            
            <!-- User Actions -->
            <div class="user-actions">
                <?php if (is_user_logged_in()): ?>
                    <a href="<?php echo wp_logout_url(); ?>" class="nav-link">Logout</a>
                <?php else: ?>
                    <a href="<?php echo wp_login_url(); ?>" class="nav-link">Login</a>
                <?php endif; ?>
                
                <!-- Cart Icon -->
                <a href="<?php echo esc_url(wc_get_cart_url()); ?>" class="cart-icon">
                    🛒
                    <?php 
                    $cart_count = WC()->cart->get_cart_contents_count();
                    if ($cart_count > 0): ?>
                        <span class="cart-count"><?php echo $cart_count; ?></span>
                    <?php endif; ?>
                </a>
                
                <!-- Wishlist -->
                <a href="#" class="nav-link">Wishlist</a>
            </div>
        </nav>
    </div>
</header>

<!-- Search Bar -->
<div class="search-container">
    <form role="search" method="get" class="search-form" action="<?php echo esc_url(home_url('/')); ?>">
        <input type="search" class="search-input" placeholder="Search products..." 
               value="<?php echo get_search_query(); ?>" name="s" />
        <button type="submit" class="search-button">🔍</button>
    </form>
</div>

<!-- Hero Section -->
<section class="hero-section">
    <div class="hero-content">
        <h1>Welcome to <?php bloginfo('name'); ?></h1>
        <p>Premium pet food and supplies for your beloved companions</p>
        <a href="<?php echo esc_url(home_url('/shop')); ?>" class="cta-button">Shop Now</a>
    </div>
</section>

<!-- Main Content Container -->
<main class="main-content">
