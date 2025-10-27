# Pet Food E-commerce Platform - Docker Import Script (PowerShell)
# This script imports and runs the exported Docker image on a new machine

param(
    [switch]$SkipDatabase,
    [switch]$Force,
    [string]$Port = "8000"
)

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

# Check system requirements
function Test-Requirements {
    Write-Info "Checking system requirements..."
    
    # Check Docker
    try {
        $dockerVersion = docker --version 2>$null
        if (-not $dockerVersion) {
            Write-Error "Docker is not installed. Please install Docker Desktop first."
            Write-Host "Visit: https://docs.docker.com/desktop/windows/" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Error "Docker is not installed. Please install Docker Desktop first."
        return $false
    }
    
    # Check Docker Compose
    try {
        $composeVersion = docker-compose --version 2>$null
        if (-not $composeVersion) {
            $composeVersion = docker compose version 2>$null
            if (-not $composeVersion) {
                Write-Error "Docker Compose is not available. Please install Docker Desktop."
                return $false
            }
        }
    }
    catch {
        Write-Error "Docker Compose is not available. Please install Docker Desktop."
        return $false
    }
    
    # Check if Docker is running
    try {
        $null = docker info 2>$null
        Write-Success "All requirements met"
        return $true
    }
    catch {
        Write-Error "Docker is not running. Please start Docker Desktop and try again."
        return $false
    }
}

# Find and import Docker image
function Import-DockerImage {
    Write-Info "Looking for Docker image file..."
    
    $imageFile = Get-ChildItem -Path "." -Filter "*pet-food-store*.tar*" | Select-Object -First 1
    
    if (-not $imageFile) {
        Write-Error "No Docker image file found. Expected file like 'pet-food-store_*.tar.zip'"
        Write-Info "Please ensure you copied the complete export package."
        return $false
    }
    
    Write-Info "Found image file: $($imageFile.Name)"
    
    Write-Info "Importing Docker image (this may take a few minutes)..."
    
    try {
        if ($imageFile.Extension -eq ".zip") {
            # Extract and load
            Write-Info "Extracting compressed image..."
            Expand-Archive -Path $imageFile.FullName -DestinationPath "." -Force
            
            $tarFile = Get-ChildItem -Path "." -Filter "*pet-food-store*.tar" | Select-Object -First 1
            if ($tarFile) {
                docker load -i $tarFile.Name 2>&1 | Out-Host
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Docker image imported successfully"
                    Remove-Item $tarFile.FullName -Force
                    return $true
                } else {
                    Write-Error "Failed to import Docker image"
                    return $false
                }
            }
        } else {
            # Load directly
            docker load -i $imageFile.Name 2>&1 | Out-Host
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Docker image imported successfully"
                return $true
            } else {
                Write-Error "Failed to import Docker image"
                return $false
            }
        }
    }
    catch {
        Write-Error "Failed to import Docker image: $($_.Exception.Message)"
        return $false
    }
    
    return $false
}

# Setup environment
function Initialize-Environment {
    Write-Info "Setting up environment..."
    
    New-Item -ItemType Directory -Path "backups" -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType Directory -Path "logs" -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Success "Environment setup completed"
}

# Import database if available
function Import-Database {
    if ($SkipDatabase) {
        Write-Info "Skipping database import (--SkipDatabase specified)"
        return
    }
    
    Write-Info "Checking for database backup..."
    
    $dbFile = Get-ChildItem -Path "." -Filter "*.sql" | Select-Object -First 1
    
    if ($dbFile) {
        Write-Info "Found database backup: $($dbFile.Name)"
        Write-Info "Database will be imported after containers start"
        
        Copy-Item $dbFile.FullName "backups\" -Force
        $dbFile.Name | Out-File -FilePath "backups\.import_on_start" -Encoding UTF8
        Write-Success "Database backup prepared for import"
    } else {
        Write-Info "No database backup found. Starting with fresh installation."
    }
}

