<?php
/**
 * Admin Dashboard for Pet Food Store
 * แดชบอร์ดสำหรับจัดการร้านอาหารสัตว์เลี้ยง
 */

// Load environment variables
$env_file = __DIR__ . '/../.env';
if (file_exists($env_file)) {
    $env = parse_ini_file($env_file);
    foreach ($env as $key => $value) {
        putenv("$key=$value");
    }
}

$app_name = getenv('APP_NAME') ?: 'pet-food-store';
$app_url = getenv('APP_URL') ?: 'http://localhost:8000';

// Handle actions
$message = '';
$message_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    switch ($action) {
        case 'start':
            exec('cd .. && docker-compose up -d 2>&1', $output, $return_var);
            $message = $return_var === 0 ? 'ระบบเริ่มทำงานเรียบร้อย!' : 'เกิดข้อผิดพลาด: ' . implode("\n", $output);
            $message_type = $return_var === 0 ? 'success' : 'error';
            break;
            
        case 'stop':
            exec('cd .. && docker-compose down 2>&1', $output, $return_var);
            $message = $return_var === 0 ? 'หยุดระบบเรียบร้อย!' : 'เกิดข้อผิดพลาด: ' . implode("\n", $output);
            $message_type = $return_var === 0 ? 'success' : 'error';
            break;
            
        case 'backup':
            exec('cd .. && ./scripts/backup.sh 2>&1', $output, $return_var);
            $message = $return_var === 0 ? 'สำรองข้อมูลเรียบร้อย!' : 'เกิดข้อผิดพลาด: ' . implode("\n", $output);
            $message_type = $return_var === 0 ? 'success' : 'error';
            break;
            
        case 'clear_cache':
            exec("docker exec {$app_name}_wordpress wp cache flush --allow-root 2>&1", $output1);
            exec("docker exec {$app_name}_redis redis-cli FLUSHALL 2>&1", $output2);
            $message = 'ล้างแคชเรียบร้อย!';
            $message_type = 'success';
            break;
            
        case 'install_thai':
            exec('cd .. && ./scripts/setup-thai.sh 2>&1', $output, $return_var);
            $message = $return_var === 0 ? 'ติดตั้งภาษาไทยเรียบร้อย!' : 'เกิดข้อผิดพลาด: ' . implode("\n", $output);
            $message_type = $return_var === 0 ? 'success' : 'error';
            break;
    }
}

// Get system status
$status = [];
exec('docker-compose ps --format json 2>/dev/null', $output);
if (!empty($output)) {
    foreach ($output as $line) {
        $container = json_decode($line, true);
        if ($container) {
            $status[] = $container;
        }
    }
}

