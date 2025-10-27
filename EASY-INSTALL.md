# 🐾 ร้านสัตว์เลี้ยง - ติดตั้งง่าย 5 นาที

## 🎯 เทมเพลตร้านขายอุปกรณ์และอาหารสัตว์เลี้ยง
- ✅ **ลงง่ายที่สุด** - คลิกเดียวเสร็จ
- ✅ **ใช้งานได้ทันที** - มีสินค้าตัวอย่าง
- ✅ **สวยงาม** - ดีไซน์ทันสมัย
- ✅ **รองรับมือถือ** - Responsive Design
- ✅ **WooCommerce พร้อมใช้** - ระบบขายของครบ

## 🚀 ติดตั้งแบบเร็ว (5 นาที)

### สำหรับ Windows:
```cmd
1. ดาวน์โหลดโปรเจค
2. เปิด Command Prompt
3. รันคำสั่ง: quick-start.bat
4. เข้าใช้งาน: http://localhost:8000
```

### สำหรับ Mac/Linux:
```bash
1. ดาวน์โหลดโปรเจค
2. เปิด Terminal
3. รันคำสั่ง: ./quick-start.sh
4. เข้าใช้งาน: http://localhost:8000
```

## 📱 ลิงก์เข้าใช้งาน

| บริการ | URL | รายละเอียด |
|--------|-----|-----------|
| 🌐 **เว็บไซต์** | http://localhost:8000 | หน้าร้านค้า |
| 👤 **Admin** | http://localhost:8000/wp-admin | จัดการร้านค้า |
| 🗄️ **phpMyAdmin** | http://localhost:8080 | จัดการฐานข้อมูล |

## 🔑 ข้อมูลเข้าใช้งาน

**WordPress Admin:**
- Username: `admin`
- Password: `admin`

**Database:**
- Host: `localhost:3306`
- Username: `wordpress`
- Password: `wordpress123`

## 🎨 ฟีเจอร์ที่ได้

### ✨ หน้าร้านค้า:
- หน้าแรกสวยงาม
- แสดงหมวดหมู่สินค้า
- สินค้าแนะนำ
- ระบบค้นหา
- ตะกร้าสินค้า

### 🛠️ ระบบจัดการ:
- เพิ่ม/แก้ไข/ลบ สินค้า
- จัดการหมวดหมู่
- ระบบคำสั่งซื้อ
- ระบบลูกค้า
- รายงานยอดขาย

### 📦 สินค้าตัวอย่าง:
- อาหารสุนัข/แมว
- ของเล่นสัตว์เลี้ยง
- อุปกรณ์ดูแล
- บ้านและที่นอน

## 🛠️ การปรับแต่ง

### เปลี่ยนชื่อร้าน:
1. เข้า Admin → Settings → General
2. แก้ไข "Site Title"

### เพิ่มสินค้า:
1. เข้า Admin → Products → Add New
2. ใส่รายละเอียดสินค้า
3. กำหนดราคา
4. เผยแพร่

### เปลี่ยนธีม:
1. เข้า Admin → Appearance → Themes
2. เลือกธีมที่ต้องการ
3. กดปุ่ม Activate

## 🔧 คำสั่งที่มีประโยชน์

```bash
# หยุดระบบ
docker-compose -f simple-docker-compose.yml down

# เริ่มระบบ
docker-compose -f simple-docker-compose.yml up -d

# ดู logs
docker-compose -f simple-docker-compose.yml logs -f

# เข้า WordPress container
docker exec -it petstore_web bash
```

## 🆘 แก้ปัญหา

### ปัญหา: เข้าเว็บไม่ได้
```
✅ ตรวจสอบ Docker ทำงานหรือไม่
✅ ตรวจสอบ port 8000 ว่าง
✅ รอ 1-2 นาทีให้ระบบพร้อม
```

### ปัญหา: ลืมรหัส Admin
```
1. เข้า phpMyAdmin: http://localhost:8080
2. เลือกฐานข้อมูล wordpress
3. ไปตาราง wp_users
4. แก้ไขรหัสผ่านใหม่
```

### ปัญหา: สินค้าไม่แสดง
```
1. เข้า Admin → WooCommerce → Status
2. ตรวจสอบการตั้งค่า
3. หรือนำเข้าข้อมูลตัวอย่าง: sample-products.sql
```

## 📂 โครงสร้างไฟล์

```
pet-store/
├── simple-pet-store/          # ธีมร้านสัตว์เลี้ยง
├── simple-docker-compose.yml  # Docker configuration
├── quick-start.bat            # Windows installer
├── quick-start.sh             # Mac/Linux installer  
├── sample-products.sql        # ข้อมูลสินค้าตัวอย่าง
└── EASY-INSTALL.md           # คู่มือนี้
```

## 🎉 พร้อมใช้งานแล้ว!

หลังจากติดตั้งเสร็จ คุณจะได้:
- ✅ ร้านออนไลน์พร้อมใช้งาน
- ✅ ระบบขายของครบถ้วน  
- ✅ หน้าตาสวยงาม
- ✅ รองรับมือถือ
- ✅ ข้อมูลตัวอย่าง

**เริ่มขายของได้เลย!** 🛍️

---

💡 **เคล็ดลับ**: หากต้องการปรับแต่งเพิ่มเติม สามารถแก้ไขไฟล์ในโฟลเดอร์ `simple-pet-store/` ได้เลย