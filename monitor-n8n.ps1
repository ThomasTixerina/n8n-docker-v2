# Script de Monitoreo de n8n
# Este script verifica el estado del entorno n8n y muestra informacion util

Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  Monitor de Estado n8n' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

$projectDir = 'C:\Users\Thomas Tixerina\.gemini\antigravity\scratch\n8n-docker-v2'
Set-Location $projectDir

# 1. Verificar estado de contenedores
Write-Host '📦 Estado de Contenedores:' -ForegroundColor Cyan
docker-compose ps

# 2. Obtener URL de Cloudflare desde .env
Write-Host ''
Write-Host '🌐 URL de Cloudflare Tunnel:' -ForegroundColor Cyan
if (Test-Path '.env') {
    $envContent = Get-Content '.env'
    $urlLine = $envContent | Select-String -Pattern 'WEBHOOK_URL='
    if ($urlLine) {
        $url = $urlLine.ToString().Split('=')[1].Trim()
        Write-Host "  $url" -ForegroundColor White
    }
    else {
        Write-Host '  ⚠ WEBHOOK_URL no encontrada en .env' -ForegroundColor Yellow
    }
}
else {
    Write-Host '  ⚠ Archivo .env no encontrado' -ForegroundColor Red
}

# 3. Verificar salud de n8n
Write-Host ''
Write-Host '❤️ Health Check de n8n:' -ForegroundColor Cyan
if ($url) {
    try {
        $healthUrl = $url.TrimEnd('/') + '/healthz'
        $response = Invoke-WebRequest -Uri $healthUrl -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host '  ✓ n8n esta respondiendo correctamente' -ForegroundColor Green
        }
        else {
            Write-Host "  ⚠ n8n respondio con codigo: $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host '  ✗ n8n no esta respondiendo' -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Gray
    }
}
else {
    Write-Host '  ⚠ No se puede verificar salud sin URL' -ForegroundColor Yellow
}

# 4. Listar workflows disponibles
Write-Host ''
Write-Host '📋 Workflows Disponibles:' -ForegroundColor Cyan
$workflows = Get-ChildItem -Path $projectDir -Filter "*.json" | Where-Object { 
    $_.Name -notlike "package*.json" -and 
    $_.Name -notlike "tsconfig*.json" 
}

foreach ($workflow in $workflows) {
    $size = [math]::Round($workflow.Length / 1KB, 2)
    $modified = $workflow.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
    Write-Host "  • $($workflow.Name)" -ForegroundColor White
    Write-Host "    Tamano: $size KB | Modificado: $modified" -ForegroundColor Gray
}

# 5. Variables de entorno (seguro)
Write-Host ''
Write-Host '🔧 Configuración Actual:' -ForegroundColor Cyan
if (Test-Path ".env") {
    $envVars = Get-Content ".env" | Where-Object { $_ -match "^[^#]" -and $_ -match "=" }
    foreach ($var in $envVars) {
        $parts = $var -split "=", 2
        $key = $parts[0]
        $value = $parts[1]
        if ($key -match "TOKEN|PASSWORD|KEY") { $value = "***OCULTO***" }
        Write-Host "  $key = $value" -ForegroundColor Gray
    }
}

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host "  Ultima actualizacion: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host '========================================' -ForegroundColor Cyan
