# Development Scripts Guide

This guide covers the two main development scripts created for the WordPress pet food shop project:

1. **Demo Data Upload Script** - Uploads sample products and data to WooCommerce
2. **Auto-Sync Script** - Automatically syncs wp-content changes when developing in VSCode

## 🐾 Demo Data Upload Script

Uploads sample WooCommerce products, categories, and pages to your WordPress installation.

### Features
- Creates 7 product categories (Dog Food, Cat Food, Bird Food, etc.)
- Adds 10 demo products with Thai and English descriptions
- Configures WooCommerce settings for Thai market (THB currency, etc.)
- Creates sample About Us and Contact pages
- Works with both Windows and Linux

### Usage

#### Linux/macOS
```bash
# Make sure WordPress is running first
./scripts/quick-start.sh

# Run the demo data upload
./scripts/upload-demo-data.sh
```

#### Windows (Batch)
```cmd
REM Make sure WordPress is running first
scripts\quick-start.bat

REM Run the demo data upload
scripts\upload-demo-data.bat
```

#### Windows (PowerShell)
```powershell
# Make sure WordPress is running first
.\scripts\quick-start.ps1

# Run the demo data upload
.\scripts\upload-demo-data.ps1
```

### What gets created:

#### Product Categories
- Dog Food (อาหารสุนัข)
- Cat Food (อาหารแมว)
- Bird Food (อาหารนก)
- Fish Food (อาหารปลา)
- Small Pet Food (อาหารสัตว์เล็ก)
- Pet Treats (ขนมสัตว์เลี้ยง)
- Pet Supplements (วิตามินสัตว์เลี้ยง)

#### Sample Products
- Royal Canin Adult Dog Food (฿1,250)
- Whiskas Cat Food Tuna (฿285)
- Hill's Science Diet Puppy (฿1,890)
- Purina Pro Plan Cat Indoor (฿950)
- Tropical Fish Flakes (฿125)
- And 5 more products...

#### WooCommerce Configuration
- Currency: Thai Baht (THB)
- Country: Thailand
- Guest checkout enabled
- Tax calculation enabled

---

## 🔄 Auto-Sync Script

Monitors your development workspace and automatically syncs changes to the WordPress wp-content directory.

### Features
- Real-time file monitoring using inotify (Linux) or FileSystemWatcher (Windows)
- Syncs to both local wp-content and Docker container
- Supports themes and plugins development
- Creates organized development workspace
- Cross-platform compatibility

### Development Structure
```
dev-workspace/
├── themes/
│   └── custom/          # Custom themes go here
│       └── my-theme/
│           ├── style.css
│           ├── index.php
│           ├── functions.php
│           └── ...
└── plugins/
    └── custom/          # Custom plugins go here
        └── my-plugin/
            ├── my-plugin.php
            ├── includes/
            ├── assets/
            └── ...
```

### Usage

#### Linux/macOS
```bash
# Start auto-sync (creates workspace and starts monitoring)
./scripts/auto-sync-wp-content.sh

# Options:
./scripts/auto-sync-wp-content.sh --help          # Show help
./scripts/auto-sync-wp-content.sh --setup-only    # Only create workspace
./scripts/auto-sync-wp-content.sh --sync-only     # One-time sync without monitoring
```

#### Windows (Batch)
```cmd
REM Start auto-sync
scripts\auto-sync-wp-content.bat

REM Note: The batch version uses polling every 2 seconds
REM For better performance, use the PowerShell version
```

#### Windows (PowerShell) - Recommended
```powershell
# Start auto-sync (best Windows experience)
.\scripts\auto-sync-wp-content.ps1

# Options:
.\scripts\auto-sync-wp-content.ps1 -Help          # Show help
.\scripts\auto-sync-wp-content.ps1 -SetupOnly     # Only create workspace
.\scripts\auto-sync-wp-content.ps1 -SyncOnly      # One-time sync without monitoring
```

### How it works

1. **Setup Phase**
   - Creates `dev-workspace` directory structure
   - Generates README files with instructions
   - Sets up monitoring

2. **Initial Sync**
   - Copies any existing files from dev-workspace to wp-content
   - Syncs to both local directory and Docker container

3. **Real-time Monitoring**
   - Linux: Uses `inotifywait` for efficient file watching
   - Windows: Uses `FileSystemWatcher` for real-time events
   - Automatically syncs changes when you save files in VSCode

4. **File Operations**
   - **CREATE/MODIFY**: Copies file to wp-content and container
   - **DELETE**: Removes file from wp-content and container
   - **RENAME**: Handles as create operation

### Development Workflow

1. **Start Auto-Sync**
   ```bash
   # Linux/macOS
   ./scripts/auto-sync-wp-content.sh
   
   # Windows PowerShell
   .\scripts\auto-sync-wp-content.ps1
   ```

