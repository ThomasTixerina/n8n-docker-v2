# ✅ DEPLOYMENT COMPLETADO - Instrucciones de Prueba

**Fecha**: 2026-01-16 05:54
**Estado**: 🟢 100% OPERATIVO

---

## 🎉 ¡SISTEMA COMPLETAMENTE DEPLOY ADO!

### Contenedores Activos

```
✅ n8n-v2                - n8n Editor y Motor de Workflows
✅ n8n-tunnel            - Cloudflare Tunnel (Acceso Público)
✅ miconsul-redis        - Event Bus (Comunicación entre agentes)
✅ miconsul-postgres     - Base de Datos de Metadata
✅ miconsul-orchestrator - Agentes Autónomos (FUNCIONANDO)
```

### 🤖 Agentes Autónomos Corriendo

```
✅ SupportAgent        - Auto-healing activo
✅ DeploymentAgent     - Listo para deployments
✅ CustomizationAgent  - Listo para personalización
✅ MigrationAgent      - Listo para migraciones
✅ EventBus            - Redis conectado
```

---

## 🧪 INSTRUCCIONES PARA PROBAR N8N

### 1️⃣ Acceder a n8n Editor

**Opción A - Acceso Local** (recomendado para configuración inicial):
```
http://localhost:5678
```

**Opción B - Acceso Público** (para webhooks y acceso remoto):
1. Ejecuta este comando para obtener la URL pública:
   ```powershell
   docker logs n8n-tunnel 2>&1 | Select-String "trycloudflare.com" | Select-Object -Last 1
   ```
2. Busca una URL como: `https://xxxxx.trycloudflare.com`
3. Abre esa URL en tu navegador

**Primera vez usando n8n:**
- Si es primera vez, n8n te pedirá crear una cuenta
- Email: usa tu email
- Password: crea una contraseña segura
- Esto es solo local/para este servidor

---

### 2️⃣ Crear tu Primer Workflow de Prueba

#### Test Simple: Webhook → Debug

1. **Crear nuevo workflow**:
   - Click en "+ Create Workflow"
   
2. **Agregar nodo Webhook**:
   - Click en "+" para agregar nodo
   - Busca "Webhook"
   - Configura:
     - HTTP Method: `POST`
     - Path: `test-webhook`
     - Respond: `Immediately - 200`

3. **Agregar nodo de respuesta**:
   - Click en "+" después del Webhook
   - Busca "Code" o "Function"
   - En el código, pon:
     ```javascript
     return [{
       json: {
         message: "¡Webhook funcionando!",
         timestamp: new Date().toISOString(),
         data: $input.all()
       }
     }];
     ```

4. **Guardar y Activar**:
   - Click en "Save" (arriba derecha)
   - Pon nombre: "Test Webhook"
   - Toggle "Active" a ON

5. **Probar el webhook**:
   ```powershell
   # Desde PowerShell
   $webhookUrl = "http://localhost:5678/webhook/test-webhook"
   $body = @{
       test = "Hola desde PowerShell"
       timestamp = Get-Date -Format "o"
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri $webhookUrl -Method POST -Body $body -ContentType "application/json"
   ```

   **Deberías ver una respuesta como**:
   ```json
   {
     "message": "¡Webhook funcionando!",
     "timestamp": "2026-01-16T05:54:00.000Z",
     "data": [...]
   }
   ```

---

### 3️⃣ Verificar el Orchestrator Dashboard

El orchestrator tiene un dashboard para monitorear los agentes:

```
http://localhost:3000/api/dashboard
```

**Endpoints disponibles**:
- `/api/dashboard/status` - Estado general del sistema
- `/api/dashboard/tenants` - Lista de tenants (clientes)
- `/api/health` - Health check

**Probar desde PowerShell**:
```powershell
# Ver estado
Invoke-WebRequest -Uri "http://localhost:3000/api/dashboard" | Select-Object -ExpandProperty Content

# Health check
Invoke-WebRequest -Uri "http://localhost:3000/api/health"
```

---

### 4️⃣ Test de Webhook Público (Opcional)

Si necesitas probar webhooks desde internet (para integraciones externas):

1. **Obtener URL pública**:
   ```powershell
   docker logs n8n-tunnel 2>&1 | Select-String "trycloudflare" | Select-Object -Last 1
   ```

2. **Usar esa URL para webhooks**:
   ```
   https://xxxxx.trycloudflare.com/webhook/test-webhook
   ```

3. **Probar desde cualquier lugar**:
   ```bash
   curl -X POST https://xxxxx.trycloudflare.com/webhook/test-webhook \
     -H "Content-Type: application/json" \
     -d '{"test": "desde internet"}'
   ```

---

### 5️⃣ Crear Workflow de Automatización Real

#### Ejemplo: Notificación de Nuevos Pacientes

