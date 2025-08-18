/**
 * Pet Food E-commerce Platform - Theme Manager JavaScript
 * Advanced theme management interface
 */

(function($) {
    'use strict';
    
    var ThemeManager = {
        
        init: function() {
            this.bindEvents();
            this.initSortable();
        },
        
        bindEvents: function() {
            // Theme activation
            $(document).on('click', '.activate-theme', this.activateTheme);
            
            // Theme backup
            $(document).on('click', '.backup-theme', this.backupTheme);
            
            // Theme deletion
            $(document).on('click', '.delete-theme', this.deleteTheme);
            
            // Backup restoration
            $(document).on('click', '.restore-backup', this.restoreBackup);
            
            // Backup deletion
            $(document).on('click', '.delete-backup', this.deleteBackup);
            
            // Theme upload
            $('#theme-upload-form').on('submit', this.uploadTheme);
            
            // Gallery theme installation
            $(document).on('click', '.install-gallery-theme', this.installGalleryTheme);
            
            // Preview gallery theme
            $(document).on('click', '.preview-gallery-theme', this.previewGalleryTheme);
            
            // Create backup
            $('#create-backup').on('click', this.createFullBackup);
            
            // Toggle auto backup
            $('#auto-backup-toggle').on('click', this.toggleAutoBackup);
            
            // Customize theme
            $(document).on('click', '.customize-theme', this.customizeTheme);
            
            // Download backup
            $(document).on('click', '.download-backup', this.downloadBackup);
        },
        
        initSortable: function() {
            $('#active-themes').sortable({
                items: '.theme-card',
                handle: '.theme-card',
                placeholder: 'theme-placeholder',
                update: function(event, ui) {
                    ThemeManager.updateThemeOrder();
                }
            });
        },
        
        activateTheme: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            var theme = $button.data('theme');
            
            if (!confirm(themeManager.messages.confirm_delete.replace('delete', 'activate'))) {
                return;
            }
            
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'activate_theme',
                theme: theme,
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    ThemeManager.showMessage(themeManager.messages.success, 'success');
                    location.reload();
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        backupTheme: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            var theme = $button.data('theme');
            
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'backup_theme',
                theme: theme,
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    ThemeManager.showMessage('Theme backup created successfully!', 'success');
                    ThemeManager.refreshBackups();
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        deleteTheme: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            var theme = $button.data('theme');
            
            if (!confirm(themeManager.messages.confirm_delete)) {
                return;
            }
            
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'delete_theme',
                theme: theme,
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    ThemeManager.showMessage('Theme deleted successfully!', 'success');
                    $button.closest('.theme-card').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        restoreBackup: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            var backup = $button.data('backup');
            
            if (!confirm(themeManager.messages.confirm_restore)) {
                return;
            }
            
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'restore_backup',
                backup: backup,
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    ThemeManager.showMessage('Backup restored successfully!', 'success');
                    location.reload();
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        deleteBackup: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            var backup = $button.data('backup');
            
            if (!confirm('Are you sure you want to delete this backup?')) {
                return;
            }
            
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'delete_backup',
                backup: backup,
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    ThemeManager.showMessage('Backup deleted successfully!', 'success');
                    $button.closest('.theme-card').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        uploadTheme: function(e) {
            e.preventDefault();
            
            var $form = $(this);
            var formData = new FormData();
            var fileInput = $form.find('input[type="file"]')[0];
            
            if (!fileInput.files.length) {
                ThemeManager.showMessage('Please select a theme file to upload.', 'error');
                return;
            }
            
            formData.append('action', 'theme_manager_action');
            formData.append('theme_action', 'upload_theme');
            formData.append('theme_file', fileInput.files[0]);
            formData.append('nonce', themeManager.nonce);
            
            var $button = $form.find('button[type="submit"]');
            ThemeManager.showLoading($button);
            
            $.ajax({
                url: themeManager.ajax_url,
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    if (response.success) {
                        ThemeManager.showMessage('Theme uploaded successfully!', 'success');
                        location.reload();
                    } else {
                        ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                    }
                },
                error: function() {
                    ThemeManager.showMessage(themeManager.messages.error, 'error');
                },
                complete: function() {
                    ThemeManager.hideLoading($button);
                    $form[0].reset();
                }
            });
        },
        
        installGalleryTheme: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            var themeUrl = $button.data('theme-url');
            
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'install_gallery_theme',
                theme_url: themeUrl,
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    ThemeManager.showMessage('Theme installed successfully!', 'success');
                    location.reload();
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        previewGalleryTheme: function(e) {
            e.preventDefault();
            
            var previewUrl = $(this).data('preview');
            window.open(previewUrl, '_blank');
        },
        
        createFullBackup: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'create_full_backup',
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    ThemeManager.showMessage('Full backup created successfully!', 'success');
                    ThemeManager.refreshBackups();
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        toggleAutoBackup: function(e) {
            e.preventDefault();
            
            var $button = $(this);
            ThemeManager.showLoading($button);
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'toggle_auto_backup',
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    var status = response.data.enabled ? 'enabled' : 'disabled';
                    ThemeManager.showMessage('Auto backup ' + status + ' successfully!', 'success');
                    $button.text(response.data.enabled ? 'Disable Auto Backup' : 'Enable Auto Backup');
                } else {
                    ThemeManager.showMessage(response.data || themeManager.messages.error, 'error');
                }
            }).always(function() {
                ThemeManager.hideLoading($button);
            });
        },
        
        customizeTheme: function(e) {
            e.preventDefault();
            
            var theme = $(this).data('theme');
            var customizeUrl = wp.customize ? wp.customize.settings.url.self : '/wp-admin/customize.php';
            
            if (theme) {
                customizeUrl += '?theme=' + theme;
            }
            
            window.open(customizeUrl, '_blank');
        },
        
        downloadBackup: function(e) {
            e.preventDefault();
            
            var backup = $(this).data('backup');
            var downloadUrl = themeManager.ajax_url + '?action=download_theme_backup&backup=' + backup + '&nonce=' + themeManager.nonce;
            
            window.open(downloadUrl, '_blank');
        },
        
        updateThemeOrder: function() {
            var order = [];
            $('#active-themes .theme-card').each(function() {
                order.push($(this).data('theme'));
            });
            
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'update_theme_order',
                order: order,
                nonce: themeManager.nonce
            });
        },
        
        refreshBackups: function() {
            $.post(themeManager.ajax_url, {
                action: 'theme_manager_action',
                theme_action: 'get_backups',
                nonce: themeManager.nonce
            }, function(response) {
                if (response.success) {
                    $('#theme-backups').html(response.data);
                }
            });
        },
        
        showLoading: function($element) {
            $element.prop('disabled', true);
            $element.addClass('loading');
            
            if (!$element.data('original-text')) {
                $element.data('original-text', $element.text());
            }
            
            $element.text('Loading...');
        },
        
        hideLoading: function($element) {
            $element.prop('disabled', false);
            $element.removeClass('loading');
            
            if ($element.data('original-text')) {
                $element.text($element.data('original-text'));
            }
        },
        
        showMessage: function(message, type) {
            var $message = $('<div class="' + type + '-message">' + message + '</div>');
            
            $('.theme-manager-container').prepend($message);
            
            setTimeout(function() {
                $message.fadeOut(300, function() {
                    $(this).remove();
                });
            }, 5000);
        }
    };
    
    // Initialize when document is ready
    $(document).ready(function() {
        ThemeManager.init();
    });
    
    // Export for global access
    window.PetFoodThemeManager = ThemeManager;
    
})(jQuery);