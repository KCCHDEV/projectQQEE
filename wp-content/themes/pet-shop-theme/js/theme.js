/**
 * Pet Shop Pro Theme JavaScript
 */

(function($) {
    'use strict';

    // Theme object
    const PetShopTheme = {
        
        // Initialize theme
        init: function() {
            this.bindEvents();
            this.initComponents();
            this.setupAjax();
            this.initAdvancedFeatures();
            this.initAuth();
        },

        // Bind event listeners
        bindEvents: function() {
            $(document).ready(function() {
                PetShopTheme.setupMobileMenu();
                PetShopTheme.setupSmoothScrolling();
                PetShopTheme.setupProductCards();
                PetShopTheme.setupCartFunctionality();
                PetShopTheme.setupLazyLoading();
                PetShopTheme.setupBackToTop();
                PetShopTheme.setupNewsletterForm();
                PetShopTheme.setupAdvancedFilters();
                PetShopTheme.setupQuickView();
                PetShopTheme.setupWishlist();
                PetShopTheme.setupComparison();
                PetShopTheme.setupAuthForms();
            });
        },

        // Initialize components
        initComponents: function() {
            // Add loading states to buttons
            $('.add-to-cart-btn, .cta-button, .category-link').on('click', function() {
                if (!$(this).hasClass('loading')) {
                    $(this).addClass('loading');
                    setTimeout(() => {
                        $(this).removeClass('loading');
                    }, 2000);
                }
            });

            // Add hover effects to category cards
            $('.category-card').hover(
                function() {
                    $(this).addClass('hover');
                },
                function() {
                    $(this).removeClass('hover');
                }
            );
        },

        // Initialize advanced features
        initAdvancedFeatures: function() {
            // Add wishlist and compare buttons to header
            this.addHeaderButtons();
            
            // Initialize price sliders
            this.initPriceSliders();
            
            // Setup product filtering
            this.setupProductFiltering();
        },

        // Initialize authentication
        initAuth: function() {
            // Check if user is logged in and update UI
            this.updateAuthUI();
        },

        // Setup authentication forms
        setupAuthForms: function() {
            // Login form
            $('#login-form').on('submit', function(e) {
                e.preventDefault();
                PetShopTheme.handleLogin();
            });

            // Register form
            $('#register-form').on('submit', function(e) {
                e.preventDefault();
                PetShopTheme.handleRegister();
            });

            // Forgot password form
            $('#forgot-form').on('submit', function(e) {
                e.preventDefault();
                PetShopTheme.handleForgotPassword();
            });

            // Switch between modals
            $('.switch-to-register').on('click', function(e) {
                e.preventDefault();
                PetShopTheme.switchAuthModal('register');
            });

            $('.switch-to-login').on('click', function(e) {
                e.preventDefault();
                PetShopTheme.switchAuthModal('login');
            });

            // Forgot password link
            $('.forgot-password').on('click', function(e) {
                e.preventDefault();
                PetShopTheme.showAuthModal('forgot');
            });

            // Close modals
            $('.auth-close').on('click', function() {
                PetShopTheme.hideAuthModals();
            });

            // Close modal when clicking outside
            $('.auth-modal').on('click', function(e) {
                if (e.target === this) {
                    PetShopTheme.hideAuthModals();
                }
            });

            // Password strength checker
            $('#register-password').on('input', function() {
                PetShopTheme.checkPasswordStrength($(this).val());
            });

            // Social login buttons
            $('.social-btn').on('click', function(e) {
                e.preventDefault();
                PetShopTheme.handleSocialLogin($(this).text().trim());
            });
        },

        // Handle login
        handleLogin: function() {
            const email = $('#login-email').val();
            const password = $('#login-password').val();
            const remember = $('#login-form input[name="remember"]').is(':checked');

            if (!email || !password) {
                this.showNotification('Please fill in all fields', 'error');
                return;
            }

            const $submitBtn = $('#login-form .auth-submit');
            $submitBtn.prop('disabled', true).text('Signing In...');

            $.ajax({
                url: pet_shop_ajax.ajax_url,
                type: 'POST',
                data: {
                    action: 'pet_shop_login',
                    email: email,
                    password: password,
                    remember: remember,
                    nonce: pet_shop_ajax.nonce
                },
                success: (response) => {
                    if (response.success) {
                        this.showNotification(response.data.message, 'success');
                        setTimeout(() => {
                            window.location.href = response.data.redirect;
                        }, 1500);
                    } else {
                        this.showNotification(response.data, 'error');
                    }
                },
                error: () => {
                    this.showNotification('Network error. Please try again.', 'error');
                },
                complete: () => {
                    $submitBtn.prop('disabled', false).text('Sign In');
                }
            });
        },

        // Handle registration
        handleRegister: function() {
            const formData = {
                firstname: $('#register-firstname').val(),
                lastname: $('#register-lastname').val(),
                email: $('#register-email').val(),
                phone: $('#register-phone').val(),
                password: $('#register-password').val(),
                confirm_password: $('#register-confirm-password').val(),
                terms: $('#register-form input[name="terms"]').is(':checked'),
                newsletter: $('#register-form input[name="newsletter"]').is(':checked')
            };

            // Validation
            if (!formData.firstname || !formData.lastname || !formData.email || !formData.phone || !formData.password) {
                this.showNotification('Please fill in all required fields', 'error');
                return;
            }

            if (formData.password !== formData.confirm_password) {
                this.showNotification('Passwords do not match', 'error');
                return;
            }

            if (!formData.terms) {
                this.showNotification('Please agree to the Terms & Conditions', 'error');
                return;
            }

            const $submitBtn = $('#register-form .auth-submit');
            $submitBtn.prop('disabled', true).text('Creating Account...');

            $.ajax({
                url: pet_shop_ajax.ajax_url,
                type: 'POST',
                data: {
                    action: 'pet_shop_register',
                    ...formData,
                    nonce: pet_shop_ajax.nonce
                },
                success: (response) => {
                    if (response.success) {
                        this.showNotification(response.data.message, 'success');
                        setTimeout(() => {
                            window.location.href = response.data.redirect;
                        }, 1500);
                    } else {
                        this.showNotification(response.data, 'error');
                    }
                },
                error: () => {
                    this.showNotification('Network error. Please try again.', 'error');
                },
                complete: () => {
                    $submitBtn.prop('disabled', false).text('Create Account');
                }
            });
        },

        // Handle forgot password
        handleForgotPassword: function() {
            const email = $('#forgot-email').val();

            if (!email) {
                this.showNotification('Please enter your email address', 'error');
                return;
            }

            const $submitBtn = $('#forgot-form .auth-submit');
            $submitBtn.prop('disabled', true).text('Sending...');

            $.ajax({
                url: pet_shop_ajax.ajax_url,
                type: 'POST',
                data: {
                    action: 'pet_shop_forgot_password',
                    email: email,
                    nonce: pet_shop_ajax.nonce
                },
                success: (response) => {
                    if (response.success) {
                        this.showNotification(response.data, 'success');
                        this.hideAuthModals();
                    } else {
                        this.showNotification(response.data, 'error');
                    }
                },
                error: () => {
                    this.showNotification('Network error. Please try again.', 'error');
                },
                complete: () => {
                    $submitBtn.prop('disabled', false).text('Send Reset Link');
                }
            });
        },

        // Show auth modal
        showAuthModal: function(type) {
            this.hideAuthModals();
            $(`#${type}-modal`).addClass('active');
        },

        // Hide all auth modals
        hideAuthModals: function() {
            $('.auth-modal').removeClass('active');
        },

        // Switch between auth modals
        switchAuthModal: function(type) {
            this.hideAuthModals();
            this.showAuthModal(type);
        },

        // Check password strength
        checkPasswordStrength: function(password) {
            const $strengthBar = $('.strength-bar');
            const $strengthText = $('.strength-text');
            
            let strength = 0;
            let text = 'Password strength';
            
            if (password.length >= 8) strength += 25;
            if (password.match(/[a-z]/)) strength += 25;
            if (password.match(/[A-Z]/)) strength += 25;
            if (password.match(/[0-9]/)) strength += 25;
            
            $strengthBar.removeClass('weak medium strong very-strong');
            
            if (strength <= 25) {
                $strengthBar.addClass('weak');
                text = 'Weak';
            } else if (strength <= 50) {
                $strengthBar.addClass('medium');
                text = 'Medium';
            } else if (strength <= 75) {
                $strengthBar.addClass('strong');
                text = 'Strong';
            } else {
                $strengthBar.addClass('very-strong');
                text = 'Very Strong';
            }
            
            $strengthText.text(text);
        },

        // Handle social login
        handleSocialLogin: function(provider) {
            this.showNotification(`${provider} login coming soon!`, 'info');
        },

        // Update auth UI based on login status
        updateAuthUI: function() {
            // This would be called after successful login/logout
            // For now, we'll just hide the modals
            this.hideAuthModals();
        },

        // Add header buttons for wishlist and compare
        addHeaderButtons: function() {
            const headerNav = $('.main-navigation');
            if (headerNav.length) {
                headerNav.append(`
                    <div class="header-actions">
                        <button class="wishlist-toggle" title="Wishlist">
                            ❤️ <span class="wishlist-count">0</span>
                        </button>
                        <button class="compare-toggle" title="Compare">
                            ⚖️ <span class="compare-count">0</span>
                        </button>
                    </div>
                `);
                
                this.updateWishlistCount();
                this.updateCompareCount();
            }
        },

        // Setup mobile menu
        setupMobileMenu: function() {
            const $menuToggle = $('.menu-toggle');
            const $mobileMenu = $('.mobile-menu');

            $menuToggle.on('click', function(e) {
                e.preventDefault();
                $mobileMenu.toggleClass('active');
                $(this).toggleClass('active');
            });

            // Close menu when clicking outside
            $(document).on('click', function(e) {
                if (!$(e.target).closest('.mobile-menu-toggle, .mobile-menu').length) {
                    $mobileMenu.removeClass('active');
                    $menuToggle.removeClass('active');
                }
            });
        },

        // Setup smooth scrolling
        setupSmoothScrolling: function() {
            $('a[href^="#"]').on('click', function(e) {
                e.preventDefault();
                const target = $($(this).attr('href'));
                if (target.length) {
                    $('html, body').animate({
                        scrollTop: target.offset().top - 80
                    }, 800);
                }
            });
        },

        // Setup product cards
        setupProductCards: function() {
            $('.product-card').hover(
                function() {
                    $(this).addClass('hover');
                },
                function() {
                    $(this).removeClass('hover');
                }
            );

            // Add to cart animation
            $('.add-to-cart-btn').on('click', function(e) {
                const $btn = $(this);
                const originalText = $btn.text();
                
                $btn.text('Adding...').prop('disabled', true);
                
                setTimeout(() => {
                    $btn.text('Added!').addClass('success');
                    setTimeout(() => {
                        $btn.text(originalText).prop('disabled', false).removeClass('success');
                    }, 1500);
                }, 1000);
            });
        },

        // Setup cart functionality
        setupCartFunctionality: function() {
            // Update cart count
            window.updateCartCount = function() {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'get_cart_count',
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            $('.cart-count').text(response.data.count);
                        }
                    }
                });
            };

            // Add to cart function
            window.addToCart = function(productId) {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'add_to_cart',
                        product_id: productId,
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            updateCartCount();
                            PetShopTheme.showNotification('Product added to cart! 🎉', 'success');
                        } else {
                            PetShopTheme.showNotification('Failed to add product to cart', 'error');
                        }
                    },
                    error: function() {
                        PetShopTheme.showNotification('Network error. Please try again.', 'error');
                    }
                });
            };
        },

        // Setup wishlist functionality
        setupWishlist: function() {
            // Add to wishlist function
            window.addToWishlist = function(productId) {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'add_to_wishlist',
                        product_id: productId,
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            PetShopTheme.updateWishlistCount();
                            PetShopTheme.showNotification('Added to wishlist! ❤️', 'success');
                            $(`.wishlist-btn[onclick*="${productId}"]`).addClass('active');
                        } else {
                            PetShopTheme.showNotification(response.data, 'error');
                        }
                    },
                    error: function() {
                        PetShopTheme.showNotification('Please login to use wishlist', 'error');
                    }
                });
            };

            // Remove from wishlist
            window.removeFromWishlist = function(productId) {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'remove_from_wishlist',
                        product_id: productId,
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            PetShopTheme.updateWishlistCount();
                            PetShopTheme.showNotification('Removed from wishlist', 'info');
                        }
                    }
                });
            };

            // Update wishlist count
            this.updateWishlistCount = function() {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'get_wishlist_count',
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            $('.wishlist-count').text(response.data.count);
                        }
                    }
                });
            };

            // Toggle wishlist sidebar
            $('.wishlist-toggle').on('click', function() {
                PetShopTheme.toggleSidebar('wishlist');
            });
        },

        // Setup comparison functionality
        setupComparison: function() {
            // Add to compare function
            window.addToCompare = function(productId) {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'add_to_compare',
                        product_id: productId,
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            PetShopTheme.updateCompareCount();
                            PetShopTheme.showNotification('Added to comparison! ⚖️', 'success');
                            $(`.compare-btn[onclick*="${productId}"]`).addClass('active');
                        } else {
                            PetShopTheme.showNotification(response.data, 'error');
                        }
                    }
                });
            };

            // Remove from compare
            window.removeFromCompare = function(productId) {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'remove_from_compare',
                        product_id: productId,
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            PetShopTheme.updateCompareCount();
                            PetShopTheme.showNotification('Removed from comparison', 'info');
                        }
                    }
                });
            };

            // Update compare count
            this.updateCompareCount = function() {
                const compareList = JSON.parse(localStorage.getItem('pet_shop_compare') || '[]');
                $('.compare-count').text(compareList.length);
            };

            // Toggle compare sidebar
            $('.compare-toggle').on('click', function() {
                PetShopTheme.toggleSidebar('compare');
            });
        },

        // Setup quick view
        setupQuickView: function() {
            // Quick view function
            window.quickView = function(productId) {
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'quick_view',
                        product_id: productId,
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            PetShopTheme.showQuickView(response.data);
                        } else {
                            PetShopTheme.showNotification('Product not found', 'error');
                        }
                    }
                });
            };

            // Show quick view modal
            this.showQuickView = function(content) {
                const modal = $(`
                    <div class="quick-view-modal">
                        <div class="quick-view-content">
                            <button class="quick-view-close">&times;</button>
                            ${content}
                        </div>
                    </div>
                `);

                $('body').append(modal);
                setTimeout(() => modal.addClass('active'), 10);

                // Close modal
                modal.on('click', function(e) {
                    if (e.target === this || $(e.target).hasClass('quick-view-close')) {
                        modal.removeClass('active');
                        setTimeout(() => modal.remove(), 300);
                    }
                });
            };
        },

        // Setup advanced filters
        setupAdvancedFilters: function() {
            // Price slider functionality
            this.initPriceSliders = function() {
                const $priceMin = $('#price-min');
                const $priceMax = $('#price-max');
                const $priceDisplay = $('#price-display');

                function updatePriceDisplay() {
                    const min = $priceMin.val();
                    const max = $priceMax.val();
                    $priceDisplay.text(`฿${min} - ฿${max}`);
                }

                $priceMin.on('input', updatePriceDisplay);
                $priceMax.on('input', updatePriceDisplay);

                // Apply filters
                $('#apply-filters').on('click', function() {
                    PetShopTheme.applyFilters();
                });

                // Clear filters
                $('#clear-filters').on('click', function() {
                    PetShopTheme.clearFilters();
                });
            };
        },

        // Apply product filters
        applyFilters: function() {
            const filters = {
                petType: $('#pet-type-filter').val(),
                ageRange: $('#age-range-filter').val(),
                size: $('#size-filter').val(),
                priceMin: $('#price-min').val(),
                priceMax: $('#price-max').val()
            };

            // Store filters in localStorage
            localStorage.setItem('pet_shop_filters', JSON.stringify(filters));

            // Apply filters to products
            $('.product-card').each(function() {
                const $card = $(this);
                const productId = $card.data('product-id');
                let show = true;

                // Apply pet type filter
                if (filters.petType && $card.find('.pet-type').text() !== filters.petType) {
                    show = false;
                }

                // Apply age range filter
                if (filters.ageRange && $card.find('.age-range').text() !== filters.ageRange) {
                    show = false;
                }

                // Apply size filter
                if (filters.size && $card.find('.size').text() !== filters.size) {
                    show = false;
                }

                // Apply price filter
                const price = parseFloat($card.find('.product-price').text().replace(/[^\d.]/g, ''));
                if (price < filters.priceMin || price > filters.priceMax) {
                    show = false;
                }

                if (show) {
                    $card.show();
                } else {
                    $card.hide();
                }
            });

            this.showNotification('Filters applied!', 'success');
        },

        // Clear all filters
        clearFilters: function() {
            $('#pet-type-filter, #age-range-filter, #size-filter').val('');
            $('#price-min').val(0);
            $('#price-max').val(2000);
            $('#price-display').text('฿0 - ฿2000');
            
            $('.product-card').show();
            localStorage.removeItem('pet_shop_filters');
            
            this.showNotification('Filters cleared!', 'info');
        },

        // Toggle sidebar
        toggleSidebar: function(type) {
            const sidebar = $(`.${type}-sidebar`);
            
            if (sidebar.length) {
                sidebar.toggleClass('active');
            } else {
                // Create sidebar if it doesn't exist
                this.createSidebar(type);
            }
        },

        // Create sidebar
        createSidebar: function(type) {
            const title = type === 'wishlist' ? 'Wishlist' : 'Compare Products';
            const icon = type === 'wishlist' ? '❤️' : '⚖️';
            
            const sidebar = $(`
                <div class="sidebar-panel ${type}-sidebar">
                    <div class="sidebar-header">
                        <h3>${icon} ${title}</h3>
                        <button class="sidebar-close">&times;</button>
                    </div>
                    <div class="sidebar-content">
                        <div class="sidebar-items"></div>
                    </div>
                </div>
            `);

            $('body').append(sidebar);
            
            // Close sidebar
            sidebar.find('.sidebar-close').on('click', function() {
                sidebar.removeClass('active');
            });

            // Load items
            this.loadSidebarItems(type);
            
            // Show sidebar
            setTimeout(() => sidebar.addClass('active'), 10);
        },

        // Load sidebar items
        loadSidebarItems: function(type) {
            const sidebar = $(`.${type}-sidebar .sidebar-items`);
            
            if (type === 'wishlist') {
                // Load wishlist items
                $.ajax({
                    url: pet_shop_ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'get_wishlist_items',
                        nonce: pet_shop_ajax.nonce
                    },
                    success: function(response) {
                        if (response.success) {
                            sidebar.html(response.data);
                        }
                    }
                });
            } else {
                // Load compare items
                const compareList = JSON.parse(localStorage.getItem('pet_shop_compare') || '[]');
                if (compareList.length > 0) {
                    // Load compare items from session
                    sidebar.html('<p>Compare items loaded...</p>');
                } else {
                    sidebar.html('<p>No items to compare</p>');
                }
            }
        },

        // Setup lazy loading
        setupLazyLoading: function() {
            if ('IntersectionObserver' in window) {
                const imageObserver = new IntersectionObserver((entries, observer) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            const img = entry.target;
                            img.src = img.dataset.src;
                            img.classList.remove('lazy');
                            imageObserver.unobserve(img);
                        }
                    });
                });

                document.querySelectorAll('img[data-src]').forEach(img => {
                    imageObserver.observe(img);
                });
            }
        },

        // Setup back to top button
        setupBackToTop: function() {
            const $backToTop = $('#back-to-top');
            
            $(window).on('scroll', function() {
                if ($(this).scrollTop() > 300) {
                    $backToTop.addClass('visible');
                } else {
                    $backToTop.removeClass('visible');
                }
            });

            $backToTop.on('click', function() {
                $('html, body').animate({
                    scrollTop: 0
                }, 800);
            });
        },

        // Setup newsletter form
        setupNewsletterForm: function() {
            $('.newsletter-form').on('submit', function(e) {
                e.preventDefault();
                const email = $(this).find('input[type="email"]').val();
                
                if (email) {
                    PetShopTheme.showNotification('Thank you for subscribing! 📧', 'success');
                    $(this).find('input[type="email"]').val('');
                } else {
                    PetShopTheme.showNotification('Please enter a valid email address', 'error');
                }
            });
        },

        // Setup AJAX
        setupAjax: function() {
            // Add CSRF token to all AJAX requests
            $.ajaxSetup({
                beforeSend: function(xhr) {
                    xhr.setRequestHeader('X-WP-Nonce', pet_shop_ajax.nonce);
                }
            });
        },

        // Show notification
        showNotification: function(message, type = 'info') {
            const notification = $(`
                <div class="notification notification-${type}">
                    <span>${message}</span>
                    <button class="notification-close">&times;</button>
                </div>
            `);

            $('body').append(notification);

            // Auto remove after 5 seconds
            setTimeout(() => {
                notification.fadeOut(() => {
                    notification.remove();
                });
            }, 5000);

            // Manual close
            notification.find('.notification-close').on('click', function() {
                notification.fadeOut(() => {
                    notification.remove();
                });
            });
        },

        // Utility functions
        utils: {
            // Debounce function
            debounce: function(func, wait, immediate) {
                let timeout;
                return function() {
                    const context = this, args = arguments;
                    const later = function() {
                        timeout = null;
                        if (!immediate) func.apply(context, args);
                    };
                    const callNow = immediate && !timeout;
                    clearTimeout(timeout);
                    timeout = setTimeout(later, wait);
                    if (callNow) func.apply(context, args);
                };
            },

            // Throttle function
            throttle: function(func, limit) {
                let inThrottle;
                return function() {
                    const args = arguments;
                    const context = this;
                    if (!inThrottle) {
                        func.apply(context, args);
                        inThrottle = true;
                        setTimeout(() => inThrottle = false, limit);
                    }
                };
            }
        }
    };

    // Initialize theme
    PetShopTheme.init();

    // Add notification styles
    $('<style>')
        .prop('type', 'text/css')
        .html(`
            .notification {
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 1rem 1.5rem;
                border-radius: 8px;
                color: white;
                font-weight: 600;
                z-index: 10000;
                display: flex;
                align-items: center;
                gap: 1rem;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
                animation: slideIn 0.3s ease;
            }
            
            .notification-success {
                background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            }
            
            .notification-error {
                background: linear-gradient(135deg, #e53e3e 0%, #c53030 100%);
            }
            
            .notification-info {
                background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);
            }
            
            .notification-close {
                background: none;
                border: none;
                color: white;
                font-size: 1.5rem;
                cursor: pointer;
                padding: 0;
                line-height: 1;
            }
            
            @keyframes slideIn {
                from {
                    transform: translateX(100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
            
            .loading {
                position: relative;
                pointer-events: none;
            }
            
            .loading::after {
                content: '';
                position: absolute;
                top: 50%;
                left: 50%;
                width: 20px;
                height: 20px;
                margin: -10px 0 0 -10px;
                border: 3px solid rgba(255, 255, 255, 0.3);
                border-radius: 50%;
                border-top-color: #fff;
                animation: spin 1s linear infinite;
            }
            
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
            
            .product-card.hover {
                transform: translateY(-10px) scale(1.02);
            }
            
            .category-card.hover {
                transform: translateY(-10px);
                border-color: #667eea;
            }
            
            .add-to-cart-btn.success {
                background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            }
            
            .header-actions {
                display: flex;
                gap: 1rem;
                align-items: center;
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
        `)
        .appendTo('head');

})(jQuery); 