# 🚀 Auto Install Everything - คู่มือการติดตั้งอัตโนมัติ

## 📋 ภาพรวม (Overview)

คู่มือนี้จะแนะนำการใช้งาน script `auto-install-everything.bat` ที่จะติดตั้งระบบร้านอาหารสัตว์เลี้ยงแบบอัตโนมัติครบถ้วน โดยรวมไฟล์จาก:

- **`pet-food-shop-template/`** - WordPress + WooCommerce template
- **`exampleUi/`** - รูปภาพตัวอย่าง
- **`rimping-animal-foods/`** - UI template สำหรับร้านอาหารสัตว์

## 🎯 สิ่งที่คุณจะได้

### ✅ ระบบพื้นฐาน
- WordPress + WooCommerce
- ธีม Pet Paws (สร้างจาก Rimping UI)
- ฐานข้อมูล MySQL
- phpMyAdmin สำหรับจัดการฐานข้อมูล
- MailHog สำหรับทดสอบอีเมล

### ✅ เนื้อหาตัวอย่าง
- หน้าตัวอย่าง (เกี่ยวกับเรา, ติดต่อเรา)
- สินค้าตัวอย่าง (อาหารสัตว์, ของเล่น)
- หมวดหมู่สินค้า
- เมนูนำทาง

### ✅ การตั้งค่าไทย
- สกุลเงินบาท (THB)
- ประเทศไทย
- เขตเวลาเอเชีย/กรุงเทพ
- รูปแบบวันที่ไทย

## 🚀 วิธีการใช้งาน

### 1. การติดตั้งแบบง่าย (แนะนำ)

```cmd
# เปิด start-windows.bat
start-windows.bat

# เลือกตัวเลือก 14: ติดตั้งระบบทั้งหมดอัตโนมัติ
```

### 2. การติดตั้งแบบตรง

```cmd
# รัน script โดยตรง
scripts\auto-install-everything.bat
```

### 3. การตั้งค่าเพิ่มเติมหลังการติดตั้ง

```cmd
# เปิด start-windows.bat
start-windows.bat

# เลือกตัวเลือก 15: ตั้งค่าเพิ่มเติมหลังการติดตั้ง
```

## 📋 ขั้นตอนการติดตั้ง

### ขั้นตอนที่ 1: ตรวจสอบความพร้อมของระบบ
- ✅ ตรวจสอบ Docker
- ✅ ตรวจสอบ Docker Compose
- ✅ ตรวจสอบสิทธิ์การเข้าถึง

### ขั้นตอนที่ 2: สร้างโครงสร้างโปรเจค
- ✅ สร้างโฟลเดอร์ wp-content
- ✅ สร้างโฟลเดอร์ themes, plugins, uploads
- ✅ สร้างโฟลเดอร์ backups, dev-workspace

### ขั้นตอนที่ 3: คัดลอกไฟล์เทมเพลต
- ✅ คัดลอก docker-compose.yml
- ✅ คัดลอก install.sh
- ✅ คัดลอก README.md

### ขั้นตอนที่ 4: คัดลอกรูปภาพตัวอย่าง
- ✅ คัดลอกรูปภาพจาก exampleUi/
- ✅ จัดเก็บใน wp-content/uploads/2024/12/example-ui/

### ขั้นตอนที่ 5: คัดลอก UI Template
- ✅ คัดลอกไฟล์จาก rimping-animal-foods/
- ✅ จัดเก็บใน dev-workspace/ui-template/

### ขั้นตอนที่ 6: สร้างไฟล์การตั้งค่า
- ✅ สร้างไฟล์ .env
- ✅ ตั้งค่าพอร์ตและฐานข้อมูล
- ✅ ตั้งค่าสกุลเงินและเขตเวลา

### ขั้นตอนที่ 7: สร้างธีม WordPress
- ✅ สร้างธีม Pet Paws
- ✅ คัดลอก CSS และ JavaScript
- ✅ สร้างไฟล์ PHP หลัก (index.php, header.php, footer.php, functions.php)

### ขั้นตอนที่ 8: เริ่มต้น Docker Containers
- ✅ เริ่มต้น WordPress container
- ✅ เริ่มต้น MySQL container
- ✅ เริ่มต้น phpMyAdmin container
- ✅ เริ่มต้น MailHog container

