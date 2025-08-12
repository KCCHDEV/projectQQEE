# 🏪 คู่มือผู้ดูแลระบบ - Admin Guide

คู่มือสำหรับผู้ดูแลระบบร้านอาหารสัตว์เลี้ยง (Pet Food Store Admin Guide)

## 🚀 เริ่มต้นอย่างรวดเร็ว (Quick Start)

### 1. เริ่มระบบครั้งแรก
```bash
# คัดลอกไฟล์ตั้งค่า
cp .env.example .env

# แก้ไขค่าต่างๆ ใน .env
nano .env

# เริ่มระบบด่วน
./scripts/quick-start.sh

# เปิดใช้งาน Pet Paws Theme
./scripts/activate-theme.sh

# ติดตั้งภาษาไทย
./scripts/setup-thai.sh
```

### 2. ตรวจสอบระบบ
```bash
./scripts/system-check.sh
```

## 🎯 การเข้าใช้งาน (Access Points)

### เว็บไซต์และแอดมิน
- **🌐 เว็บไซต์หลัก**: http://localhost:8000 (Pet Paws Theme)
- **👤 WordPress Admin**: http://localhost:8000/wp-admin
- **🎛️ Easy Admin Dashboard**: http://localhost:8888 (Modern UI)
- **📊 phpMyAdmin**: http://localhost:8080
- **📧 MailHog**: http://localhost:8025

