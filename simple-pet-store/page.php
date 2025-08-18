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
    <article style="background: white; padding: 3rem; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); margin: 2rem 0;">
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
            
            <h1 style="color: #333; margin-bottom: 2rem; text-align: center; font-size: 2.5rem;">
                <?php the_title(); ?>
            </h1>
            
            <?php if (has_post_thumbnail()) : ?>
                <div style="margin-bottom: 2rem; text-align: center;">
                    <?php the_post_thumbnail('large', array('style' => 'max-width: 100%; height: auto; border-radius: 10px;')); ?>
                </div>
            <?php endif; ?>
            
            <div style="line-height: 1.8; color: #333; font-size: 1.1rem;">
                <?php the_content(); ?>
            </div>
            
        <?php endwhile; endif; ?>
    </article>
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