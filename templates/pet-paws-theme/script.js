// Pet Paws Theme JavaScript

jQuery(document).ready(function($) {
    
    // Category Filter Functionality
    $('.category-button').on('click', function() {
        const category = $(this).data('category');
        
        // Update active button
        $('.category-button').removeClass('active');
        $(this).addClass('active');
        
        // Filter products
        if (category === 'all') {
            $('.product-card').show();
        } else {
            $('.product-card').hide();
            $('.product-card[data-category="' + category + '"]').show();
        }
    });
    
    // Add to Cart Animation
    $('.add-to-cart').on('click', function(e) {
        e.preventDefault();
        
        const button = $(this);
        const originalText = button.text();
        
        // Show loading state
        button.text('Adding...').prop('disabled', true);
        
        // Simulate AJAX request
        setTimeout(function() {
            // Show success message
            const successMessage = $('<div class="success-message">Product added to cart!</div>');
            button.parent().append(successMessage);
            
            // Reset button
            button.text(originalText).prop('disabled', false);
            
            // Remove message after 3 seconds
            setTimeout(function() {
                successMessage.fadeOut(function() {
                    $(this).remove();
                });
            }, 3000);
            
            // Update cart count
            updateCartCount();
        }, 1000);
    });
    
    // Update cart count
    function updateCartCount() {
        const cartCount = $('.cart-count');
        if (cartCount.length) {
            let currentCount = parseInt(cartCount.text()) || 0;
            cartCount.text(currentCount + 1);
        }
    }
    
    // Smooth scrolling for anchor links
    $('a[href^="#"]').on('click', function(e) {
        e.preventDefault();
        
        const target = $(this.getAttribute('href'));
        if (target.length) {
            $('html, body').animate({
                scrollTop: target.offset().top - 100
            }, 800);
        }
    });
    
    // Search functionality
    $('.search-form').on('submit', function(e) {
        const searchTerm = $('.search-input').val().trim();
        if (!searchTerm) {
            e.preventDefault();
            $('.search-input').focus();
        }
    });
    
    // Mobile menu toggle
    $('.mobile-menu-toggle').on('click', function() {
        $('.nav-menu').toggleClass('active');
        $(this).toggleClass('active');
    });
    
    // Product image hover effect
    $('.product-card').hover(
        function() {
            $(this).find('.product-image').addClass('hover');
        },
        function() {
            $(this).find('.product-image').removeClass('hover');
        }
    );
    
    // Lazy loading for images
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
    
    // Add to wishlist functionality
    $('.wishlist-button').on('click', function(e) {
        e.preventDefault();
        
        const button = $(this);
        const productId = button.data('product-id');
        
        // Toggle wishlist state
        button.toggleClass('active');
        
        if (button.hasClass('active')) {
            button.text('❤️');
            showNotification('Added to wishlist!', 'success');
        } else {
            button.text('🤍');
            showNotification('Removed from wishlist!', 'info');
        }
        
        // Send AJAX request to update wishlist
        $.ajax({
            url: pet_paws_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'update_wishlist',
                product_id: productId,
                nonce: pet_paws_ajax.nonce
            },
            success: function(response) {
                console.log('Wishlist updated:', response);
            }
        });
    });
    
    // Show notification
    function showNotification(message, type = 'info') {
        const notification = $('<div class="notification notification-' + type + '">' + message + '</div>');
        $('body').append(notification);
        
        // Animate in
        notification.addClass('show');
        
        // Remove after 3 seconds
        setTimeout(function() {
            notification.removeClass('show');
            setTimeout(function() {
                notification.remove();
            }, 300);
        }, 3000);
    }
    
    // Quantity selector for products
    $('.quantity-selector').on('click', function() {
        const button = $(this);
        const input = button.siblings('.quantity-input');
        const currentValue = parseInt(input.val()) || 1;
        
        if (button.hasClass('quantity-up')) {
            input.val(currentValue + 1);
        } else if (button.hasClass('quantity-down') && currentValue > 1) {
            input.val(currentValue - 1);
        }
        
        // Trigger change event
        input.trigger('change');
    });
    
    // Price range slider
    if ($('.price-range').length) {
        $('.price-range').slider({
            range: true,
            min: 0,
            max: 1000,
            values: [0, 1000],
            slide: function(event, ui) {
                $('.price-min').text('฿' + ui.values[0]);
                $('.price-max').text('฿' + ui.values[1]);
            },
            change: function(event, ui) {
                filterProductsByPrice(ui.values[0], ui.values[1]);
            }
        });
    }
    
    // Filter products by price
    function filterProductsByPrice(min, max) {
        $('.product-card').each(function() {
            const price = parseFloat($(this).find('.product-price').text().replace('฿', '').replace(',', ''));
            if (price >= min && price <= max) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    }
    
    // Back to top button
    const backToTop = $('<button class="back-to-top">↑</button>');
    $('body').append(backToTop);
    
    $(window).scroll(function() {
        if ($(this).scrollTop() > 300) {
            backToTop.addClass('show');
        } else {
            backToTop.removeClass('show');
        }
    });
    
    backToTop.on('click', function() {
        $('html, body').animate({scrollTop: 0}, 800);
    });
    
    // Product quick view
    $('.quick-view-button').on('click', function(e) {
        e.preventDefault();
        
        const productId = $(this).data('product-id');
        
        // Show loading
        showNotification('Loading product details...', 'info');
        
        // Load product details via AJAX
        $.ajax({
            url: pet_paws_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'quick_view',
                product_id: productId,
                nonce: pet_paws_ajax.nonce
            },
            success: function(response) {
                if (response.success) {
                    showQuickViewModal(response.data);
                } else {
                    showNotification('Error loading product details', 'error');
                }
            }
        });
    });
    
    // Show quick view modal
    function showQuickViewModal(productData) {
        const modal = $(`
            <div class="quick-view-modal">
                <div class="modal-content">
                    <span class="close">&times;</span>
                    <div class="product-details">
                        <div class="product-image">
                            <img src="${productData.image}" alt="${productData.title}">
                        </div>
                        <div class="product-info">
                            <h3>${productData.title}</h3>
                            <p>${productData.description}</p>
                            <div class="price">${productData.price}</div>
                            <button class="add-to-cart" data-product-id="${productData.id}">Add to Cart</button>
                        </div>
                    </div>
                </div>
            </div>
        `);
        
        $('body').append(modal);
        
        // Close modal
        modal.find('.close, .quick-view-modal').on('click', function() {
            modal.remove();
        });
    }
    
    // Newsletter signup
    $('.newsletter-form').on('submit', function(e) {
        e.preventDefault();
        
        const email = $(this).find('input[type="email"]').val();
        
        if (!email) {
            showNotification('Please enter your email address', 'error');
            return;
        }
        
        // Simulate newsletter signup
        showNotification('Thank you for subscribing!', 'success');
        $(this).find('input[type="email"]').val('');
    });
    
    // Initialize tooltips
    $('[data-tooltip]').tooltip();
    
    // Initialize popovers
    $('[data-popover]').popover();
    
});

