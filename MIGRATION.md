# WordPress/WooCommerce Migration Guide

This guide will help you easily move your pet food e-commerce website to a new host.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Migration Methods](#migration-methods)
4. [Step-by-Step Guide](#step-by-step-guide)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Options](#advanced-options)

## Quick Start

For the fastest migration, use the migration helper:

```bash
./scripts/migrate.sh
```

This interactive script will guide you through the entire process.

## Prerequisites

### On Current Host
- Docker and Docker Compose installed
- Access to run Docker commands
- At least 2GB free disk space for backups

### On New Host
- Docker and Docker Compose installed
- Ports available: 8000, 8080, 6379 (or configure custom ports)
- At least 4GB free disk space
- Domain name pointed to new host (if using custom domain)

## Migration Methods

### Method 1: Automated Migration (Recommended)

1. **On current host:**
   ```bash
   # Create migration package
   ./scripts/migrate.sh
   # Select option 4 (Export migration package)
   ```

2. **Transfer the package** to new host via SCP, FTP, or cloud storage

3. **On new host:**
   ```bash
   # Extract package and run
   tar -xzf migration_package_*.tar.gz
   cd migration_*
   ./deploy.sh
   ```

### Method 2: Manual Migration

1. **Create backup on current host:**
   ```bash
   ./scripts/backup.sh
   ```

2. **Copy entire project** to new host:
   ```bash
   rsync -avz --exclude='wordpress_data' ./ user@newhost:/path/to/destination/
   ```

3. **On new host:**
   ```bash
   # Update environment settings
   cp .env.example .env
   nano .env  # Edit with new host settings
   
   # Start containers
   docker-compose up -d
   
   # Restore from backup
   ./scripts/restore.sh <timestamp>
   ```

## Step-by-Step Guide

### Step 1: Prepare Current Site

1. **Create `.env` file if not exists:**
   ```bash
   cp .env.example .env
   ```

2. **Update `.env` with current settings**

3. **Create full backup:**
   ```bash
   ./scripts/backup.sh
   ```

### Step 2: Prepare New Host

1. **Install Docker:**
   ```bash
   # Ubuntu/Debian
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

2. **Create project directory:**
   ```bash
   mkdir -p /var/www/pet-food-store
   cd /var/www/pet-food-store
   ```

### Step 3: Transfer Files

**Option A - Using Migration Package:**
```bash
# On current host
./scripts/migrate.sh  # Choose option 4

# Transfer to new host
scp migration_package_*.tar.gz user@newhost:/var/www/pet-food-store/
```

**Option B - Direct Transfer:**
```bash
# From current host
rsync -avz \
  --exclude='wordpress_data' \
  --exclude='db_data' \
  --exclude='redis_data' \
  ./ user@newhost:/var/www/pet-food-store/
```

### Step 4: Configure New Host

1. **Extract files (if using package):**
   ```bash
   tar -xzf migration_package_*.tar.gz
   cd migration_*
   ```

2. **Update environment configuration:**
   ```bash
   cp .env.example .env
   nano .env
   ```

   Key settings to update:
   - `APP_URL`: Your new domain (e.g., https://newdomain.com)
   - `DB_PASSWORD`: Strong database password
   - `DB_ROOT_PASSWORD`: Strong root password
   - Port numbers if defaults are taken

3. **Make scripts executable:**
   ```bash
   chmod +x scripts/*.sh
   ```

### Step 5: Deploy and Restore

1. **Start containers:**
   ```bash
   docker-compose up -d
   ```

2. **Check container status:**
   ```bash
   docker-compose ps
   ```

3. **Restore from backup:**
   ```bash
   ./scripts/restore.sh <timestamp>
   ```

4. **Update URLs when prompted** with your new domain

### Step 6: Post-Migration Tasks

1. **Update DNS:** Point your domain to the new host

2. **Configure SSL (for production):**
   ```bash
   # Install Certbot
   sudo apt-get update
   sudo apt-get install certbot
   
   # Get SSL certificate
   sudo certbot certonly --standalone -d yourdomain.com
   ```

3. **Test the site:**
   - Visit your site URL
   - Test admin login
   - Check WooCommerce functionality
   - Verify image uploads work

4. **Update external services:**
   - Payment gateway webhooks
   - Email service settings
   - CDN configuration
   - Analytics tracking

## Troubleshooting

### Common Issues

**Containers won't start:**
```bash
# Check logs
docker-compose logs -f

# Check port conflicts
sudo lsof -i :8000
sudo lsof -i :8080
```

**Database connection errors:**
```bash
# Check database container
docker exec -it pet-food-store_db mysql -u root -p
# Enter root password and check database exists
```

**Permission issues:**
```bash
# Fix WordPress permissions
docker exec pet-food-store_wordpress chown -R www-data:www-data /var/www/html
```

**Site shows old URL:**
```bash
# Update URLs in database
docker exec pet-food-store_wordpress wp search-replace "old-url.com" "new-url.com" --allow-root
```

### Rollback Procedure

If migration fails:
1. Keep old host running until new host is verified
2. Create fresh backup before any major changes
3. Use restore script to rollback: `./scripts/restore.sh <old-timestamp>`

## Advanced Options

### Custom Ports

Edit `.env` file:
```env
WORDPRESS_PORT=8001
PHPMYADMIN_PORT=8081
REDIS_PORT=6380
```

### Production Optimizations

1. **Enable Redis object caching:**
   ```bash
   docker exec pet-food-store_wordpress wp plugin install redis-cache --activate --allow-root
   docker exec pet-food-store_wordpress wp redis enable --allow-root
   ```

2. **Configure email for production:**
   Update `.env` with real SMTP settings:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASSWORD=your-app-password
   ```

3. **Set up automated backups:**
   ```bash
   # Add to crontab
   0 2 * * * /var/www/pet-food-store/scripts/backup.sh
   ```

### Scaling Options

For high-traffic sites:
1. Use external MySQL database (RDS, Cloud SQL)
2. Implement CDN (Cloudflare, AWS CloudFront)
3. Add load balancer for multiple WordPress containers
4. Use external Redis cluster

## Support

### Logs Location
- WordPress debug: `wp-content/debug.log`
- Docker logs: `docker-compose logs <service-name>`
- Backup logs: `backups/*.info`

### Getting Help
1. Check container status: `docker-compose ps`
2. View logs: `docker-compose logs -f`
3. Test database connection: `docker exec pet-food-store_db mysql -u root -p`
4. Verify file permissions: `ls -la wp-content/`

### Backup Recovery
Always keep multiple backups:
- Before migration
- After successful migration
- Regular automated backups

Remember: Never delete old backups until the new host is fully verified and running smoothly for at least a week.