### ขั้นตอนที่ 9: รอให้ WordPress พร้อมใช้งาน
- ✅ ตรวจสอบการเชื่อมต่อฐานข้อมูล
- ✅ รอให้ WordPress พร้อมใช้งาน

### ขั้นตอนที่ 10: ติดตั้งและตั้งค่า WordPress
- ✅ ติดตั้ง WordPress
- ✅ ตั้งค่าผู้ดูแลระบบ

### ขั้นตอนที่ 11: ติดตั้ง WooCommerce
- ✅ ติดตั้ง WooCommerce plugin
- ✅ เปิดใช้งาน WooCommerce

### ขั้นตอนที่ 12: ตั้งค่า WooCommerce
- ✅ ตั้งค่าสกุลเงินบาท
- ✅ ตั้งค่าประเทศไทย
- ✅ ตั้งค่าเขตเวลา
- ✅ ตั้งค่ารูปแบบวันที่

### ขั้นตอนที่ 13: เปิดใช้งานธีม Pet Paws
- ✅ เปิดใช้งานธีม Pet Paws
- ✅ ตรวจสอบการแสดงผล

### ขั้นตอนที่ 14: สร้างหน้าตัวอย่าง
- ✅ สร้างหน้า "เกี่ยวกับเรา"
- ✅ สร้างหน้า "ติดต่อเรา"

### ขั้นตอนที่ 15: เพิ่มสินค้าตัวอย่าง
- ✅ สร้างหมวดหมู่สินค้า
- ✅ เพิ่มสินค้าตัวอย่าง

### ขั้นตอนที่ 16: ตั้งค่าเมนูนำทาง
- ✅ สร้างเมนูหลัก
- ✅ เพิ่มหน้าลงในเมนู
- ✅ กำหนดตำแหน่งเมนู

### ขั้นตอนที่ 17: การตั้งค่าสุดท้าย
- ✅ ตั้งค่าหน้าแรก
- ✅ ล้างแคช

## 🔧 การตั้งค่าเพิ่มเติม

### การตั้งค่าการชำระเงิน
```cmd
scripts\post-install-setup.bat
# เลือก 1) ตั้งค่าการชำระเงิน
```

**ตัวเลือกการชำระเงิน:**
- โอนเงินผ่านธนาคาร
- เก็บเงินปลายทาง

### การตั้งค่าการจัดส่ง
```cmd
scripts\post-install-setup.bat
# เลือก 2) ตั้งค่าการจัดส่ง
```

**อัตราค่าจัดส่ง:**
- กรุงเทพฯ: 50 บาท
- ต่างจังหวัด: 100 บาท

### การตั้งค่าภาษี
```cmd
scripts\post-install-setup.bat
# เลือก 4) ตั้งค่าภาษี
```

**การตั้งค่าภาษี:**
- ภาษีมูลค่าเพิ่ม 7%
- แสดงราคารวมภาษี

### การปรับแต่งธีม
```cmd
scripts\post-install-setup.bat
# เลือก 5) ปรับแต่งธีม Pet Paws
```

**การปรับแต่ง:**
- สร้างไฟล์ custom.css
- ปรับแต่งสีและฟอนต์
- เพิ่มเอฟเฟกต์

## 🌐 ลิงก์สำคัญ

หลังการติดตั้งเสร็จ คุณสามารถเข้าถึง:

- **🌐 เว็บไซต์**: http://localhost:8000
- **👤 แอดมิน**: http://localhost:8000/wp-admin
- **📊 phpMyAdmin**: http://localhost:8080
- **📧 MailHog**: http://localhost:8025

## 🔑 ข้อมูลเข้าสู่ระบบ

- **👤 Username**: admin
- **🔒 Password**: admin123

⚠️ **คำแนะนำ**: เปลี่ยนรหัสผ่านทันทีหลังการติดตั้ง!

## 📁 โครงสร้างไฟล์

```
projectQQEE/
├── wp-content/
│   ├── themes/
│   │   └── pet-paws/          # ธีม Pet Paws
│   ├── uploads/
│   │   └── 2024/12/
│   │       ├── example-ui/    # รูปภาพตัวอย่าง
│   │       └── products/      # รูปภาพสินค้า
│   └── plugins/               # Plugins
├── dev-workspace/
│   └── ui-template/           # UI Template จาก Rimping
├── backups/                   # ข้อมูลสำรอง
├── scripts/                   # Scripts ทั้งหมด
└── docker-compose.yml         # Docker configuration
```

