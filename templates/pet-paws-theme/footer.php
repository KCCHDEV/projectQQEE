</main>

<!-- Footer -->
<footer class="site-footer">
    <div class="footer-content">
        <div class="footer-section">
            <h3>About <?php bloginfo('name'); ?></h3>
            <p>Premium pet food and supplies store dedicated to providing the best care for your beloved companions. We offer high-quality products for dogs, cats, and other pets.</p>
        </div>
        
        <div class="footer-section">
            <h3>Quick Links</h3>
            <ul style="list-style: none; padding: 0;">
                <li><a href="<?php echo esc_url(home_url('/shop')); ?>">Shop</a></li>
                <li><a href="<?php echo esc_url(home_url('/about')); ?>">About Us</a></li>
                <li><a href="<?php echo esc_url(home_url('/contact')); ?>">Contact</a></li>
                <li><a href="<?php echo esc_url(home_url('/my-account')); ?>">My Account</a></li>
            </ul>
        </div>
        
        <div class="footer-section">
            <h3>Customer Service</h3>
            <ul style="list-style: none; padding: 0;">
                <li><a href="#">Shipping Information</a></li>
                <li><a href="#">Returns & Exchanges</a></li>
                <li><a href="#">FAQ</a></li>
                <li><a href="#">Size Guide</a></li>
            </ul>
        </div>
        
        <div class="footer-section">
            <h3>Contact Info</h3>
            <p>📞 Phone: 02-123-4567</p>
            <p>📧 Email: info@petfoodstore.com</p>
            <p>📍 Address: Bangkok, Thailand</p>
            <p>🕒 Hours: Mon-Sat 9AM-6PM</p>
        </div>
    </div>
    
    <div class="footer-bottom">
        <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?>. All rights reserved. | Made with ❤️ for pets</p>
    </div>
</footer>

<?php wp_footer(); ?>

</body>
</html>
