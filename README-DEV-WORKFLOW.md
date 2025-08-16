# Development Workflow - External UI/Script Editing

This guide explains how to develop WordPress themes, plugins, and scripts outside of WordPress and deploy only code changes without uploading WordPress content.

## 🎯 Overview

The new development workflow allows you to:
- ✅ Edit themes and plugins outside WordPress
- ✅ Deploy only code changes via command line
- ✅ Exclude WordPress uploads and content
- ✅ Maintain version control of code only
- ✅ Sync changes to remote servers
- ✅ Watch for file changes and auto-deploy

## 🚀 Quick Start

### 1. Initialize Development Workspace

```bash
# Create development environment
./scripts/dev-workflow.sh init

# Check status
./scripts/dev-workflow.sh status
```

This creates a `dev-workspace/` directory with:
- `themes/` - Custom themes for external editing
- `plugins/` - Custom plugins for external editing  
- `assets/` - Static assets (CSS, JS, images)
- `scripts/` - Deployment and utility scripts

### 2. External Development

Edit files in the development workspace:
```
dev-workspace/
├── themes/
│   └── custom/
│       └── my-theme/
│           ├── style.css
│           ├── index.php
│           ├── functions.php
│           └── assets/
│               ├── css/
│               ├── js/
│               └── images/
├── plugins/
│   └── my-custom-plugin/
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
└── scripts/
```

### 3. Deploy Changes

```bash
# Deploy themes only
./scripts/dev-workflow.sh deploy themes

# Deploy all changes
./scripts/dev-workflow.sh deploy all

# Watch for changes and auto-deploy
./scripts/dev-workflow.sh watch
```

## 📋 Available Commands

### Development Workflow Commands

```bash
# Initialize development workspace
./scripts/dev-workflow.sh init

# Sync files to wp-content (local)
./scripts/dev-workflow.sh sync [themes|plugins|assets|all]

# Deploy to WordPress container
./scripts/dev-workflow.sh deploy [themes|plugins|assets|all]

# Watch for changes and auto-deploy
./scripts/dev-workflow.sh watch

# Extract existing theme for editing
./scripts/dev-workflow.sh extract-theme <theme-name>

# Build assets (if build tools available)
./scripts/dev-workflow.sh build

# Show development status
./scripts/dev-workflow.sh status
```

### Deployment Commands (No Uploads)

```bash
# Create code-only deployment package
./scripts/deploy-no-uploads.sh package

# Apply deployment package
./scripts/deploy-no-uploads.sh apply [package-file]

# Sync code to remote server
./scripts/deploy-no-uploads.sh sync-remote user@host [remote-path]

# Show deployment status
./scripts/deploy-no-uploads.sh status
```

## 🔄 Development Workflow

### Local Development

1. **Initialize workspace** (one time):
   ```bash
   ./scripts/dev-workflow.sh init
   ```

2. **Extract existing theme** (if needed):
   ```bash
   ./scripts/dev-workflow.sh extract-theme twentytwentyfour
   ```

3. **Edit files externally** in your favorite editor:
   - Use VS Code, PHPStorm, or any editor
   - Edit files in `dev-workspace/themes/`
   - Make changes to CSS, JS, PHP files

4. **Deploy changes**:
   ```bash
   # Deploy specific type
   ./scripts/dev-workflow.sh deploy themes
   
   # Or deploy everything
   ./scripts/dev-workflow.sh deploy all
   ```

5. **Auto-watch mode** (optional):
   ```bash
   ./scripts/dev-workflow.sh watch
   ```

### Remote Deployment

1. **Create deployment package**:
   ```bash
   ./scripts/deploy-no-uploads.sh package
   ```

2. **Transfer to remote server**:
   ```bash
   scp code-deploy-*.tar.gz user@remote-server:/path/to/wordpress/
   ```

3. **Apply on remote server**:
   ```bash
   ssh user@remote-server
   cd /path/to/wordpress
   ./scripts/deploy-no-uploads.sh apply
   ```

### Direct Remote Sync

```bash
# Sync code directly to remote server
./scripts/deploy-no-uploads.sh sync-remote user@remote-server /var/www/html
```

## 🚫 What's Excluded from Deployments

### Automatically Excluded:
- ❌ `wp-content/uploads/` (all user uploads)
- ❌ Cache files and logs
- ❌ Database content
- ❌ Temporary files
- ❌ `node_modules/` and `vendor/` directories
- ❌ Compiled build artifacts
- ❌ WordPress auto-generated files

### What's Included:
- ✅ Theme code files (`.php`, `.css`, `.js`, `.json`)
- ✅ Plugin code files
- ✅ Custom scripts
- ✅ Configuration files
- ✅ Development workspace

## 📁 File Structure

