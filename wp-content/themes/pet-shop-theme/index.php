<?php get_header(); ?>

<main id="main" class="site-main">
    <!-- Hero Section -->
    <section class="hero-section">
        <div class="hero-content">
            <h1 class="hero-title">🐕 Pet Paradise</h1>
            <p class="hero-subtitle">Everything your furry friends need for a happy, healthy life</p>
            <a href="<?php echo wc_get_page_permalink('shop'); ?>" class="cta-button">Shop Now</a>
        </div>
    </section>

    <!-- Categories Section -->
    <section class="categories-section">
        <div class="container">
            <h2 class="section-title">Shop by Category</h2>
            <div class="categories-grid">
                <div class="category-card">
                    <span class="category-icon">🦴</span>
                    <h3 class="category-title">Dog Food</h3>
                    <p class="category-description">Premium nutrition for your canine companion</p>
                    <a href="<?php echo get_term_link('dog-food', 'product_cat'); ?>" class="category-link">Browse Food</a>
                </div>
                
                <div class="category-card">
                    <span class="category-icon">🧸</span>
                    <h3 class="category-title">Toys & Games</h3>
                    <p class="category-description">Fun and engaging toys for playtime</p>
                    <a href="<?php echo get_term_link('toys', 'product_cat'); ?>" class="category-link">Browse Toys</a>
                </div>
                
                <div class="category-card">
                    <span class="category-icon">🛁</span>
                    <h3 class="category-title">Grooming</h3>
                    <p class="category-description">Keep your pet clean and healthy</p>
                    <a href="<?php echo get_term_link('grooming', 'product_cat'); ?>" class="category-link">Browse Grooming</a>
                </div>
                
                <div class="category-card">
                    <span class="category-icon">🏠</span>
                    <h3 class="category-title">Beds & Accessories</h3>
                    <p class="category-description">Comfortable homes and accessories</p>
                    <a href="<?php echo get_term_link('accessories', 'product_cat'); ?>" class="category-link">Browse Accessories</a>
                </div>
                
                <div class="category-card">
                    <span class="category-icon">💊</span>
                    <h3 class="category-title">Health & Wellness</h3>
                    <p class="category-description">Supplements and health products</p>
                    <a href="<?php echo get_term_link('health', 'product_cat'); ?>" class="category-link">Browse Health</a>
                </div>
                
                <div class="category-card">
                    <span class="category-icon">🐱</span>
                    <h3 class="category-title">Cat Products</h3>
                    <p class="category-description">Everything for your feline friends</p>
                    <a href="<?php echo get_term_link('cat-products', 'product_cat'); ?>" class="category-link">Browse Cat Products</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Featured Products Section -->
    <section class="products-section">
        <div class="container">
            <h2 class="section-title">Featured Products</h2>
            <div class="products-grid">
                <?php
                $featured_products = wc_get_featured_product_ids();
                if (!empty($featured_products)) {
                    $args = array(
                        'post_type' => 'product',
                        'posts_per_page' => 8,
                        'post__in' => $featured_products,
                        'meta_query' => array(
                            array(
                                'key' => '_visibility',
                                'value' => array('catalog', 'visible'),
                                'compare' => 'IN'
                            )
                        )
                    );
                } else {
                    $args = array(
                        'post_type' => 'product',
                        'posts_per_page' => 8,
                        'meta_query' => array(
                            array(
                                'key' => '_visibility',
                                'value' => array('catalog', 'visible'),
                                'compare' => 'IN'
                            )
                        )
                    );
                }
                
                $products = new WP_Query($args);
                
                if ($products->have_posts()) :
                    while ($products->have_posts()) : $products->the_post();
                        global $product;
                        ?>
                        <div class="product-card">
                            <a href="<?php the_permalink(); ?>">
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
                    endwhile;
                    wp_reset_postdata();
                else :
                    echo '<p>No products found.</p>';
                endif;
                ?>
            </div>
            
            <div style="text-align: center; margin-top: 3rem;">
                <a href="<?php echo wc_get_page_permalink('shop'); ?>" class="cta-button">View All Products</a>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section">
        <div class="container">
            <h2 class="section-title">Why Choose Pet Paradise?</h2>
            <div class="features-grid">
                <div class="feature-item">
                    <span class="feature-icon">🚚</span>
                    <h3 class="feature-title">Free Shipping</h3>
                    <p class="feature-description">Free delivery on orders over ฿500</p>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">⭐</span>
                    <h3 class="feature-title">Premium Quality</h3>
                    <p class="feature-description">Only the best brands and products</p>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">🔄</span>
                    <h3 class="feature-title">Easy Returns</h3>
                    <p class="feature-description">30-day return policy</p>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">🛡️</span>
                    <h3 class="feature-title">Secure Payment</h3>
                    <p class="feature-description">100% secure checkout</p>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">📞</span>
                    <h3 class="feature-title">24/7 Support</h3>
                    <p class="feature-description">Always here to help you</p>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">💝</span>
                    <h3 class="feature-title">Loyalty Rewards</h3>
                    <p class="feature-description">Earn points on every purchase</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Newsletter Section -->
    <section class="newsletter-section" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 4rem 0; color: white; text-align: center;">
        <div class="container">
            <h2 style="margin-bottom: 1rem;">Stay Updated</h2>
            <p style="margin-bottom: 2rem; opacity: 0.9;">Get the latest pet care tips and exclusive offers</p>
            <form class="newsletter-form" style="max-width: 400px; margin: 0 auto;">
                <input type="email" placeholder="Enter your email" style="width: 100%; padding: 1rem; border: none; border-radius: 8px; margin-bottom: 1rem; font-size: 1rem;">
                <button type="submit" class="cta-button" style="width: 100%;">Subscribe</button>
            </form>
        </div>
    </section>
</main>

<script>
function addToCart(productId) {
    const button = event.target;
    const originalText = button.textContent;
    
    button.textContent = 'Adding...';
    button.disabled = true;
    
    fetch('/wp-admin/admin-ajax.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=add_to_cart&product_id=' + productId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            button.textContent = 'Added!';
            button.style.background = '#48bb78';
            
            // Update cart count if you have a cart icon
            if (typeof updateCartCount === 'function') {
                updateCartCount();
            }
            
            setTimeout(() => {
                button.textContent = originalText;
                button.disabled = false;
                button.style.background = '';
            }, 2000);
        } else {
            button.textContent = 'Error';
            button.style.background = '#e53e3e';
            
            setTimeout(() => {
                button.textContent = originalText;
                button.disabled = false;
                button.style.background = '';
            }, 2000);
        }
    })
    .catch(error => {
        button.textContent = 'Error';
        button.style.background = '#e53e3e';
        
        setTimeout(() => {
            button.textContent = originalText;
            button.disabled = false;
            button.style.background = '';
        }, 2000);
    });
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});
</script>

<?php get_footer(); ?> 