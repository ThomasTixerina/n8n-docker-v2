# Script de Verificación de Configuración n8n + MCP
# Este script verifica que todo esté configurado correctamente

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verificación de Configuración n8n+MCP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Users\Thomas Tixerina\.gemini\antigravity\scratch\n8n-docker-v2"
Set-Location $projectDir

$passedChecks = 0
$totalChecks = 0

function Test-Check {
    param(
        [string]$Name,
        [bool]$Result,
        [string]$SuccessMessage,
        [string]$FailureMessage
    )
    
    $script:totalChecks++
    
    if ($Result) {
        Write-Host "✓ $Name" -ForegroundColor Green
        Write-Host "  $SuccessMessage" -ForegroundColor Gray
        $script:passedChecks++
        return $true
    } else {
        Write-Host "✗ $Name" -ForegroundColor Red
        Write-Host "  $FailureMessage" -ForegroundColor Yellow
        return $false
    }
}

Write-Host "🔍 Verificando Archivos de Configuración..." -ForegroundColor Cyan
Write-Host ""

# Verificar archivos principales
Test-Check -Name "Archivo .env" `
    -Result (Test-Path ".env") `
    -SuccessMessage "Archivo de variables de entorno encontrado" `
    -FailureMessage "Falta el archivo .env - Copia .env.template y configúralo"

Test-Check -Name "Archivo docker-compose.yml" `
    -Result (Test-Path "docker-compose.yml") `
    -SuccessMessage "Configuración de Docker encontrada" `
    -FailureMessage "Falta docker-compose.yml"

Test-Check -Name "Archivo .gitignore" `
    -Result (Test-Path ".gitignore") `
    -SuccessMessage "Configuración de Git encontrada" `
    -FailureMessage "Falta .gitignore"

Write-Host ""
Write-Host "🔧 Verificando Configuración MCP..." -ForegroundColor Cyan
Write-Host ""

Test-Check -Name "Configuración MCP" `
    -Result (Test-Path ".agent/mcp-config.yaml") `
    -SuccessMessage "Configuración MCP encontrada" `
    -FailureMessage "Falta .agent/mcp-config.yaml"

Test-Check -Name "Configuración VSCode" `
    -Result (Test-Path ".vscode/settings.json") `
    -SuccessMessage "Configuración de VSCode encontrada" `
    -FailureMessage "Falta .vscode/settings.json"

Test-Check -Name "Workflow de Inicio" `
    -Result (Test-Path ".agent/workflows/n8n-startup.md") `
    -SuccessMessage "Workflow de inicio encontrado" `
    -FailureMessage "Falta .agent/workflows/n8n-startup.md"

Test-Check -Name "Workflow de Publicación" `
    -Result (Test-Path ".agent/workflows/publish-workflow.md") `
    -SuccessMessage "Workflow de publicación encontrado" `
    -FailureMessage "Falta .agent/workflows/publish-workflow.md"

Write-Host ""
Write-Host "📜 Verificando Scripts..." -ForegroundColor Cyan
Write-Host ""

Test-Check -Name "Script de Inicio" `
    -Result (Test-Path "start-n8n.ps1") `
    -SuccessMessage "Script de inicio encontrado" `
    -FailureMessage "Falta start-n8n.ps1"

Test-Check -Name "Script de Monitoreo" `
    -Result (Test-Path "monitor-n8n.ps1") `
    -SuccessMessage "Script de monitoreo encontrado" `
    -FailureMessage "Falta monitor-n8n.ps1"

Test-Check -Name "Script de Autostart" `
    -Result (Test-Path "setup-autostart.ps1") `
    -SuccessMessage "Script de autostart encontrado" `
    -FailureMessage "Falta setup-autostart.ps1"

Write-Host ""
Write-Host "📚 Verificando Documentación..." -ForegroundColor Cyan
Write-Host ""

Test-Check -Name "README.md" `
    -Result (Test-Path "README.md") `
    -SuccessMessage "Documentación principal encontrada" `
    -FailureMessage "Falta README.md"

Test-Check -Name "GUIA_MCP.md" `
    -Result (Test-Path "GUIA_MCP.md") `
    -SuccessMessage "Guía MCP encontrada" `
    -FailureMessage "Falta GUIA_MCP.md"

Test-Check -Name "INDICE.md" `
    -Result (Test-Path "INDICE.md") `
    -SuccessMessage "Índice de documentación encontrado" `
    -FailureMessage "Falta INDICE.md"

Write-Host ""
Write-Host "🐳 Verificando Docker..." -ForegroundColor Cyan
Write-Host ""

$dockerRunning = $false
try {
    $null = docker ps 2>&1
    $dockerRunning = $LASTEXITCODE -eq 0
} catch {
    $dockerRunning = $false
}

Test-Check -Name "Docker Desktop" `
    -Result $dockerRunning `
    -SuccessMessage "Docker está corriendo correctamente" `
    -FailureMessage "Docker no está corriendo - Inicia Docker Desktop"

Write-Host ""
Write-Host "📦 Verificando Contenedores..." -ForegroundColor Cyan
Write-Host ""

