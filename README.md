# Pet Food E-commerce Platform

A modern WordPress/WooCommerce-based e-commerce platform for pet food products, containerized with Docker for easy deployment and migration.

## 🚀 Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd pet-food-ecommerce

# Run quick start script
./scripts/quick-start.sh
```

This will:
- Set up environment configuration
- Start all Docker containers
- Initialize WordPress and WooCommerce
- Provide access URLs

### 🎨 Activate Beautiful Theme

```bash
# Activate the Pet Paws theme
./scripts/activate-theme.sh

# (Optional) Install Thai language
./scripts/setup-thai.sh
```

## 🖼️ Beautiful Modern UI

The platform includes:
- **Custom Pet Paws Theme**: Professional design specifically for pet stores
- **Modern Admin Dashboard**: Beautiful management interface at http://localhost:8888
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile
- **Smooth Animations**: Enhanced user experience with subtle animations
- **Professional Color Scheme**: Carefully chosen colors for pet industry
- **Thai Language Ready**: Full support for Thai localization

## 🌟 Features

- **WordPress & WooCommerce**: Full e-commerce functionality
- **Docker Containerized**: Easy deployment and scaling
- **Database Management**: MySQL with phpMyAdmin interface
- **Caching**: Redis for improved performance
- **Email Testing**: MailHog for development
- **Easy Migration**: Built-in backup and restore tools
- **Environment-based Configuration**: Simple host switching
- **Thai Language Support**: Full Thai localization with THB currency
- **Easy Admin Panel**: Beautiful web-based management dashboard
- **Terminal Admin**: Command-line management interface
- **Pet Paws Theme**: Modern, responsive custom theme designed for pet stores
- **Beautiful UI**: Professional design with animations and modern styling

## 📋 Prerequisites

- Docker and Docker Compose
- 4GB+ free disk space
- Ports 8000, 8080, 6379 available (configurable)

## 🏗️ Architecture

```
├── docker-compose.yml      # Container orchestration
├── .env.example           # Environment configuration template
├── scripts/               # Automation scripts
│   ├── backup.sh         # Backup database and files
│   ├── restore.sh        # Restore from backup
│   ├── migrate.sh        # Migration helper
│   └── quick-start.sh    # Quick setup
├── wp-content/           # WordPress content
├── backups/              # Backup storage
└── MIGRATION.md          # Detailed migration guide
```

## 🔧 Configuration

1. Copy `.env.example` to `.env`
2. Update values for your environment:
   - `APP_URL`: Your domain
   - Database passwords
   - Port numbers
   - Email settings

## 🚀 Deployment

### Local Development

```bash
# Start containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

### 📦 Docker Export/Import (ย้ายไปเครื่องอื่น)

**สำหรับการใช้งานบนเครื่องอื่น - Export แล้วนำไป Import ได้เลย:**

```bash
# Export (เครื่องต้นทาง)
./docker-export.sh

# Import (เครื่องปลายทาง)
cd docker-export/
./docker-import.sh
```

**ผลลัพธ์:**
- ✅ WordPress + WooCommerce พร้อมใช้งาน
- ✅ ธีมและปลั๊กอินครบถ้วน
- ✅ ฐานข้อมูลย้ายมาด้วย
- ✅ ใช้งานได้ทันทีที่ http://localhost:8000

**คู่มือโดยละเอียด:**
- [📖 DOCKER-EXPORT-GUIDE.md](DOCKER-EXPORT-GUIDE.md) - คู่มือสมบูรณ์
- [⚡ QUICK-EXPORT-GUIDE.md](QUICK-EXPORT-GUIDE.md) - คู่มือเร็ว 5 นาที
- [🪟 WINDOWS-GUIDE.md](WINDOWS-GUIDE.md) - คู่มือเฉพาะ Windows

### 🎨 ระบบจัดการธีมขั้นสูง

**Theme Management ที่ทันสมัย:**

```bash
# Linux/Mac
./scripts/theme-manager.sh list
./scripts/theme-manager.sh activate petpaws

# Windows
scripts\theme-manager.bat list
scripts\theme-manager.bat activate petpaws
```

**Web Interface สำหรับจัดการธีม:**
- 🌐 เข้าที่: http://localhost:8000/wp-admin
- 🎯 ไปที่: **Appearance > Theme Manager**
- ✨ ฟีเจอร์: Upload, Gallery, Backup, Restore, Customize

### Production Deployment

See [MIGRATION.md](MIGRATION.md) for detailed deployment instructions.

## 💾 Backup & Restore

### Create Backup

```bash
./scripts/backup.sh
```

Creates timestamped backups of:
- Database
- WordPress files
- Configuration

### Restore Backup

```bash
./scripts/restore.sh <timestamp>
```

## 🔄 Migration

The project includes powerful migration tools for easy host switching:

### Interactive Migration

```bash
./scripts/migrate.sh
```

Options:
1. Prepare for migration (backup)
2. Deploy to new host
3. Check requirements
4. Export migration package
5. Import migration package

### Quick Migration

1. **On current host:**
   ```bash
   ./scripts/migrate.sh
   # Select option 4 - Export package
   ```

2. **Transfer package to new host**

3. **On new host:**
   ```bash
   tar -xzf migration_package_*.tar.gz
   cd migration_*
   ./deploy.sh
   ```

## 📊 Access Points

- **WordPress**: http://localhost:8000
- **WordPress Admin**: http://localhost:8000/wp-admin
- **Admin Dashboard**: http://localhost:8888 (Easy management panel)
- **phpMyAdmin**: http://localhost:8080
- **MailHog**: http://localhost:8025

## 🛠️ Maintenance

### Update WordPress/Plugins

```bash
# Access WordPress CLI
docker exec -it pet-food-store_wordpress bash

# Update WordPress
wp core update --allow-root

# Update plugins
wp plugin update --all --allow-root
```

### Clear Cache

```bash
# WordPress cache
docker exec pet-food-store_wordpress wp cache flush --allow-root

# Redis cache
docker exec pet-food-store_redis redis-cli FLUSHALL
```

## 🔒 Security

- Change all default passwords in `.env`
- Use strong database passwords
- Enable SSL for production
- Regular backups
- Keep WordPress and plugins updated

## 📝 Environment Variables

Key variables in `.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| APP_URL | Site URL | http://localhost:8000 |
| WORDPRESS_PORT | WordPress port | 8000 |
| DB_PASSWORD | Database password | secure_password_here |
| WP_DEBUG | Debug mode | false |

## 🐛 Troubleshooting

### Container Issues

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs wordpress
```

### Database Connection

```bash
# Test database connection
docker exec pet-food-store_db mysql -u root -p
```

### Permission Issues

```bash
# Fix file permissions
docker exec pet-food-store_wordpress chown -R www-data:www-data /var/www/html
```

## 📚 Documentation

- [MIGRATION.md](MIGRATION.md) - Detailed migration guide
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [WordPress Docs](https://wordpress.org/documentation/)
- [WooCommerce Docs](https://woocommerce.com/documentation/)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues or questions:
1. Check [MIGRATION.md](MIGRATION.md) for migration help
2. Review container logs
3. Check WordPress debug log
4. Open an issue on GitHub

---
Built with ❤️ for pet lovers everywhere 