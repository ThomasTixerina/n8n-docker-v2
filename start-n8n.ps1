# Script de Inicio del Autonomous Agent Orchestra + n8n
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  Iniciando Autonomous Agent Orchestra + n8n Production  ' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan

# --- NUEVA SECCIÓN INTERACTIVA ---
$currentDir = Get-Location
if ($currentDir.Path -match "n8n-infrastructure") {
    Write-Host "`n[CONFIGURACIÓN DE ENTORNO]" -ForegroundColor Magenta
    $tenant = Read-Host "Hola con que tenant de trabajo quieres empezar a trabajar mi consul"
    $folders = Read-Host "Perfecto, ¿vamos a usar una o dos carpetas de trabajo? (1/2)"
    
    Write-Host "`nConfigurando entorno para: $tenant ($folders carpeta(s))`n" -ForegroundColor Cyan
    
    # Aquí se podrían exportar estas variables si otros procesos las necesitan
    $env:TENANT_ID = $tenant
    $env:WORK_FOLDERS = $folders

    # --- Lógica de Archivos de Entorno Multi-Tenant ---
    $tenantEnvFile = ".env.$tenant"
    
    if (Test-Path $tenantEnvFile) {
        Write-Host "  📂 Cargando configuración existente para '$tenant'..." -ForegroundColor Cyan
        Copy-Item -Path $tenantEnvFile -Destination ".env" -Force
    }
    else {
        Write-Host "  🆕 Creando nueva configuración para '$tenant'..." -ForegroundColor Yellow
        if (Test-Path ".env.template") {
            Copy-Item -Path ".env.template" -Destination $tenantEnvFile
            Copy-Item -Path ".env.template" -Destination ".env" -Force
        }
        else {
            # Fallback si no hay template, usar el .env actual como base
            Copy-Item -Path ".env" -Destination $tenantEnvFile
        }
    }
    # --------------------------------------------------
}
# ---------------------------------

# 1. Verificar Docker
Write-Host '[1/6] Verificando Docker...' -ForegroundColor Yellow
docker ps > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host '❌ Error: Docker no esta corriendo.' -ForegroundColor Red
    Write-Host 'Por favor inicia Docker Desktop y vuelve a ejecutar este script.' -ForegroundColor Yellow
    exit 1
}
Write-Host '✅ Docker esta corriendo' -ForegroundColor Green

# 2. Verificar que orchestrator esté compilado
Write-Host '[2/6] Verificando build del Orchestrator...' -ForegroundColor Yellow
if (Test-Path "agents\orchestrator\dist") {
    Write-Host '✅ Orchestrator compilado correctamente' -ForegroundColor Green
}
else {
    Write-Host '⚠️  Orchestrator no compilado - compilando ahora...' -ForegroundColor Yellow
    Push-Location agents\orchestrator
    npm run build
    Pop-Location
    
    if (Test-Path "agents\orchestrator\dist") {
        Write-Host '✅ Build completado' -ForegroundColor Green
    }
    else {
        Write-Host '❌ Error al compilar orchestrator' -ForegroundColor Red
        exit 1
    }
}

# 3. Iniciar todos los servicios
Write-Host '[3/6] Iniciando servicios (n8n, redis, postgres, orchestrator, tunnel)...' -ForegroundColor Yellow
docker-compose up -d

# 4. Esperar a que servicios estén listos
Write-Host '[4/6] Esperando a que servicios estén listos...' -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verificar cada servicio
$services = @('n8n-v2', 'miconsul-redis', 'miconsul-postgres', 'n8n-tunnel', 'miconsul-orchestrator')
foreach ($service in $services) {
    $status = docker ps --filter "name=$service" --format "{{.Status}}"
    if ($status -match "Up") {
        Write-Host "  ✅ $service corriendo" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  $service no está corriendo aún" -ForegroundColor Yellow
    }
}

# 5. Obtener URL de Cloudflare Tunnel
Write-Host '[5/6] Obteniendo URL de Cloudflare Tunnel...' -ForegroundColor Yellow
Start-Sleep -Seconds 5
$log = docker logs n8n-tunnel 2>&1
$match = $log | Select-String -Pattern "https://.*\.trycloudflare\.com" | Select-Object -Last 1

if ($match) {
    $url = $match.Line -replace '.*?(https://[^\s]+\.trycloudflare\.com).*', '$1'
    $url = $url.Trim()
    
    Write-Host "  ✅ URL Detectada: $url" -ForegroundColor Green
    
    # Actualizar .env
    $envContent = Get-Content '.env'
    $envContent = $envContent -replace 'WEBHOOK_URL=.*', "WEBHOOK_URL=$url"
    $envContent | Set-Content '.env'
    
    # --- Actualizar configuración persistente del Tenant ---
    if ($tenantEnvFile -and (Test-Path $tenantEnvFile)) {
        Write-Host "  💾 Guardando URL en configuración de '$tenant'..." -ForegroundColor Cyan
        $tenantContent = Get-Content $tenantEnvFile
        $tenantContent = $tenantContent -replace 'WEBHOOK_URL=.*', "WEBHOOK_URL=$url"
        $tenantContent | Set-Content $tenantEnvFile
    }
    # -----------------------------------------------------
    
    Write-Host '  ✅ Archivo .env actualizado' -ForegroundColor Green
    
    # 6. Reiniciar para aplicar nueva URL
    Write-Host '[6/6] Aplicando configuración final (reinicio)...' -ForegroundColor Yellow
    docker-compose restart n8n orchestrator
    Start-Sleep -Seconds 10
}
else {
    Write-Host '  ⚠️  No se pudo detectar la URL todavia. Reintenta en 1 minuto.' -ForegroundColor Yellow
}

# Resumen final
Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  🚀 Sistema Completamente Operativo  ' -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Cyan
if ($url) { 
    Write-Host "  📡 n8n Editor: $url" -ForegroundColor Green 
    Write-Host "  📡 Webhooks: $url/webhook/<path>" -ForegroundColor Green
}
Write-Host "  📊 Orchestrator Dashboard: http://localhost:3000/api/dashboard" -ForegroundColor Green
Write-Host "  🔄 Monitoring Loop: Activo (cada 30s)" -ForegroundColor Cyan
Write-Host "  🔮 Predictive Loop: Activo (cada 1min)" -ForegroundColor Cyan
Write-Host "  ⚡ Optimization Loop: Activo (cada 5min)" -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Para ver logs del orchestrator: docker logs miconsul-orchestrator -f' -ForegroundColor Yellow
Write-Host 'Para verificar estado: docker-compose ps' -ForegroundColor Yellow
Write-Host ''
