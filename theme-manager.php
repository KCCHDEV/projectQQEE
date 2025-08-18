<?php
/**
 * Pet Food E-commerce Platform - Theme Manager
 * Advanced theme management system for WordPress
 */

class PetFoodThemeManager {
    
    private $themes_dir;
    private $backup_dir;
    private $config_file;
    
    public function __construct() {
        $this->themes_dir = WP_CONTENT_DIR . '/themes';
        $this->backup_dir = WP_CONTENT_DIR . '/themes-backup';
        $this->config_file = WP_CONTENT_DIR . '/theme-config.json';
        
        // Ensure directories exist
        if (!file_exists($this->backup_dir)) {
            wp_mkdir_p($this->backup_dir);
        }
        
        // Initialize hooks
        add_action('init', array($this, 'init'));
        add_action('wp_ajax_theme_manager_action', array($this, 'handle_ajax'));
        add_action('admin_menu', array($this, 'add_admin_menu'));
        add_action('admin_enqueue_scripts', array($this, 'enqueue_scripts'));
    }
    
    public function init() {
        // Register theme manager capabilities
        if (current_user_can('manage_options')) {
            $this->register_theme_endpoints();
        }
    }
    
    /**
     * Add admin menu for theme management
     */
    public function add_admin_menu() {
        add_theme_page(
            'Theme Manager',
            'Theme Manager',
            'manage_options',
            'pet-theme-manager',
            array($this, 'admin_page')
        );
    }
    
