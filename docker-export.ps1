# Pet Food E-commerce Platform - Docker Export Script (PowerShell)
# This script builds and exports the Docker image for deployment on other machines

param(
    [switch]$SkipDatabase,
    [switch]$Compress = $true,
    [string]$OutputDir = "docker-export"
)

# Configuration
$ImageName = "pet-food-store"
$ImageTag = "latest"
$BackupDir = "backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $colors = @{
        "Red" = "Red"
        "Green" = "Green" 
        "Yellow" = "Yellow"
        "Blue" = "Cyan"
        "White" = "White"
    }
    
    Write-Host $Message -ForegroundColor $colors[$Color]
}

function Write-Info { param([string]$Message) Write-ColorOutput "[INFO] $Message" "Blue" }
function Write-Success { param([string]$Message) Write-ColorOutput "[SUCCESS] $Message" "Green" }
function Write-Warning { param([string]$Message) Write-ColorOutput "[WARNING] $Message" "Yellow" }
function Write-Error { param([string]$Message) Write-ColorOutput "[ERROR] $Message" "Red" }

# Check if Docker is running
function Test-Docker {
    Write-Info "Checking Docker..."
    
    try {
        $null = docker info 2>$null
        Write-Success "Docker is running"
        return $true
    }
    catch {
        Write-Error "Docker is not running. Please start Docker Desktop and try again."
        return $false
    }
}

# Create export directory
function New-ExportDirectory {
    Write-Info "Creating export directory..."
    
    if (Test-Path $OutputDir) {
        Write-Warning "Export directory exists. Creating backup..."
        $backupName = "$OutputDir" + "_backup_$Timestamp"
        Move-Item $OutputDir $backupName -Force
    }
    
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    New-Item -ItemType Directory -Path $BackupDir -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Success "Created export directory: $OutputDir"
}

# Build Docker image
function Build-DockerImage {
    Write-Info "Building Docker image..."
    
    try {
        docker build -t "$ImageName`:$ImageTag" . 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker image built successfully: $ImageName`:$ImageTag"
            return $true
        } else {
            Write-Error "Failed to build Docker image"
            return $false
        }
    }
    catch {
        Write-Error "Failed to build Docker image: $($_.Exception.Message)"
        return $false
    }
}

# Export Docker image
function Export-DockerImage {
    Write-Info "Exporting Docker image..."
    
    $exportFile = "$OutputDir\$ImageName" + "_$ImageTag" + "_$Timestamp.tar"
    
    try {
        docker save -o $exportFile "$ImageName`:$ImageTag" 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker image exported to: $exportFile"
            
            if ($Compress) {
                Write-Info "Compressing exported image..."
                Compress-Archive -Path $exportFile -DestinationPath "$exportFile.zip" -Force
                Remove-Item $exportFile
                
                $compressedSize = (Get-Item "$exportFile.zip").Length
                $sizeInMB = [math]::Round($compressedSize / 1MB, 2)
                Write-Success "Image compressed: $exportFile.zip ($sizeInMB MB)"
            }
            return $true
        } else {
            Write-Error "Failed to export Docker image"
            return $false
        }
    }
    catch {
        Write-Error "Failed to export Docker image: $($_.Exception.Message)"
        return $false
    }
}

# Export database
function Export-Database {
    if ($SkipDatabase) {
        Write-Info "Skipping database export (--SkipDatabase specified)"
        return
    }
    
    Write-Info "Checking for running database container..."
    
    try {
        $containers = docker ps --format "table {{.Names}}" 2>$null
        if ($containers -match "pet-food-store_db") {
            Write-Info "Exporting database..."
            
            $dbExportFile = "$BackupDir\database_$Timestamp.sql"
            
            docker exec pet-food-store_db mysqldump -u wordpress -ppetshop123 wordpress | Out-File -FilePath $dbExportFile -Encoding UTF8
            
            if ($LASTEXITCODE -eq 0 -and (Test-Path $dbExportFile)) {
                Write-Success "Database exported to: $dbExportFile"
                Copy-Item $dbExportFile $OutputDir
                Write-Success "Database backup copied to export directory"
            } else {
                Write-Warning "Failed to export database. The image will work but without existing data."
            }
        } else {
            Write-Warning "Database container not running. Skipping database export."
            Write-Info "To export database later, run: scripts\backup.ps1"
        }
    }
    catch {
        Write-Warning "Error checking database container: $($_.Exception.Message)"
    }
}

# Copy configuration files
function Copy-ConfigFiles {
    Write-Info "Copying configuration files..."
    
    $filesToCopy = @(
        "docker-compose.yml",
        "docker-import.bat", 
        "docker-import.ps1"
    )
    
    foreach ($file in $filesToCopy) {
        if (Test-Path $file) {
            Copy-Item $file $OutputDir -Force
        }
    }
    
    # Create README
    $readmeContent = @"
Pet Food E-commerce Platform - Docker Export Package
Generated on: $(Get-Date)

Contents:
- $ImageName`_$ImageTag`_$Timestamp.tar.zip: Docker image
- docker-compose.yml: Docker Compose configuration
- docker-import.bat: Import script for Windows Command Prompt
- docker-import.ps1: Import script for PowerShell
- database_$Timestamp.sql: Database backup (if available)

To import on another Windows machine:
1. Install Docker Desktop
2. Run PowerShell as Administrator
3. Run: .\docker-import.ps1
4. Access the site at http://localhost:8000

For more information, see the main project documentation.
"@
    
    $readmeContent | Out-File -FilePath "$OutputDir\README.txt" -Encoding UTF8
    Write-Success "Configuration files and documentation copied"
}

# Display summary
function Show-Summary {
    Write-Success "Export completed successfully!"
    Write-Host ""
    Write-Host "Export package location: $OutputDir" -ForegroundColor Cyan
    Write-Host "Contents:" -ForegroundColor Cyan
    Get-ChildItem $OutputDir | Format-Table Name, Length, LastWriteTime -AutoSize
    
    Write-Host "To deploy on another machine:" -ForegroundColor Yellow
    Write-Host "1. Copy the entire '$OutputDir' folder to the target machine" -ForegroundColor White
    Write-Host "2. Run: cd $OutputDir && .\docker-import.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "The exported package includes:" -ForegroundColor Yellow
    Write-Host "- Complete Docker image with WordPress, WooCommerce, and custom theme" -ForegroundColor White
    Write-Host "- Database backup (if available)" -ForegroundColor White
    Write-Host "- Configuration files" -ForegroundColor White
    Write-Host "- Import scripts for easy deployment" -ForegroundColor White
}

# Main execution
function Main {
    Write-Host "Pet Food E-commerce Platform - Docker Export (PowerShell)" -ForegroundColor Magenta
    Write-Host "=============================================================" -ForegroundColor Magenta
    Write-Host ""
    
    if (-not (Test-Docker)) { exit 1 }
    
    New-ExportDirectory
    
    if (-not (Build-DockerImage)) { exit 1 }
    if (-not (Export-DockerImage)) { exit 1 }
    
    Export-Database
    Copy-ConfigFiles
    Show-Summary
}

# Run main function
Main