# Script para crear una tarea programada que inicie n8n automáticamente
# Este script debe ejecutarse con privilegios de administrador

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configurar Inicio Automático de n8n  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar privilegios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠ Este script requiere privilegios de administrador" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Por favor, ejecuta PowerShell como Administrador y vuelve a ejecutar este script" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

$taskName = "n8n-AutoStart"
$scriptPath = "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure\start-n8n.ps1"
$userName = $env:USERNAME

Write-Host "Configurando tarea programada..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Nombre de la tarea: $taskName" -ForegroundColor Gray
Write-Host "  Script: $scriptPath" -ForegroundColor Gray
Write-Host "  Usuario: $userName" -ForegroundColor Gray
Write-Host ""

# Eliminar tarea existente si existe
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "Eliminando tarea existente..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "✓ Tarea existente eliminada" -ForegroundColor Green
}

# Crear acción
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""

# Crear trigger (al iniciar sesión)
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $userName

# Crear trigger adicional (al iniciar el sistema con retraso)
$triggerStartup = New-ScheduledTaskTrigger -AtStartup
$triggerStartup.Delay = "PT2M"  # Retraso de 2 minutos

# Configuración de la tarea
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

# Crear principal (ejecutar con privilegios más altos)
$principal = New-ScheduledTaskPrincipal -UserId $userName -LogonType Interactive -RunLevel Highest

# Registrar la tarea
try {
    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger, $triggerStartup `
        -Settings $settings `
        -Principal $principal `
        -Description "Inicia automáticamente el entorno n8n con Docker y Cloudflare Tunnel al iniciar el sistema"
    
    Write-Host ""
    Write-Host "✓ Tarea programada creada exitosamente" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar información de la tarea
    $task = Get-ScheduledTask -TaskName $taskName
    Write-Host "📋 Información de la Tarea:" -ForegroundColor Cyan
    Write-Host "  Estado: $($task.State)" -ForegroundColor White
    Write-Host "  Última ejecución: $($task.LastRunTime)" -ForegroundColor White
    Write-Host "  Próxima ejecución: $($task.NextRunTime)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🎯 Triggers configurados:" -ForegroundColor Cyan
    Write-Host "  1. Al iniciar sesión del usuario $userName" -ForegroundColor White
    Write-Host "  2. Al iniciar el sistema (con retraso de 2 minutos)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔧 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "  Ver tarea:      Get-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
    Write-Host "  Ejecutar ahora: Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
    Write-Host "  Deshabilitar:   Disable-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
    Write-Host "  Habilitar:      Enable-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
    Write-Host "  Eliminar:       Unregister-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
    Write-Host ""
    
    # Preguntar si desea ejecutar ahora
    Write-Host "¿Deseas ejecutar la tarea ahora para probar? (S/N): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    
    if ($response -eq "S" -or $response -eq "s") {
        Write-Host ""
        Write-Host "Ejecutando tarea..." -ForegroundColor Yellow
        Start-ScheduledTask -TaskName $taskName
        Start-Sleep -Seconds 2
        Write-Host "✓ Tarea ejecutada" -ForegroundColor Green
        Write-Host ""
        Write-Host "Verifica el estado con: Get-ScheduledTaskInfo -TaskName '$taskName'" -ForegroundColor Gray
    }
    
}
catch {
    Write-Host ""
    Write-Host "✗ Error al crear la tarea programada" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuración Completada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "n8n se iniciará automáticamente cuando:" -ForegroundColor White
Write-Host "  • Inicies sesión en Windows" -ForegroundColor Gray
Write-Host "  • El sistema se reinicie" -ForegroundColor Gray
Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
