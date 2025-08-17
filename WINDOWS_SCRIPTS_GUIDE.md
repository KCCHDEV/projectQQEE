# 🪟 Windows Scripts Guide - คู่มือการใช้งาน Scripts สำหรับ Windows

## 📋 ภาพรวม (Overview)

คู่มือนี้จะแนะนำการใช้งาน scripts ทั้งหมดสำหรับ Windows users โดยมีไฟล์ `.bat` ที่รองรับ Windows ครบทุกตัว

## 🚀 การเริ่มต้นใช้งาน (Getting Started)

### 1. ตรวจสอบความพร้อมของระบบ
```cmd
scripts\system-check.bat
```

### 2. เริ่มต้นระบบ WordPress/WooCommerce
```cmd
scripts\quick-start.bat
```

### 3. ติดตั้งภาษาไทย
```cmd
scripts\setup-thai.bat
```

## 📁 รายการ Scripts ทั้งหมด

### 🔧 การจัดการระบบ (System Management)

| Script | คำอธิบาย | คำสั่ง |
|--------|----------|--------|
| `quick-start.bat` | เริ่มต้นระบบ WordPress/WooCommerce | `scripts\quick-start.bat` |
| `system-check.bat` | ตรวจสอบความพร้อมของระบบ | `scripts\system-check.bat` |
| `setup-thai.bat` | ติดตั้งภาษาไทยและตั้งค่าไทย | `scripts\setup-thai.bat` |

### 💾 การสำรองข้อมูล (Backup & Restore)

| Script | คำอธิบาย | คำสั่ง |
|--------|----------|--------|
| `backup.bat` | สำรองข้อมูลทั้งหมด | `scripts\backup.bat` |
| `restore.bat` | คืนค่าข้อมูลจาก backup | `scripts\restore.bat <timestamp>` |

### 🛒 จัดการ WooCommerce

| Script | คำอธิบาย | คำสั่ง |
|--------|----------|--------|
| `admin-panel.bat` | แผงควบคุมการจัดการระบบ | `scripts\admin-panel.bat` |
| `upload-demo-data.bat` | อัปโหลดข้อมูลตัวอย่าง | `scripts\upload-demo-data.bat` |

### 🎨 การพัฒนา (Development)

| Script | คำอธิบาย | คำสั่ง |
|--------|----------|--------|
| `auto-sync-wp-content.bat` | ซิงค์ไฟล์อัตโนมัติ | `scripts\auto-sync-wp-content.bat` |
| `dev-workflow.bat` | ระบบการพัฒนาภายนอก | `scripts\dev-workflow.bat` |
| `activate-theme.bat` | เปิดใช้งานธีม | `scripts\activate-theme.bat` |

### 🚀 การ Deploy และ Migration

| Script | คำอธิบาย | คำสั่ง |
|--------|----------|--------|
| `migrate.bat` | ย้ายระบบไปยังโฮสต์ใหม่ | `scripts\migrate.bat` |
| `deploy-no-uploads.bat` | Deploy เฉพาะโค้ด | `scripts\deploy-no-uploads.bat` |

## 🔧 การใช้งาน Scripts หลัก

### 1. ระบบตรวจสอบ (System Check)
```cmd
scripts\system-check.bat
```
**ฟีเจอร์:**
- ตรวจสอบ Docker และ Docker Compose
- ตรวจสอบสถานะ Containers
- ตรวจสอบการติดตั้ง WordPress
- ตรวจสอบการสำรองข้อมูล

### 2. แผงควบคุม (Admin Panel)
```cmd
scripts\admin-panel.bat
```
**เมนูหลัก:**
- 🚀 เริ่ม/หยุด/รีสตาร์ทระบบ
- 📦 สำรองและคืนค่าข้อมูล
- 🛒 จัดการ WooCommerce
- 🔧 เครื่องมือดูแลระบบ
- 🌐 ตั้งค่าภาษา

### 3. การพัฒนา (Development Workflow)
```cmd
scripts\dev-workflow.bat init
scripts\dev-workflow.bat sync themes
scripts\dev-workflow.bat deploy themes
```

**คำสั่งหลัก:**
- `init` - สร้าง workspace การพัฒนา
- `sync [themes|plugins|assets|all]` - ซิงค์ไฟล์
- `deploy [themes|plugins|assets|all]` - Deploy ไปยัง container
- `extract-theme <name>` - ดึงธีมออกมาแก้ไข
- `status` - ดูสถานะการพัฒนา

### 4. การสำรองข้อมูล (Backup & Restore)
```cmd
REM สร้าง backup
scripts\backup.bat

REM คืนค่าข้อมูล
scripts\restore.bat 20241201_143022
```

