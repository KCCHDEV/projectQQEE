@echo off
chcp 65001
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════╗
echo ║       🏪 ร้านอาหารสัตว์เลี้ยง - Windows Launcher 🐾    ║
echo ║         Pet Food Store - Windows Launcher             ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

REM Check if .env exists
if not exist .env (
    echo ⚠️  ไม่พบไฟล์ .env
    echo 📝 กำลังสร้างไฟล์ .env...
    echo APP_NAME=pet-food-store > .env
    echo WORDPRESS_PORT=8000 >> .env
    echo PHPMYADMIN_PORT=8080 >> .env
    echo MAILHOG_WEB_PORT=8025 >> .env
    echo DB_ROOT_PASSWORD=rootpassword >> .env
    echo DB_NAME=wordpress >> .env
    echo DB_USER=wordpress >> .env
    echo DB_PASSWORD=wordpress >> .env
    echo APP_URL=http://localhost:8000 >> .env
    echo ✅ สร้างไฟล์ .env เรียบร้อย
    echo.
)

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker ไม่ได้ติดตั้ง!
    echo.
    echo 📥 ดาวน์โหลด Docker Desktop:
    echo    https://docs.docker.com/desktop/install/windows/
    echo.
    echo ⚠️  กรุณาติดตั้ง Docker Desktop และรีสตาร์ทเครื่อง
    pause
    exit /b 1
)

echo ✅ Docker พร้อมใช้งาน
echo.

:main_menu
echo 🚀 เลือกการดำเนินการ:
echo.
echo 🔧 การจัดการระบบ:
echo    1) ตรวจสอบความพร้อมของระบบ
echo    2) เริ่มต้นระบบ WordPress/WooCommerce
echo    3) หยุดระบบ
echo    4) รีสตาร์ทระบบ
echo.
echo 💾 การสำรองข้อมูล:
echo    5) สำรองข้อมูล
echo    6) คืนค่าข้อมูล
echo.
echo 🛒 จัดการ WooCommerce:
echo    7) แผงควบคุมระบบ
echo    8) อัปโหลดข้อมูลตัวอย่าง
echo.
echo 🌐 ตั้งค่าภาษา:
echo    9) ติดตั้งภาษาไทย
echo.
echo 🎨 การพัฒนา:
echo    10) ระบบการพัฒนาภายนอก
echo    11) ซิงค์ไฟล์อัตโนมัติ
echo.
echo 🚀 การ Deploy:
echo    12) ย้ายระบบ (Migration)
echo    13) Deploy เฉพาะโค้ด
echo.
echo 🚀 การติดตั้งอัตโนมัติ:
echo    14) ติดตั้งระบบทั้งหมดอัตโนมัติ
echo    15) ติดตั้งระบบครบวงจร (Complete Setup) - ใหม่!
echo    16) ติดตั้งระบบแบบง่าย (Simple Setup) - เร็วที่สุด!
echo    17) ตั้งค่าเพิ่มเติมหลังการติดตั้ง
echo    18) ดำเนินการติดตั้งต่อ (Continue Installation)
echo    19) ติดตั้ง WP-CLI
echo    20) ทดสอบระบบหลังการติดตั้ง
echo    21) แก้ไขปัญหา Container Name
echo    22) แก้ไขปัญหา Theme Error
echo.
echo 📊 ข้อมูลระบบ:
echo    23) ดูสถานะ Containers
echo    24) ดู Logs
echo.
echo ❌ ออกจากระบบ:
echo    0) ออกจากระบบ
echo.
set /p choice="เลือกตัวเลือก (0-24): "

