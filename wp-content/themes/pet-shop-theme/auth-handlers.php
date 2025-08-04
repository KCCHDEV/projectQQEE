<?php
/**
 * Pet Shop Pro - Authentication Handlers
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * AJAX Login Handler
 */
function pet_shop_ajax_login() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $email = sanitize_email($_POST['email']);
    $password = $_POST['password'];
    $remember = isset($_POST['remember']) ? true : false;
    
    if (empty($email) || empty($password)) {
        wp_send_json_error('Please fill in all fields');
        return;
    }
    
    $user = get_user_by('email', $email);
    
    if (!$user) {
        wp_send_json_error('Invalid email or password');
        return;
    }
    
    $creds = array(
        'user_login' => $user->user_login,
        'user_password' => $password,
        'remember' => $remember
    );
    
    $login_result = wp_signon($creds, false);
    
    if (is_wp_error($login_result)) {
        wp_send_json_error('Invalid email or password');
    } else {
        wp_send_json_success(array(
            'message' => 'Login successful!',
            'redirect' => home_url('/my-account/')
        ));
    }
}
add_action('wp_ajax_nopriv_pet_shop_login', 'pet_shop_ajax_login');

/**
 * AJAX Registration Handler
 */
function pet_shop_ajax_register() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $firstname = sanitize_text_field($_POST['firstname']);
    $lastname = sanitize_text_field($_POST['lastname']);
    $email = sanitize_email($_POST['email']);
    $phone = sanitize_text_field($_POST['phone']);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];
    $terms = isset($_POST['terms']) ? true : false;
    $newsletter = isset($_POST['newsletter']) ? true : false;
    
    // Validation
    if (empty($firstname) || empty($lastname) || empty($email) || empty($phone) || empty($password)) {
        wp_send_json_error('Please fill in all required fields');
        return;
    }
    
    if (!is_email($email)) {
        wp_send_json_error('Please enter a valid email address');
        return;
    }
    
    if (email_exists($email)) {
        wp_send_json_error('This email address is already registered');
        return;
    }
    
    if (strlen($password) < 8) {
        wp_send_json_error('Password must be at least 8 characters long');
        return;
    }
    
    if ($password !== $confirm_password) {
        wp_send_json_error('Passwords do not match');
        return;
    }
    
    if (!$terms) {
        wp_send_json_error('Please agree to the Terms & Conditions');
        return;
    }
    
    // Create user
    $user_data = array(
        'user_login' => $email,
        'user_email' => $email,
        'user_pass' => $password,
        'first_name' => $firstname,
        'last_name' => $lastname,
        'display_name' => $firstname . ' ' . $lastname,
        'role' => 'customer'
    );
    
    $user_id = wp_insert_user($user_data);
    
    if (is_wp_error($user_id)) {
        wp_send_json_error('Registration failed. Please try again.');
        return;
    }
    
    // Add custom fields
    update_user_meta($user_id, 'phone', $phone);
    update_user_meta($user_id, 'newsletter_subscription', $newsletter);
    
    // Auto login
    wp_set_current_user($user_id);
    wp_set_auth_cookie($user_id);
    
    // Send welcome email
    $to = $email;
    $subject = 'Welcome to Pet Paradise!';
    $message = "Hi $firstname,\n\nWelcome to Pet Paradise! Your account has been created successfully.\n\nYou can now:\n- Browse our pet products\n- Save items to your wishlist\n- Track your orders\n- Get exclusive offers\n\nThank you for choosing Pet Paradise!\n\nBest regards,\nThe Pet Paradise Team";
    $headers = array('Content-Type: text/plain; charset=UTF-8');
    
    wp_mail($to, $subject, $message, $headers);
    
    wp_send_json_success(array(
        'message' => 'Account created successfully! Welcome to Pet Paradise!',
        'redirect' => home_url('/my-account/')
    ));
}
add_action('wp_ajax_nopriv_pet_shop_register', 'pet_shop_ajax_register');

/**
 * AJAX Forgot Password Handler
 */