if ($dockerRunning) {
    $n8nRunning = $false
    $tunnelRunning = $false
    
    try {
        $containers = docker ps --format "{{.Names}}" 2>&1
        $n8nRunning = $containers -contains "n8n-v2"
        $tunnelRunning = $containers -contains "n8n-tunnel"
    } catch {
        $n8nRunning = $false
        $tunnelRunning = $false
    }
    
    Test-Check -Name "Contenedor n8n" `
        -Result $n8nRunning `
        -SuccessMessage "Contenedor n8n está corriendo" `
        -FailureMessage "Contenedor n8n no está corriendo - Ejecuta .\start-n8n.ps1"
    
    Test-Check -Name "Contenedor Cloudflare" `
        -Result $tunnelRunning `
        -SuccessMessage "Cloudflare Tunnel está corriendo" `
        -FailureMessage "Cloudflare Tunnel no está corriendo - Ejecuta .\start-n8n.ps1"
} else {
    Write-Host "⚠ Saltando verificación de contenedores (Docker no está corriendo)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌐 Verificando Conectividad..." -ForegroundColor Cyan
Write-Host ""

if ($dockerRunning -and $n8nRunning) {
    try {
        $response = Invoke-WebRequest -Uri "https://postcards-actor-logging-procedure.trycloudflare.com/healthz" -TimeoutSec 5 -UseBasicParsing 2>&1
        $n8nAccessible = $response.StatusCode -eq 200
    } catch {
        $n8nAccessible = $false
    }
    
    Test-Check -Name "n8n Accesible" `
        -Result $n8nAccessible `
        -SuccessMessage "n8n está respondiendo en la URL configurada" `
        -FailureMessage "n8n no está accesible - Verifica los logs"
} else {
    Write-Host "⚠ Saltando verificación de conectividad (n8n no está corriendo)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Verificando Workflows..." -ForegroundColor Cyan
Write-Host ""

$workflows = Get-ChildItem -Path $projectDir -Filter "*.json" | Where-Object { 
    $_.Name -notlike "package*.json" -and 
    $_.Name -notlike "tsconfig*.json" 
}

$workflowCount = $workflows.Count
Test-Check -Name "Workflows Disponibles" `
    -Result ($workflowCount -gt 0) `
    -SuccessMessage "Encontrados $workflowCount workflows" `
    -FailureMessage "No se encontraron workflows"

# Validar JSON de workflows
$validWorkflows = 0
$invalidWorkflows = 0

foreach ($workflow in $workflows) {
    try {
        $null = Get-Content $workflow.FullName | ConvertFrom-Json
        $validWorkflows++
    } catch {
        $invalidWorkflows++
        Write-Host "  ⚠ $($workflow.Name) tiene errores de JSON" -ForegroundColor Yellow
    }
}

Test-Check -Name "Validación de Workflows" `
    -Result ($invalidWorkflows -eq 0) `
    -SuccessMessage "Todos los workflows tienen JSON válido ($validWorkflows/$workflowCount)" `
    -FailureMessage "$invalidWorkflows workflows tienen errores de JSON"

Write-Host ""
Write-Host "🔐 Verificando Variables de Entorno..." -ForegroundColor Cyan
Write-Host ""

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    
    $hasToken = $envContent -match "N8N_MCP_TOKEN=.+"
    $hasWebhook = $envContent -match "WEBHOOK_URL=.+"
    $hasGithub = $envContent -match "GITHUB_TOKEN=.+"
    
    Test-Check -Name "Token MCP" `
        -Result $hasToken `
        -SuccessMessage "Token MCP configurado" `
        -FailureMessage "Falta configurar N8N_MCP_TOKEN en .env"
    
    Test-Check -Name "URL de Webhook" `
        -Result $hasWebhook `
        -SuccessMessage "URL de Webhook configurada" `
        -FailureMessage "Falta configurar WEBHOOK_URL en .env"
    
    Test-Check -Name "Token GitHub" `
        -Result $hasGithub `
        -SuccessMessage "Token GitHub configurado" `
        -FailureMessage "Falta configurar GITHUB_TOKEN en .env"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resumen de Verificación" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$percentage = [math]::Round(($passedChecks / $totalChecks) * 100, 2)

Write-Host "Total de verificaciones: $totalChecks" -ForegroundColor White
Write-Host "Verificaciones exitosas: $passedChecks" -ForegroundColor Green
Write-Host "Verificaciones fallidas: $($totalChecks - $passedChecks)" -ForegroundColor Red
Write-Host "Porcentaje de éxito: $percentage%" -ForegroundColor $(if ($percentage -ge 80) { "Green" } elseif ($percentage -ge 50) { "Yellow" } else { "Red" })
Write-Host ""

if ($passedChecks -eq $totalChecks) {
    Write-Host "🎉 ¡Configuración perfecta! Todo está listo para usar." -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Cyan
    Write-Host "  1. Ejecuta .\start-n8n.ps1 para iniciar el entorno" -ForegroundColor Gray
    Write-Host "  2. Abre https://postcards-actor-logging-procedure.trycloudflare.com/" -ForegroundColor Gray
    Write-Host "  3. Comienza a crear workflows" -ForegroundColor Gray
} elseif ($percentage -ge 80) {
    Write-Host "✓ Configuración casi completa. Revisa los elementos faltantes arriba." -ForegroundColor Yellow
} else {
    Write-Host "⚠ Configuración incompleta. Revisa los elementos faltantes arriba." -ForegroundColor Red
    Write-Host ""
    Write-Host "Consulta la documentación:" -ForegroundColor Yellow
    Write-Host "  - README.md" -ForegroundColor Gray
    Write-Host "  - GUIA_MCP.md" -ForegroundColor Gray
    Write-Host "  - INDICE.md" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
