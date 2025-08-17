<?php get_header(); ?>

<!-- Category Filter -->
<div class="category-filter">
    <button class="category-button active" data-category="all">All Products</button>
    <button class="category-button" data-category="dog-food">Dog Food</button>
    <button class="category-button" data-category="cat-food">Cat Food</button>
    <button class="category-button" data-category="toys">Pet Toys</button>
</div>

<!-- Products Section -->
<section class="products-section">
    <h2 class="section-title">Our Products</h2>
    
    <div class="products-grid">
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
            <article class="product-card">
                <div class="product-image">
                    <?php if (has_post_thumbnail()) : ?>
                        <?php the_post_thumbnail('medium'); ?>
                    <?php else : ?>
                        <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 3rem;">
                            🐕
                        </div>
                    <?php endif; ?>
                </div>
                
                <div class="product-info">
                    <h3 class="product-title"><?php the_title(); ?></h3>
                    <p class="product-description"><?php echo wp_trim_words(get_the_excerpt(), 15); ?></p>
                    
                    <?php if (class_exists('WooCommerce') && get_post_type() === 'product') : ?>
                        <?php
                        $product = wc_get_product(get_the_ID());
                        if ($product) :
                        ?>
                            <div class="product-price">
                                <?php echo $product->get_price_html(); ?>
                            </div>
                            
                            <form class="cart" action="<?php echo esc_url($product->add_to_cart_url()); ?>" method="post" enctype='multipart/form-data'>
                                <button type="submit" class="add-to-cart" name="add-to-cart" value="<?php echo esc_attr($product->get_id()); ?>">
                                    Add to Cart
                                </button>
                            </form>
                        <?php endif; ?>
                    <?php else : ?>
                        <div class="product-price">฿299.00</div>
                        <button class="add-to-cart">Add to Cart</button>
                    <?php endif; ?>
                </div>
            </article>
        <?php endwhile; endif; ?>
        
        <!-- Sample Products if no posts -->
        <?php if (!have_posts()) : ?>
            <!-- Dog Food Products -->
            <article class="product-card" data-category="dog-food">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🐕
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">ADULT สุนัขโต</h3>
                    <p class="product-description">อาหารสุนัข แบบเปียก Pedigree รส ไก่กับดับในน้ำเกรวี่</p>
                    <div class="product-price">฿22.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <article class="product-card" data-category="dog-food">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🦴
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Pedigree ADULT MINI</h3>
                    <p class="product-description">อาหารสุนัข แบบเม็ด Pedigree รส เนื้อวัว 1.3 kg</p>
                    <div class="product-price">฿250.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <article class="product-card" data-category="dog-food">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🍖
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Pedigree ADULT MINI</h3>
                    <p class="product-description">อาหารสุนัข แบบเม็ด ยี่ห้อ Pedigree รส ไก่ 1.3 kg</p>
                    <div class="product-price">฿250.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <!-- Cat Food Products -->
            <article class="product-card" data-category="cat-food">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🐱
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Sheba Cat Food</h3>
                    <p class="product-description">อาหารแมว แบบเปียก Sheba รส ทูน่าปูอัด</p>
                    <div class="product-price">฿18.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <article class="product-card" data-category="cat-food">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🐟
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Pet8 Cat Food</h3>
                    <p class="product-description">อาหารแมว แบบเปียก Cat8 รส ทูน่า</p>
                    <div class="product-price">฿15.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <article class="product-card" data-category="cat-food">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🦀
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Sheba Premium</h3>
                    <p class="product-description">อาหารแมว แบบเปียก Sheba รส ทูน่าและปูอัด</p>
                    <div class="product-price">฿18.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <!-- Pet Toys -->
            <article class="product-card" data-category="toys">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🎾
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Dog Ball Toy</h3>
                    <p class="product-description">ลูกบอลของเล่นสุนัข ยางคุณภาพสูง</p>
                    <div class="product-price">฿150.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <article class="product-card" data-category="toys">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🐭
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Cat Mouse Toy</h3>
                    <p class="product-description">ของเล่นแมว รูปหนู มีเสียง</p>
                    <div class="product-price">฿89.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
            
            <article class="product-card" data-category="toys">
                <div class="product-image">
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 4rem;">
                        🦴
                    </div>
                </div>
                <div class="product-info">
                    <h3 class="product-title">Chew Bone</h3>
                    <p class="product-description">กระดูกเคี้ยวสำหรับสุนัข ปลอดภัย</p>
                    <div class="product-price">฿120.00</div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            </article>
        <?php endif; ?>
    </div>
</section>

<script>
// Category Filter Functionality
document.addEventListener('DOMContentLoaded', function() {
    const categoryButtons = document.querySelectorAll('.category-button');
    const productCards = document.querySelectorAll('.product-card');
    
    categoryButtons.forEach(button => {
        button.addEventListener('click', function() {
            const category = this.getAttribute('data-category');
            
            // Update active button
            categoryButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // Filter products
            productCards.forEach(card => {
                if (category === 'all' || card.getAttribute('data-category') === category) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });
    
    // Add to Cart Animation
    const addToCartButtons = document.querySelectorAll('.add-to-cart');
    addToCartButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Show success message
            const successMessage = document.createElement('div');
            successMessage.className = 'success-message';
            successMessage.textContent = 'Product added to cart!';
            
            this.parentNode.appendChild(successMessage);
            
            // Remove message after 3 seconds
            setTimeout(() => {
                successMessage.remove();
            }, 3000);
        });
    });
});
</script>

<?php get_footer(); ?>
