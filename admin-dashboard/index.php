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
    <title>Admin Dashboard - ร้านอาหารสัตว์เลี้ยง</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Sarabun', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 0;
            text-align: center;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .subtitle {
            font-size: 1.2em;
            opacity: 0.9;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        
        .card h2 {
            color: #667eea;
            margin-bottom: 20px;
            font-size: 1.5em;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .status-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .status-item {
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .status-online {
            border-left-color: #10b981;
        }
        
        .status-offline {
            border-left-color: #ef4444;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            margin: 5px;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
        }
        
        .btn-primary:hover {
            background: #5a67d8;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(102, 126, 234, 0.4);
        }
        
        .btn-success {
            background: #10b981;
            color: white;
        }
        
        .btn-danger {
            background: #ef4444;
            color: white;
        }
        
        .btn-warning {
            background: #f59e0b;
            color: white;
        }
        
        .btn-info {
            background: #3b82f6;
            color: white;
        }
        
        .btn-group {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 15px;
        }
        
        .message {
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-weight: 500;
        }
        
        .message.success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #10b981;
        }
        
        .message.error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #ef4444;
        }
        
        .backup-list {
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            padding: 10px;
        }
        
        .backup-item {
            padding: 8px;
            border-bottom: 1px solid #f3f4f6;
            font-size: 14px;
        }
        
        .backup-item:last-child {
            border-bottom: none;
        }
        
        .icon {
            width: 24px;
            height: 24px;
            display: inline-block;
            vertical-align: middle;
        }
        
        .links {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 10px;
            margin-top: 20px;
        }
        
        .link-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
            text-decoration: none;
            color: #333;
            transition: all 0.2s;
            border: 2px solid transparent;
        }
        
        .link-card:hover {
            border-color: #667eea;
            background: #f3f4ff;
        }
        
        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }
            
            .status-grid {
                grid-template-columns: 1fr;
            }
            
            h1 {
                font-size: 2em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🏪 ระบบจัดการร้านอาหารสัตว์เลี้ยง</h1>
            <p class="subtitle">Pet Food Store Admin Dashboard</p>
        </header>
        
        <?php if ($message): ?>
        <div class="message <?php echo $message_type; ?>">
            <?php echo htmlspecialchars($message); ?>
        </div>
        <?php endif; ?>
        
        <div class="grid">
            <!-- System Status -->
            <div class="card">
                <h2>📊 สถานะระบบ</h2>
                <div class="status-grid">
                    <?php
                    $services = ['wordpress' => 'WordPress', 'db' => 'Database', 'redis' => 'Redis', 'phpmyadmin' => 'phpMyAdmin'];
                    foreach ($services as $service => $label):
                        $is_running = false;
                        foreach ($status as $container) {
                            if (strpos($container['Service'] ?? '', $service) !== false && ($container['State'] ?? '') === 'running') {
                                $is_running = true;
                                break;
                            }
                        }
                    ?>
                    <div class="status-item <?php echo $is_running ? 'status-online' : 'status-offline'; ?>">
                        <strong><?php echo $label; ?></strong><br>
                        <?php echo $is_running ? '✅ ทำงานปกติ' : '❌ ไม่ทำงาน'; ?>
                    </div>
                    <?php endforeach; ?>
                </div>
                
                <form method="post" style="display: inline;">
                    <input type="hidden" name="action" value="start">
                    <button type="submit" class="btn btn-success">🚀 เริ่มระบบ</button>
                </form>
                
                <form method="post" style="display: inline;">
                    <input type="hidden" name="action" value="stop">
                    <button type="submit" class="btn btn-danger">🛑 หยุดระบบ</button>
                </form>
            </div>
            
            <!-- Quick Actions -->
            <div class="card">
                <h2>⚡ การดำเนินการด่วน</h2>
                <div class="btn-group">
                    <form method="post">
                        <input type="hidden" name="action" value="backup">
                        <button type="submit" class="btn btn-primary">📦 สำรองข้อมูล</button>
                    </form>
                    
                    <form method="post">
                        <input type="hidden" name="action" value="clear_cache">
                        <button type="submit" class="btn btn-warning">🧹 ล้างแคช</button>
                    </form>
                    
                    <form method="post">
                        <input type="hidden" name="action" value="install_thai">
                        <button type="submit" class="btn btn-info">🇹🇭 ติดตั้งภาษาไทย</button>
                    </form>
                    
                    <a href="/scripts/admin-panel.sh" class="btn btn-primary" onclick="alert('กรุณารันคำสั่ง ./scripts/admin-panel.sh ใน Terminal'); return false;">
                        🖥️ Terminal Admin
                    </a>
                </div>
            </div>
            
            <!-- Backups -->
            <div class="card">
                <h2>💾 การสำรองข้อมูล</h2>
                <div class="backup-list">
                    <?php if (empty($backups)): ?>
                        <p>ยังไม่มีข้อมูลสำรอง</p>
                    <?php else: ?>
                        <?php foreach (array_slice($backups, 0, 5) as $backup): ?>
                        <div class="backup-item">
                            📅 <?php echo htmlspecialchars($backup['timestamp']); ?><br>
                            <small><?php echo htmlspecialchars($backup['date']); ?></small>
                        </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
            
            <!-- Quick Links -->
            <div class="card">
                <h2>🔗 ลิงก์ด่วน</h2>
                <div class="links">
                    <a href="<?php echo $app_url; ?>" target="_blank" class="link-card">
                        🌐 เว็บไซต์หลัก
                    </a>
                    <a href="<?php echo $app_url; ?>/wp-admin" target="_blank" class="link-card">
                        👤 WordPress Admin
                    </a>
                    <a href="http://localhost:<?php echo getenv('PHPMYADMIN_PORT') ?: '8080'; ?>" target="_blank" class="link-card">
                        🗄️ phpMyAdmin
                    </a>
                    <a href="http://localhost:<?php echo getenv('MAILHOG_WEB_PORT') ?: '8025'; ?>" target="_blank" class="link-card">
                        📧 MailHog
                    </a>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>📚 คู่มือการใช้งาน</h2>
            <ul style="line-height: 2;">
                <li><strong>เริ่มต้นใช้งาน:</strong> คลิก "เริ่มระบบ" เพื่อเริ่มการทำงานของเว็บไซต์</li>
                <li><strong>สำรองข้อมูล:</strong> ควรสำรองข้อมูลเป็นประจำทุกวันหรือก่อนทำการเปลี่ยนแปลงสำคัญ</li>
                <li><strong>ภาษาไทย:</strong> คลิก "ติดตั้งภาษาไทย" เพื่อเปลี่ยนระบบเป็นภาษาไทยทั้งหมด</li>
                <li><strong>การย้ายโฮสต์:</strong> ใช้ Terminal Admin หรือรันคำสั่ง <code>./scripts/migrate.sh</code></li>
                <li><strong>ปัญหาการใช้งาน:</strong> ตรวจสอบสถานะระบบและดู logs ใน Terminal</li>
            </ul>
        </div>
    </div>
</body>
</html>