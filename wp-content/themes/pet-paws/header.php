<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="profile" href="https://gmpg.org/xfn/11">
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<div id="page" class="site">
    <a class="skip-link screen-reader-text" href="#primary"><?php esc_html_e('Skip to content', 'pet-paws'); ?></a>
    
    <!-- Header -->
    <header class="site-header">
        <!-- Top Bar -->
        <div class="header-top">
            <div class="container">
                <div class="header-top-content">
                    <div class="header-info">
                        <?php 
                        $phone = get_theme_mod('pet_paws_phone', '02-123-4567');
                        $email = get_theme_mod('pet_paws_email', 'info@petpaws.com');
                        ?>
                        <?php if ($phone): ?>
                        <div class="header-info-item">
                            <i class="fas fa-phone"></i>
                            <span><?php echo esc_html($phone); ?></span>
                        </div>
                        <?php endif; ?>
                        
                        <?php if ($email): ?>
                        <div class="header-info-item">
                            <i class="fas fa-envelope"></i>
                            <span><?php echo esc_html($email); ?></span>
                        </div>
                        <?php endif; ?>
                    </div>
                    
                    <div class="header-social">
                        <?php echo pet_paws_get_social_links(); ?>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Main Header -->
        <div class="header-main">
            <div class="container">
                <div class="header-content">
                    <!-- Logo -->
                    <div class="site-branding">
                        <?php if (has_custom_logo()): ?>
                            <?php the_custom_logo(); ?>
                        <?php else: ?>
                            <a href="<?php echo esc_url(home_url('/')); ?>" class="logo">
                                <div class="logo-icon">🐾</div>
                                <span><?php bloginfo('name'); ?></span>
                            </a>
                        <?php endif; ?>
                    </div>
                    
                    <!-- Navigation -->
                    <nav class="main-navigation">
                        <?php
                        wp_nav_menu(array(
                            'theme_location' => 'primary',
                            'menu_id'        => 'primary-menu',
                            'menu_class'     => 'nav-menu',
                            'container'      => false,
                            'fallback_cb'    => 'pet_paws_primary_menu_fallback',
                        ));
                        ?>
                    </nav>
                    
                    <!-- Header Actions -->
                    <div class="header-actions">
                        <!-- Search Toggle -->
                        <button class="search-toggle" aria-label="<?php esc_attr_e('Open search', 'pet-paws'); ?>">
                            <i class="fas fa-search"></i>
                        </button>
                        
                        <?php if (class_exists('WooCommerce')): ?>
                        <!-- Cart -->
                        <a href="<?php echo esc_url(wc_get_cart_url()); ?>" class="cart-toggle">
                            <i class="fas fa-shopping-cart"></i>
                            <?php 
                            $cart_count = WC()->cart->get_cart_contents_count();
                            if ($cart_count > 0): 
                            ?>
                            <span class="cart-badge"><?php echo esc_html($cart_count); ?></span>
                            <?php endif; ?>
                        </a>
                        <?php endif; ?>
                        
                        <!-- Mobile Menu Toggle -->
                        <button class="menu-toggle" aria-label="<?php esc_attr_e('Open menu', 'pet-paws'); ?>">
                            <i class="fas fa-bars"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Search Overlay -->
        <div class="search-overlay">
            <div class="container">
                <form role="search" method="get" class="search-form" action="<?php echo esc_url(home_url('/')); ?>">
                    <input type="search" class="search-field" placeholder="<?php echo esc_attr_x('Search products...', 'placeholder', 'pet-paws'); ?>" value="<?php echo get_search_query(); ?>" name="s" />
                    <?php if (class_exists('WooCommerce')): ?>
                    <input type="hidden" name="post_type" value="product" />
                    <?php endif; ?>
                    <button type="submit" class="search-submit">
                        <i class="fas fa-search"></i>
                    </button>
                </form>
                <button class="search-close" aria-label="<?php esc_attr_e('Close search', 'pet-paws'); ?>">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </div>
    </header>
    
    <?php
    // Menu fallback function
    function pet_paws_primary_menu_fallback() {
        ?>
        <ul class="nav-menu">
            <li><a href="<?php echo esc_url(home_url('/')); ?>"><?php esc_html_e('Home', 'pet-paws'); ?></a></li>
            <?php if (class_exists('WooCommerce')): ?>
            <li><a href="<?php echo esc_url(get_permalink(wc_get_page_id('shop'))); ?>"><?php esc_html_e('Shop', 'pet-paws'); ?></a></li>
            <?php endif; ?>
            <li><a href="<?php echo esc_url(get_permalink(get_option('page_for_posts'))); ?>"><?php esc_html_e('Blog', 'pet-paws'); ?></a></li>
            <li><a href="<?php echo esc_url(home_url('/contact')); ?>"><?php esc_html_e('Contact', 'pet-paws'); ?></a></li>
        </ul>
        <?php
    }
    ?>
    
    <div id="content" class="site-content">