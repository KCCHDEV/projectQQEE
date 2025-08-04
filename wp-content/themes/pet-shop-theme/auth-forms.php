<?php
/**
 * Pet Shop Pro - Authentication Forms
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

function pet_shop_auth_forms() {
    if (!is_user_logged_in()) {
        ?>
        <div class="auth-modals">
            <!-- Login Modal -->
            <div id="login-modal" class="auth-modal">
                <div class="auth-content">
                    <button class="auth-close">&times;</button>
                    <div class="auth-header">
                        <h2>🐕 Welcome Back!</h2>
                        <p>Sign in to your Pet Paradise account</p>
                    </div>
                    
                    <form id="login-form" class="auth-form">
                        <div class="form-group">
                            <label for="login-email">Email Address</label>
                            <input type="email" id="login-email" name="email" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="login-password">Password</label>
                            <input type="password" id="login-password" name="password" required>
                        </div>
                        
                        <div class="form-options">
                            <label class="checkbox-label">
                                <input type="checkbox" name="remember">
                                <span>Remember me</span>
                            </label>
                            <a href="#" class="forgot-password">Forgot password?</a>
                        </div>
                        
                        <button type="submit" class="auth-submit">Sign In</button>
                    </form>
                    
                    <div class="social-login">
                        <p>Or sign in with</p>
                        <div class="social-buttons">
                            <button class="social-btn google-btn">Google</button>
                            <button class="social-btn facebook-btn">Facebook</button>
                        </div>
                    </div>
                    
                    <div class="auth-footer">
                        <p>Don't have an account? <a href="#" class="switch-to-register">Sign up</a></p>
                    </div>
                </div>
            </div>
            
            <!-- Register Modal -->
            <div id="register-modal" class="auth-modal">
                <div class="auth-content">
                    <button class="auth-close">&times;</button>
                    <div class="auth-header">
                        <h2>🐕 Join Pet Paradise!</h2>
                        <p>Create your account and start shopping</p>
                    </div>
                    
                    <form id="register-form" class="auth-form">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="register-firstname">First Name</label>
                                <input type="text" id="register-firstname" name="firstname" required>
                            </div>
                            <div class="form-group">
                                <label for="register-lastname">Last Name</label>
                                <input type="text" id="register-lastname" name="lastname" required>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-email">Email Address</label>
                            <input type="email" id="register-email" name="email" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-phone">Phone Number</label>
                            <input type="tel" id="register-phone" name="phone" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-password">Password</label>
                            <input type="password" id="register-password" name="password" required>
                            <div class="password-strength">
                                <div class="strength-bar"></div>
                                <span class="strength-text">Password strength</span>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="register-confirm-password">Confirm Password</label>
                            <input type="password" id="register-confirm-password" name="confirm_password" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="checkbox-label">
                                <input type="checkbox" name="terms" required>
                                <span>I agree to the <a href="#">Terms & Conditions</a> and <a href="#">Privacy Policy</a></span>
                            </label>
                        </div>
                        
                        <div class="form-group">
                            <label class="checkbox-label">
                                <input type="checkbox" name="newsletter">
                                <span>Subscribe to our newsletter for pet care tips and exclusive offers</span>
                            </label>
                        </div>
                        
                        <button type="submit" class="auth-submit">Create Account</button>
                    </form>
                    
                    <div class="social-login">
                        <p>Or sign up with</p>
                        <div class="social-buttons">
                            <button class="social-btn google-btn">Google</button>
                            <button class="social-btn facebook-btn">Facebook</button>
                        </div>
                    </div>
                    
                    <div class="auth-footer">
                        <p>Already have an account? <a href="#" class="switch-to-login">Sign in</a></p>
                    </div>
                </div>
            </div>
            
            <!-- Forgot Password Modal -->
            <div id="forgot-modal" class="auth-modal">
                <div class="auth-content">
                    <button class="auth-close">&times;</button>
                    <div class="auth-header">
                        <h2>🔑 Reset Password</h2>
                        <p>Enter your email to receive reset instructions</p>
                    </div>
                    
                    <form id="forgot-form" class="auth-form">
                        <div class="form-group">
                            <label for="forgot-email">Email Address</label>
                            <input type="email" id="forgot-email" name="email" required>
                        </div>
                        
                        <button type="submit" class="auth-submit">Send Reset Link</button>
                    </form>
                    
                    <div class="auth-footer">
                        <p>Remember your password? <a href="#" class="switch-to-login">Sign in</a></p>
                    </div>
                </div>
            </div>
        </div>
        <?php
    }
} 