### 5. การ Migration
```cmd
scripts\migrate.bat
```
**ตัวเลือก:**
1. เตรียมการย้าย (สร้าง backup)
2. Deploy ไปยังโฮสต์ใหม่
3. ตรวจสอบความต้องการ
4. สร้าง migration package
5. Import migration package

## ⚙️ การตั้งค่า (Configuration)

### ไฟล์ .env
สร้างไฟล์ `.env` ในโฟลเดอร์หลัก:

```env
APP_NAME=pet-food-store
WORDPRESS_PORT=8000
PHPMYADMIN_PORT=8080
MAILHOG_WEB_PORT=8025
DB_ROOT_PASSWORD=rootpassword
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpress
APP_URL=http://localhost:8000
```

### การตั้งค่า Docker
1. ติดตั้ง Docker Desktop
2. เปิดใช้งาน WSL 2 (ถ้าจำเป็น)
3. ตรวจสอบ Docker ทำงานปกติ

## 🐛 การแก้ไขปัญหา (Troubleshooting)

### ปัญหาที่พบบ่อย

#### 1. Docker ไม่ทำงาน
```cmd
docker --version
docker-compose --version
```
**แก้ไข:** ติดตั้ง Docker Desktop และรีสตาร์ทเครื่อง

#### 2. Port ถูกใช้งาน
```cmd
netstat -an | findstr :8000
```
**แก้ไข:** เปลี่ยน port ในไฟล์ .env

#### 3. ไฟล์ .env ไม่พบ
```cmd
copy .env.example .env
notepad .env
```

#### 4. Permission ผิดพลาด
```cmd
REM ตรวจสอบสิทธิ์การเข้าถึง
icacls scripts\*.bat
```

### การ Debug
```cmd
REM ดู logs ของ containers
docker-compose logs -f

REM ดูสถานะ containers
docker-compose ps

REM เข้าไปใน WordPress container
docker exec -it pet-food-store_wordpress bash
```

## 📚 คำสั่งที่มีประโยชน์ (Useful Commands)

### Docker Commands
```cmd
docker-compose up -d          # เริ่ม containers
docker-compose down           # หยุด containers
docker-compose restart        # รีสตาร์ท containers
docker-compose logs -f        # ดู logs แบบ real-time
```

### WordPress Commands
```cmd
docker exec pet-food-store_wordpress wp --info
docker exec pet-food-store_wordpress wp user list
docker exec pet-food-store_wordpress wp plugin list
```

### System Commands
```cmd
netstat -an | findstr :8000   # ตรวจสอบ port
tasklist | findstr docker     # ตรวจสอบ Docker processes
```

## 🔒 ความปลอดภัย (Security)

### คำแนะนำ
1. เปลี่ยนรหัสผ่านในไฟล์ .env
2. ใช้ SSL certificate สำหรับ production
3. อัปเดตระบบเป็นประจำ
4. สำรองข้อมูลทุกวัน

### การตั้งค่าความปลอดภัย
```cmd
REM เปลี่ยนรหัสผ่าน admin
docker exec pet-food-store_wordpress wp user update admin --user_pass=NEW_PASSWORD

REM ตั้งค่า file permissions
icacls wp-content /grant "Users":(OI)(CI)F
```

## 📞 การสนับสนุน (Support)

### การรายงานปัญหา
1. ใช้ `scripts\system-check.bat` เพื่อตรวจสอบระบบ
2. บันทึก error messages
3. ตรวจสอบ logs ด้วย `docker-compose logs`

### ข้อมูลที่ต้องเตรียม
- เวอร์ชัน Windows
- เวอร์ชัน Docker
- Error messages
- Log files
- ขั้นตอนที่ทำให้เกิดปัญหา

## 🎯 สรุป

Scripts ทั้งหมดได้รับการออกแบบให้ใช้งานง่ายบน Windows โดยมีฟีเจอร์:

✅ **รองรับ Windows ครบถ้วน** - ใช้ .bat files  
✅ **ภาษาไทย** - รองรับการแสดงผลภาษาไทย  
✅ **UI ที่ใช้งานง่าย** - เมนูและข้อความที่ชัดเจน  
✅ **การจัดการข้อผิดพลาด** - แสดงข้อความ error ที่เข้าใจง่าย  
✅ **Documentation ครบถ้วน** - คู่มือการใช้งานละเอียด  

เริ่มต้นใช้งานได้ทันทีด้วยคำสั่ง:
```cmd
scripts\quick-start.bat
```