## 🚀 คำสั่งที่มีประโยชน์

### การจัดการระบบ
```cmd
# ดูสถานะ containers
docker-compose ps

# ดู logs
docker-compose logs -f

# หยุดระบบ
docker-compose down

# รีสตาร์ทระบบ
docker-compose restart
```

### การจัดการ WordPress
```cmd
# เข้าไปใน WordPress container
docker exec -it pet-food-store_wordpress bash

# ดูเวอร์ชัน WordPress
docker exec pet-food-store_wordpress wp core version --allow-root

# ดูรายการ plugins
docker exec pet-food-store_wordpress wp plugin list --allow-root

# ดูรายการ themes
docker exec pet-food-store_wordpress wp theme list --allow-root
```

### การจัดการ WooCommerce
```cmd
# ดูรายการสินค้า
docker exec pet-food-store_wordpress wp post list --post_type=product --allow-root

# ดูหมวดหมู่สินค้า
docker exec pet-food-store_wordpress wp term list product_cat --allow-root

# ดูคำสั่งซื้อ
docker exec pet-food-store_wordpress wp wc order list --allow-root
```

## 🐛 การแก้ไขปัญหา

### ปัญหา: Docker ไม่ทำงาน
```cmd
# ตรวจสอบ Docker
docker --version

# เริ่มต้น Docker Desktop
# หรือรีสตาร์ทเครื่อง
```

### ปัญหา: Port ถูกใช้งาน
```cmd
# ตรวจสอบ port
netstat -an | findstr :8000

# เปลี่ยน port ในไฟล์ .env
WORDPRESS_PORT=8001
```

### ปัญหา: WordPress ไม่สามารถติดตั้งได้
```cmd
# ตรวจสอบ logs
docker-compose logs wordpress

# รีสตาร์ท containers
docker-compose restart
```

### ปัญหา: ธีมไม่แสดงผล
```cmd
# ตรวจสอบธีม
docker exec pet-food-store_wordpress wp theme list --allow-root

# เปิดใช้งานธีมใหม่
docker exec pet-food-store_wordpress wp theme activate pet-paws --allow-root
```

## 💡 คำแนะนำเพิ่มเติม

### 1. การปรับแต่งธีม
- แก้ไขไฟล์ใน `wp-content/themes/pet-paws/`
- ใช้ `custom.css` สำหรับ CSS เพิ่มเติม
- ใช้ `functions.php` สำหรับ PHP functions

### 2. การเพิ่มสินค้า
- เข้าไปที่ WooCommerce > Products
- เพิ่มสินค้าใหม่
- ตั้งราคาและรายละเอียด
- อัปโหลดรูปภาพ

### 3. การตั้งค่าการชำระเงิน
- ไปที่ WooCommerce > Settings > Payments
- เปิดใช้งานวิธีการชำระเงินที่ต้องการ
- ตั้งค่ารายละเอียด

### 4. การสำรองข้อมูล
```cmd
# สร้าง backup
scripts\backup.bat

# คืนค่าข้อมูล
scripts\restore.bat <timestamp>
```

## 🎯 สรุป

Script `auto-install-everything.bat` จะทำให้คุณได้:

✅ **ระบบร้านค้าออนไลน์ครบถ้วน** - WordPress + WooCommerce  
✅ **ธีมสวยงาม** - Pet Paws theme จาก Rimping UI  
✅ **เนื้อหาตัวอย่าง** - หน้าตัวอย่างและสินค้า  
✅ **การตั้งค่าไทย** - สกุลเงิน, ภาษา, เขตเวลา  
✅ **เครื่องมือจัดการ** - phpMyAdmin, MailHog  
✅ **ระบบสำรองข้อมูล** - Backup และ Restore  

**เริ่มต้นใช้งานได้ทันทีด้วยคำสั่ง:**
```cmd
scripts\auto-install-everything.bat
```

หรือใช้ launcher:
```cmd
start-windows.bat
# เลือก 14) ติดตั้งระบบทั้งหมดอัตโนมัติ
```
