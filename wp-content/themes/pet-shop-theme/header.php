<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="profile" href="https://gmpg.org/xfn/11">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<div id="page" class="site">
    <header id="masthead" class="site-header">
        <div class="header-container">
            <div class="header-left">
                <a href="<?php echo esc_url(home_url('/')); ?>" class="site-logo">
                    <?php bloginfo('name'); ?>
                </a>
            </div>
            
            <nav id="site-navigation" class="main-navigation">
                <a href="<?php echo esc_url(home_url('/')); ?>">Home</a>
                <a href="<?php echo wc_get_page_permalink('shop'); ?>">Shop</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_shop_page_id')); ?>">Products</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_cart_page_id')); ?>">Cart</a>
                
                <?php if (is_user_logged_in()) : ?>
                    <a href="<?php echo get_permalink(get_option('woocommerce_myaccount_page_id')); ?>">My Account</a>
                    <a href="<?php echo wp_logout_url(home_url()); ?>">Logout</a>
                <?php else : ?>
                    <div class="auth-buttons">
                        <button class="auth-btn login-btn">Sign In</button>
                        <button class="auth-btn primary register-btn">Sign Up</button>
                    </div>
                <?php endif; ?>
                
                <!-- Cart Icon with Count -->
                <div class="cart-icon-container">
                    <a href="<?php echo wc_get_cart_url(); ?>" class="cart-icon">
                        🛒 <span class="cart-count"><?php echo WC()->cart->get_cart_contents_count(); ?></span>
                    </a>
                </div>
                
                <!-- Wishlist and Compare Buttons -->
                <div class="header-actions">
                    <button class="wishlist-toggle" title="Wishlist">
                        ❤️ <span class="wishlist-count">0</span>
                    </button>
                    <button class="compare-toggle" title="Compare Products">
                        ⚖️ <span class="compare-count">0</span>
                    </button>
                </div>
            </nav>
            
            <!-- Mobile Menu Toggle -->
            <div class="mobile-menu-toggle">
                <button class="menu-toggle" aria-controls="primary-menu" aria-expanded="false">
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
            </div>
        </div>
        
        <!-- Mobile Menu -->
        <div class="mobile-menu">
            <a href="<?php echo esc_url(home_url('/')); ?>">Home</a>
            <a href="<?php echo wc_get_page_permalink('shop'); ?>">Shop</a>
            <a href="<?php echo get_permalink(get_option('woocommerce_shop_page_id')); ?>">Products</a>
            <a href="<?php echo get_permalink(get_option('woocommerce_cart_page_id')); ?>">Cart</a>
            
            <?php if (is_user_logged_in()) : ?>
                <a href="<?php echo get_permalink(get_option('woocommerce_myaccount_page_id')); ?>">My Account</a>
                <a href="<?php echo wp_logout_url(home_url()); ?>">Logout</a>
            <?php else : ?>
                <a href="#" class="login-btn-mobile">Sign In</a>
                <a href="#" class="register-btn-mobile">Sign Up</a>
            <?php endif; ?>
            
            <a href="#" class="wishlist-toggle-mobile">Wishlist ❤️</a>
            <a href="#" class="compare-toggle-mobile">Compare ⚖️</a>
        </div>
    </header>

    <!-- Include Authentication Forms -->
    <?php 
    if (file_exists(get_template_directory() . '/auth-forms.php')) {
        include get_template_directory() . '/auth-forms.php';
        pet_shop_auth_forms();
    }
    ?>

    <style>
    .cart-icon-container {
        position: relative;
        margin-left: 1rem;
    }
    
    .cart-icon {
        color: white;
        text-decoration: none;
        font-size: 1.2rem;
        position: relative;
        display: inline-block;
        padding: 0.5rem;
        border-radius: 8px;
        transition: all 0.3s ease;
    }
    
    .cart-icon:hover {
        background: rgba(255, 255, 255, 0.2);
        transform: translateY(-2px);
    }
    
    .cart-count {
        position: absolute;
        top: -5px;
        right: -5px;
        background: #e53e3e;
        color: white;
        border-radius: 50%;
        width: 20px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.75rem;
        font-weight: 700;
    }
    
    .header-actions {
        display: flex;
        gap: 1rem;
        align-items: center;
        margin-left: 1rem;
    }
    
    .header-actions button {
        background: rgba(255, 255, 255, 0.2);
        border: none;
        color: white;
        padding: 0.5rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.3s ease;
        position: relative;
        font-size: 1.2rem;
    }
    
    .header-actions button:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: translateY(-2px);
    }
    
    .header-actions .wishlist-count,
    .header-actions .compare-count {
        position: absolute;
        top: -5px;
        right: -5px;
        background: #e53e3e;
        color: white;
        border-radius: 50%;
        width: 18px;
        height: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.75rem;
        font-weight: 700;
    }
    
    .auth-buttons {
        display: flex;
        gap: 1rem;
        align-items: center;
        margin-left: 1rem;
    }
    
    .auth-btn {
        background: rgba(255, 255, 255, 0.2);
        color: white;
        border: none;
        padding: 0.5rem 1rem;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.3s ease;
        font-weight: 500;
        font-size: 0.875rem;
    }
    
    .auth-btn:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: translateY(-2px);
    }
    
    .auth-btn.primary {
        background: #48bb78;
    }
    
    .auth-btn.primary:hover {
        background: #38a169;
    }
    
    .mobile-menu-toggle {
        display: none;
    }
    
    .mobile-menu {
        display: none;
        background: rgba(102, 126, 234, 0.95);
        padding: 1rem;
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        z-index: 999;
    }
    
    .mobile-menu a {
        display: block;
        color: white;
        text-decoration: none;
        padding: 0.75rem 1rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        transition: background 0.3s ease;
    }
    
    .mobile-menu a:hover {
        background: rgba(255, 255, 255, 0.1);
    }
    
    .mobile-menu a:last-child {
        border-bottom: none;
    }
    
    .menu-toggle {
        background: none;
        border: none;
        color: white;
        font-size: 1.5rem;
        cursor: pointer;
        padding: 0.5rem;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    
    .menu-toggle span {
        display: block;
        width: 25px;
        height: 3px;
        background: white;
        border-radius: 2px;
        transition: all 0.3s ease;
    }
    
    @media (max-width: 768px) {
        .main-navigation {
            display: none;
        }
        
        .mobile-menu-toggle {
            display: block;
        }
        
        .mobile-menu.active {
            display: block;
        }
        
        .header-actions {
            display: none;
        }
        
        .auth-buttons {
            display: none;
        }
    }
    </style>

    <script>
    // Mobile menu toggle
    document.addEventListener('DOMContentLoaded', function() {
        const menuToggle = document.querySelector('.menu-toggle');
        const mobileMenu = document.querySelector('.mobile-menu');
        
        if (menuToggle && mobileMenu) {
            menuToggle.addEventListener('click', function() {
                mobileMenu.classList.toggle('active');
                const isExpanded = mobileMenu.classList.contains('active');
                menuToggle.setAttribute('aria-expanded', isExpanded);
            });
        }
        
        // Close mobile menu when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.closest('.mobile-menu-toggle') && !event.target.closest('.mobile-menu')) {
                mobileMenu.classList.remove('active');
                menuToggle.setAttribute('aria-expanded', 'false');
            }
        });
        
        // Mobile wishlist and compare toggles
        document.querySelectorAll('.wishlist-toggle-mobile, .compare-toggle-mobile').forEach(function(button) {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const type = this.classList.contains('wishlist-toggle-mobile') ? 'wishlist' : 'compare';
                if (typeof PetShopTheme !== 'undefined') {
                    PetShopTheme.toggleSidebar(type);
                }
            });
        });
        
        // Auth button handlers
        document.querySelectorAll('.login-btn, .login-btn-mobile').forEach(function(button) {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                if (typeof PetShopTheme !== 'undefined') {
                    PetShopTheme.showAuthModal('login');
                }
            });
        });
        
        document.querySelectorAll('.register-btn, .register-btn-mobile').forEach(function(button) {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                if (typeof PetShopTheme !== 'undefined') {
                    PetShopTheme.showAuthModal('register');
                }
            });
        });
    });
    
    // Update cart count
    function updateCartCount() {
        fetch('/wp-admin/admin-ajax.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=get_cart_count'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const cartCount = document.querySelector('.cart-count');
                if (cartCount) {
                    cartCount.textContent = data.data.count;
                }
            }
        });
    }
    
    // Add to cart AJAX handler
    document.addEventListener('DOMContentLoaded', function() {
        // This will be handled by the existing addToCart function in index.php
    });
    </script>