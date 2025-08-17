# 🚀 Pet Food Shop - คู่มือติดตั้งแบบง่าย (ไฟล์เดียวจบ!)

## 📋 ภาพรวม

ตอนนี้เรามีสคริปต์เดียวที่ทำได้ทุกอย่าง! ไม่ต้องงงกับไฟล์เยอะแยะแล้ว 🎉

**ไฟล์เดียวจบ:**
- Windows: `install-pet-shop.bat`
- Linux/macOS: `install-pet-shop.sh`

## 🎯 รองรับทั้ง 2 วิธี

### 🐳 Docker (แนะนำ)
- ติดตั้งง่าย รันได้เลย
- มี WordPress + WooCommerce + phpMyAdmin + MailHog
- ไม่ต้องติดตั้งอะไรเพิ่ม (นอกจาก Docker)

### 📁 XAMPP/Local Server
- ใช้ XAMPP ที่มีอยู่
- รองรับ Apache + MySQL + PHP
- สำหรับคนที่มี XAMPP อยู่แล้ว

## 🚀 วิธีใช้งาน

### สำหรับ Windows:
```cmd
# ดับเบิลคลิกไฟล์
install-pet-shop.bat

# หรือเปิด Command Prompt แล้วรัน
install-pet-shop.bat
```

### สำหรับ Linux/macOS:
```bash
# ทำให้รันได้
chmod +x install-pet-shop.sh

# รัน
./install-pet-shop.sh

# หรือ
bash install-pet-shop.sh
```

## 🎮 การใช้งาน

เมื่อรันสคริปต์ จะเห็นเมนู:

```
🚀 เลือกวิธีการติดตั้ง:

  1) 🐳 Docker (แนะนำ - ติดตั้งง่าย มีทุกอย่างครบ)
  2) 📁 XAMPP (ใช้ XAMPP ที่มีอยู่)
  3) ❓ ตรวจสอบระบบ
  4) 🚪 ออกจากโปรแกรม

👉 เลือก (1-4):
```

### ตัวเลือกที่ 1: Docker 🐳
- ตรวจสอบ Docker
- สร้างไฟล์ docker-compose.yml
- ติดตั้ง WordPress + WooCommerce
- ตั้งค่าสกุลเงินไทย
- สร้างสินค้าตัวอย่าง
- **ผลลัพธ์:** http://localhost:8000

### ตัวเลือกที่ 2: XAMPP 📁
- ตรวจหา XAMPP
- ดาวน์โหลด WordPress
- สร้างฐานข้อมูล
- สร้างธีม Pet Paws
- **ผลลัพธ์:** http://localhost/pet-food-store

### ตัวเลือกที่ 3: ตรวจสอบระบบ ❓
- ตรวจสอบ Docker
- ตรวจสอบ Apache/MySQL/PHP
- แสดงวิธีติดตั้งที่ขาดหาย

## 📊 ข้อกำหนดระบบ

### สำหรับ Docker:
- ✅ Windows 10/11 หรือ Linux/macOS
- ✅ Docker Desktop
- ✅ 4GB RAM (แนะนำ 8GB)
- ✅ 2GB พื้นที่ว่าง

### สำหรับ XAMPP:
- ✅ XAMPP หรือ Apache+MySQL+PHP
- ✅ PHP 7.4+ 
- ✅ MySQL 5.7+
- ✅ 1GB พื้นที่ว่าง

## 🎉 ผลลัพธ์หลังติดตั้ง

### Docker:
- 🌐 เว็บไซต์: http://localhost:8000
- 🔐 Admin: http://localhost:8000/wp-admin (admin/admin123)
- 🗄️ phpMyAdmin: http://localhost:8080
- 📧 MailHog: http://localhost:8025

### XAMPP:
- 🌐 เว็บไซต์: http://localhost/pet-food-store
- 🗄️ phpMyAdmin: http://localhost/phpmyadmin
- 📁 ไฟล์: C:\xampp\htdocs\pet-food-store (หรือตาม path ที่กำหนด)

## 🔧 คำสั่งที่มีประโยชน์

### Docker:
```bash
# หยุดระบบ
docker-compose down

# รีสตาร์ท
docker-compose restart

# ดูสถานะ
docker-compose ps

# ดู logs
docker-compose logs wordpress
```

### XAMPP:
```bash
# เริ่มต้น XAMPP (Linux)
sudo /opt/lampp/lampp start

# หยุด XAMPP (Linux)
sudo /opt/lampp/lampp stop
```

## 🆘 แก้ไขปัญหา

### ปัญหา: Port ถูกใช้งาน
```bash
# ตรวจสอบ port
netstat -tulpn | grep :8000

# Docker: เปลี่ยน port ใน docker-compose.yml
ports:
  - "8001:80"  # เปลี่ยนจาก 8000 เป็น 8001
```

### ปัญหา: Docker ไม่ทำงาน
```bash
# Linux
sudo systemctl start docker
sudo usermod -aG docker $USER

# Windows: เปิด Docker Desktop
```

### ปัญหา: XAMPP ไม่ทำงาน
```bash
# ตรวจสอบ Apache
sudo systemctl status apache2

# ตรวจสอบ MySQL
sudo systemctl status mysql
```

## 🎯 ข้อดี

✅ **ไฟล์เดียว** - ไม่ต้องหาไฟล์หลายตัว  
✅ **รองรับหลายระบบ** - Docker และ XAMPP  
✅ **ติดตั้งอัตโนมัติ** - กดปุ่มเดียวจบ  
✅ **มี Error Handling** - ไม่หยุดทำงานง่ายๆ  
✅ **ธีมสวย** - มาพร้อมธีม Pet Paws  
✅ **WooCommerce** - พร้อมขายของทันที  
✅ **ตั้งค่าไทย** - สกุลเงินบาท ประเทศไทย  

## 🚀 เริ่มต้นใช้งาน

1. **ดาวน์โหลดไฟล์**
   - Windows: `install-pet-shop.bat`
   - Linux/macOS: `install-pet-shop.sh`

2. **รันไฟล์**
   - Windows: ดับเบิลคลิก
   - Linux/macOS: `bash install-pet-shop.sh`

3. **เลือกวิธีติดตั้ง**
   - Docker (แนะนำ)
   - XAMPP

4. **รอติดตั้งเสร็จ**
   - Docker: 2-3 นาที
   - XAMPP: 1-2 นาที

5. **เข้าใช้งาน**
   - เปิดเว็บบราวเซอร์
   - ไปที่ URL ที่แสดง

**เท่านี้ก็เสร็จแล้ว! 🎉**