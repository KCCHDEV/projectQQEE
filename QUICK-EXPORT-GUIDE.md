# 🚀 Quick Export Guide - คู่มือเร็ว

## การ Export (5 นาที)

```bash
# 1. เข้าโฟลเดอร์โปรเจค
cd pet-food-ecommerce

# 2. รัน export
./docker-export.sh

# 3. รอให้เสร็จ (3-5 นาที)
# ได้โฟลเดอร์ docker-export/ พร้อม copy ไปเครื่องอื่น
```

## การ Import (3 นาที)

```bash
# 1. Copy โฟลเดอร์ docker-export/ มาเครื่องใหม่

# 2. เข้าโฟลเดอร์และรัน
cd docker-export/
./docker-import.sh

# 3. เข้าใช้งาน
# เว็บไซต์: http://localhost:8000
# Admin: http://localhost:8000/wp-admin (admin/admin123)
```

## ✅ เสร็จแล้ว!

- ✅ WordPress + WooCommerce พร้อมใช้งาน
- ✅ ธีมและปลั๊กอินครบถ้วน  
- ✅ ฐานข้อมูลย้ายมาด้วย
- ✅ ใช้งานได้ทันทีบนเครื่องใหม่

---

**สำหรับรายละเอียดเพิ่มเติม**: อ่าน [DOCKER-EXPORT-GUIDE.md](DOCKER-EXPORT-GUIDE.md)