```
project/
├── dev-workspace/              # External development files
│   ├── themes/
│   ├── plugins/
│   ├── assets/
│   └── scripts/
├── wp-content/                 # WordPress content (synced from dev-workspace)
│   ├── themes/                 # ✅ Included in deployments
│   ├── plugins/                # ✅ Included in deployments
│   └── uploads/                # ❌ Excluded from deployments
├── scripts/
│   ├── dev-workflow.sh         # Development workflow script
│   └── deploy-no-uploads.sh    # Code-only deployment script
├── code-deploy-*.tar.gz        # Deployment packages
├── backup-*/                   # Automatic backups
└── .gitignore                  # Updated to exclude uploads
```

## 🔧 Configuration

### Environment Variables

The scripts use your existing `.env` file:
- `APP_NAME` - WordPress container name
- `APP_URL` - WordPress URL

### Development Configuration

The workspace includes `dev-config.json`:
```json
{
  "projectName": "pet-food-store",
  "wordpressUrl": "http://localhost:8000",
  "developmentMode": true,
  "excludeUploads": true,
  "syncPaths": {
    "themes": "wp-content/themes",
    "plugins": "wp-content/plugins",
    "assets": "wp-content/uploads/dev-assets"
  }
}
```

## 🛡️ Version Control

### Updated .gitignore

The `.gitignore` has been updated to exclude:
```gitignore
# WordPress uploads and content
wp-content/uploads/**
wp-content/cache/**
wp-content/backup*/**

# Development workspace (optional - you may want to include this)
dev-workspace/
code-deploy-*.tar.gz
backup-*/

# Theme/plugin development
wp-content/themes/*/node_modules/
wp-content/themes/*/vendor/
wp-content/themes/*/assets/dist/
wp-content/plugins/*/cache/
wp-content/plugins/*/logs/
```

### What to Commit

✅ **Commit these**:
- Theme and plugin source code
- Development scripts
- Configuration files
- Documentation

❌ **Don't commit these**:
- WordPress uploads
- Cache files
- Deployment packages
- Backups
- Build artifacts

## 🔄 Auto-Watch Mode

For active development, use watch mode:

```bash
./scripts/dev-workflow.sh watch
```

This will:
1. Monitor `dev-workspace/` for file changes
2. Automatically sync changes to `wp-content/`
3. Deploy changes to WordPress container
4. Show real-time status updates

Press `Ctrl+C` to stop watching.

## 📦 Deployment Packages

### Package Contents

Code-only deployment packages include:
- Scripts and utilities
- Theme code files (`.php`, `.css`, `.js`, `.json`)
- Plugin code files
- Configuration files
- Development workspace

### Package Info

Each package includes `DEPLOYMENT_INFO.txt` with:
- Creation timestamp
- Package contents
- Deployment instructions
- Exclusion details

## 🔍 Troubleshooting

### Common Issues

1. **Container not running**:
   ```bash
   docker-compose up -d
   ```

2. **Permission issues**:
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Missing development workspace**:
   ```bash
   ./scripts/dev-workflow.sh init
   ```

4. **File watcher not working**:
   ```bash
   # Install inotify-tools
   sudo apt-get install inotify-tools  # Ubuntu/Debian
   sudo yum install inotify-tools      # CentOS/RHEL
   ```

### Status Check

```bash
# Check development environment
./scripts/dev-workflow.sh status

# Check deployment status  
./scripts/deploy-no-uploads.sh status
```

## 🎯 Use Cases

### Theme Development
1. Extract existing theme: `./scripts/dev-workflow.sh extract-theme mytheme`
2. Edit in `dev-workspace/themes/extracted/mytheme/`
3. Deploy: `./scripts/dev-workflow.sh deploy themes`

### Plugin Development
1. Create plugin in `dev-workspace/plugins/myplugin/`
2. Develop features externally
3. Deploy: `./scripts/dev-workflow.sh deploy plugins`

### Asset Management
1. Add CSS/JS to `dev-workspace/assets/`
2. Deploy: `./scripts/dev-workflow.sh deploy assets`
3. Access via `/wp-content/uploads/dev-assets/`

### Production Deployment
1. Package: `./scripts/deploy-no-uploads.sh package`
2. Transfer: `scp code-deploy-*.tar.gz user@server:/path/`
3. Deploy: `./scripts/deploy-no-uploads.sh apply`

## 🚀 Benefits

- **🔒 Secure**: No WordPress uploads in version control
- **⚡ Fast**: Deploy only code changes
- **🎯 Focused**: Separate development from content
- **🔄 Automated**: Watch mode for live development
- **💾 Safe**: Automatic backups before deployment
- **🌐 Remote**: Easy remote server deployment
- **📦 Portable**: Self-contained deployment packages

---

## 🆘 Support

For issues or questions:
1. Check container status: `docker-compose ps`
2. View logs: `docker-compose logs wordpress`
3. Check development status: `./scripts/dev-workflow.sh status`
4. Review this documentation

Happy coding! 🎉