/**
 * Pet Paws Theme Scripts
 */

(function($) {
    'use strict';
    
    // DOM Ready
    $(document).ready(function() {
        
        // Mobile Menu Toggle
        $('.menu-toggle').on('click', function() {
            $('.nav-menu').toggleClass('active');
            $('body').toggleClass('menu-open');
            $(this).find('i').toggleClass('fa-bars fa-times');
        });
        
        // Search Toggle
        $('.search-toggle').on('click', function() {
            $('.search-overlay').addClass('active');
            $('.search-field').focus();
        });
        
        $('.search-close').on('click', function() {
            $('.search-overlay').removeClass('active');
        });
        
        // Escape key to close search
        $(document).on('keyup', function(e) {
            if (e.key === 'Escape') {
                $('.search-overlay').removeClass('active');
            }
        });
        
        // Sticky Header
        let lastScroll = 0;
        const header = $('.site-header');
        const headerHeight = header.outerHeight();
        
        $(window).on('scroll', function() {
            const currentScroll = $(this).scrollTop();
            
            if (currentScroll > headerHeight) {
                header.addClass('sticky');
                
                if (currentScroll > lastScroll) {
                    header.addClass('hidden');
                } else {
                    header.removeClass('hidden');
                }
            } else {
                header.removeClass('sticky hidden');
            }
            
            lastScroll = currentScroll;
        });
        
        // Product Tabs
        $('.tab-button').on('click', function() {
            const tab = $(this).data('tab');
            
            $('.tab-button').removeClass('active');
            $(this).addClass('active');
            
            // Here you would typically load different products
            // For now, we'll just animate the existing ones
            $('.product-card').each(function(index) {
                $(this).css('animation-delay', (index * 0.1) + 's');
                $(this).addClass('fade-in');
            });
        });
        
        // Quick View
        $('.quick-view').on('click', function(e) {
            e.preventDefault();
            const productId = $(this).data('product-id');
            
            // Show loading
            $('body').append('<div class="quick-view-overlay"><div class="loading"></div></div>');
            
            // AJAX request for product details
            $.ajax({
                url: pet_paws_ajax.ajax_url,
                type: 'POST',
                data: {
                    action: 'pet_paws_quick_view',
                    product_id: productId,
                    nonce: pet_paws_ajax.nonce
                },
                success: function(response) {
                    $('.quick-view-overlay').html(response);
                },
                error: function() {
                    $('.quick-view-overlay').remove();
                    alert('Error loading product details');
                }
            });
        });
        
        // Close quick view
        $(document).on('click', '.quick-view-overlay', function(e) {
            if (e.target === this) {
                $(this).remove();
            }
        });
        
        // Add to wishlist
        $('.add-to-wishlist').on('click', function(e) {
            e.preventDefault();
            const button = $(this);
            
            button.addClass('loading');
            
            // Simulate adding to wishlist
            setTimeout(function() {
                button.removeClass('loading');
                button.find('i').removeClass('far').addClass('fas');
                button.addClass('added');
            }, 1000);
        });
        
        // Smooth scroll
        $('a[href*="#"]:not([href="#"])').on('click', function() {
            if (location.pathname.replace(/^\//, '') === this.pathname.replace(/^\//, '') && location.hostname === this.hostname) {
                let target = $(this.hash);
                target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
                
                if (target.length) {
                    $('html, body').animate({
                        scrollTop: target.offset().top - headerHeight
                    }, 800);
                    return false;
                }
            }
        });
        
        // Parallax effect for hero section
        $(window).on('scroll', function() {
            const scrolled = $(this).scrollTop();
            $('.hero').css('transform', 'translateY(' + (scrolled * 0.5) + 'px)');
        });
        
        // Animate on scroll
        const animateElements = $('.feature-card, .product-card, .category-card, .blog-card');
        
        function checkAnimation() {
            const windowHeight = $(window).height();
            const scrollTop = $(window).scrollTop();
            
            animateElements.each(function() {
                const element = $(this);
                const elementTop = element.offset().top;
                
                if (scrollTop + windowHeight - 100 > elementTop) {
                    element.addClass('animated');
                }
            });
        }
        
        checkAnimation();
        $(window).on('scroll', checkAnimation);
        
        // Product image hover effect
        $('.product-image').on('mouseenter', function() {
            $(this).find('img').css('transform', 'scale(1.1)');
        }).on('mouseleave', function() {
            $(this).find('img').css('transform', 'scale(1)');
        });
        
        // Cart update animation
        $('.add_to_cart_button').on('click', function() {
            const button = $(this);
            const cartBadge = $('.cart-badge');
            
            // Animate cart icon
            $('.cart-toggle').addClass('bounce');
            
            setTimeout(function() {
                $('.cart-toggle').removeClass('bounce');
            }, 1000);
        });
        
        // Newsletter form
        $('.newsletter-form').on('submit', function(e) {
            e.preventDefault();
            const form = $(this);
            const email = form.find('input[type="email"]').val();
            
            if (email) {
                form.find('button').text('Subscribing...').prop('disabled', true);
                
                // Simulate subscription
                setTimeout(function() {
                    form.html('<div class="success-message">Thank you for subscribing!</div>');
                }, 1500);
            }
        });
        
        // Category filter (if on shop page)
        $('.category-filter').on('change', function() {
            const category = $(this).val();
            
            if (category) {
                window.location.href = $(this).find(':selected').data('url');
            }
        });
        
        // Price range slider
        if ($('#price-range').length) {
            const priceRange = document.getElementById('price-range');
            
            noUiSlider.create(priceRange, {
                start: [0, 1000],
                connect: true,
                range: {
                    'min': 0,
                    'max': 5000
                },
                format: {
                    to: function(value) {
                        return '฿' + Math.round(value);
                    },
                    from: function(value) {
                        return value.replace('฿', '');
                    }
                }
            });
        }
        
        // Loading animation for AJAX requests
        $(document).ajaxStart(function() {
            $('body').addClass('loading');
        }).ajaxStop(function() {
            $('body').removeClass('loading');
        });
        
    });
    
    // Window Load
    $(window).on('load', function() {
        // Remove preloader
        $('.preloader').fadeOut('slow');
        
        // Trigger animations
        $('body').addClass('loaded');
    });
    
})(jQuery);

// CSS Classes for animations
const style = document.createElement('style');
style.textContent = `
    /* Animations */
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    @keyframes bounce {
        0%, 20%, 50%, 80%, 100% {
            transform: translateY(0);
        }
        40% {
            transform: translateY(-10px);
        }
        60% {
            transform: translateY(-5px);
        }
    }
    
    .fade-in {
        animation: fadeIn 0.6s ease-out forwards;
    }
    
    .bounce {
        animation: bounce 1s ease-out;
    }
    
    .animated {
        opacity: 0;
        transform: translateY(30px);
        transition: all 0.6s ease-out;
    }
    
    .animated.animated {
        opacity: 1;
        transform: translateY(0);
    }
    
    /* Sticky header styles */
    .site-header.sticky {
        position: fixed;
        top: 0;
        width: 100%;
        z-index: 9999;
        transition: transform 0.3s ease;
    }
    
    .site-header.sticky.hidden {
        transform: translateY(-100%);
    }
    
    .site-header.sticky .header-top {
        display: none;
    }
    
    /* Search overlay */
    .search-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.95);
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
        z-index: 10000;
    }
    
    .search-overlay.active {
        opacity: 1;
        visibility: visible;
    }
    
    .search-overlay .search-form {
        display: flex;
        max-width: 600px;
        width: 90%;
    }
    
    .search-overlay .search-field {
        flex: 1;
        padding: 1rem 1.5rem;
        font-size: 1.25rem;
        border: none;
        border-radius: 50px 0 0 50px;
        background: white;
    }
    
    .search-overlay .search-submit {
        padding: 1rem 2rem;
        background: var(--primary);
        color: white;
        border: none;
        border-radius: 0 50px 50px 0;
        font-size: 1.25rem;
        cursor: pointer;
        transition: background 0.3s ease;
    }
    
    .search-overlay .search-submit:hover {
        background: var(--primary-dark);
    }
    
    .search-close {
        position: absolute;
        top: 2rem;
        right: 2rem;
        background: none;
        border: none;
        color: white;
        font-size: 2rem;
        cursor: pointer;
        transition: transform 0.3s ease;
    }
    
    .search-close:hover {
        transform: rotate(90deg);
    }
    
    /* Quick view overlay */
    .quick-view-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        padding: 2rem;
    }
    
    .quick-view-content {
        background: white;
        border-radius: 16px;
        max-width: 800px;
        width: 100%;
        display: grid;
        grid-template-columns: 1fr 1fr;
        overflow: hidden;
        animation: fadeIn 0.3s ease;
    }
    
    .quick-view-image {
        background: #f8f9fa;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 2rem;
    }
    
    .quick-view-info {
        padding: 2rem;
    }
    
    /* Loading spinner */
    .loading {
        width: 50px;
        height: 50px;
        border: 3px solid rgba(255, 255, 255, 0.3);
        border-top-color: white;
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
    
    /* Mobile menu styles */
    body.menu-open {
        overflow: hidden;
    }
    
    @media (max-width: 1024px) {
        .nav-menu {
            position: fixed;
            top: 80px;
            left: -100%;
            width: 80%;
            max-width: 300px;
            height: calc(100vh - 80px);
            background: white;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
            transition: left 0.3s ease;
            z-index: 999;
            overflow-y: auto;
            padding: 2rem;
        }
        
        .nav-menu.active {
            left: 0;
        }
        
        .nav-menu li {
            display: block;
            margin: 0 0 1rem 0;
        }
        
        .nav-menu a {
            display: block;
            padding: 0.75rem 0;
            font-size: 1.125rem;
        }
    }
`;
document.head.appendChild(style);