### เครื่องมือแอดมิน
1. **Web Admin Dashboard** (http://localhost:8888) ✨ อัพเดทใหม่!
   - **ดีไซน์สวยงามทันสมัย** พร้อม gradients และ animations
   - **สีสันสดใส** ใช้งานง่ายด้วย card-based layout
   - **รองรับ Responsive** ใช้งานได้ทุกอุปกรณ์
   - **แสดงสถานะแบบ Real-time** พร้อม auto-refresh
   - **ไอคอนสวยงาม** จาก Font Awesome 6
   - **รองรับภาษาไทย 100%**

2. **Terminal Admin Panel**
   ```bash
   ./scripts/admin-panel.sh
   ```
   - เมนูภาษาไทยใน Terminal
   - ฟังก์ชันครบถ้วน
   - เหมาะสำหรับผู้ที่ชอบใช้ command line

### 🎨 Pet Paws Theme
ธีมใหม่ที่ออกแบบมาเฉพาะสำหรับร้านอาหารสัตว์เลี้ยง:
- **Hero Section** พร้อม parallax effect
- **Product Showcase** แสดงสินค้าสวยงาม
- **Smooth Animations** เมื่อ scroll และ hover
- **Quick View** ดูสินค้าแบบ popup
- **Wishlist** ระบบรายการโปรด
- **Mobile First** ออกแบบให้สวยบนมือถือ

## 🇹🇭 การตั้งค่าภาษาไทย (Thai Configuration)

### ติดตั้งภาษาไทยอัตโนมัติ
```bash
./scripts/setup-thai.sh
```

สิ่งที่จะได้รับ:
- ✅ เมนูและข้อความเป็นภาษาไทย
- ✅ สกุลเงินบาท (฿)
- ✅ รูปแบบวันที่แบบไทย
- ✅ เขตเวลา Asia/Bangkok
- ✅ VAT 7%
- ✅ จังหวัดของไทยใน checkout
- ✅ วิธีชำระเงิน: โอนเงิน, ปลายทาง

### การตั้งค่าเพิ่มเติม
- **เปลี่ยนชื่อร้าน**: ไปที่ Settings > General
- **ตั้งค่าการจัดส่ง**: WooCommerce > Settings > Shipping
- **เพิ่มบัญชีธนาคาร**: WooCommerce > Settings > Payments > Bank Transfer

## 💾 การสำรองและกู้คืนข้อมูล (Backup & Restore)

### สำรองข้อมูล
```bash
# สำรองข้อมูลทันที
./scripts/backup.sh

# ตั้งเวลาสำรองอัตโนมัติ (ทุกวันเวลา 2:00)
crontab -e
# เพิ่มบรรทัดนี้:
0 2 * * * /path/to/project/scripts/backup.sh
```

### กู้คืนข้อมูล
```bash
# ดูรายการสำรองข้อมูล
ls backups/*.info

# กู้คืนข้อมูล
./scripts/restore.sh <timestamp>
```

## 🔄 การย้ายโฮสต์ (Migration)

### วิธีที่ 1: ใช้ Migration Helper
```bash
./scripts/migrate.sh
```
เลือกเมนู:
- 1: เตรียมข้อมูลสำหรับย้าย
- 4: สร้างแพ็คเกจสำหรับย้าย

### วิธีที่ 2: Manual
```bash
# บนเซิร์ฟเวอร์เก่า
./scripts/backup.sh

# คัดลอกไฟล์ไปเซิร์ฟเวอร์ใหม่
scp -r . user@newserver:/path/

# บนเซิร์ฟเวอร์ใหม่
./scripts/restore.sh <timestamp>
```

## 🛠️ การบำรุงรักษา (Maintenance)

### งานประจำวัน
1. **ตรวจสอบคำสั่งซื้อ**
   - WordPress Admin > WooCommerce > Orders
   
2. **ตรวจสอบสต็อกสินค้า**
   - WordPress Admin > Products

3. **ดูรายงานยอดขาย**
   - WooCommerce > Analytics

### งานประจำสัปดาห์
1. **สำรองข้อมูล**
   ```bash
   ./scripts/backup.sh
   ```

2. **อัพเดทระบบ**
   ```bash
   # ผ่าน Web Dashboard
   http://localhost:8888
   # หรือ Terminal
   docker exec pet-food-store_wordpress wp core update --allow-root
   docker exec pet-food-store_wordpress wp plugin update --all --allow-root
   ```

3. **ล้างแคช**
   ```bash
   # ผ่าน Web Dashboard หรือ
   docker exec pet-food-store_wordpress wp cache flush --allow-root
   docker exec pet-food-store_redis redis-cli FLUSHALL
   ```

### งานประจำเดือน
1. **ตรวจสอบพื้นที่จัดเก็บ**
2. **ทบทวนรายงานการขาย**
3. **ลบข้อมูลสำรองเก่า** (เก็บไว้อย่างน้อย 30 วัน)

## 🚨 การแก้ไขปัญหา (Troubleshooting)

### ปัญหาที่พบบ่อย

**1. เว็บไซต์เข้าไม่ได้**
```bash
# ตรวจสอบ containers
docker-compose ps

# ดู logs
docker-compose logs wordpress

# รีสตาร์ท
docker-compose restart
```

**2. ฐานข้อมูลเชื่อมต่อไม่ได้**
```bash
# ตรวจสอบ database
docker exec pet-food-store_db mysql -u root -p

# รีสตาร์ท database
docker-compose restart db
```

**3. ภาษาไทยแสดงผลไม่ถูกต้อง**
```bash
# ติดตั้งภาษาไทยใหม่
./scripts/setup-thai.sh

# ล้างแคช
docker exec pet-food-store_wordpress wp cache flush --allow-root
```

**4. ไม่สามารถอัพโหลดรูปภาพ**
```bash
# แก้ไข permissions
docker exec pet-food-store_wordpress chown -R www-data:www-data /var/www/html/wp-content/uploads
```

## 📱 การจัดการผ่านมือถือ

### WordPress Mobile App
1. ดาวน์โหลด WordPress app
2. เพิ่มไซต์: http://your-domain.com
3. ใช้ username/password เดียวกับ web

### Web Admin Dashboard
- เข้าที่ http://localhost:8888
- รองรับ responsive design
- ใช้งานได้บนมือถือและแท็บเล็ต

## 🔒 ความปลอดภัย (Security)

### สิ่งที่ควรทำ
1. **เปลี่ยนรหัสผ่านเริ่มต้น** ใน `.env`
2. **ใช้ SSL certificate** สำหรับ production
3. **จำกัด IP** ที่เข้าถึง admin panel
4. **สำรองข้อมูลเป็นประจำ**
5. **อัพเดทระบบเสมอ**

### การตั้งค่าความปลอดภัย
```bash
# เปลี่ยนรหัสผ่าน WordPress admin
docker exec pet-food-store_wordpress wp user update 1 --user_pass=NewSecurePassword --allow-root

# ปิดการแก้ไขไฟล์ผ่าน WordPress
docker exec pet-food-store_wordpress wp config set DISALLOW_FILE_EDIT true --raw --allow-root
```

## 📞 การติดต่อช่วยเหลือ

### ช่องทางการสนับสนุน
1. **Documentation**: อ่านคู่มือนี้และ MIGRATION.md
2. **Logs**: ตรวจสอบ logs ก่อนเสมอ
   ```bash
   docker-compose logs -f
   ```
3. **System Check**: รัน system check
   ```bash
   ./scripts/system-check.sh
   ```

### คำสั่งที่มีประโยชน์
```bash
# ดูสถานะระบบ
./scripts/system-check.sh

# เปิด admin panel
./scripts/admin-panel.sh

# สำรองข้อมูล
./scripts/backup.sh

# ดู logs แบบ real-time
docker-compose logs -f

# เข้า WordPress container
docker exec -it pet-food-store_wordpress bash
```

---

💡 **เคล็ดลับ**: จดจำ URL สำคัญ 3 อัน
1. http://localhost:8000 (เว็บไซต์)
2. http://localhost:8000/wp-admin (WordPress Admin)
3. http://localhost:8888 (Easy Admin Dashboard)

🎯 **แนะนำ**: ใช้ Easy Admin Dashboard (http://localhost:8888) สำหรับการจัดการทั่วไป เพราะใช้งานง่ายและเป็นภาษาไทย