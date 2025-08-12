    </div><!-- #content -->
    
    <!-- Footer -->
    <footer class="site-footer">
        <div class="container">
            <div class="footer-content">
                <!-- Footer Brand -->
                <div class="footer-column footer-brand-column">
                    <div class="footer-brand">
                        <div class="footer-logo">🐾</div>
                        <div>
                            <h3><?php bloginfo('name'); ?></h3>
                            <p class="footer-tagline"><?php bloginfo('description'); ?></p>
                        </div>
                    </div>
                    <p class="footer-description">
                        <?php esc_html_e('Your trusted partner for premium pet food and supplies. We care about your pets as much as you do!', 'pet-paws'); ?>
                    </p>
                    <div class="footer-social">
                        <?php echo pet_paws_get_social_links(); ?>
                    </div>
                </div>
                
                <!-- Footer Menu 1 -->
                <div class="footer-column">
                    <?php if (is_active_sidebar('footer-1')): ?>
                        <?php dynamic_sidebar('footer-1'); ?>
                    <?php else: ?>
                        <h4 class="footer-title"><?php esc_html_e('Quick Links', 'pet-paws'); ?></h4>
                        <?php
                        wp_nav_menu(array(
                            'theme_location' => 'footer',
                            'menu_class'     => 'footer-links',
                            'container'      => false,
                            'depth'          => 1,
                            'fallback_cb'    => 'pet_paws_footer_menu_fallback',
                        ));
                        ?>
                    <?php endif; ?>
                </div>
                
                <!-- Footer Menu 2 -->
                <div class="footer-column">
                    <?php if (is_active_sidebar('footer-2')): ?>
                        <?php dynamic_sidebar('footer-2'); ?>
                    <?php else: ?>
                        <h4 class="footer-title"><?php esc_html_e('Customer Service', 'pet-paws'); ?></h4>
                        <ul class="footer-links">
                            <li><a href="<?php echo esc_url(home_url('/shipping-policy')); ?>"><?php esc_html_e('Shipping Policy', 'pet-paws'); ?></a></li>
                            <li><a href="<?php echo esc_url(home_url('/return-policy')); ?>"><?php esc_html_e('Return Policy', 'pet-paws'); ?></a></li>
                            <li><a href="<?php echo esc_url(home_url('/faq')); ?>"><?php esc_html_e('FAQ', 'pet-paws'); ?></a></li>
                            <li><a href="<?php echo esc_url(home_url('/contact')); ?>"><?php esc_html_e('Contact Us', 'pet-paws'); ?></a></li>
                        </ul>
                    <?php endif; ?>
                </div>
                
                <!-- Footer Contact -->
                <div class="footer-column">
                    <?php if (is_active_sidebar('footer-3')): ?>
                        <?php dynamic_sidebar('footer-3'); ?>
                    <?php else: ?>
                        <h4 class="footer-title"><?php esc_html_e('Contact Info', 'pet-paws'); ?></h4>
                        <div class="footer-contact">
                            <?php 
                            $phone = get_theme_mod('pet_paws_phone', '02-123-4567');
                            $email = get_theme_mod('pet_paws_email', 'info@petpaws.com');
                            ?>
                            
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon">
                                    <i class="fas fa-map-marker-alt"></i>
                                </div>
                                <div>
                                    <p><?php esc_html_e('123 Pet Street, Bangkok 10110', 'pet-paws'); ?></p>
                                    <p><?php esc_html_e('Thailand', 'pet-paws'); ?></p>
                                </div>
                            </div>
                            
                            <?php if ($phone): ?>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon">
                                    <i class="fas fa-phone"></i>
                                </div>
                                <div>
                                    <p><?php echo esc_html($phone); ?></p>
                                </div>
                            </div>
                            <?php endif; ?>
                            
                            <?php if ($email): ?>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon">
                                    <i class="fas fa-envelope"></i>
                                </div>
                                <div>
                                    <p><?php echo esc_html($email); ?></p>
                                </div>
                            </div>
                            <?php endif; ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <!-- Footer Bottom -->
            <div class="footer-bottom">
                <p class="footer-copyright">
                    &copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?>. 
                    <?php esc_html_e('All rights reserved.', 'pet-paws'); ?>
                </p>
            </div>
        </div>
    </footer>
    
    <?php
    // Footer menu fallback
    function pet_paws_footer_menu_fallback() {
        ?>
        <ul class="footer-links">
            <li><a href="<?php echo esc_url(home_url('/about')); ?>"><?php esc_html_e('About Us', 'pet-paws'); ?></a></li>
            <li><a href="<?php echo esc_url(home_url('/products')); ?>"><?php esc_html_e('Products', 'pet-paws'); ?></a></li>
            <li><a href="<?php echo esc_url(home_url('/blog')); ?>"><?php esc_html_e('Blog', 'pet-paws'); ?></a></li>
            <li><a href="<?php echo esc_url(home_url('/contact')); ?>"><?php esc_html_e('Contact', 'pet-paws'); ?></a></li>
        </ul>
        <?php
    }
    ?>
    
</div><!-- #page -->

<?php wp_footer(); ?>

</body>
</html>