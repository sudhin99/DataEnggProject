Write-Host "Checking WSL and Docker prerequisites..." -ForegroundColor Cyan

# Check WSL status
try {
    wsl --status 2>$null | Out-Null
    $wslInstalled = $true
} catch {
    $wslInstalled = $false
}

if ($wslInstalled) {
    Write-Host "WSL appears installed. Installed distros:" -ForegroundColor Green
    wsl -l -v
} else {
    Write-Host "WSL does not appear installed. Run 'wsl --install' as Administrator." -ForegroundColor Yellow
}

# Check Docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "Docker is installed:" -ForegroundColor Green
    docker --version
    docker compose version
} else {
    Write-Host "Docker CLI not found. Please install Docker Desktop and enable WSL integration:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
}

Write-Host "Quick port check: is 8080 in use?" -ForegroundColor Cyan
$net = netstat -ano | Select-String ":8080 " | Select-Object -First 1
if ($net) {
    Write-Host "Port 8080 appears in use:" -ForegroundColor Yellow
    Write-Host $net.Line
} else {
    Write-Host "Port 8080 appears free." -ForegroundColor Green
}

Write-Host "Check complete." -ForegroundColor Cyan