if "%choice%"=="0" (
    echo 👋 ขอบคุณที่ใช้งาน!
    pause
    exit /b 0
) else if "%choice%"=="1" (
    echo.
    echo 🔍 ตรวจสอบความพร้อมของระบบ...
    call scripts\system-check.bat
) else if "%choice%"=="2" (
    echo.
    echo 🚀 เริ่มต้นระบบ WordPress/WooCommerce...
    call scripts\quick-start.bat
) else if "%choice%"=="3" (
    echo.
    echo 🛑 หยุดระบบ...
    docker-compose down
    echo ✅ หยุดระบบเรียบร้อย
    pause
) else if "%choice%"=="4" (
    echo.
    echo 🔄 รีสตาร์ทระบบ...
    docker-compose restart
    echo ✅ รีสตาร์ทระบบเรียบร้อย
    pause
) else if "%choice%"=="5" (
    echo.
    echo 📦 สำรองข้อมูล...
    call scripts\backup.bat
) else if "%choice%"=="6" (
    echo.
    echo 📥 คืนค่าข้อมูล...
    echo รายการสำรองข้อมูล:
    if exist backups\*.info (
        for %%f in (backups\*.info) do (
            set "filename=%%~nf"
            echo !filename:backup_=!
        )
    ) else (
        echo ไม่พบข้อมูลสำรอง
        pause
        goto :main_menu
    )
    set /p timestamp="ใส่ timestamp ที่ต้องการคืนค่า: "
    call scripts\restore.bat "%timestamp%"
) else if "%choice%"=="7" (
    echo.
    echo 🏪 เปิดแผงควบคุมระบบ...
    call scripts\admin-panel.bat
) else if "%choice%"=="8" (
    echo.
    echo 📦 อัปโหลดข้อมูลตัวอย่าง...
    call scripts\upload-demo-data.bat
) else if "%choice%"=="9" (
    echo.
    echo 🇹🇭 ติดตั้งภาษาไทย...
    call scripts\setup-thai.bat
) else if "%choice%"=="10" (
    echo.
    echo 🎨 ระบบการพัฒนาภายนอก...
    echo.
    echo คำสั่งที่มีประโยชน์:
    echo   scripts\dev-workflow.bat init     - สร้าง workspace
    echo   scripts\dev-workflow.bat sync     - ซิงค์ไฟล์
    echo   scripts\dev-workflow.bat deploy   - Deploy
    echo   scripts\dev-workflow.bat status   - ดูสถานะ
    echo.
    set /p dev_command="ใส่คำสั่ง (หรือ Enter เพื่อดูสถานะ): "
    if not "%dev_command%"=="" (
        call scripts\dev-workflow.bat %dev_command%
    ) else (
        call scripts\dev-workflow.bat status
    )
) else if "%choice%"=="11" (
    echo.
    echo 🔄 เริ่มซิงค์ไฟล์อัตโนมัติ...
    echo ⚠️  กด Ctrl+C เพื่อหยุด
    call scripts\auto-sync-wp-content.bat
) else if "%choice%"=="12" (
    echo.
    echo 🚀 ระบบย้ายโฮสต์...
    call scripts\migrate.bat
       ) else if "%choice%"=="13" (
           echo.
           echo 📦 Deploy เฉพาะโค้ด...
           echo.
           echo คำสั่งที่มีประโยชน์:
           echo   scripts\deploy-no-uploads.bat package  - สร้าง package
           echo   scripts\deploy-no-uploads.bat apply    - Deploy
           echo   scripts\deploy-no-uploads.bat status   - ดูสถานะ
           echo.
           set /p deploy_command="ใส่คำสั่ง (หรือ Enter เพื่อดูสถานะ): "
           if not "%deploy_command%"=="" (
               call scripts\deploy-no-uploads.bat %deploy_command%
           ) else (
               call scripts\deploy-no-uploads.bat status
           )
       ) else if "%choice%"=="14" (
           echo.
           echo 🚀 เริ่มต้นการติดตั้งระบบทั้งหมดอัตโนมัติ...
           echo ⚠️  กระบวนการนี้จะใช้เวลาประมาณ 5-10 นาที
           echo.
           set /p confirm="ยืนยันการติดตั้ง? (y/N): "
           if /i "%confirm%"=="y" (
               call scripts\auto-install-everything.bat
           ) else (
               echo ❌ ยกเลิกการติดตั้ง
               pause
           )
               ) else if "%choice%"=="15" (
            echo.
            echo 🚀 เริ่มต้นการติดตั้งระบบครบวงจร...
            echo ⚠️  กระบวนการนี้จะใช้เวลาประมาณ 10-15 นาที
            echo.
            set /p confirm="ยืนยันการติดตั้ง? (y/N): "
            if /i "%confirm%"=="y" (
                call scripts\complete-setup.bat
            ) else (
                echo ❌ ยกเลิกการติดตั้ง
                pause
            )
        ) else if "%choice%"=="16" (
            echo.
            echo 🚀 เริ่มต้นการติดตั้งระบบแบบง่าย...
            echo ⚠️  กระบวนการนี้จะใช้เวลาประมาณ 2-3 นาที
            echo.
            set /p confirm="ยืนยันการติดตั้ง? (y/N): "
            if /i "%confirm%"=="y" (
                call scripts\simple-setup.bat
            ) else (
                echo ❌ ยกเลิกการติดตั้ง
                pause
            )
        ) else if "%choice%"=="17" (
            echo.
            echo 🔧 เปิดการตั้งค่าเพิ่มเติมหลังการติดตั้ง...
            call scripts\post-install-setup.bat
        ) else if "%choice%"=="18" (
            echo.
            echo 🔧 ดำเนินการติดตั้งต่อ...
            call scripts\continue-installation.bat
        ) else if "%choice%"=="19" (
            echo.
            echo 🔧 ติดตั้ง WP-CLI...
            call scripts\install-wp-cli.bat
        ) else if "%choice%"=="20" (
            echo.
            echo 🧪 เริ่มต้นการทดสอบระบบ...
            call scripts\test-system.bat
        ) else if "%choice%"=="21" (
            echo.
            echo 🔧 แก้ไขปัญหา Container Name...
            call scripts\fix-container-name.bat
        ) else if "%choice%"=="22" (
            echo.
            echo 🔧 แก้ไขปัญหา Theme Error...
            call scripts\fix-theme-error.bat
        ) else if "%choice%"=="23" (
            echo.
            echo 📊 สถานะ Containers:
            docker-compose ps
            echo.
            echo 📈 การใช้ทรัพยากร:
            docker stats --no-stream
            pause
        ) else if "%choice%"=="24" (
            echo.
            echo 📄 เลือกล็อกที่ต้องการดู:
           echo 1) WordPress logs
           echo 2) Database logs
           echo 3) Redis logs
           echo 4) All logs
           echo.
           set /p log_choice="เลือก (1-4): "
           if "%log_choice%"=="1" (
               docker-compose logs --tail=50 wordpress
           ) else if "%log_choice%"=="2" (
               docker-compose logs --tail=50 db
           ) else if "%log_choice%"=="3" (
               docker-compose logs --tail=50 redis
           ) else if "%log_choice%"=="4" (
               docker-compose logs --tail=50
           )
           pause
) else (
    echo ❌ ตัวเลือกไม่ถูกต้อง กรุณาลองใหม่
    timeout /t 2 /nobreak >nul
)

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║                    🔗 ลิงก์สำคัญ                      ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 🌐 เว็บไซต์: http://localhost:8000
echo 👤 แอดมิน: http://localhost:8000/wp-admin
echo 📊 phpMyAdmin: http://localhost:8080
echo 📧 MailHog: http://localhost:8025
echo.
echo 💡 คำแนะนำ:
echo    - ใช้ตัวเลือก 1 เพื่อตรวจสอบระบบ
echo    - ใช้ตัวเลือก 2 เพื่อเริ่มต้นระบบ
echo    - ใช้ตัวเลือก 7 เพื่อเข้าถึงแผงควบคุม
echo.
echo 📚 คู่มือการใช้งาน: WINDOWS_SCRIPTS_GUIDE.md
echo.

pause
cls
goto :main_menu