// CSS for additional styles
const additionalStyles = `
<style>
.notification {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 15px 20px;
    border-radius: 5px;
    color: white;
    font-weight: bold;
    z-index: 9999;
    transform: translateX(100%);
    transition: transform 0.3s ease;
}

.notification.show {
    transform: translateX(0);
}

.notification-success {
    background: #4caf50;
}

.notification-info {
    background: #2196f3;
}

.notification-error {
    background: #f44336;
}

.back-to-top {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 50px;
    height: 50px;
    background: #1976d2;
    color: white;
    border: none;
    border-radius: 50%;
    font-size: 20px;
    cursor: pointer;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
    z-index: 1000;
}

.back-to-top.show {
    opacity: 1;
    visibility: visible;
}

.back-to-top:hover {
    background: #1565c0;
    transform: translateY(-2px);
}

.quick-view-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10000;
}

.modal-content {
    background: white;
    padding: 30px;
    border-radius: 10px;
    max-width: 600px;
    width: 90%;
    position: relative;
}

.close {
    position: absolute;
    top: 10px;
    right: 15px;
    font-size: 24px;
    cursor: pointer;
    color: #666;
}

.close:hover {
    color: #000;
}

.product-details {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

@media (max-width: 768px) {
    .product-details {
        grid-template-columns: 1fr;
    }
}

.lazy {
    opacity: 0;
    transition: opacity 0.3s;
}

.lazy.loaded {
    opacity: 1;
}

.product-image.hover {
    transform: scale(1.05);
}

.quantity-selector {
    display: flex;
    align-items: center;
    gap: 10px;
}

.quantity-input {
    width: 60px;
    text-align: center;
    border: 1px solid #ddd;
    border-radius: 5px;
    padding: 5px;
}

.quantity-up,
.quantity-down {
    width: 30px;
    height: 30px;
    border: 1px solid #ddd;
    background: white;
    cursor: pointer;
    border-radius: 5px;
}

.quantity-up:hover,
.quantity-down:hover {
    background: #f5f5f5;
}

.price-range {
    margin: 20px 0;
}

.price-min,
.price-max {
    font-weight: bold;
    color: #1976d2;
}
</style>
`;

// Add styles to head
document.head.insertAdjacentHTML('beforeend', additionalStyles);
