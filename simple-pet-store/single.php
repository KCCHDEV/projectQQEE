<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php wp_title('|', true, 'right'); ?><?php bloginfo('name'); ?></title>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>

<!-- Header -->
<header class="site-header">
    <div class="header-container">
        <a href="<?php echo home_url(); ?>" class="site-title">
            🐾 <?php bloginfo('name'); ?>
        </a>
        
        <nav class="main-nav">
            <?php
            wp_nav_menu(array(
                'theme_location' => 'primary',
                'container' => false,
                'fallback_cb' => 'simple_pet_store_fallback_menu'
            ));
            ?>
        </nav>
    </div>
</header>

<!-- Main Content -->
<main class="main-content">
    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem; margin-top: 2rem;">
        
        <article style="background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.1);">
            <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
                
                <h1 style="color: #333; margin-bottom: 1rem;"><?php the_title(); ?></h1>
                
                <div style="color: #666; margin-bottom: 1.5rem; font-size: 0.9rem;">
                    📅 <?php echo get_the_date(); ?> | 
                    👤 <?php the_author(); ?> | 
                    📂 <?php the_category(', '); ?>
                </div>
                
                <?php if (has_post_thumbnail()) : ?>
                    <div style="margin-bottom: 2rem;">
                        <?php the_post_thumbnail('large', array('style' => 'width: 100%; height: 300px; object-fit: cover; border-radius: 10px;')); ?>
                    </div>
                <?php endif; ?>
                
                <div style="line-height: 1.8; color: #333;">
                    <?php the_content(); ?>
                </div>
                
                <div style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #eee;">
                    <div style="display: flex; gap: 1rem;">
                        <?php if (get_previous_post()) : ?>
                            <a href="<?php echo get_permalink(get_previous_post()); ?>" class="btn" style="background: #667eea;">← บทความก่อนหน้า</a>
                        <?php endif; ?>
                        
                        <?php if (get_next_post()) : ?>
                            <a href="<?php echo get_permalink(get_next_post()); ?>" class="btn" style="background: #667eea;">บทความถัดไป →</a>
                        <?php endif; ?>
                    </div>
                </div>
                
            <?php endwhile; endif; ?>
        </article>
        
        <aside style="background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); height: fit-content;">
            <h3 style="color: #333; margin-bottom: 1rem;">บทความล่าสุด</h3>
            
            <?php
            $recent_posts = wp_get_recent_posts(array(
                'numberposts' => 5,
                'post_status' => 'publish'
            ));
            
            foreach ($recent_posts as $post) : ?>
                <div style="margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid #eee;">
                    <a href="<?php echo get_permalink($post['ID']); ?>" style="color: #333; text-decoration: none; font-weight: 500;">
                        <?php echo $post['post_title']; ?>
                    </a>
                    <div style="font-size: 0.8rem; color: #666; margin-top: 0.5rem;">
                        📅 <?php echo get_the_date('', $post['ID']); ?>
                    </div>
                </div>
            <?php endforeach; ?>
            
            <div style="margin-top: 2rem;">
                <h3 style="color: #333; margin-bottom: 1rem;">หมวดหมู่</h3>
                <?php
                $categories = get_categories();
                foreach ($categories as $category) : ?>
                    <a href="<?php echo get_category_link($category->term_id); ?>" 
                       style="display: inline-block; background: #f0f0f0; padding: 0.3rem 0.8rem; margin: 0.2rem; border-radius: 15px; text-decoration: none; color: #666; font-size: 0.9rem;">
                        <?php echo $category->name; ?> (<?php echo $category->count; ?>)
                    </a>
                <?php endforeach; ?>
            </div>
        </aside>
        
    </div>
</main>

<!-- Footer -->
<footer class="site-footer">
    <div class="footer-content">
        <div class="footer-section">
            <h3>เกี่ยวกับเรา</h3>
            <p>ร้านขายอุปกรณ์และอาหารสัตว์เลี้ยงคุณภาพ มีสินค้าหลากหลายสำหรับสัตว์เลี้ยงทุกชนิด</p>
        </div>
        
        <div class="footer-section">
            <h3>ติดต่อเรา</h3>
            <ul>
                <li>📞 โทร: 02-xxx-xxxx</li>
                <li>📧 อีเมล: info@petstore.com</li>
                <li>📍 ที่อยู่: กรุงเทพมหานคร</li>
            </ul>
        </div>
        
        <div class="footer-section">
            <h3>บริการ</h3>
            <ul>
                <li><a href="#">จัดส่งฟรี</a></li>
                <li><a href="#">รับประกันสินค้า</a></li>
                <li><a href="#">คำแนะนำการเลี้ยง</a></li>
                <li><a href="#">บริการหลังการขาย</a></li>
            </ul>
        </div>
        
        <div class="footer-section">
            <h3>ติดตามเรา</h3>
            <ul>
                <li><a href="#">📘 Facebook</a></li>
                <li><a href="#">📷 Instagram</a></li>
                <li><a href="#">🐦 Twitter</a></li>
                <li><a href="#">📺 YouTube</a></li>
            </ul>
        </div>
    </div>
    
    <div class="footer-bottom">
        <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?>. สงวนลิขสิทธิ์.</p>
    </div>
</footer>

<?php wp_footer(); ?>
</body>
</html>