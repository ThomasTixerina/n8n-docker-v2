---
description: Publicar workflows de n8n a producción
---

# Workflow de Publicación de n8n

Este workflow publica workflows de n8n al servidor de producción y los versiona en GitHub.

## Pasos de Ejecución

// turbo-all

### 1. Validar que el servidor n8n está activo
```powershell
curl -s https://activated-arrangements-divine-power.trycloudflare.com/healthz
```

### 2. Listar workflows disponibles para publicar
```powershell
Get-ChildItem -Path "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure" -Filter "*.json" | Where-Object { $_.Name -notlike "package*.json" } | Select-Object Name, LastWriteTime
```

### 3. Crear backup de workflows actuales
```powershell
$backupDir = "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure\backups\$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"
New-Item -ItemType Directory -Path $backupDir -Force
Copy-Item -Path "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure\*.json" -Destination $backupDir -Exclude "package*.json"
```

### 4. Validar formato JSON de workflows
```powershell
Get-ChildItem -Path "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure" -Filter "*.json" | Where-Object { $_.Name -notlike "package*.json" } | ForEach-Object {
    try {
        $null = Get-Content $_.FullName | ConvertFrom-Json
        Write-Host "✓ $($_.Name) - Válido" -ForegroundColor Green
    } catch {
        Write-Host "✗ $($_.Name) - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

### 5. Commit y push a GitHub (si hay cambios)
```powershell
cd "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure"
git add *.json *.md
git commit -m "Update workflows - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git push origin main
```

### 6. Verificar logs de n8n después de la publicación
```powershell
docker logs n8n-v2 --tail 20
```

## Workflows Principales del Proyecto

1. **fidelizacion_email_whatsapp.json** - Workflow de fidelización con email y WhatsApp
2. **fidelizacion_ycloud.json** - Workflow de fidelización con YCloud
3. **fidelizacion_pacientes_nuevos.json** - Workflow para pacientes nuevos
4. **mi_consul_hub_eventos.json** - Hub de eventos de Mi Consul
5. **reporte_diario_doctores.json** - Reportes diarios para doctores
6. **webhook_test_workflow.json** - Workflow de prueba de webhooks

## Checklist de Publicación

- [ ] Servidor n8n activo y accesible
- [ ] Workflows validados (JSON correcto)
- [ ] Backup creado exitosamente
- [ ] Cambios commiteados a GitHub
- [ ] Logs verificados sin errores
- [ ] Webhooks funcionando correctamente

## URLs de Verificación

- **Editor n8n**: https://activated-arrangements-divine-power.trycloudflare.com/
- **Health Check**: https://activated-arrangements-divine-power.trycloudflare.com/healthz
- **Webhook Base**: ${WEBHOOK_URL}
