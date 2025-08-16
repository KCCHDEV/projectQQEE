# Auto-sync PowerShell script for WordPress wp-content development
# Monitors dev-workspace for changes and syncs to WordPress container

param(
    [switch]$SetupOnly,
    [switch]$SyncOnly,
    [switch]$Help
)

# Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Header {
    Write-Host "🔄 WordPress Auto-Sync - Development Monitor" -ForegroundColor Blue
    Write-Host "==================================================" -ForegroundColor Blue
    Write-Host ""
}

function Write-Status {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param($Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Load-Environment {
    $script:APP_NAME = "pet-food-store"
    
    if (Test-Path ".env") {
        Get-Content ".env" | ForEach-Object {
            if ($_ -match "^([^=]+)=(.*)$") {
                $name = $matches[1]
                $value = $matches[2]
                if ($name -eq "APP_NAME") {
                    $script:APP_NAME = $value
                }
            }
        }
    } else {
        Write-Warning ".env file not found! Using default values."
    }
}

function Test-Dependencies {
    Write-Info "Checking dependencies..."
    
    # Check if Docker is available
    try {
        $null = docker --version
        Write-Status "Docker is available"
    } catch {
        Write-Error "Docker not found! Please install Docker Desktop."
        exit 1
    }
}

function Test-WordPressStatus {
    Write-Info "Checking WordPress container status..."
    
    $containers = docker ps --format "table {{.Names}}" | Select-String "$script:APP_NAME-wordpress"
    if ($containers) {
        Write-Status "WordPress container is running"
        return $true
    } else {
        Write-Error "WordPress container is not running!"
        Write-Info "Please start your WordPress environment first:"
        Write-Info "  ./scripts/quick-start.sh"
        exit 1
    }
}

function Setup-DevWorkspace {
    Write-Info "Setting up development workspace..."
    
    # Create development directories if they don't exist
    $directories = @(
        "dev-workspace",
        "dev-workspace\themes",
        "dev-workspace\plugins",
        "dev-workspace\themes\custom",
        "dev-workspace\plugins\custom"
    )
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    # Create README files if they don't exist
    $themesReadme = "dev-workspace\themes\custom\README.md"
    if (!(Test-Path $themesReadme)) {
        @"
# Custom Themes Development

Place your custom theme files here. They will be automatically synced to:
``pet-food-shop-template/wp-content/themes/``

## Structure:
``````
dev-workspace/themes/custom/
├── your-theme-name/
│   ├── style.css
│   ├── index.php
│   ├── functions.php
│   └── ...
``````

Files are monitored and synced automatically when you save them in VSCode.
"@ | Out-File -FilePath $themesReadme -Encoding UTF8
    }
    
    $pluginsReadme = "dev-workspace\plugins\custom\README.md"
    if (!(Test-Path $pluginsReadme)) {
        @"
# Custom Plugins Development

Place your custom plugin files here. They will be automatically synced to:
``pet-food-shop-template/wp-content/plugins/``

## Structure:
``````
dev-workspace/plugins/custom/
├── your-plugin-name/
│   ├── your-plugin-name.php
│   ├── includes/
│   ├── assets/
│   └── ...
``````

Files are monitored and synced automatically when you save them in VSCode.
"@ | Out-File -FilePath $pluginsReadme -Encoding UTF8
    }
    
    Write-Status "Development workspace ready at: .\dev-workspace\"
}

function Sync-File {
    param($SourcePath)
    
    if (!(Test-Path $SourcePath)) {
        return
    }
    
    $relativePath = $SourcePath.Replace((Get-Location).Path + "\dev-workspace\", "").Replace("\", "/")
    $destPath = "pet-food-shop-template\wp-content\$relativePath".Replace("/", "\")
    
    # Create destination directory if it doesn't exist
    $destDir = Split-Path $destPath -Parent
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    try {
        # Copy file to local wp-content
        Copy-Item $SourcePath $destPath -Force
        Write-Info "📄 Synced file: $relativePath"
        
        # Copy to WordPress container
        $containerCheck = docker ps --format "table {{.Names}}" | Select-String "$script:APP_NAME-wordpress"
        if ($containerCheck) {
            $containerPath = "/var/www/html/wp-content/$relativePath"
            docker cp $destPath "$script:APP_NAME-wordpress:$containerPath" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Status "🚀 Deployed to container: $relativePath"
            }
        } else {
            Write-Warning "WordPress container not running, only local sync completed"
        }
    } catch {
        Write-Warning "Failed to sync: $relativePath"
    }
}

function Sync-Directory {
    param($SourcePath)
    
    if (!(Test-Path $SourcePath)) {
        return
    }
    
    $relativePath = $SourcePath.Replace((Get-Location).Path + "\dev-workspace\", "").Replace("\", "/")
    $destPath = "pet-food-shop-template\wp-content\$relativePath".Replace("/", "\")
    
    try {
        # Copy directory to local wp-content
        if (Test-Path $destPath) {
            Remove-Item $destPath -Recurse -Force
        }
        Copy-Item $SourcePath $destPath -Recurse -Force
        Write-Info "📁 Synced directory: $relativePath"
        
        # Copy to WordPress container
        $containerCheck = docker ps --format "table {{.Names}}" | Select-String "$script:APP_NAME-wordpress"
        if ($containerCheck) {
            $containerPath = "/var/www/html/wp-content/$relativePath"
            docker cp $destPath "$script:APP_NAME-wordpress:$containerPath" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Status "🚀 Deployed to container: $relativePath"
            }
        }
    } catch {
        Write-Warning "Failed to sync directory: $relativePath"
    }
}

function Start-InitialSync {
    Write-Info "Performing initial sync..."
    
    if (Test-Path "dev-workspace") {
        # Sync custom themes
        if (Test-Path "dev-workspace\themes\custom") {
            Get-ChildItem "dev-workspace\themes\custom" -Directory | ForEach-Object {
                Sync-Directory $_.FullName
            }
        }
        
        # Sync custom plugins
        if (Test-Path "dev-workspace\plugins\custom") {
            Get-ChildItem "dev-workspace\plugins\custom" -Directory | ForEach-Object {
                Sync-Directory $_.FullName
            }
        }
        
        # Sync individual files
        Get-ChildItem "dev-workspace" -File -Recurse | Where-Object { 
            $_.Name -ne "README.md" -and $_.Name -notlike ".*"
        } | ForEach-Object {
            Sync-File $_.FullName
        }
        
        Write-Status "Initial sync completed"
    }
}

function Start-FileMonitoring {
    Write-Info "Starting file monitoring..."
    Write-Info "Monitoring: .\dev-workspace\"
    Write-Info "Press Ctrl+C to stop monitoring"
    Write-Host ""
    
    # Create FileSystemWatcher for better performance
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = (Get-Location).Path + "\dev-workspace"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    
    # Register event handlers
    $action = {
        $path = $Event.SourceEventArgs.FullPath
        $changeType = $Event.SourceEventArgs.ChangeType
        $name = $Event.SourceEventArgs.Name
        
        # Skip hidden files, git files, and README files
        if ($name -notlike ".*" -and $name -notlike "*.git*" -and $name -ne "README.md") {
            switch ($changeType) {
                "Changed" { 
                    if (Test-Path $path -PathType Leaf) {
                        Sync-File $path 
                    }
                }
                "Created" { 
                    if (Test-Path $path -PathType Leaf) {
                        Sync-File $path 
                    } elseif (Test-Path $path -PathType Container) {
                        Sync-Directory $path
                    }
                }
                "Renamed" { 
                    if (Test-Path $path -PathType Leaf) {
                        Sync-File $path 
                    } elseif (Test-Path $path -PathType Container) {
                        Sync-Directory $path
                    }
                }
                "Deleted" {
                    $relativePath = $path.Replace((Get-Location).Path + "\dev-workspace\", "").Replace("\", "/")
                    $destPath = "pet-food-shop-template\wp-content\$relativePath".Replace("/", "\")
                    
                    if (Test-Path $destPath) {
                        Remove-Item $destPath -Recurse -Force
                        Write-Info "🗑️  Deleted: $relativePath"
                    }
                    
                    # Remove from container
                    $containerCheck = docker ps --format "table {{.Names}}" | Select-String "$script:APP_NAME-wordpress"
                    if ($containerCheck) {
                        $containerPath = "/var/www/html/wp-content/$relativePath"
                        docker exec "$script:APP_NAME-wordpress" rm -rf $containerPath 2>$null
                        if ($LASTEXITCODE -eq 0) {
                            Write-Status "🗑️  Removed from container: $relativePath"
                        }
                    }
                }
            }
        }
    }
    
    Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName "Renamed" -Action $action | Out-Null
    
    try {
        # Keep the script running
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } finally {
        # Cleanup
        $watcher.EnableRaisingEvents = $false
        $watcher.Dispose()
        Get-EventSubscriber | Unregister-Event
        Write-Info "Stopping file monitoring..."
        Write-Status "Auto-sync stopped"
    }
}

function Show-Usage {
    Write-Host "Usage: .\auto-sync-wp-content.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help          Show this help message"
    Write-Host "  -SetupOnly     Only setup workspace, don't start monitoring"
    Write-Host "  -SyncOnly      Perform initial sync only, don't start monitoring"
    Write-Host ""
    Write-Host "Development Structure:"
    Write-Host "  dev-workspace/"
    Write-Host "  ├── themes/"
    Write-Host "  │   └── custom/          # Custom themes go here"
    Write-Host "  │       └── my-theme/"
    Write-Host "  └── plugins/"
    Write-Host "      └── custom/          # Custom plugins go here"
    Write-Host "          └── my-plugin/"
    Write-Host ""
    Write-Host "Files are automatically synced to:"
    Write-Host "  - pet-food-shop-template/wp-content/"
    Write-Host "  - WordPress container wp-content/"
}

# Main execution
if ($Help) {
    Show-Usage
    exit 0
}

Write-Header

Load-Environment
Test-Dependencies

if ($SetupOnly) {
    Setup-DevWorkspace
    Write-Status "Workspace setup completed"
    exit 0
}

Test-WordPressStatus
Setup-DevWorkspace

if ($SyncOnly) {
    Start-InitialSync
    exit 0
}

Start-InitialSync

Write-Host ""
Write-Info "🎯 Ready for development!"
Write-Info "Edit files in .\dev-workspace\ and they will be auto-synced"
Write-Info "WordPress site: http://localhost:8080"
Write-Info "Admin: http://localhost:8080/wp-admin"
Write-Host ""

Start-FileMonitoring