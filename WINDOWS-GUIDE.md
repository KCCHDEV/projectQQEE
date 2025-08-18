# Windows Guide - คู่มือสำหรับ Windows

คู่มือการใช้งาน Pet Food E-commerce Platform บน Windows พร้อมระบบจัดการธีมขั้นสูง

## 🎯 ความต้องการระบบ

### สำหรับ Windows 10/11:
- **Docker Desktop for Windows** (ล่าสุด)
- **PowerShell 5.1+** หรือ **Windows Terminal**
- **4GB+ RAM** ว่าง
- **10GB+ พื้นที่ hard disk** ว่าง
- **Port 8000, 8080, 8025** ว่าง

## 🚀 การติดตั้งเริ่มต้น

### 1. ติดตั้ง Docker Desktop

```powershell
# ดาวน์โหลดและติดตั้ง Docker Desktop
# https://docs.docker.com/desktop/windows/

# หรือใช้ Chocolatey
choco install docker-desktop

# หรือใช้ winget
winget install Docker.DockerDesktop
```

### 2. Export จากเครื่องต้นทาง

#### วิธี Command Prompt:
```cmd
# Export แบบ Batch
docker-export.bat

# หรือระบุ options
docker-export.bat --skip-database --no-compress
```

#### วิธี PowerShell (แนะนำ):
```powershell
# Export แบบ PowerShell
.\docker-export.ps1

# หรือระบุ parameters
.\docker-export.ps1 -SkipDatabase -Compress:$false -OutputDir "my-export"
```

### 3. Import ไปเครื่องใหม่

#### วิธี Command Prompt:
```cmd
cd docker-export
docker-import.bat
```

#### วิธี PowerShell (แนะนำ):
```powershell
cd docker-export
.\docker-import.ps1

# หรือระบุ parameters
.\docker-import.ps1 -SkipDatabase -Port 9000 -Force
```

## 🎨 ระบบจัดการธีม (Theme Management)

### การใช้งานผ่าน Command Line

#### Windows Command Prompt:
```cmd
# ดูรายการธีมทั้งหมด
scripts\theme-manager.bat list

# เปิดใช้งานธีม
scripts\theme-manager.bat activate petpaws

# สำรองข้อมูลธีม
scripts\theme-manager.bat backup petpaws

# ติดตั้งธีมจากไฟล์
scripts\theme-manager.bat install C:\path\to\theme.zip

# ติดตั้งธีมจาก URL
scripts\theme-manager.bat install-url https://example.com/theme.zip

# ดู gallery ธีม
scripts\theme-manager.bat gallery

# ติดตั้งธีมจาก gallery
scripts\theme-manager.bat install-gallery 1
```

#### PowerShell:
```powershell
# ใช้งานเหมือน Command Prompt แต่รันใน PowerShell
.\scripts\theme-manager.bat list
```

### การใช้งานผ่าน Web Interface

1. เข้า WordPress Admin: `http://localhost:8000/wp-admin`
2. ไปที่ **Appearance > Theme Manager**
3. ใช้งาน interface ที่สวยงาม:
   - **Upload Theme**: อัปโหลดธีมใหม่
   - **Theme Gallery**: เลือกธีมจาก gallery
   - **Backup & Restore**: จัดการ backup ธีม
   - **Theme Customizer**: ปรับแต่งธีม

## 📁 โครงสร้างไฟล์

```
pet-food-ecommerce/
├── docker-export.bat           # Export script (Windows)
├── docker-export.ps1           # Export script (PowerShell)
├── docker-import.bat           # Import script (Windows)
├── docker-import.ps1           # Import script (PowerShell)
├── scripts/
│   ├── theme-manager.bat       # Theme management (Windows)
│   └── theme-manager.sh        # Theme management (Linux/Mac)
├── theme-manager.php           # WordPress theme manager
├── theme-manager.js            # Frontend JavaScript
├── docker-export/              # Export package folder
│   ├── pet-food-store_*.tar.zip
│   ├── database_*.sql
│   ├── docker-compose.yml
│   ├── docker-import.bat
│   ├── docker-import.ps1
│   └── README.txt
└── backups/
    └── themes/                 # Theme backups
```

