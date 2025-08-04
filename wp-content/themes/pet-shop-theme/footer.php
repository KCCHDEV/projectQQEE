    <footer id="colophon" class="site-footer">
        <div class="footer-content">
            <div class="footer-section">
                <h3>🐕 Pet Paradise</h3>
                <p>Your trusted partner for all pet care needs. We provide premium quality products and exceptional service to keep your furry friends happy and healthy.</p>
                <div class="social-links">
                    <a href="#" aria-label="Facebook">📘</a>
                    <a href="#" aria-label="Instagram">📷</a>
                    <a href="#" aria-label="Twitter">🐦</a>
                    <a href="#" aria-label="YouTube">📺</a>
                </div>
            </div>
            
            <div class="footer-section">
                <h3>Quick Links</h3>
                <a href="<?php echo esc_url(home_url('/')); ?>">Home</a>
                <a href="<?php echo wc_get_page_permalink('shop'); ?>">Shop</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_shop_page_id')); ?>">Products</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_cart_page_id')); ?>">Cart</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_myaccount_page_id')); ?>">My Account</a>
            </div>
            
            <div class="footer-section">
                <h3>Categories</h3>
                <a href="<?php echo get_term_link('dog-food', 'product_cat'); ?>">Dog Food</a>
                <a href="<?php echo get_term_link('toys', 'product_cat'); ?>">Toys & Games</a>
                <a href="<?php echo get_term_link('grooming', 'product_cat'); ?>">Grooming</a>
                <a href="<?php echo get_term_link('accessories', 'product_cat'); ?>">Beds & Accessories</a>
                <a href="<?php echo get_term_link('health', 'product_cat'); ?>">Health & Wellness</a>
            </div>
            
            <div class="footer-section">
                <h3>Customer Service</h3>
                <a href="<?php echo get_permalink(get_option('woocommerce_terms_page_id')); ?>">Terms & Conditions</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_privacy_policy_page_id')); ?>">Privacy Policy</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_refund_returns_page_id')); ?>">Returns & Refunds</a>
                <a href="<?php echo get_permalink(get_option('woocommerce_shipping_page_id')); ?>">Shipping Information</a>
                <a href="mailto:support@petparadise.com">Contact Support</a>
            </div>
            
            <div class="footer-section">
                <h3>Contact Info</h3>
                <p>📍 123 Pet Street, Bangkok 10110</p>
                <p>📞 +66 2 123 4567</p>
                <p>📧 hello@petparadise.com</p>
                <p>🕒 Mon-Sat: 9AM-8PM</p>
            </div>
        </div>
        
        <div class="footer-bottom">
            <p>&copy; <?php echo date('Y'); ?> Pet Paradise. All rights reserved. Made with ❤️ for pets everywhere.</p>
        </div>
    </footer>

    <style>
    .social-links {
        margin-top: 1rem;
    }
    
    .social-links a {
        display: inline-block;
        margin-right: 1rem;
        font-size: 1.5rem;
        transition: transform 0.3s ease;
    }
    
    .social-links a:hover {
        transform: translateY(-3px);
    }
    
    .footer-section p {
        margin-bottom: 0.5rem;
        line-height: 1.6;
    }
    </style>

    <!-- Back to Top Button -->
    <button id="back-to-top" class="back-to-top" aria-label="Back to top">
        ↑
    </button>

    <style>
    .back-to-top {
        position: fixed;
        bottom: 2rem;
        right: 2rem;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        width: 50px;
        height: 50px;
        border-radius: 50%;
        font-size: 1.5rem;
        cursor: pointer;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
        z-index: 1000;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
    }
    
    .back-to-top.visible {
        opacity: 1;
        visibility: visible;
    }
    
    .back-to-top:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
    }
    
    @media (max-width: 768px) {
        .back-to-top {
            bottom: 1rem;
            right: 1rem;
            width: 45px;
            height: 45px;
            font-size: 1.25rem;
        }
    }
    </style>

    <script>
    // Back to top functionality
    document.addEventListener('DOMContentLoaded', function() {
        const backToTopButton = document.getElementById('back-to-top');
        
        if (backToTopButton) {
            // Show/hide button based on scroll position
            window.addEventListener('scroll', function() {
                if (window.pageYOffset > 300) {
                    backToTopButton.classList.add('visible');
                } else {
                    backToTopButton.classList.remove('visible');
                }
            });
            
            // Smooth scroll to top when clicked
            backToTopButton.addEventListener('click', function() {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            });
        }
        
        // Add loading animation to all buttons
        const buttons = document.querySelectorAll('button, .cta-button, .category-link');
        buttons.forEach(button => {
            button.addEventListener('click', function() {
                if (!this.disabled) {
                    this.style.transform = 'scale(0.95)';
                    setTimeout(() => {
                        this.style.transform = '';
                    }, 150);
                }
            });
        });
        
        // Add hover effects to product cards
        const productCards = document.querySelectorAll('.product-card');
        productCards.forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-10px) scale(1.02)';
            });
            
            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0) scale(1)';
            });
        });
    });
    
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
    </script>

</div><!-- #page -->

<?php wp_footer(); ?>

</body>
</html> 