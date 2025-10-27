# 🐾 Pet Store - ร้านสัตว์เลี้ยง

เทมเพลตร้านขายอุปกรณ์และอาหารสัตว์เลี้ยงแบบง่าย ติดตั้งได้ใน 5 นาที!

## ✨ ฟีเจอร์เด่น

- 🚀 **ติดตั้งง่าย** - คลิกเดียวเสร็จ
- 🎨 **สวยงาม** - ดีไซน์ทันสมัยรองรับมือถือ
- 🛍️ **WooCommerce** - ระบบขายของครบถ้วน
- 📦 **สินค้าตัวอย่าง** - พร้อมใช้งานทันที
- 🔧 **ปรับแต่งง่าย** - แก้ไขได้ตามต้องการ

## 🚀 ติดตั้งแบบเร็ว (5 นาที)

### Windows:
```cmd
quick-start.bat
```

### Mac/Linux:
```bash
./quick-start.sh
```

### เข้าใช้งาน:
- 🌐 **เว็บไซต์**: http://localhost:8000
- 👤 **Admin**: http://localhost:8000/wp-admin (admin/admin)

## 📱 หน้าตาเว็บไซต์

### 🏠 หน้าแรก:
- Hero section สวยงาม
- หมวดหมู่สินค้า (🐕 🐱 🐦 🐠 🐹 🦎)
- สินค้าแนะนำ
- ข้อมูลร้านค้า

### 🛍️ ระบบร้านค้า:
- หน้าสินค้า WooCommerce
- ตะกร้าสินค้า
- ระบบชำระเงิน
- ระบบสมาชิก
- รายงานยอดขาย

## 🛒 สินค้าตัวอย่างที่มีให้

- 🐕 **อาหารสุนัข**: พรีเมียม, พันธุ์เล็ก
- 🐱 **อาหารแมว**: เปียก, แห้ง
- 🎾 **ของเล่น**: ลูกบอล, ไม้แกว่ง
- 🧴 **อุปกรณ์ดูแล**: แปรงขน, แชมพู
- 🏠 **บ้านและที่นอน**: บ้านไม้, ที่นอนนุ่ม

## 🔧 ปรับแต่งง่าย

### เปลี่ยนชื่อร้าน:
```
Admin → Settings → General → Site Title
```

### เพิ่มสินค้า:
```
Admin → Products → Add New
```

### เปลี่ยนสี/ธีม:
```
แก้ไขไฟล์: simple-pet-store/style.css
```

## 📋 ความต้องการระบบ

- Docker Desktop (Windows/Mac) หรือ Docker (Linux)
- 2GB+ RAM ว่าง
- 5GB+ พื้นที่ hard disk ว่าง

## 📂 ไฟล์สำคัญ

```
pet-store/
├── simple-pet-store/          # ธีมร้านสัตว์เลี้ยง
├── simple-docker-compose.yml  # การตั้งค่า Docker
├── quick-start.bat            # ติดตั้ง Windows
├── quick-start.sh             # ติดตั้ง Mac/Linux
├── sample-products.sql        # ข้อมูลสินค้าตัวอย่าง
└── EASY-INSTALL.md           # คู่มือติดตั้ง
```

## 🛠️ คำสั่งที่มีประโยชน์

```bash
# หยุดระบบ
docker-compose -f simple-docker-compose.yml down

# เริ่มระบบ
docker-compose -f simple-docker-compose.yml up -d

# ดู logs
docker-compose -f simple-docker-compose.yml logs -f
```

## 📚 คู่มือเพิ่มเติม

- 📖 **[EASY-INSTALL.md](EASY-INSTALL.md)** - คู่มือติดตั้งแบบละเอียด
- 🔧 **[DOCKER-EXPORT-GUIDE.md](DOCKER-EXPORT-GUIDE.md)** - วิธีย้ายไปเครื่องอื่น
- 🪟 **[WINDOWS-GUIDE.md](WINDOWS-GUIDE.md)** - คู่มือเฉพาะ Windows

## 🆘 ช่วยเหลือ

### ปัญหาที่พบบ่อย:
- **เข้าเว็บไม่ได้**: รอ 1-2 นาที หรือ restart Docker
- **ลืมรหัส**: ใช้ admin/admin หรือรีเซ็ตใน phpMyAdmin
- **Port ถูกใช้**: เปลี่ยน port ในไฟล์ docker-compose

### ติดต่อ:
- 🐛 **Bug Report**: สร้าง Issue ใน GitHub
- 💡 **ขอฟีเจอร์**: สร้าง Feature Request
- ❓ **คำถาม**: ถามใน Discussions

---

## 🎉 พร้อมใช้งานแล้ว!

หลังจากติดตั้งเสร็จ คุณจะได้ร้านสัตว์เลี้ยงออนไลน์ที่:
- ✅ ใช้งานได้ทันที
- ✅ สวยงามและทันสมัย  
- ✅ รองรับมือถือ
- ✅ มีสินค้าตัวอย่าง
- ✅ ระบบขายของครบถ้วน

**เริ่มขายได้เลย!** 🛍️

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