# Docker Export/Import Guide

คู่มือการ Export และ Import โปรเจค Pet Food E-commerce Platform ให้ใช้งานได้บนเครื่องอื่น

## 🎯 วัตถุประสงค์

คู่มือนี้จะแสดงวิธีการ:
- Export โปรเจคเป็น Docker image ที่สมบูรณ์
- Import และติดตั้งบนเครื่องอื่นได้อย่างง่ายดาย
- ย้ายข้อมูลและการตั้งค่าทั้งหมด

## 🚀 การ Export (เครื่องต้นทาง)

### ขั้นตอนที่ 1: เตรียมโปรเจค

```bash
# ตรวจสอบว่า Docker กำลังทำงาน
docker --version
docker-compose --version

# เข้าไปในโฟลเดอร์โปรเจค
cd /path/to/pet-food-ecommerce
```

### ขั้นตอนที่ 2: รัน Export Script

```bash
# รัน script สำหรับ export
./docker-export.sh
```

Script นี้จะ:
- ✅ สร้าง Docker image ที่มีทุกอย่างครบถ้วน
- ✅ Export image เป็นไฟล์ .tar.gz
- ✅ Backup ฐานข้อมูล (ถ้ามี)
- ✅ รวม configuration files ทั้งหมด
- ✅ สร้าง import script สำหรับเครื่องปลายทาง

### ขั้นตอนที่ 3: ตรวจสอบผลลัพธ์

หลังจาก export เสร็จ จะได้โฟลเดอร์ `docker-export/` ที่มี:

```
docker-export/
├── pet-food-store_latest_20241208_143022.tar.gz  # Docker image
├── database_20241208_143022.sql                  # Database backup
├── docker-compose.yml                            # Configuration
├── docker-import.sh                              # Import script
└── README.txt                                    # คำแนะนำ
```

## 📦 การ Import (เครื่องปลายทาง)

### ขั้นตอนที่ 1: เตรียมเครื่องปลายทาง

```bash
# ติดตั้ง Docker และ Docker Compose
# สำหรับ Ubuntu/Debian:
sudo apt update
sudo apt install docker.io docker-compose

# สำหรับ Windows: ติดตั้ง Docker Desktop
# สำหรับ macOS: ติดตั้ง Docker Desktop
```

### ขั้นตอนที่ 2: Copy ไฟล์

```bash
# Copy โฟลเดอร์ docker-export ทั้งหมดมาที่เครื่องใหม่
scp -r docker-export/ user@target-machine:/home/user/
# หรือใช้ USB, Google Drive, etc.
```

### ขั้นตอนที่ 3: รัน Import Script

```bash
# เข้าไปในโฟลเดอร์ที่ copy มา
cd docker-export/

# รัน import script
chmod +x docker-import.sh
./docker-import.sh
```

### ขั้นตอนที่ 4: เข้าใช้งาน

หลังจาก import เสร็จ สามารถเข้าใช้งานได้ที่:

- 🌐 **เว็บไซต์**: http://localhost:8000
- 👤 **Admin Panel**: http://localhost:8000/wp-admin
- 🗄️ **phpMyAdmin**: http://localhost:8080
- 📧 **MailHog**: http://localhost:8025

**ข้อมูลเข้าใช้งานเริ่มต้น:**
- Username: `admin`
- Password: `admin123`

## 🔧 การจัดการหลัง Import

### คำสั่งที่มีประโยชน์

```bash
# หยุดระบบ
docker-compose down

# เริ่มระบบ
docker-compose up -d

# ดู logs
docker-compose logs -f

# Restart บริการ
docker-compose restart

# ดูสถานะ containers
docker-compose ps
```

### การเปลี่ยน URL

หากต้องการเปลี่ยน URL จาก localhost:

1. แก้ไขไฟล์ `docker-compose.yml`:
```yaml
environment:
  WORDPRESS_URL: http://your-domain.com
```

2. Restart containers:
```bash
docker-compose down
docker-compose up -d
```

## 🛠️ การแก้ไขปัญหา

### ปัญหาที่อาจพบ

#### 1. Port ถูกใช้งานแล้ว
```bash
# ตรวจสอบ port ที่ใช้งาน
netstat -tulpn | grep :8000

# หยุดบริการที่ใช้ port ซ้ำ หรือเปลี่ยน port ใน docker-compose.yml
```

#### 2. Docker image ไม่โหลด
```bash
# โหลด image แบบ manual
docker load -i pet-food-store_latest_*.tar.gz

# หรือ
gunzip -c pet-food-store_latest_*.tar.gz | docker load
```

#### 3. Database ไม่เข้า
```bash
# Import database แบบ manual
docker exec -i pet-food-store_db mysql -u wordpress -ppetshop123 wordpress < database_*.sql
```

#### 4. Permission ปัญหา
```bash
# แก้ไข permission
sudo chown -R $USER:$USER ./
chmod -R 755 ./
```

## 📋 Checklist สำหรับการ Export/Import

### ก่อน Export:
- [ ] ตรวจสอบว่าโปรเจคทำงานปกติ
- [ ] Backup ข้อมูลสำคัญ
- [ ] ทดสอบ export script

### ก่อน Import:
- [ ] ติดตั้ง Docker และ Docker Compose
- [ ] ตรวจสอบ port ที่จะใช้งาน (8000, 8080, 8025)
- [ ] เตรียมพื้นที่เก็บข้อมูล

### หลัง Import:
- [ ] ทดสอบเข้าใช้งานเว็บไซต์
- [ ] ทดสอบ admin panel
- [ ] ตรวจสอบข้อมูลใน database
- [ ] ทดสอบการส่งอีเมล

## 🎉 ข้อดีของวิธีนี้

1. **ครบถ้วน**: รวมทุกอย่างในไฟล์เดียว
2. **ง่ายต่อการใช้งาน**: รันแค่ script เดียว
3. **เสถียร**: ใช้ Docker ที่เสถียร
4. **ปลอดภัย**: มี backup ข้อมูล
5. **ใช้ซ้ำได้**: Export ครั้งเดียว ใช้หลายเครื่อง

## 🔄 การอัปเดตโปรเจค

หากมีการแก้ไขโปรเจค:

1. แก้ไขในเครื่องต้นทาง
2. รัน `./docker-export.sh` ใหม่
3. Copy ไฟล์ export ใหม่ไปเครื่องปลายทาง
4. รัน `./docker-import.sh` ใหม่

---

**หมายเหตุ**: คู่มือนี้เหมาะสำหรับการใช้งานใน environment ต่างๆ รวมถึง development, staging, และ production