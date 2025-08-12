<?php
/**
 * The front page template file
 *
 * @package Pet_Paws
 */

get_header();
?>

<main id="primary" class="site-main">
    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <div class="hero-content">
                <div class="hero-text">
                    <p class="hero-subtitle"><?php esc_html_e('Premium Pet Food & Supplies', 'pet-paws'); ?></p>
                    <h1 class="hero-title"><?php esc_html_e('Everything Your Pet Needs for a Happy Life', 'pet-paws'); ?></h1>
                    <p class="hero-description">
                        <?php esc_html_e('Discover our wide range of high-quality pet food, toys, and accessories. We care about your furry friends!', 'pet-paws'); ?>
                    </p>
                    <div class="hero-buttons">
                        <a href="<?php echo esc_url(get_permalink(wc_get_page_id('shop'))); ?>" class="btn btn-primary btn-lg">
                            <i class="fas fa-shopping-cart"></i>
                            <?php esc_html_e('Shop Now', 'pet-paws'); ?>
                        </a>
                        <a href="#categories" class="btn btn-outline btn-lg">
                            <?php esc_html_e('Browse Categories', 'pet-paws'); ?>
                        </a>
                    </div>
                </div>
                <div class="hero-image">
                    <img src="<?php echo get_template_directory_uri(); ?>/assets/images/hero-pets.jpg" alt="<?php esc_attr_e('Happy pets', 'pet-paws'); ?>">
                    <div class="hero-badge">
                        <div class="hero-badge-icon">🏆</div>
                        <div class="hero-badge-text"><?php esc_html_e('Trusted by 10,000+ Pet Owners', 'pet-paws'); ?></div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Features Section -->
    <section class="features">
        <div class="container">
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-truck"></i>
                    </div>
                    <h3 class="feature-title"><?php esc_html_e('Free Shipping', 'pet-paws'); ?></h3>
                    <p class="feature-description"><?php esc_html_e('Free delivery on orders over ฿500', 'pet-paws'); ?></p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-medal"></i>
                    </div>
                    <h3 class="feature-title"><?php esc_html_e('Premium Quality', 'pet-paws'); ?></h3>
                    <p class="feature-description"><?php esc_html_e('Only the best brands for your pets', 'pet-paws'); ?></p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-heart"></i>
                    </div>
                    <h3 class="feature-title"><?php esc_html_e('Pet Nutrition Experts', 'pet-paws'); ?></h3>
                    <p class="feature-description"><?php esc_html_e('Expert advice for your pet\'s health', 'pet-paws'); ?></p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3 class="feature-title"><?php esc_html_e('100% Safe', 'pet-paws'); ?></h3>
                    <p class="feature-description"><?php esc_html_e('Secure payment & data protection', 'pet-paws'); ?></p>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Product Categories -->
    <section id="categories" class="product-categories">
        <div class="container">
            <div class="section-header">
                <p class="section-subtitle"><?php esc_html_e('Browse by Category', 'pet-paws'); ?></p>
                <h2 class="section-title"><?php esc_html_e('Shop by Pet Type', 'pet-paws'); ?></h2>
            </div>
            
            <div class="categories-grid">
                <?php
                $product_categories = get_terms(array(
                    'taxonomy' => 'product_cat',
                    'hide_empty' => false,
                    'parent' => 0,
                    'number' => 6,
                ));
                
                if ($product_categories && !is_wp_error($product_categories)):
                    foreach ($product_categories as $category):
                        $thumbnail_id = get_term_meta($category->term_id, 'thumbnail_id', true);
                        $image = wp_get_attachment_url($thumbnail_id);
                        ?>
                        <a href="<?php echo esc_url(get_term_link($category)); ?>" class="category-card">
                            <div class="category-image">
                                <?php if ($image): ?>
                                    <img src="<?php echo esc_url($image); ?>" alt="<?php echo esc_attr($category->name); ?>">
                                <?php else: ?>
                                    <div class="category-placeholder">
                                        <i class="fas fa-paw"></i>
                                    </div>
                                <?php endif; ?>
                            </div>
                            <h3 class="category-name"><?php echo esc_html($category->name); ?></h3>
                            <span class="category-count"><?php echo esc_html($category->count); ?> <?php esc_html_e('Products', 'pet-paws'); ?></span>
                        </a>
                    <?php 
                    endforeach;
                endif;
                ?>
            </div>
        </div>
    </section>
    
    <!-- Featured Products -->
    <section class="products">
        <div class="container">
            <div class="section-header">
                <p class="section-subtitle"><?php esc_html_e('Featured Products', 'pet-paws'); ?></p>
                <h2 class="section-title"><?php esc_html_e('Best Sellers', 'pet-paws'); ?></h2>
                <p class="section-description"><?php esc_html_e('Check out our most popular products loved by pet owners', 'pet-paws'); ?></p>
            </div>
            
            <div class="product-tabs">
                <button class="tab-button active" data-tab="featured"><?php esc_html_e('Featured', 'pet-paws'); ?></button>
                <button class="tab-button" data-tab="best-sellers"><?php esc_html_e('Best Sellers', 'pet-paws'); ?></button>
                <button class="tab-button" data-tab="new"><?php esc_html_e('New Arrivals', 'pet-paws'); ?></button>
                <button class="tab-button" data-tab="sale"><?php esc_html_e('On Sale', 'pet-paws'); ?></button>
            </div>
            
            <div class="products-grid">
                <?php
                $featured_products = pet_paws_get_featured_products(8);
                
                if ($featured_products->have_posts()):
                    while ($featured_products->have_posts()): $featured_products->the_post();
                        global $product;
                        ?>
                        <div class="product-card">
                            <div class="product-image">
                                <a href="<?php the_permalink(); ?>">
                                    <?php
                                    if (has_post_thumbnail()) {
                                        the_post_thumbnail('pet-paws-product');
                                    } else {
                                        echo '<img src="' . wc_placeholder_img_src() . '" alt="' . get_the_title() . '">';
                                    }
                                    ?>
                                </a>
                                
                                <div class="product-badges">
                                    <?php if ($product->is_on_sale()): ?>
                                        <span class="product-badge sale"><?php esc_html_e('Sale', 'pet-paws'); ?></span>
                                    <?php endif; ?>
                                    
                                    <?php if ($product->is_featured()): ?>
                                        <span class="product-badge featured"><?php esc_html_e('Hot', 'pet-paws'); ?></span>
                                    <?php endif; ?>
                                </div>
                                
                                <div class="product-actions">
                                    <button class="product-action quick-view" data-product-id="<?php echo get_the_ID(); ?>">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="product-action add-to-wishlist">
                                        <i class="fas fa-heart"></i>
                                    </button>
                                </div>
                            </div>
                            
                            <div class="product-info">
                                <div class="product-category">
                                    <?php
                                    $categories = get_the_terms(get_the_ID(), 'product_cat');
                                    if ($categories && !is_wp_error($categories)) {
                                        echo esc_html($categories[0]->name);
                                    }
                                    ?>
                                </div>
                                
                                <h3 class="product-name">
                                    <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                                </h3>
                                
                                <?php if ($average = $product->get_average_rating()): ?>
                                <div class="product-rating">
                                    <div class="stars">
                                        <?php echo wc_get_rating_html($average); ?>
                                    </div>
                                    <span class="rating-count">(<?php echo $product->get_review_count(); ?>)</span>
                                </div>
                                <?php endif; ?>
                                
                                <div class="product-price">
                                    <?php echo $product->get_price_html(); ?>
                                </div>
                                
                                <?php woocommerce_template_loop_add_to_cart(); ?>
                            </div>
                        </div>
                    <?php
                    endwhile;
                    wp_reset_postdata();
                endif;
                ?>
            </div>
            
            <div class="text-center" style="margin-top: 3rem;">
                <a href="<?php echo esc_url(get_permalink(wc_get_page_id('shop'))); ?>" class="btn btn-primary btn-lg">
                    <?php esc_html_e('View All Products', 'pet-paws'); ?>
                    <i class="fas fa-arrow-right"></i>
                </a>
            </div>
        </div>
    </section>
    
    <!-- CTA Section -->
    <section class="cta">
        <div class="container">
            <div class="cta-content">
                <h2 class="cta-title"><?php esc_html_e('Join Our Pet Lovers Community', 'pet-paws'); ?></h2>
                <p class="cta-description">
                    <?php esc_html_e('Get exclusive offers, pet care tips, and be the first to know about new products!', 'pet-paws'); ?>
                </p>
                <div class="cta-buttons">
                    <a href="<?php echo esc_url(home_url('/newsletter')); ?>" class="btn btn-secondary btn-lg">
                        <i class="fas fa-envelope"></i>
                        <?php esc_html_e('Subscribe Newsletter', 'pet-paws'); ?>
                    </a>
                    <a href="<?php echo esc_url(home_url('/contact')); ?>" class="btn btn-outline btn-lg" style="background: white; color: var(--primary);">
                        <?php esc_html_e('Contact Us', 'pet-paws'); ?>
                    </a>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Blog Section -->
    <section class="blog-section">
        <div class="container">
            <div class="section-header">
                <p class="section-subtitle"><?php esc_html_e('Pet Care Tips', 'pet-paws'); ?></p>
                <h2 class="section-title"><?php esc_html_e('Latest from Our Blog', 'pet-paws'); ?></h2>
            </div>
            
            <div class="blog-grid">
                <?php
                $recent_posts = new WP_Query(array(
                    'posts_per_page' => 3,
                    'post_type' => 'post',
                    'post_status' => 'publish',
                ));
                
                if ($recent_posts->have_posts()):
                    while ($recent_posts->have_posts()): $recent_posts->the_post();
                        ?>
                        <article class="blog-card">
                            <div class="blog-image">
                                <a href="<?php the_permalink(); ?>">
                                    <?php
                                    if (has_post_thumbnail()) {
                                        the_post_thumbnail('pet-paws-blog');
                                    } else {
                                        echo '<img src="' . get_template_directory_uri() . '/assets/images/blog-placeholder.jpg" alt="' . get_the_title() . '">';
                                    }
                                    ?>
                                </a>
                                <div class="blog-category">
                                    <?php
                                    $categories = get_the_category();
                                    if (!empty($categories)) {
                                        echo esc_html($categories[0]->name);
                                    }
                                    ?>
                                </div>
                            </div>
                            
                            <div class="blog-content">
                                <div class="blog-meta">
                                    <span class="blog-date">
                                        <i class="fas fa-calendar"></i>
                                        <?php echo get_the_date(); ?>
                                    </span>
                                    <span class="blog-author">
                                        <i class="fas fa-user"></i>
                                        <?php the_author(); ?>
                                    </span>
                                </div>
                                
                                <h3 class="blog-title">
                                    <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                                </h3>
                                
                                <p class="blog-excerpt"><?php echo wp_trim_words(get_the_excerpt(), 20); ?></p>
                                
                                <a href="<?php the_permalink(); ?>" class="blog-link">
                                    <?php esc_html_e('Read More', 'pet-paws'); ?>
                                    <i class="fas fa-arrow-right"></i>
                                </a>
                            </div>
                        </article>
                    <?php
                    endwhile;
                    wp_reset_postdata();
                endif;
                ?>
            </div>
        </div>
    </section>
</main>

<?php
get_footer();
?>