# Start containers
function Start-Containers {
    Write-Info "Starting Docker containers..."
    
    # Stop any existing containers
    if ($Force) {
        docker-compose down 2>$null | Out-Null
    }
    
    # Update port in docker-compose.yml if different
    if ($Port -ne "8000") {
        Write-Info "Updating port configuration to $Port..."
        $composeContent = Get-Content "docker-compose.yml" -Raw
        $composeContent = $composeContent -replace '"8000:80"', """$Port`:80"""
        $composeContent | Out-File -FilePath "docker-compose.yml" -Encoding UTF8
    }
    
    try {
        docker-compose up -d 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Containers started successfully"
        } else {
            Write-Error "Failed to start containers"
            return $false
        }
    }
    catch {
        Write-Error "Failed to start containers: $($_.Exception.Message)"
        return $false
    }
    
    # Wait for containers to be ready
    Write-Info "Waiting for containers to be ready..."
    Start-Sleep -Seconds 10
    
    # Check container status
    try {
        $containerStatus = docker-compose ps 2>$null
        if ($containerStatus -match "Up") {
            Write-Success "Containers are running"
            return $true
        } else {
            Write-Warning "Some containers may not be running properly"
            docker-compose ps
            return $false
        }
    }
    catch {
        Write-Warning "Could not verify container status"
        return $true
    }
}

# Import database after containers start
function Import-DatabasePostStart {
    if (Test-Path "backups\.import_on_start") {
        $dbFile = Get-Content "backups\.import_on_start" -Raw
        $dbFile = $dbFile.Trim()
        
        Write-Info "Importing database backup..."
        
        # Wait for database to be ready
        Start-Sleep -Seconds 15
        
        try {
            Get-Content "backups\$dbFile" | docker exec -i pet-food-store_db mysql -u wordpress -ppetshop123 wordpress
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Database imported successfully"
                Remove-Item "backups\.import_on_start" -Force
            } else {
                Write-Warning "Failed to import database. You can import it manually later."
            }
        }
        catch {
            Write-Warning "Failed to import database: $($_.Exception.Message)"
        }
    }
}

# Display access information
function Show-AccessInfo {
    Write-Success "Pet Food E-commerce Platform is now running!"
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "🌐 Website:      http://localhost:$Port" -ForegroundColor White
    Write-Host "👤 Admin Panel:  http://localhost:$Port/wp-admin" -ForegroundColor White
    Write-Host "🗄️  phpMyAdmin:  http://localhost:8080" -ForegroundColor White
    Write-Host "📧 MailHog:      http://localhost:8025" -ForegroundColor White
    Write-Host ""
    Write-Host "Default Credentials:" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "WordPress Admin:" -ForegroundColor Yellow
    Write-Host "  Username: admin" -ForegroundColor White
    Write-Host "  Password: admin123" -ForegroundColor White
    Write-Host ""
    Write-Host "Database:" -ForegroundColor Yellow
    Write-Host "  Host: localhost:3306" -ForegroundColor White
    Write-Host "  Username: wordpress" -ForegroundColor White
    Write-Host "  Password: petshop123" -ForegroundColor White
    Write-Host "  Database: wordpress" -ForegroundColor White
    Write-Host ""
    Write-Host "Useful Commands:" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "Stop:     docker-compose down" -ForegroundColor White
    Write-Host "Start:    docker-compose up -d" -ForegroundColor White
    Write-Host "Logs:     docker-compose logs -f" -ForegroundColor White
    Write-Host "Restart:  docker-compose restart" -ForegroundColor White
    Write-Host ""
    Write-Host "🎉 Installation completed successfully!" -ForegroundColor Green
}

# Main execution
function Main {
    Write-Host "Pet Food E-commerce Platform - Docker Import (PowerShell)" -ForegroundColor Magenta
    Write-Host "=============================================================" -ForegroundColor Magenta
    Write-Host ""
    
    if (-not (Test-Requirements)) { exit 1 }
    if (-not (Import-DockerImage)) { exit 1 }
    
    Initialize-Environment
    Import-Database
    
    if (-not (Start-Containers)) { exit 1 }
    
    Import-DatabasePostStart
    Show-AccessInfo
}

# Error handling
trap {
    Write-Error "Import failed: $($_.Exception.Message)"
    Write-Info "Cleaning up..."
    docker-compose down 2>$null | Out-Null
    exit 1
}

# Run main function
Main