1. **Trigger**: Webhook recibe datos de nuevo paciente
2. **Process**: Extrae nombre, email, teléfono
3. **Action 1**: Enviar email de bienvenida
4. **Action 2**: Crear ticket en sistema
5. **Action 3**: Notificar a equipo por WhatsApp (YCloud)

**Nodos a usar**:
- Webhook (trigger)
- Code (procesamiento)
- HTTP Request (APIs externas)
- Email Send (notificaciones)

---

### 6️⃣ Monitorear Logs del Sistema

#### Ver logs de n8n:
```powershell
docker logs n8n-v2 -f
```

#### Ver logs del orchestrator (agentes autónomos):
```powershell
docker logs miconsul-orchestrator -f
```

**Logs que deberías ver** (orchestrator):
```
✅ Redis Publisher connected
✅ Redis Subscriber connected
✅ Event Bus initialized
✅ MiConsul Orchestrator is running
✅ Agent loops starting...
```

#### Ver logs de Redis (Event Bus):
```powershell
docker logs miconsul-redis --tail 50
```

---

### 7️⃣ Verificar que TODO esté corriendo

Ejecuta este comando para verificación completa:

```powershell
Write-Host "🔍 Verificación Completa del Sistema" -ForegroundColor Cyan
Write-Host ""

# Contenedores
Write-Host "📦 Contenedores Docker:" -ForegroundColor Yellow
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "n8n|redis|postgres|orchestrator"

# Health checks
Write-Host ""
Write-Host "🏥 Health Checks:" -ForegroundColor Yellow
Write-Host "  n8n:" -NoNewline
try { 
    $response = Invoke-WebRequest -Uri "http://localhost:5678" -TimeoutSec 5
    Write-Host " ✅ OK" -ForegroundColor Green
} catch {
    Write-Host " ❌ ERROR" -ForegroundColor Red
}

Write-Host "  Orchestrator:" -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 5
    Write-Host " ✅ OK" -ForegroundColor Green
} catch {
    Write-Host " ❌ ERROR" -ForegroundColor Red
}

Write-Host ""
Write-Host "🌐 URL Pública (Cloudflare):" -ForegroundColor Yellow
docker logs n8n-tunnel 2>&1 | Select-String "trycloudflare.com" | Select-Object -Last 1
```

---

## 🚀 Sistema Listo para Producción

### Auto-Inicio con Windows
Si quieres que todo arranque automáticamente al iniciar Windows:

```powershell
.\setup-autostart.ps1
```

Esto creará una tarea programada que ejecuta `start-n8n.ps1` al iniciar sesión.

### Reiniciar Todo el Stack
```powershell
docker-compose restart
```

### Detener Todo
```powershell
docker-compose down
```

### Iniciar Todo
```powershell
.\start-n8n.ps1
```

---

## 📊 Próximos Pasos Recomendados

### Para Desarrollo:
1. ✅ Crear workflows de prueba en n8n
2. ✅ Configurar credenciales (Email, APIs, etc.)
3. ✅ Probar webhooks públicos
4. ✅ Monitorear logs del orchestrator

### Para Producción:
1. ⚠️ Configurar dominio propio (en lugar de Cloudflare Tunnel temporal)
2. ⚠️ Configurar SSL/TLS permanente
3. ⚠️ Hacer backups de volúmenes Docker:
   - `n8n_data`
   - `postgres_data`
   - `redis_data`
4. ⚠️ Configurar monitoreo externo (Uptime monitoring)

---

## 🆘 Solución de Problemas

### n8n no responde:
```powershell
docker logs n8n-v2 --tail 50
docker restart n8n-v2
```

### Orchestrator con errores:
```powershell
docker logs miconsul-orchestrator --tail 100
docker restart miconsul-orchestrator
```

### Regenerar URL de Cloudflare:
```powershell
docker-compose restart cloudflared
Start-Sleep -Seconds 10
docker logs n8n-tunnel 2>&1 | Select-String "trycloudflare.com"
```

### Ver todos los contenedores:
```powershell
docker-compose ps
```

---

## 🎯 Confirmación Final

**Antes de empezar a usar:**
- [ ] n8n accesible en `http://localhost:5678`
- [ ] Orchestrator dashboard en `http://localhost:3000/api/dashboard`
- [ ] MCP configurado correctamente en `.agent/mcp-config.yaml`
- [ ] Todos los contenedores "Up" en `docker ps`
- [ ] Logs del orchestrator muestran "Redis connected"

**Si todo está ✅, estás listo para:**
- Crear workflows en n8n
- Configurar automatizaciones
- Usar webhooks públicos
- Servir múltiples clientes con multi-tenancy

---

🎉 **¡FELICIDADES! Tu servidor de automatización está 100% operativo** 🎉

Puedes empezar a crear workflows, configurar credenciales, y automatizar procesos para tus clientes.

**¿Tienes dudas?** Consulta:
- `GUIA_MCP.md` - Configuración MCP
- `AUDITORIA_SISTEMA.md` - Estado del sistema
- `docs/sistema_bucle_agentico.md` - Arquitectura de agentes