## 🛠️ การแก้ไขปัญหาใน Windows

### ปัญหา Docker Desktop

```powershell
# ตรวจสอบสถานะ Docker
docker --version
docker info

# Restart Docker Desktop
Restart-Service docker
# หรือ restart จาก system tray

# ตรวจสอบ WSL2 (ถ้าใช้)
wsl --list --verbose
wsl --update
```

### ปัญหา PowerShell Execution Policy

```powershell
# อนุญาต script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# หรือ bypass สำหรับ script เดียว
PowerShell -ExecutionPolicy Bypass -File .\docker-export.ps1
```

### ปัญหา Port ถูกใช้งาน

```cmd
# ตรวจสอบ port ที่ใช้งาน
netstat -ano | findstr :8000
netstat -ano | findstr :8080

# หยุดบริการที่ใช้ port (ถ้าจำเป็น)
taskkill /PID <PID_NUMBER> /F
```

### ปัญหา Path และ File Name

```powershell
# ใช้ path แบบ full path
.\docker-export.ps1 -OutputDir "C:\Users\Username\Desktop\my-export"

# หลีกเลี่ยงการใช้ space ในชื่อ folder
# ใช้ "C:\my-export" แทน "C:\My Export Folder"
```

## 🎯 การปรับแต่งสำหรับ Windows

### การเปลี่ยน Port

แก้ไขไฟล์ `docker-compose.yml`:
```yaml
ports:
  - "9000:80"  # เปลี่ยนจาก 8000 เป็น 9000
```

### การตั้งค่า Memory Limit

```powershell
# ตั้งค่า Docker Desktop memory limit
# Settings > Resources > Advanced > Memory: 4GB+
```

### การใช้งาน Windows Terminal

```json
// เพิ่มใน Windows Terminal settings
{
    "name": "Pet Food Admin",
    "commandline": "powershell.exe -NoExit -Command \"cd 'C:\\path\\to\\pet-food-ecommerce'\"",
    "startingDirectory": "C:\\path\\to\\pet-food-ecommerce"
}
```

## 🔧 คำสั่งที่มีประโยชน์

### การจัดการ Container

```cmd
# ดูสถานะ containers
docker-compose ps

# ดู logs
docker-compose logs -f

# เข้า container
docker exec -it pet-food-store_wordpress bash

# Restart containers
docker-compose restart

# หยุดและเริ่มใหม่
docker-compose down && docker-compose up -d
```

### การ Backup และ Restore

```cmd
# Backup ทั้งระบบ
scripts\backup.bat

# Backup เฉพาะธีม
scripts\theme-manager.bat backup-all

# Restore database
scripts\restore.bat database_backup.sql
```

## 📋 Checklist สำหรับ Windows

### ก่อนเริ่มใช้งาน:
- [ ] ติดตั้ง Docker Desktop
- [ ] ตั้งค่า WSL2 (ถ้าจำเป็น)
- [ ] ตรวจสอบ port ว่าง (8000, 8080, 8025)
- [ ] ตั้งค่า PowerShell execution policy
- [ ] ทดสอบ docker command

### หลังติดตั้ง:
- [ ] ทดสอบเข้าเว็บไซต์ http://localhost:8000
- [ ] ทดสอบ admin panel http://localhost:8000/wp-admin
- [ ] ทดสอบระบบจัดการธีม
- [ ] ทำ backup ครั้งแรก
- [ ] ตั้งค่า auto-backup (ถ้าต้องการ)

## 🎉 ข้อดีของเวอร์ชัน Windows

1. **รองรับทั้ง Command Prompt และ PowerShell**
2. **GUI ที่ใช้งานง่าย** ผ่าน Docker Desktop
3. **Integration กับ Windows Terminal**
4. **ระบบจัดการธีมขั้นสูง** ผ่าน web interface
5. **Auto-backup และ restore** ที่สะดวก
6. **Gallery ธีม** สำหรับร้านสัตว์เลี้ยงโดยเฉพาะ

---

**หมายเหตุ**: คู่มือนี้เหมาะสำหรับ Windows 10/11 ที่มี Docker Desktop ติดตั้งแล้ว