// Get backup list
$backups = [];
$backup_dir = __DIR__ . '/../backups';
if (is_dir($backup_dir)) {
    $files = glob($backup_dir . '/backup_*.info');
    foreach ($files as $file) {
        $timestamp = str_replace(['backup_', '.info'], '', basename($file));
        $info = file_get_contents($file);
        preg_match('/Date: (.+)/', $info, $matches);
        $date = $matches[1] ?? '';
        $backups[] = ['timestamp' => $timestamp, 'date' => $date];
    }
    rsort($backups);
}
?>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pet Paws Admin - ระบบจัดการร้านอาหารสัตว์เลี้ยง</title>
    <link href="https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&family=Prompt:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root {
            --primary: #FF6B6B;
            --primary-dark: #FA5252;
            --secondary: #4ECDC4;
            --accent: #FFE66D;
            --dark: #2D3436;
            --light: #DFE6E9;
            --white: #FFFFFF;
            --success: #00B894;
            --warning: #FDCB6E;
            --danger: #D63031;
            --info: #74B9FF;
            --gradient-1: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --gradient-2: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            --gradient-3: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            --gradient-4: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.08);
            --shadow-md: 0 4px 8px rgba(0,0,0,0.12);
            --shadow-lg: 0 8px 16px rgba(0,0,0,0.16);
            --shadow-xl: 0 12px 24px rgba(0,0,0,0.2);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Prompt', 'Kanit', sans-serif;
            background: #f8f9fa;
            color: var(--dark);
            line-height: 1.6;
            min-height: 100vh;
            background-image: 
                radial-gradient(circle at 20% 80%, rgba(255, 107, 107, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(78, 205, 196, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(255, 230, 109, 0.03) 0%, transparent 50%);
        }
        
        /* Sidebar */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            width: 280px;
            height: 100vh;
            background: var(--white);
            box-shadow: var(--shadow-lg);
            z-index: 1000;
            overflow-y: auto;
            transition: transform 0.3s ease;
        }
        
        .sidebar-header {
            background: var(--gradient-1);
            padding: 2rem;
            text-align: center;
            color: white;
        }
        
        .logo {
            width: 80px;
            height: 80px;
            background: white;
            border-radius: 50%;
            margin: 0 auto 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            box-shadow: var(--shadow-lg);
        }
        
        .sidebar h1 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        
        .sidebar-menu {
            padding: 1.5rem 0;
        }
        
        .menu-section {
            margin-bottom: 2rem;
        }
        
        .menu-title {
            font-size: 0.75rem;
            font-weight: 600;
            color: #999;
            text-transform: uppercase;
            padding: 0 2rem;
            margin-bottom: 0.5rem;
            letter-spacing: 1px;
        }
        
        .menu-item {
            display: block;
            padding: 0.875rem 2rem;
            color: var(--dark);
            text-decoration: none;
            transition: all 0.3s ease;
            position: relative;
            font-weight: 500;
        }
        
        .menu-item:hover {
            background: rgba(102, 126, 234, 0.1);
            color: var(--primary);
            padding-left: 2.5rem;
        }
        
        .menu-item i {
            width: 20px;
            margin-right: 1rem;
            font-size: 1.1rem;
        }
        
        .menu-item.active {
            background: rgba(102, 126, 234, 0.1);
            color: #667eea;
            border-right: 3px solid #667eea;
        }
        
        /* Main Content */
        .main-content {
            margin-left: 280px;
            min-height: 100vh;
            transition: margin-left 0.3s ease;
        }
        
        /* Top Bar */
        .topbar {
            background: white;
            padding: 1.5rem 2rem;
            box-shadow: var(--shadow-sm);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        
        .topbar-left {
            display: flex;
            align-items: center;
            gap: 2rem;
        }
        
        .menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--dark);
        }
        
        .search-box {
            position: relative;
        }
        
        .search-box input {
            padding: 0.75rem 1rem 0.75rem 3rem;
            border: 2px solid #e9ecef;
            border-radius: 50px;
            width: 300px;
            font-size: 0.875rem;
            transition: all 0.3s ease;
            font-family: inherit;
        }
        
        .search-box input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.1);
        }
        
        .search-box i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
        }
        
        .topbar-right {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }
        
        .notification-btn {
            position: relative;
            background: none;
            border: none;
            font-size: 1.25rem;
            cursor: pointer;
            color: #666;
            transition: color 0.3s ease;
        }
        
        .notification-btn:hover {
            color: var(--primary);
        }
        
        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: var(--danger);
            color: white;
            font-size: 0.625rem;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
        }
        
        .user-menu {
            display: flex;
            align-items: center;
            gap: 1rem;
            cursor: pointer;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            transition: background 0.3s ease;
        }
        
        .user-menu:hover {
            background: #f8f9fa;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--gradient-2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
        }
        
        /* Content Area */
        .content {
            padding: 2rem;
        }
        
        .page-header {
            margin-bottom: 2rem;
        }
        
        .page-title {
            font-size: 2rem;
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 0.5rem;
        }
        
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #666;
            font-size: 0.875rem;
        }
        
        .breadcrumb a {
            color: #666;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .breadcrumb a:hover {
            color: var(--primary);
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: var(--shadow-sm);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-xl);
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 100px;
            height: 100px;
            background: var(--gradient-1);
            opacity: 0.1;
            border-radius: 50%;
            transform: translate(30px, -30px);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }
        
        .stat-icon.primary {
            background: rgba(255, 107, 107, 0.1);
            color: var(--primary);
        }
        
        .stat-icon.success {
            background: rgba(0, 184, 148, 0.1);
            color: var(--success);
        }
        
        .stat-icon.warning {
            background: rgba(253, 203, 110, 0.1);
            color: var(--warning);
        }
        
        .stat-icon.info {
            background: rgba(116, 185, 255, 0.1);
            color: var(--info);
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 0.25rem;
        }
        
        .stat-label {
            color: #666;
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        .stat-change {
            position: absolute;
            top: 1.5rem;
            right: 1.5rem;
            font-size: 0.75rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        .stat-change.positive {
            color: var(--success);
        }
        
        .stat-change.negative {
            color: var(--danger);
        }
        
        /* Cards */
        .card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: var(--shadow-sm);
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .card:hover {
            box-shadow: var(--shadow-md);
        }
        
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .card-title i {
            font-size: 1.5rem;
            opacity: 0.8;
        }
        
        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 12px;
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            font-family: inherit;
            position: relative;
            overflow: hidden;
        }
        
        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.2);
            transition: left 0.3s ease;
        }
        
        .btn:hover::before {
            left: 100%;
        }
        
        .btn-primary {
            background: var(--primary);
            color: white;
        }
        
        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3);
        }
        
        .btn-success {
            background: var(--success);
            color: white;
        }
        
        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 184, 148, 0.3);
        }
        
        .btn-danger {
            background: var(--danger);
            color: white;
        }
        
        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(214, 48, 49, 0.3);
        }
        
        .btn-warning {
            background: var(--warning);
            color: var(--dark);
        }
        
        .btn-warning:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(253, 203, 110, 0.3);
        }
        
        .btn-info {
            background: var(--info);
            color: white;
        }
        
        .btn-info:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(116, 185, 255, 0.3);
        }
        
        .btn-outline {
            background: transparent;
            border: 2px solid var(--primary);
            color: var(--primary);
        }
        
        .btn-outline:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3);
        }
        
        .btn-group {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }
        
        /* Status Pills */
        .status {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-online {
            background: rgba(0, 184, 148, 0.1);
            color: var(--success);
        }
        
        .status-offline {
            background: rgba(214, 48, 49, 0.1);
            color: var(--danger);
        }
        
        .status-warning {
            background: rgba(253, 203, 110, 0.1);
            color: var(--warning);
        }
        
        /* System Status Grid */
        .system-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .system-item {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.25rem;
            text-align: center;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .system-item.online {
            border-color: var(--success);
            background: rgba(0, 184, 148, 0.05);
        }
        
        .system-item.offline {
            border-color: var(--danger);
            background: rgba(214, 48, 49, 0.05);
        }
        
        .system-item-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .system-item-name {
            font-weight: 600;
            margin-bottom: 0.25rem;
        }
        
        .system-item-status {
            font-size: 0.875rem;
            color: #666;
        }
        
        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
        }
        
        .action-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 16px;
            padding: 1.5rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            position: relative;
            overflow: hidden;
        }
        
        .action-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: rgba(255, 255, 255, 0.1);
            transform: rotate(45deg);
            transition: all 0.5s ease;
            opacity: 0;
        }
        
        .action-card:hover::before {
            opacity: 1;
        }
        
        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        
        .action-card.success {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        
        .action-card.warning {
            background: linear-gradient(135deg, #f2994a 0%, #f2c94c 100%);
        }
        
        .action-card.danger {
            background: linear-gradient(135deg, #eb3349 0%, #f45c43 100%);
        }
        
        .action-card.info {
            background: linear-gradient(135deg, #2196f3 0%, #21cbf3 100%);
        }
        
        .action-icon {
            font-size: 2.5rem;
            margin-bottom: 0.75rem;
        }
        
        .action-label {
            font-weight: 600;
            font-size: 0.875rem;
        }
        
        /* Backup List */
        .backup-list {
            max-height: 300px;
            overflow-y: auto;
            padding-right: 0.5rem;
        }
        
        .backup-list::-webkit-scrollbar {
            width: 6px;
        }
        
        .backup-list::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }
        
        .backup-list::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 10px;
        }
        
        .backup-list::-webkit-scrollbar-thumb:hover {
            background: #a1a1a1;
        }
        
        .backup-item {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 0.75rem;
            display: flex;
            justify-content: between;
            align-items: center;
            transition: all 0.3s ease;
        }
        
        .backup-item:hover {
            background: #e9ecef;
            transform: translateX(5px);
        }
        
        .backup-info {
            flex: 1;
        }
        
        .backup-date {
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 0.25rem;
        }
        
        .backup-time {
            font-size: 0.75rem;
            color: #666;
        }
        
        .backup-actions {
            display: flex;
            gap: 0.5rem;
        }
        
        .backup-btn {
            padding: 0.5rem;
            background: none;
            border: none;
            color: #666;
            cursor: pointer;
            transition: all 0.3s ease;
            border-radius: 8px;
        }
        
        .backup-btn:hover {
            background: var(--primary);
            color: white;
        }
        
        /* Links Grid */
        .links-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
        }
        
        .link-card {
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 16px;
            padding: 1.5rem;
            text-align: center;
            text-decoration: none;
            color: var(--dark);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .link-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: var(--gradient-1);
            transform: translateX(-100%);
            transition: transform 0.3s ease;
        }
        
        .link-card:hover::before {
            transform: translateX(0);
        }
        
        .link-card:hover {
            border-color: var(--primary);
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        
        .link-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto 1rem;
            background: var(--gradient-1);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.75rem;
            color: white;
        }
        
        .link-card:nth-child(2) .link-icon {
            background: var(--gradient-2);
        }
        
        .link-card:nth-child(3) .link-icon {
            background: var(--gradient-3);
        }
        
        .link-card:nth-child(4) .link-icon {
            background: var(--gradient-4);
        }
        
        .link-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        
        .link-desc {
            font-size: 0.875rem;
            color: #666;
        }
        
        /* Message Alert */
        .message {
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 1rem;
            animation: slideIn 0.3s ease;
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(-20px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        .message i {
            font-size: 1.25rem;
        }
        
        .message.success {
            background: rgba(0, 184, 148, 0.1);
            color: var(--success);
            border-left: 4px solid var(--success);
        }
        
        .message.error {
            background: rgba(214, 48, 49, 0.1);
            color: var(--danger);
            border-left: 4px solid var(--danger);
        }
        
        /* Responsive */
        @media (max-width: 1024px) {
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.active {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
            }
            
            .menu-toggle {
                display: block;
            }
            
            .search-box input {
                width: 200px;
            }
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .system-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .quick-actions {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .topbar {
                padding: 1rem;
            }
            
            .content {
                padding: 1rem;
            }
            
            .search-box {
                display: none;
            }
        }
        
        /* Loading Animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        /* Tooltips */
        [data-tooltip] {
            position: relative;
        }
        
        [data-tooltip]:hover::after {
            content: attr(data-tooltip);
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            background: var(--dark);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-size: 0.75rem;
            white-space: nowrap;
            z-index: 1000;
            animation: fadeIn 0.3s ease;
        }
        
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateX(-50%) translateY(5px);
            }
            to {
                opacity: 1;
                transform: translateX(-50%) translateY(0);
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div class="logo">🐾</div>
            <h1>Pet Paws Admin</h1>
            <p style="opacity: 0.9; font-size: 0.875rem;">ระบบจัดการร้านอาหารสัตว์เลี้ยง</p>
        </div>
        
        <nav class="sidebar-menu">
            <div class="menu-section">
                <div class="menu-title">หน้าหลัก</div>
                <a href="#" class="menu-item active">
                    <i class="fas fa-home"></i>
                    <span>แดชบอร์ด</span>
                </a>
                <a href="<?php echo $app_url; ?>" target="_blank" class="menu-item">
                    <i class="fas fa-store"></i>
                    <span>เว็บไซต์หลัก</span>
                </a>
            </div>
            
            <div class="menu-section">
                <div class="menu-title">จัดการระบบ</div>
                <a href="#" class="menu-item" onclick="document.getElementById('start-form').submit(); return false;">
                    <i class="fas fa-play-circle"></i>
                    <span>เริ่มระบบ</span>
                </a>
                <a href="#" class="menu-item" onclick="document.getElementById('stop-form').submit(); return false;">
                    <i class="fas fa-stop-circle"></i>
                    <span>หยุดระบบ</span>
                </a>
                <a href="<?php echo $app_url; ?>/wp-admin" target="_blank" class="menu-item">
                    <i class="fas fa-user-shield"></i>
                    <span>WordPress Admin</span>
                </a>
            </div>
            
            <div class="menu-section">
                <div class="menu-title">เครื่องมือ</div>
                <a href="#" class="menu-item" onclick="document.getElementById('backup-form').submit(); return false;">
                    <i class="fas fa-download"></i>
                    <span>สำรองข้อมูล</span>
                </a>
                <a href="#" class="menu-item" onclick="document.getElementById('cache-form').submit(); return false;">
                    <i class="fas fa-broom"></i>
                    <span>ล้างแคช</span>
                </a>
                <a href="http://localhost:<?php echo getenv('PHPMYADMIN_PORT') ?: '8080'; ?>" target="_blank" class="menu-item">
                    <i class="fas fa-database"></i>
                    <span>phpMyAdmin</span>
                </a>
                <a href="http://localhost:<?php echo getenv('MAILHOG_WEB_PORT') ?: '8025'; ?>" target="_blank" class="menu-item">
                    <i class="fas fa-envelope"></i>
                    <span>MailHog</span>
                </a>
            </div>
            
            <div class="menu-section">
                <div class="menu-title">ตั้งค่า</div>
                <a href="#" class="menu-item" onclick="document.getElementById('thai-form').submit(); return false;">
                    <i class="fas fa-language"></i>
                    <span>ติดตั้งภาษาไทย</span>
                </a>
                <a href="#" class="menu-item">
                    <i class="fas fa-cog"></i>
                    <span>ตั้งค่าระบบ</span>
                </a>
            </div>
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Top Bar -->
        <header class="topbar">
            <div class="topbar-left">
                <button class="menu-toggle" onclick="document.getElementById('sidebar').classList.toggle('active')">
                    <i class="fas fa-bars"></i>
                </button>
                
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="ค้นหา...">
                </div>
            </div>
            
            <div class="topbar-right">
                <button class="notification-btn" data-tooltip="การแจ้งเตือน">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge">3</span>
                </button>
                
                <div class="user-menu">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div>
                        <div style="font-weight: 600;">Admin</div>
                        <div style="font-size: 0.75rem; color: #666;">ผู้ดูแลระบบ</div>
                    </div>
                </div>
            </div>
        </header>
        
        <!-- Content Area -->
        <div class="content">
            <!-- Page Header -->
            <div class="page-header">
                <h1 class="page-title">แดชบอร์ด</h1>
                <div class="breadcrumb">
                    <a href="#">หน้าหลัก</a>
                    <i class="fas fa-chevron-right" style="font-size: 0.75rem;"></i>
                    <span>แดชบอร์ด</span>
                </div>
            </div>
            
            <?php if ($message): ?>
            <div class="message <?php echo $message_type; ?>">
                <i class="fas fa-<?php echo $message_type === 'success' ? 'check-circle' : 'exclamation-circle'; ?>"></i>
                <span><?php echo htmlspecialchars($message); ?></span>
            </div>
            <?php endif; ?>
            
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon primary">
                        <i class="fas fa-shopping-cart"></i>
                    </div>
                    <div class="stat-value">156</div>
                    <div class="stat-label">คำสั่งซื้อวันนี้</div>
                    <div class="stat-change positive">
                        <i class="fas fa-arrow-up"></i>
                        <span>12%</span>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon success">
                        <i class="fas fa-coins"></i>
                    </div>
                    <div class="stat-value">฿45,280</div>
                    <div class="stat-label">ยอดขายวันนี้</div>
                    <div class="stat-change positive">
                        <i class="fas fa-arrow-up"></i>
                        <span>8%</span>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon warning">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-value">1,248</div>
                    <div class="stat-label">ลูกค้าทั้งหมด</div>
                    <div class="stat-change positive">
                        <i class="fas fa-arrow-up"></i>
                        <span>3%</span>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon info">
                        <i class="fas fa-box"></i>
                    </div>
                    <div class="stat-value">324</div>
                    <div class="stat-label">สินค้าทั้งหมด</div>
                    <div class="stat-change negative">
                        <i class="fas fa-arrow-down"></i>
                        <span>2%</span>
                    </div>
                </div>
            </div>
            
            <!-- System Status -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">
                        <i class="fas fa-server"></i>
                        สถานะระบบ
                    </h2>
                    <button class="btn btn-primary btn-sm" onclick="location.reload()">
                        <i class="fas fa-sync-alt"></i>
                        รีเฟรช
                    </button>
                </div>
                
                <div class="system-grid">
                    <?php
                    $services = [
                        'wordpress' => ['icon' => 'fab fa-wordpress', 'label' => 'WordPress'],
                        'db' => ['icon' => 'fas fa-database', 'label' => 'Database'],
                        'redis' => ['icon' => 'fas fa-memory', 'label' => 'Redis Cache'],
                        'phpmyadmin' => ['icon' => 'fas fa-server', 'label' => 'phpMyAdmin'],
                        'mailhog' => ['icon' => 'fas fa-envelope', 'label' => 'MailHog'],
                        'admin' => ['icon' => 'fas fa-tachometer-alt', 'label' => 'Admin Panel']
                    ];
                    
                    foreach ($services as $service => $info):
                        $is_running = false;
                        foreach ($status as $container) {
                            if (strpos($container['Service'] ?? '', $service) !== false && ($container['State'] ?? '') === 'running') {
                                $is_running = true;
                                break;
                            }
                        }
                    ?>
                    <div class="system-item <?php echo $is_running ? 'online' : 'offline'; ?>">
                        <div class="system-item-icon">
                            <i class="<?php echo $info['icon']; ?>" style="color: <?php echo $is_running ? 'var(--success)' : 'var(--danger)'; ?>"></i>
                        </div>
                        <div class="system-item-name"><?php echo $info['label']; ?></div>
                        <div class="system-item-status">
                            <?php if ($is_running): ?>
                                <span class="status status-online">
                                    <i class="fas fa-circle" style="font-size: 0.5rem;"></i>
                                    ทำงานปกติ
                                </span>
                            <?php else: ?>
                                <span class="status status-offline">
                                    <i class="fas fa-circle" style="font-size: 0.5rem;"></i>
                                    ไม่ทำงาน
                                </span>
                            <?php endif; ?>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
            
            <!-- Quick Actions -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">
                        <i class="fas fa-bolt"></i>
                        การดำเนินการด่วน
                    </h2>
                </div>
                
                <div class="quick-actions">
                    <button class="action-card" onclick="document.getElementById('backup-form').submit()">
                        <div class="action-icon"><i class="fas fa-download"></i></div>
                        <div class="action-label">สำรองข้อมูล</div>
                    </button>
                    
                    <button class="action-card warning" onclick="document.getElementById('cache-form').submit()">
                        <div class="action-icon"><i class="fas fa-broom"></i></div>
                        <div class="action-label">ล้างแคช</div>
                    </button>
                    
                    <button class="action-card info" onclick="document.getElementById('thai-form').submit()">
                        <div class="action-icon"><i class="fas fa-language"></i></div>
                        <div class="action-label">ติดตั้งภาษาไทย</div>
                    </button>
                    
                    <button class="action-card success" onclick="window.open('/scripts/admin-panel.sh', '_blank')">
                        <div class="action-icon"><i class="fas fa-terminal"></i></div>
                        <div class="action-label">Terminal Admin</div>
                    </button>
                </div>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <!-- Backups -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <i class="fas fa-history"></i>
                            ประวัติการสำรองข้อมูล
                        </h2>
                        <button class="btn btn-outline btn-sm" onclick="document.getElementById('backup-form').submit()">
                            <i class="fas fa-plus"></i>
                            สำรองใหม่
                        </button>
                    </div>
                    
                    <div class="backup-list">
                        <?php if (empty($backups)): ?>
                            <div style="text-align: center; padding: 2rem; color: #999;">
                                <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 1rem; display: block;"></i>
                                <p>ยังไม่มีข้อมูลสำรอง</p>
                            </div>
                        <?php else: ?>
                            <?php foreach (array_slice($backups, 0, 5) as $backup): ?>
                            <div class="backup-item">
                                <div class="backup-info">
                                    <div class="backup-date">
                                        <i class="fas fa-calendar-alt" style="margin-right: 0.5rem;"></i>
                                        <?php echo htmlspecialchars($backup['timestamp']); ?>
                                    </div>
                                    <div class="backup-time"><?php echo htmlspecialchars($backup['date']); ?></div>
                                </div>
                                <div class="backup-actions">
                                    <button class="backup-btn" data-tooltip="คืนค่า">
                                        <i class="fas fa-undo"></i>
                                    </button>
                                    <button class="backup-btn" data-tooltip="ดาวน์โหลด">
                                        <i class="fas fa-download"></i>
                                    </button>
                                </div>
                            </div>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </div>
                </div>
                
                <!-- Quick Links -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <i class="fas fa-link"></i>
                            ลิงก์ด่วน
                        </h2>
                    </div>
                    
                    <div class="links-grid">
                        <a href="<?php echo $app_url; ?>" target="_blank" class="link-card">
                            <div class="link-icon">
                                <i class="fas fa-globe"></i>
                            </div>
                            <div class="link-title">เว็บไซต์หลัก</div>
                            <div class="link-desc">ดูหน้าร้านค้า</div>
                        </a>
                        
                        <a href="<?php echo $app_url; ?>/wp-admin" target="_blank" class="link-card">
                            <div class="link-icon">
                                <i class="fab fa-wordpress"></i>
                            </div>
                            <div class="link-title">WordPress Admin</div>
                            <div class="link-desc">จัดการเนื้อหา</div>
                        </a>
                        
                        <a href="http://localhost:<?php echo getenv('PHPMYADMIN_PORT') ?: '8080'; ?>" target="_blank" class="link-card">
                            <div class="link-icon">
                                <i class="fas fa-database"></i>
                            </div>
                            <div class="link-title">phpMyAdmin</div>
                            <div class="link-desc">จัดการฐานข้อมูล</div>
                        </a>
                        
                        <a href="http://localhost:<?php echo getenv('MAILHOG_WEB_PORT') ?: '8025'; ?>" target="_blank" class="link-card">
                            <div class="link-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <div class="link-title">MailHog</div>
                            <div class="link-desc">ทดสอบอีเมล</div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Hidden Forms -->
    <form id="start-form" method="post" style="display: none;">
        <input type="hidden" name="action" value="start">
    </form>
    
    <form id="stop-form" method="post" style="display: none;">
        <input type="hidden" name="action" value="stop">
    </form>
    
    <form id="backup-form" method="post" style="display: none;">
        <input type="hidden" name="action" value="backup">
    </form>
    
    <form id="cache-form" method="post" style="display: none;">
        <input type="hidden" name="action" value="clear_cache">
    </form>
    
    <form id="thai-form" method="post" style="display: none;">
        <input type="hidden" name="action" value="install_thai">
    </form>
    
    <script>
        // Auto refresh every 30 seconds
        setTimeout(() => {
            location.reload();
        }, 30000);
        
        // Add loading state to buttons
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function() {
                const btn = document.querySelector(`[onclick*="${this.id}"]`);
                if (btn) {
                    btn.disabled = true;
                    btn.innerHTML = '<span class="loading"></span> กำลังดำเนินการ...';
                }
            });
        });
    </script>
</body>
</html>