    /**
     * Enqueue scripts and styles
     */
    public function enqueue_scripts($hook) {
        if ($hook !== 'appearance_page_pet-theme-manager') {
            return;
        }
        
        wp_enqueue_script('jquery');
        wp_enqueue_script('jquery-ui-sortable');
        wp_enqueue_style('theme-manager-css', $this->get_asset_url('theme-manager.css'));
        wp_enqueue_script('theme-manager-js', $this->get_asset_url('theme-manager.js'), array('jquery'), '1.0.0', true);
        
        wp_localize_script('theme-manager-js', 'themeManager', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('theme_manager_nonce'),
            'messages' => array(
                'confirm_delete' => __('Are you sure you want to delete this theme?', 'pet-theme-manager'),
                'confirm_restore' => __('Are you sure you want to restore this theme backup?', 'pet-theme-manager'),
                'success' => __('Operation completed successfully!', 'pet-theme-manager'),
                'error' => __('An error occurred. Please try again.', 'pet-theme-manager')
            )
        ));
    }
    
    /**
     * Admin page content
     */
    public function admin_page() {
        ?>
        <div class="wrap">
            <h1><?php _e('Pet Food Theme Manager', 'pet-theme-manager'); ?></h1>
            
            <div class="theme-manager-container">
                <!-- Theme Upload Section -->
                <div class="theme-section">
                    <h2><?php _e('Upload New Theme', 'pet-theme-manager'); ?></h2>
                    <form id="theme-upload-form" enctype="multipart/form-data">
                        <input type="file" name="theme_file" accept=".zip" required>
                        <button type="submit" class="button button-primary">
                            <?php _e('Upload Theme', 'pet-theme-manager'); ?>
                        </button>
                    </form>
                </div>
                
                <!-- Active Themes Section -->
                <div class="theme-section">
                    <h2><?php _e('Active Themes', 'pet-theme-manager'); ?></h2>
                    <div id="active-themes">
                        <?php $this->display_active_themes(); ?>
                    </div>
                </div>
                
                <!-- Theme Backups Section -->
                <div class="theme-section">
                    <h2><?php _e('Theme Backups', 'pet-theme-manager'); ?></h2>
                    <div class="backup-actions">
                        <button id="create-backup" class="button">
                            <?php _e('Create Full Backup', 'pet-theme-manager'); ?>
                        </button>
                        <button id="auto-backup-toggle" class="button">
                            <?php _e('Toggle Auto Backup', 'pet-theme-manager'); ?>
                        </button>
                    </div>
                    <div id="theme-backups">
                        <?php $this->display_theme_backups(); ?>
                    </div>
                </div>
                
                <!-- Theme Store Section -->
                <div class="theme-section">
                    <h2><?php _e('Pet Store Theme Gallery', 'pet-theme-manager'); ?></h2>
                    <div id="theme-gallery">
                        <?php $this->display_theme_gallery(); ?>
                    </div>
                </div>
            </div>
        </div>
        
        <style>
        .theme-manager-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 20px;
        }
        
        .theme-section {
            background: #fff;
            border: 1px solid #ccd0d4;
            border-radius: 4px;
            padding: 20px;
        }
        
        .theme-section h2 {
            margin-top: 0;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        
        .theme-card {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 15px;
            margin-bottom: 15px;
            background: #f9f9f9;
        }
        
        .theme-card.active {
            border-color: #0073aa;
            background: #e7f3ff;
        }
        
        .theme-actions {
            margin-top: 10px;
        }
        
        .theme-actions button {
            margin-right: 5px;
        }
        
        .backup-actions {
            margin-bottom: 15px;
        }
        
        .theme-preview {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        
        .theme-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .theme-name {
            font-weight: bold;
            font-size: 16px;
        }
        
        .theme-version {
            color: #666;
            font-size: 12px;
        }
        
        .loading {
            opacity: 0.6;
            pointer-events: none;
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        </style>
        <?php
    }
    
    /**
     * Display active themes
     */
    private function display_active_themes() {
        $themes = wp_get_themes();
        $current_theme = get_stylesheet();
        
        foreach ($themes as $theme_slug => $theme) {
            $is_active = ($theme_slug === $current_theme);
            ?>
            <div class="theme-card <?php echo $is_active ? 'active' : ''; ?>" data-theme="<?php echo esc_attr($theme_slug); ?>">
                <?php if ($theme->get_screenshot()): ?>
                    <img src="<?php echo esc_url($theme->get_screenshot()); ?>" class="theme-preview" alt="<?php echo esc_attr($theme->get('Name')); ?>">
                <?php endif; ?>
                
                <div class="theme-info">
                    <div>
                        <div class="theme-name"><?php echo esc_html($theme->get('Name')); ?></div>
                        <div class="theme-version">Version: <?php echo esc_html($theme->get('Version')); ?></div>
                        <?php if ($is_active): ?>
                            <div class="theme-status" style="color: #0073aa; font-weight: bold;">Active</div>
                        <?php endif; ?>
                    </div>
                </div>
                
                <div class="theme-description">
                    <?php echo esc_html($theme->get('Description')); ?>
                </div>
                
                <div class="theme-actions">
                    <?php if (!$is_active): ?>
                        <button class="button button-primary activate-theme" data-theme="<?php echo esc_attr($theme_slug); ?>">
                            <?php _e('Activate', 'pet-theme-manager'); ?>
                        </button>
                    <?php endif; ?>
                    
                    <button class="button backup-theme" data-theme="<?php echo esc_attr($theme_slug); ?>">
                        <?php _e('Backup', 'pet-theme-manager'); ?>
                    </button>
                    
                    <button class="button customize-theme" data-theme="<?php echo esc_attr($theme_slug); ?>">
                        <?php _e('Customize', 'pet-theme-manager'); ?>
                    </button>
                    
                    <?php if (!$is_active && $theme_slug !== 'twentytwentythree'): ?>
                        <button class="button button-link-delete delete-theme" data-theme="<?php echo esc_attr($theme_slug); ?>">
                            <?php _e('Delete', 'pet-theme-manager'); ?>
                        </button>
                    <?php endif; ?>
                </div>
            </div>
            <?php
        }
    }
    
    /**
     * Display theme backups
     */
    private function display_theme_backups() {
        $backups = $this->get_theme_backups();
        
        if (empty($backups)) {
            echo '<p>' . __('No theme backups found.', 'pet-theme-manager') . '</p>';
            return;
        }
        
        foreach ($backups as $backup) {
            ?>
            <div class="theme-card backup-card" data-backup="<?php echo esc_attr($backup['file']); ?>">
                <div class="theme-info">
                    <div>
                        <div class="theme-name"><?php echo esc_html($backup['name']); ?></div>
                        <div class="theme-version">
                            Created: <?php echo esc_html(date('Y-m-d H:i:s', $backup['date'])); ?>
                        </div>
                        <div class="theme-version">
                            Size: <?php echo esc_html($this->format_file_size($backup['size'])); ?>
                        </div>
                    </div>
                </div>
                
                <div class="theme-actions">
                    <button class="button button-primary restore-backup" data-backup="<?php echo esc_attr($backup['file']); ?>">
                        <?php _e('Restore', 'pet-theme-manager'); ?>
                    </button>
                    
                    <button class="button download-backup" data-backup="<?php echo esc_attr($backup['file']); ?>">
                        <?php _e('Download', 'pet-theme-manager'); ?>
                    </button>
                    
                    <button class="button button-link-delete delete-backup" data-backup="<?php echo esc_attr($backup['file']); ?>">
                        <?php _e('Delete', 'pet-theme-manager'); ?>
                    </button>
                </div>
            </div>
            <?php
        }
    }
    
    /**
     * Display theme gallery
     */
    private function display_theme_gallery() {
        $gallery_themes = $this->get_pet_store_themes();
        
        foreach ($gallery_themes as $theme) {
            ?>
            <div class="theme-card gallery-card" data-theme-url="<?php echo esc_attr($theme['download_url']); ?>">
                <img src="<?php echo esc_url($theme['preview']); ?>" class="theme-preview" alt="<?php echo esc_attr($theme['name']); ?>">
                
                <div class="theme-info">
                    <div>
                        <div class="theme-name"><?php echo esc_html($theme['name']); ?></div>
                        <div class="theme-version">By: <?php echo esc_html($theme['author']); ?></div>
                        <div class="theme-version">Rating: <?php echo str_repeat('⭐', $theme['rating']); ?></div>
                    </div>
                </div>
                
                <div class="theme-description">
                    <?php echo esc_html($theme['description']); ?>
                </div>
                
                <div class="theme-actions">
                    <button class="button button-primary install-gallery-theme" data-theme-url="<?php echo esc_attr($theme['download_url']); ?>">
                        <?php _e('Install', 'pet-theme-manager'); ?>
                    </button>
                    
                    <button class="button preview-gallery-theme" data-preview="<?php echo esc_attr($theme['demo_url']); ?>">
                        <?php _e('Preview', 'pet-theme-manager'); ?>
                    </button>
                </div>
            </div>
            <?php
        }
    }
    
    /**
     * Handle AJAX requests
     */
    public function handle_ajax() {
        if (!wp_verify_nonce($_POST['nonce'], 'theme_manager_nonce')) {
            wp_die('Security check failed');
        }
        
        $action = sanitize_text_field($_POST['theme_action']);
        
        switch ($action) {
            case 'activate_theme':
                $this->activate_theme($_POST['theme']);
                break;
            case 'backup_theme':
                $this->backup_theme($_POST['theme']);
                break;
            case 'delete_theme':
                $this->delete_theme($_POST['theme']);
                break;
            case 'restore_backup':
                $this->restore_backup($_POST['backup']);
                break;
            case 'delete_backup':
                $this->delete_backup($_POST['backup']);
                break;
            case 'upload_theme':
                $this->upload_theme();
                break;
            case 'install_gallery_theme':
                $this->install_gallery_theme($_POST['theme_url']);
                break;
            default:
                wp_send_json_error('Invalid action');
        }
    }
    
    /**
     * Get pet store themes from gallery
     */
    private function get_pet_store_themes() {
        return array(
            array(
                'name' => 'Pet Paws Pro',
                'author' => 'Pet Theme Studio',
                'description' => 'Professional pet store theme with advanced features',
                'preview' => 'https://via.placeholder.com/400x300/4CAF50/white?text=Pet+Paws+Pro',
                'demo_url' => '#',
                'download_url' => 'https://example.com/pet-paws-pro.zip',
                'rating' => 5
            ),
            array(
                'name' => 'Animal Care',
                'author' => 'WP Pet Themes',
                'description' => 'Modern and clean theme for pet care services',
                'preview' => 'https://via.placeholder.com/400x300/2196F3/white?text=Animal+Care',
                'demo_url' => '#',
                'download_url' => 'https://example.com/animal-care.zip',
                'rating' => 4
            ),
            array(
                'name' => 'Pet Shop Express',
                'author' => 'E-commerce Themes',
                'description' => 'Fast and responsive theme for pet shops',
                'preview' => 'https://via.placeholder.com/400x300/FF9800/white?text=Pet+Shop+Express',
                'demo_url' => '#',
                'download_url' => 'https://example.com/pet-shop-express.zip',
                'rating' => 4
            )
        );
    }
    
    /**
     * Get theme backups
     */
    private function get_theme_backups() {
        $backups = array();
        $backup_files = glob($this->backup_dir . '/*.zip');
        
        foreach ($backup_files as $file) {
            $backups[] = array(
                'file' => basename($file),
                'name' => pathinfo($file, PATHINFO_FILENAME),
                'date' => filemtime($file),
                'size' => filesize($file)
            );
        }
        
        // Sort by date (newest first)
        usort($backups, function($a, $b) {
            return $b['date'] - $a['date'];
        });
        
        return $backups;
    }
    
    /**
     * Format file size
     */
    private function format_file_size($size) {
        $units = array('B', 'KB', 'MB', 'GB');
        $unit_index = 0;
        
        while ($size >= 1024 && $unit_index < count($units) - 1) {
            $size /= 1024;
            $unit_index++;
        }
        
        return round($size, 2) . ' ' . $units[$unit_index];
    }
    
    /**
     * Get asset URL
     */
    private function get_asset_url($file) {
        return plugins_url('assets/' . $file, __FILE__);
    }
    
    /**
     * Activate theme
     */
    private function activate_theme($theme_slug) {
        $theme = wp_get_theme($theme_slug);
        if ($theme->exists()) {
            switch_theme($theme_slug);
            wp_send_json_success('Theme activated successfully');
        } else {
            wp_send_json_error('Theme not found');
        }
    }
    
    /**
     * Backup theme
     */
    private function backup_theme($theme_slug) {
        $theme_dir = $this->themes_dir . '/' . $theme_slug;
        
        if (!is_dir($theme_dir)) {
            wp_send_json_error('Theme directory not found');
        }
        
        $backup_file = $this->backup_dir . '/' . $theme_slug . '_' . date('Y-m-d_H-i-s') . '.zip';
        
        $zip = new ZipArchive();
        if ($zip->open($backup_file, ZipArchive::CREATE) !== TRUE) {
            wp_send_json_error('Could not create backup file');
        }
        
        $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($theme_dir));
        
        foreach ($iterator as $file) {
            if ($file->isFile()) {
                $relative_path = str_replace($theme_dir . '/', '', $file->getPathname());
                $zip->addFile($file->getPathname(), $relative_path);
            }
        }
        
        $zip->close();
        
        wp_send_json_success('Theme backup created successfully');
    }
    
    /**
     * Register theme endpoints for REST API
     */
    private function register_theme_endpoints() {
        // Add custom REST API endpoints if needed
    }
}

// Initialize the theme manager
new PetFoodThemeManager();