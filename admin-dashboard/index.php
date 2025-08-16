<?php
/**
 * Modern Admin Dashboard for Pet Food Store
 * แดชบอร์ดสำหรับจัดการร้านอาหารสัตว์เลี้ยง - เวอร์ชันใหม่
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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Kanit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root {
            /* Modern Color Palette */
            --primary: #6366f1;
            --primary-light: #818cf8;
            --primary-dark: #4f46e5;
            --secondary: #ec4899;
            --accent: #06b6d4;
            --success: #10b981;
            --warning: #f59e0b;
            --error: #ef4444;
            --info: #3b82f6;
            
            /* Neutral Colors */
            --gray-50: #f9fafb;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-300: #d1d5db;
            --gray-400: #9ca3af;
            --gray-500: #6b7280;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --gray-900: #111827;
            
            /* Background */
            --bg-primary: #ffffff;
            --bg-secondary: #f8fafc;
            --bg-accent: #374151; /* Changed from #f1f5f9 */
            
            /* Gradients */
            --gradient-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --gradient-secondary: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            --gradient-success: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            --gradient-warning: linear-gradient(135deg, #fdbb2d 0%, #22c1c3 100%);
            --gradient-info: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
            --gradient-hero: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            
            /* Shadows */
            --shadow-xs: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            --shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            
            /* Border Radius */
            --radius-sm: 0.375rem;
            --radius-md: 0.5rem;
            --radius-lg: 0.75rem;
            --radius-xl: 1rem;
            --radius-2xl: 1.5rem;
            
            /* Transitions */
            --transition: all 0.2s ease-in-out;
            --transition-slow: all 0.3s ease-in-out;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', 'Kanit', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--bg-secondary);
            color: var(--gray-900);
            line-height: 1.6;
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Sidebar */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            width: 280px;
            height: 100vh;
            background: var(--bg-primary);
            box-shadow: var(--shadow-xl);
            z-index: 1000;
            overflow-y: auto;
            transition: var(--transition-slow);
            border-right: 1px solid var(--gray-200);
        }
        
        .sidebar-header {
            background: var(--gradient-hero);
            padding: 2rem;
            text-align: center;
            color: white;
            position: relative;
            overflow: hidden;
        }
        
        .sidebar-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="50" cy="50" r="1" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
            opacity: 0.1;
        }
        
        .logo {
            width: 80px;
            height: 80px;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            margin: 0 auto 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            position: relative;
            z-index: 1;
            transition: var(--transition);
        }
        
        .logo:hover {
            transform: scale(1.05);
            background: rgba(255, 255, 255, 0.2);
        }
        
        .sidebar h1 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            position: relative;
            z-index: 1;
        }
        
        .sidebar-subtitle {
            opacity: 0.9;
            font-size: 0.875rem;
            font-weight: 400;
            position: relative;
            z-index: 1;
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
            color: var(--gray-500);
            text-transform: uppercase;
            padding: 0 1.5rem;
            margin-bottom: 0.75rem;
            letter-spacing: 0.05em;
        }
        
        .menu-item {
            display: flex;
            align-items: center;
            padding: 0.875rem 1.5rem;
            color: var(--gray-700);
            text-decoration: none;
            transition: var(--transition);
            position: relative;
            font-weight: 500;
            margin: 0 0.75rem;
            border-radius: var(--radius-lg);
        }
        
        .menu-item:hover {
            background: var(--gray-100);
            color: var(--primary);
            transform: translateX(4px);
        }
        
        .menu-item i {
            width: 20px;
            margin-right: 0.875rem;
            font-size: 1.1rem;
        }
        
        .menu-item.active {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            box-shadow: var(--shadow-lg);
        }
        
        .menu-item.active:hover {
            transform: translateX(4px) scale(1.02);
        }
        
        /* Main Content */
        .main-content {
            margin-left: 280px;
            min-height: 100vh;
            transition: var(--transition-slow);
            background: var(--bg-secondary);
        }
        
        /* Top Bar */
        .topbar {
            background: var(--bg-primary);
            padding: 1rem 2rem;
            box-shadow: var(--shadow-sm);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 100;
            border-bottom: 1px solid var(--gray-200);
            backdrop-filter: blur(8px);
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
            color: var(--gray-600);
            padding: 0.5rem;
            border-radius: var(--radius-md);
            transition: var(--transition);
        }
        
        .menu-toggle:hover {
            background: var(--gray-100);
            color: var(--primary);
        }
        
        .search-box {
            position: relative;
        }
        
        .search-box input {
            padding: 0.75rem 1rem 0.75rem 3rem;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-xl);
            width: 350px;
            font-size: 0.875rem;
            transition: var(--transition);
            font-family: inherit;
            background: var(--bg-primary);
        }
        
        .search-box input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
            background: white;
        }
        
        .search-box i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            transition: var(--transition);
        }
        
        .search-box input:focus + i {
            color: var(--primary);
        }
        
        .topbar-right {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .notification-btn {
            position: relative;
            background: none;
            border: none;
            font-size: 1.25rem;
            cursor: pointer;
            color: var(--gray-600);
            transition: var(--transition);
            padding: 0.625rem;
            border-radius: var(--radius-lg);
        }
        
        .notification-btn:hover {
            background: var(--gray-100);
            color: var(--primary);
            transform: scale(1.05);
        }
        
        .notification-badge {
            position: absolute;
            top: 0.25rem;
            right: 0.25rem;
            background: var(--error);
            color: white;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            font-size: 0.625rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }
        
        .user-menu {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.5rem 1rem;
            border-radius: var(--radius-xl);
            transition: var(--transition);
            cursor: pointer;
        }
        
        .user-menu:hover {
            background: var(--gray-100);
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            background: var(--gradient-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.1rem;
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
            font-weight: 700;
            color: var(--gray-900);
            margin-bottom: 0.5rem;
        }
        
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            color: var(--gray-600);
        }
        
        .breadcrumb a {
            color: var(--primary);
            text-decoration: none;
            transition: var(--transition);
        }
        
        .breadcrumb a:hover {
            color: var(--primary-dark);
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: var(--bg-primary);
            border-radius: var(--radius-2xl);
            padding: 2rem;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--gray-200);
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--gradient-primary);
        }
        
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-2xl);
        }
        
        .stat-card:nth-child(2)::before {
            background: var(--gradient-secondary);
        }
        
        .stat-card:nth-child(3)::before {
            background: var(--gradient-success);
        }
        
        .stat-card:nth-child(4)::before {
            background: var(--gradient-warning);
        }
        
        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: var(--radius-xl);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
            background: var(--gradient-primary);
        }
        
        .stat-icon.success {
            background: var(--gradient-success);
        }
        
        .stat-icon.warning {
            background: var(--gradient-warning);
        }
        
        .stat-icon.info {
            background: var(--gradient-info);
        }
        
        .stat-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 0.5rem;
            line-height: 1;
        }
        
        .stat-label {
            font-size: 0.875rem;
            color: var(--gray-600);
            font-weight: 500;
            margin-bottom: 1rem;
        }
        
        .stat-change {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            font-weight: 600;
        }
        
        .stat-change.positive {
            color: var(--success);
        }
        
        .stat-change.negative {
            color: var(--error);
        }
        
        .stat-progress {
            width: 100%;
            height: 6px;
            background: var(--gray-200);
            border-radius: 3px;
            overflow: hidden;
            margin-top: 1rem;
        }
        
        .stat-progress-fill {
            height: 100%;
            background: var(--gradient-primary);
            transition: width 1s ease;
            border-radius: 3px;
        }
        
        /* Cards */
        .card {
            background: var(--bg-primary);
            border-radius: var(--radius-2xl);
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--gray-200);
            margin-bottom: 2rem;
            overflow: hidden;
            transition: var(--transition);
        }
        
        .card:hover {
            box-shadow: var(--shadow-xl);
        }
        
        .card-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--gray-50);
        }
        
        .card-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--gray-900);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .card-title i {
            color: var(--primary);
        }
        
        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: var(--radius-lg);
            font-size: 0.875rem;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: var(--transition);
            font-family: inherit;
        }
        
        .btn-primary {
            background: var(--gradient-primary);
            color: white;
            box-shadow: var(--shadow-md);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }
        
        .btn-outline {
            background: transparent;
            color: var(--primary);
            border: 2px solid var(--primary);
        }
        
        .btn-outline:hover {
            background: var(--primary);
            color: white;
        }
        
        .btn-sm {
            padding: 0.5rem 1rem;
            font-size: 0.8rem;
        }
        
        /* System Grid */
        .system-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            padding: 1.5rem;
        }
        
        .system-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            padding: 1.5rem 1rem;
            border-radius: var(--radius-xl);
            transition: var(--transition);
            border: 2px solid var(--gray-200);
        }
        
        .system-item:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        .system-item.online {
            border-color: var(--success);
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.05) 0%, rgba(16, 185, 129, 0.1) 100%);
        }
        
        .system-item.offline {
            border-color: var(--error);
            background: linear-gradient(135deg, rgba(239, 68, 68, 0.05) 0%, rgba(239, 68, 68, 0.1) 100%);
        }
        
        .system-item-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 1rem;
            background: var(--gray-100);
        }
        
        .system-item-name {
            font-weight: 600;
            color: var(--gray-900);
            margin-bottom: 0.5rem;
        }
        
        .status {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.25rem 0.75rem;
            border-radius: var(--radius-lg);
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-online {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }
        
        .status-offline {
            background: rgba(239, 68, 68, 0.1);
            color: var(--error);
        }
        
        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            padding: 1.5rem;
        }
        
        .action-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 2rem 1rem;
            background: var(--bg-primary);
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-xl);
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
            color: var(--gray-700);
        }
        
        .action-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary);
        }
        
        .action-card.warning:hover {
            border-color: var(--warning);
        }
        
        .action-card.success:hover {
            border-color: var(--success);
        }
        
        .action-card.info:hover {
            border-color: var(--info);
        }
        
        .action-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 1rem;
            background: var(--gradient-primary);
            color: white;
        }
        
        .action-card.warning .action-icon {
            background: var(--gradient-warning);
        }
        
        .action-card.success .action-icon {
            background: var(--gradient-success);
        }
        
        .action-card.info .action-icon {
            background: var(--gradient-info);
        }
        
        .action-label {
            font-weight: 600;
            font-size: 1rem;
        }
        
        /* Message Alert */
        .message {
            padding: 1rem 1.5rem;
            border-radius: var(--radius-xl);
            margin-bottom: 1.5rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 1rem;
            animation: slideIn 0.5s ease;
            border-left: 4px solid;
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
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(16, 185, 129, 0.05) 100%);
            color: var(--success);
            border-left-color: var(--success);
        }
        
        .message.error {
            background: linear-gradient(135deg, rgba(239, 68, 68, 0.1) 0%, rgba(239, 68, 68, 0.05) 100%);
            color: var(--error);
            border-left-color: var(--error);
        }
        
        /* Backup List */
        .backup-list {
            max-height: 400px;
            overflow-y: auto;
        }
        
        .backup-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--gray-200);
            transition: var(--transition);
        }
        
        .backup-item:hover {
            background: var(--gray-50);
        }
        
        .backup-item:last-child {
            border-bottom: none;
        }
        
        .backup-info {
            flex: 1;
        }
        
        .backup-date {
            font-weight: 600;
            color: var(--gray-900);
            margin-bottom: 0.25rem;
        }
        
        .backup-time {
            font-size: 0.875rem;
            color: var(--gray-600);
        }
        
        .backup-actions {
            display: flex;
            gap: 0.5rem;
        }
        
        .backup-btn {
            padding: 0.5rem;
            background: none;
            border: none;
            color: var(--gray-600);
            cursor: pointer;
            transition: var(--transition);
            border-radius: var(--radius-md);
        }
        
        .backup-btn:hover {
            background: var(--primary);
            color: white;
            transform: scale(1.1);
        }
        
        /* Links Grid */
        .links-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            padding: 1.5rem;
        }
        
        .link-card {
            background: var(--bg-primary);
            border: 2px solid var(--gray-200);
            border-radius: var(--radius-xl);
            padding: 1.5rem;
            text-align: center;
            text-decoration: none;
            color: var(--gray-700);
            transition: var(--transition);
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
            background: var(--gradient-primary);
            transform: translateX(-100%);
            transition: var(--transition);
        }
        
        .link-card:hover::before {
            transform: translateX(0);
        }
        
        .link-card:hover {
            border-color: var(--primary);
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }
        
        .link-card:nth-child(2)::before {
            background: var(--gradient-secondary);
        }
        
        .link-card:nth-child(3)::before {
            background: var(--gradient-success);
        }
        
        .link-card:nth-child(4)::before {
            background: var(--gradient-warning);
        }
        
        .link-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto 1rem;
            background: var(--gradient-primary);
            border-radius: var(--radius-xl);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
        }
        
        .link-card:nth-child(2) .link-icon {
            background: var(--gradient-secondary);
        }
        
        .link-card:nth-child(3) .link-icon {
            background: var(--gradient-success);
        }
        
        .link-card:nth-child(4) .link-icon {
            background: var(--gradient-warning);
        }
        
        .link-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 1rem;
        }
        
        .link-desc {
            font-size: 0.875rem;
            color: var(--gray-600);
        }
        
        /* Loading Animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        /* Tooltip */
        [data-tooltip] {
            position: relative;
        }
        
        [data-tooltip]:hover::after {
            content: attr(data-tooltip);
            position: absolute;
            bottom: calc(100% + 8px);
            left: 50%;
            transform: translateX(-50%);
            background: var(--gray-900);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: var(--radius-lg);
            font-size: 0.875rem;
            white-space: nowrap;
            z-index: 1000;
            animation: fadeIn 0.2s ease;
            box-shadow: var(--shadow-lg);
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
                width: 250px;
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
            
            .links-grid {
                grid-template-columns: 1fr;
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
            
            .page-title {
                font-size: 1.5rem;
            }
            
            .card-header {
                padding: 1rem 1.5rem;
            }
        }
        
        @media (max-width: 480px) {
            .stats-grid,
            .system-grid,
            .quick-actions,
            .links-grid {
                grid-template-columns: 1fr;
            }
            
            .stat-card,
            .card {
                border-radius: var(--radius-xl);
            }
            
            .topbar-right > *:not(.user-menu) {
                display: none;
            }
        }
        
        /* Dark mode support */
        @media (prefers-color-scheme: dark) {
            :root {
                --bg-primary: #1f2937;
                --bg-secondary: #111827;
                --bg-accent: #374151;
                --gray-900: #f9fafb;
                --gray-800: #f3f4f6;
                --gray-700: #e5e7eb;
                --gray-600: #d1d5db;
                --gray-500: #9ca3af;
                --gray-400: #6b7280;
                --gray-300: #4b5563;
                --gray-200: #374151;
                --gray-100: #1f2937;
                --gray-50: #111827;
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
            <p class="sidebar-subtitle">ระบบจัดการร้านอาหารสัตว์เลี้ยง</p>
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
                    <input type="text" placeholder="ค้นหา...">
                    <i class="fas fa-search"></i>
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
                        <div style="font-size: 0.75rem; color: var(--gray-500);">ผู้ดูแลระบบ</div>
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
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-shopping-cart"></i>
                        </div>
                    </div>
                    <div class="stat-value">156</div>
                    <div class="stat-label">คำสั่งซื้อวันนี้</div>
                    <div class="stat-change positive">
                        <i class="fas fa-arrow-up"></i>
                        <span>12% เพิ่มขึ้น</span>
                    </div>
                    <div class="stat-progress">
                        <div class="stat-progress-fill" style="width: 75%;"></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon success">
                            <i class="fas fa-coins"></i>
                        </div>
                    </div>
                    <div class="stat-value">฿45,280</div>
                    <div class="stat-label">ยอดขายวันนี้</div>
                    <div class="stat-change positive">
                        <i class="fas fa-arrow-up"></i>
                        <span>8% เพิ่มขึ้น</span>
                    </div>
                    <div class="stat-progress">
                        <div class="stat-progress-fill" style="width: 85%;"></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon warning">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                    <div class="stat-value">1,248</div>
                    <div class="stat-label">ลูกค้าทั้งหมด</div>
                    <div class="stat-change positive">
                        <i class="fas fa-arrow-up"></i>
                        <span>3% เพิ่มขึ้น</span>
                    </div>
                    <div class="stat-progress">
                        <div class="stat-progress-fill" style="width: 60%;"></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon info">
                            <i class="fas fa-box"></i>
                        </div>
                    </div>
                    <div class="stat-value">324</div>
                    <div class="stat-label">สินค้าทั้งหมด</div>
                    <div class="stat-change negative">
                        <i class="fas fa-arrow-down"></i>
                        <span>2% ลดลง</span>
                    </div>
                    <div class="stat-progress">
                        <div class="stat-progress-fill" style="width: 45%;"></div>
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
                            <i class="<?php echo $info['icon']; ?>" style="color: <?php echo $is_running ? 'var(--success)' : 'var(--error)'; ?>"></i>
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
                            <div style="text-align: center; padding: 3rem; color: var(--gray-500);">
                                <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 1rem; display: block; opacity: 0.5;"></i>
                                <p>ยังไม่มีข้อมูลสำรอง</p>
                                <p style="font-size: 0.875rem; margin-top: 0.5rem;">คลิกปุ่ม "สำรองใหม่" เพื่อเริ่มต้น</p>
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
        // Enhanced interactions and animations
        document.addEventListener('DOMContentLoaded', function() {
            // Animate progress bars on load
            const progressBars = document.querySelectorAll('.stat-progress-fill');
            progressBars.forEach(bar => {
                const width = bar.style.width;
                bar.style.width = '0';
                setTimeout(() => {
                    bar.style.width = width;
                }, 500);
            });
            
            // Add click feedback to action cards
            const actionCards = document.querySelectorAll('.action-card');
            actionCards.forEach(card => {
                card.addEventListener('click', function(e) {
                    // Create ripple effect
                    const ripple = document.createElement('span');
                    const rect = this.getBoundingClientRect();
                    const size = Math.max(rect.width, rect.height);
                    const x = e.clientX - rect.left - size / 2;
                    const y = e.clientY - rect.top - size / 2;
                    
                    ripple.style.cssText = `
                        position: absolute;
                        width: ${size}px;
                        height: ${size}px;
                        left: ${x}px;
                        top: ${y}px;
                        background: rgba(99, 102, 241, 0.3);
                        border-radius: 50%;
                        transform: scale(0);
                        animation: ripple 0.6s linear;
                        pointer-events: none;
                    `;
                    
                    this.style.position = 'relative';
                    this.style.overflow = 'hidden';
                    this.appendChild(ripple);
                    
                    setTimeout(() => {
                        ripple.remove();
                    }, 600);
                });
            });
            
            // Enhanced search functionality
            const searchInput = document.querySelector('.search-box input');
            if (searchInput) {
                searchInput.addEventListener('input', function(e) {
                    const query = e.target.value.toLowerCase();
                    // Add search functionality here
                    console.log('Searching for:', query);
                });
            }
            
            // Auto refresh with visual indicator
            let refreshTimer = 30;
            const refreshBtn = document.querySelector('[onclick="location.reload()"]');
            
            function updateRefreshTimer() {
                if (refreshBtn && refreshTimer > 0) {
                    refreshTimer--;
                    if (refreshTimer === 0) {
                        location.reload();
                    }
                }
            }
            
            setInterval(updateRefreshTimer, 1000);
            
            // Add loading state to forms
            document.querySelectorAll('form').forEach(form => {
                form.addEventListener('submit', function() {
                    const btn = document.querySelector(`[onclick*="${this.id}"]`);
                    if (btn) {
                        btn.disabled = true;
                        btn.style.opacity = '0.7';
                        btn.innerHTML = '<span class="loading"></span> กำลังดำเนินการ...';
                    }
                });
            });
            
            // Add smooth scroll behavior
            document.documentElement.style.scrollBehavior = 'smooth';
            
            // Enhanced mobile menu
            const menuToggle = document.querySelector('.menu-toggle');
            const sidebar = document.getElementById('sidebar');
            
            if (menuToggle && sidebar) {
                menuToggle.addEventListener('click', function() {
                    sidebar.classList.toggle('active');
                    
                    // Add overlay for mobile
                    if (sidebar.classList.contains('active')) {
                        const overlay = document.createElement('div');
                        overlay.className = 'sidebar-overlay';
                        overlay.style.cssText = `
                            position: fixed;
                            top: 0;
                            left: 0;
                            width: 100%;
                            height: 100%;
                            background: rgba(0, 0, 0, 0.5);
                            z-index: 999;
                            opacity: 0;
                            transition: opacity 0.3s ease;
                        `;
                        document.body.appendChild(overlay);
                        
                        setTimeout(() => overlay.style.opacity = '1', 10);
                        
                        overlay.addEventListener('click', function() {
                            sidebar.classList.remove('active');
                            this.style.opacity = '0';
                            setTimeout(() => this.remove(), 300);
                        });
                    } else {
                        const overlay = document.querySelector('.sidebar-overlay');
                        if (overlay) {
                            overlay.style.opacity = '0';
                            setTimeout(() => overlay.remove(), 300);
                        }
                    }
                });
            }
        });
        
        // CSS for ripple animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>