function pet_shop_ajax_forgot_password() {
    check_ajax_referer('pet_shop_nonce', 'nonce');
    
    $email = sanitize_email($_POST['email']);
    
    if (empty($email)) {
        wp_send_json_error('Please enter your email address');
        return;
    }
    
    $user = get_user_by('email', $email);
    
    if (!$user) {
        wp_send_json_error('No account found with this email address');
        return;
    }
    
    // Generate reset key
    $key = get_password_reset_key($user);
    
    if (is_wp_error($key)) {
        wp_send_json_error('Unable to generate reset key. Please try again.');
        return;
    }
    
    // Send reset email
    $reset_link = add_query_arg(array(
        'action' => 'rp',
        'key' => $key,
        'login' => rawurlencode($user->user_login)
    ), wp_login_url());
    
    $to = $email;
    $subject = 'Reset Your Pet Paradise Password';
    $message = "Hi,\n\nYou have requested to reset your password for your Pet Paradise account.\n\nTo reset your password, click the following link:\n\n$reset_link\n\nIf you didn't request this, please ignore this email.\n\nThis link will expire in 24 hours.\n\nBest regards,\nThe Pet Paradise Team";
    $headers = array('Content-Type: text/plain; charset=UTF-8');
    
    $sent = wp_mail($to, $subject, $message, $headers);
    
    if ($sent) {
        wp_send_json_success('Password reset instructions have been sent to your email');
    } else {
        wp_send_json_error('Unable to send reset email. Please try again.');
    }
}
add_action('wp_ajax_nopriv_pet_shop_forgot_password', 'pet_shop_ajax_forgot_password');

/**
 * Custom User Profile Fields
 */
function pet_shop_add_custom_user_fields($user) {
    ?>
    <h3>Pet Paradise Information</h3>
    <table class="form-table">
        <tr>
            <th><label for="phone">Phone Number</label></th>
            <td>
                <input type="tel" name="phone" id="phone" value="<?php echo esc_attr(get_user_meta($user->ID, 'phone', true)); ?>" class="regular-text" />
            </td>
        </tr>
        <tr>
            <th><label for="newsletter">Newsletter Subscription</label></th>
            <td>
                <input type="checkbox" name="newsletter" id="newsletter" value="1" <?php checked(get_user_meta($user->ID, 'newsletter_subscription', true), '1'); ?> />
                <span class="description">Receive pet care tips and exclusive offers</span>
            </td>
        </tr>
        <tr>
            <th><label for="pet_count">Number of Pets</label></th>
            <td>
                <select name="pet_count" id="pet_count">
                    <option value="">Select...</option>
                    <option value="1" <?php selected(get_user_meta($user->ID, 'pet_count', true), '1'); ?>>1 Pet</option>
                    <option value="2" <?php selected(get_user_meta($user->ID, 'pet_count', true), '2'); ?>>2 Pets</option>
                    <option value="3" <?php selected(get_user_meta($user->ID, 'pet_count', true), '3'); ?>>3 Pets</option>
                    <option value="4+" <?php selected(get_user_meta($user->ID, 'pet_count', true), '4+'); ?>>4+ Pets</option>
                </select>
            </td>
        </tr>
        <tr>
            <th><label for="pet_types">Pet Types</label></th>
            <td>
                <?php
                $pet_types = array('Dog', 'Cat', 'Bird', 'Fish', 'Rabbit', 'Hamster', 'Other');
                $user_pet_types = get_user_meta($user->ID, 'pet_types', true);
                if (!is_array($user_pet_types)) $user_pet_types = array();
                
                foreach ($pet_types as $type) {
                    $checked = in_array($type, $user_pet_types) ? 'checked' : '';
                    echo "<label><input type='checkbox' name='pet_types[]' value='$type' $checked /> $type</label><br>";
                }
                ?>
            </td>
        </tr>
    </table>
    <?php
}
add_action('show_user_profile', 'pet_shop_add_custom_user_fields');
add_action('edit_user_profile', 'pet_shop_add_custom_user_fields');

/**
 * Save Custom User Fields
 */
function pet_shop_save_custom_user_fields($user_id) {
    if (!current_user_can('edit_user', $user_id)) {
        return false;
    }
    
    update_user_meta($user_id, 'phone', sanitize_text_field($_POST['phone']));
    update_user_meta($user_id, 'newsletter_subscription', isset($_POST['newsletter']) ? '1' : '0');
    update_user_meta($user_id, 'pet_count', sanitize_text_field($_POST['pet_count']));
    
    if (isset($_POST['pet_types']) && is_array($_POST['pet_types'])) {
        update_user_meta($user_id, 'pet_types', array_map('sanitize_text_field', $_POST['pet_types']));
    }
}
add_action('personal_options_update', 'pet_shop_save_custom_user_fields');
add_action('edit_user_profile_update', 'pet_shop_save_custom_user_fields'); 