2. **Create Your Theme/Plugin**
   ```bash
   # Create a custom theme
   mkdir -p dev-workspace/themes/custom/my-pet-theme
   
   # Create basic theme files
   echo "<?php // My Pet Theme" > dev-workspace/themes/custom/my-pet-theme/index.php
   echo "/* Theme Name: My Pet Theme */" > dev-workspace/themes/custom/my-pet-theme/style.css
   ```

3. **Edit in VSCode**
   - Open the `dev-workspace` folder in VSCode
   - Edit your theme/plugin files
   - Files are automatically synced when you save (Ctrl+S)

4. **See Changes Live**
   - Visit http://localhost:8080/wp-admin
   - Go to Appearance > Themes to activate your theme
   - Or Plugins to activate your plugin
   - Changes appear immediately!

### Where Files Are Synced

When you edit a file in `dev-workspace`, it gets copied to:

1. **Local wp-content**: `pet-food-shop-template/wp-content/`
2. **Docker container**: Inside the WordPress container at `/var/www/html/wp-content/`

This ensures your changes are immediately available in the running WordPress site.

---

## 🛠️ Requirements

### Linux/macOS
- Docker and Docker Compose
- `inotify-tools` (auto-installed by script)
- `curl` (usually pre-installed)

### Windows
- Docker Desktop
- PowerShell 5.0+ (recommended for best experience)
- Windows 10/11

---

## 🚀 Quick Start Workflow

Here's a complete workflow from start to finish:

### 1. Start WordPress
```bash
# Linux/macOS
./scripts/quick-start.sh

# Windows
scripts\quick-start.bat
```

### 2. Upload Demo Data
```bash
# Linux/macOS
./scripts/upload-demo-data.sh

# Windows PowerShell
.\scripts\upload-demo-data.ps1
```

### 3. Start Development Mode
```bash
# Linux/macOS
./scripts/auto-sync-wp-content.sh

# Windows PowerShell
.\scripts\auto-sync-wp-content.ps1
```

### 4. Create Your Custom Theme
```bash
# Create theme directory
mkdir -p dev-workspace/themes/custom/my-shop-theme

# Create basic theme files (will auto-sync)
cat > dev-workspace/themes/custom/my-shop-theme/style.css << 'EOF'
/*
Theme Name: My Pet Shop Theme
Description: Custom theme for pet food shop
Version: 1.0
*/

body {
    font-family: 'Arial', sans-serif;
    background-color: #f8f9fa;
}

.header {
    background-color: #4CAF50;
    color: white;
    padding: 20px;
    text-align: center;
}
EOF

cat > dev-workspace/themes/custom/my-shop-theme/index.php << 'EOF'
<?php
/**
 * My Pet Shop Theme
 */
get_header(); ?>

<div class="header">
    <h1>🐾 Pet Food Shop</h1>
    <p>Quality Food for Your Beloved Pets</p>
</div>

<div class="container">
    <div class="products">
        <h2>Featured Products</h2>
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
            <div class="product">
                <h3><?php the_title(); ?></h3>
                <div class="content"><?php the_content(); ?></div>
            </div>
        <?php endwhile; endif; ?>
    </div>
</div>

<?php get_footer(); ?>
EOF
```

### 5. Activate Your Theme
1. Go to http://localhost:8080/wp-admin
2. Login with `admin` / `admin`
3. Go to Appearance > Themes
4. Activate "My Pet Shop Theme"

### 6. Continue Development
- Edit files in VSCode in the `dev-workspace` folder
- Save files with Ctrl+S
- See changes immediately in your browser!

---

## 🔧 Troubleshooting

### Auto-sync not working on Linux
```bash
# Install inotify-tools manually
sudo apt-get install inotify-tools  # Ubuntu/Debian
sudo yum install inotify-tools      # CentOS/RHEL
```

### Windows PowerShell execution policy
```powershell
# If you get execution policy error:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Docker container not found
```bash
# Make sure WordPress is running
docker ps | grep wordpress

# If not running, start it:
./scripts/quick-start.sh
```

### Files not syncing to container
```bash
# Check if container is running
docker ps --format "table {{.Names}}" | grep wordpress

# Manually copy files to test
docker cp dev-workspace/themes/custom/my-theme pet-food-store-wordpress:/var/www/html/wp-content/themes/
```

---

## 📝 Tips and Best Practices

1. **Use PowerShell on Windows** for the best experience with real-time file watching
2. **Keep auto-sync running** while developing for immediate feedback
3. **Use descriptive theme/plugin names** to avoid conflicts
4. **Test in different browsers** to ensure compatibility
5. **Backup your work** by committing dev-workspace to git
6. **Stop auto-sync with Ctrl+C** when done developing

---

## 🎯 What's Next?

With these scripts, you now have:
- ✅ A fully populated demo store with products
- ✅ Real-time development workflow
- ✅ Cross-platform compatibility
- ✅ Automatic file synchronization

You can now focus on creating beautiful themes and powerful plugins for your pet food e-commerce store!

Happy coding! 🐾