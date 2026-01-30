# Guía de Prueba - MiConsul Platform

## 🧪 Objetivo
Verificar que el sistema de provisioning y el orquestador funcionan correctamente.

---

## Paso 1: Verificar Prerrequisitos

### Verificar Docker
```powershell
# Verificar que Docker está corriendo
docker --version
docker ps

# Si Docker no está corriendo, iniciarlo desde Docker Desktop
```

### Verificar Node.js
```powershell
# Verificar versión de Node.js (debe ser 18+)
node --version

# Verificar npm
npm --version
```

### Crear Red Docker
```powershell
# Crear la red si no existe
docker network create miconsul-network

# Verificar que se creó
docker network ls | Select-String "miconsul"
```

---

## Paso 2: Crear Cliente de Prueba

```powershell
# Asegúrate de estar en el directorio raíz del proyecto
cd "C:\Users\Thomas Tixerina\.gemini\antigravity\scratch\n8n-docker-v2"

# Ejecutar script de provisioning
.\scripts\create_client_instance.ps1 `
  -TenantId "test-dental" `
  -TenantName "Test Dental Clinic" `
  -Plan "basic" `
  -Port 5679
```

**Tiempo estimado:** 5-10 minutos

**Qué esperar:**
- ✅ Directorio `clients/test-dental/` creado
- ✅ Archivos `docker-compose.yml`, `.env`, `config.json` generados
- ✅ Contenedores Docker iniciados
- ✅ n8n respondiendo en http://localhost:5679
- ✅ URL de Cloudflare obtenida

**Si hay errores:**
- Verificar que el puerto 5679 no esté en uso
- Verificar que Docker Desktop está corriendo
- Revisar logs: `docker logs n8n-test-dental`

---

## Paso 3: Verificar el Cliente

### Verificar Contenedores
```powershell
# Ver contenedores del cliente
docker ps | Select-String "test-dental"

# Deberías ver 3 contenedores:
# - n8n-test-dental
# - postgres-test-dental
# - cloudflared-test-dental
```

### Verificar n8n
```powershell
# Health check
curl http://localhost:5679/healthz

# Debería responder con status 200
```

### Ver Configuración
```powershell
# Ver el archivo de configuración generado
cd clients\test-dental
Get-Content config.json | ConvertFrom-Json | ConvertTo-Json -Depth 10

# Ver información de instalación
Get-Content INSTALL_INFO.txt
```

### Obtener URL Pública
```powershell
# Ver logs de Cloudflare para obtener la URL pública
docker logs cloudflared-test-dental 2>&1 | Select-String "https://"
```

---

## Paso 4: Configurar el Orquestador

### Instalar Dependencias
```powershell
# Ir al directorio del orquestador
cd ..\..\agents\orchestrator

# Instalar dependencias (primera vez)
npm install
```

**Tiempo estimado:** 2-3 minutos

### Configurar Variables de Entorno
```powershell
# Copiar template
Copy-Item .env.example .env

# Editar .env
notepad .env
```

**Configuración mínima para pruebas:**
```env
NODE_ENV=development
PORT=3000
HOST=0.0.0.0

# Redis (si usas Docker local)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# PostgreSQL (si usas Docker local)
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=orchestrator
POSTGRES_USER=orchestrator
POSTGRES_PASSWORD=change_me

# Loops
MONITORING_LOOP_INTERVAL=30000
```

**Nota:** Para esta prueba, el orquestador puede funcionar sin Redis/PostgreSQL si solo queremos ver que carga los tenants. Los servicios de base de datos son opcionales para testing básico.

---

## Paso 5: Iniciar el Orquestador

```powershell
# Modo desarrollo (con hot-reload)
npm run dev
```

**Qué esperar en los logs:**
```
🚀 MiConsul Orchestrator is running on: http://localhost:3000
📊 Dashboard available at: http://localhost:3000/api/dashboard
🔄 Agent loops starting...
[TenantManagerService] Loading tenants from filesystem...
[TenantManagerService] Loaded tenant: Test Dental Clinic (test-dental)
[TenantManagerService] ✅ Loaded 1 tenants
[EventBusService] Initializing Event Bus...
[EventBusService] ✅ Event Bus initialized
```

**Si hay errores de Redis:**
- El orquestador intentará conectar pero continuará funcionando
- Para pruebas básicas, esto es aceptable
- Para producción, necesitarás Redis corriendo

---

## Paso 6: Probar la API del Orquestador

### En otra terminal PowerShell:

```powershell
# Ver estado del sistema
curl http://localhost:3000/api/dashboard/status

# Ver lista de tenants
curl http://localhost:3000/api/dashboard/tenants

# Ver tenant específico
curl http://localhost:3000/api/dashboard/tenants/test-dental
```

**Respuesta esperada de `/status`:**
```json
{
  "status": "healthy",
  "uptime": 45.67,
  "timestamp": "2025-12-25T15:35:00.000Z",
  "tenants": {
    "total": 1,
    "active": 1,
    "suspended": 0
  },
  "loops": {
    "monitoring": "running",
    "optimization": "pending",
    "predictive": "pending",
    "learning": "pending",
    "maintenance": "pending"
  }
}
```

---

## Paso 7: Verificar Monitoring Loop

El monitoring loop se ejecuta cada 30 segundos. En los logs del orquestador deberías ver:

```
[MonitoringLoop] 🔍 Monitoring 1 tenants...
[MonitoringLoop] Health check failed for test-dental: connect ECONNREFUSED 127.0.0.1:5679
```

**Nota:** Es normal que falle si n8n aún no está completamente listo. Espera 1-2 minutos y debería empezar a pasar:

```
[EventBusService] 📢 Event emitted: health.check.passed (tenant: test-dental)
```

---

## Paso 8: Acceder a n8n

### Localmente
```
http://localhost:5679
```

### Públicamente
Usa la URL de Cloudflare obtenida en el Paso 3.

**Primera vez:**
- n8n te pedirá crear una cuenta
- Crea usuario y contraseña
- ¡Ya puedes crear workflows!

---

## ✅ Checklist de Verificación

Marca cada item cuando lo completes:

- [ ] Docker Desktop está corriendo
- [ ] Red `miconsul-network` creada
- [ ] Cliente `test-dental` creado exitosamente
- [ ] 3 contenedores corriendo (n8n, postgres, cloudflared)
- [ ] n8n responde en http://localhost:5679
- [ ] URL de Cloudflare obtenida
- [ ] Orquestador instalado (`npm install` exitoso)
- [ ] Orquestador iniciado (`npm run dev`)
- [ ] Orquestador cargó el tenant test-dental
- [ ] API `/status` responde correctamente
- [ ] API `/tenants` muestra test-dental
- [ ] Monitoring loop se ejecuta cada 30s
- [ ] Puedes acceder a n8n en el navegador

---

## 🐛 Troubleshooting

### Error: Puerto en uso
```powershell
# Ver qué está usando el puerto
netstat -ano | findstr :5679

# Cambiar a otro puerto
.\scripts\create_client_instance.ps1 -TenantId "test-dental" -TenantName "Test" -Plan "basic" -Port 5680
```

### Error: Docker network not found
```powershell
docker network create miconsul-network
```

### Error: npm install falla
```powershell
# Limpiar cache
npm cache clean --force

# Intentar de nuevo
npm install
```

### Orquestador no carga tenants
```powershell
# Verificar que existe el directorio
ls clients\test-dental

# Verificar que existe config.json
ls clients\test-dental\config.json

# Ver contenido
Get-Content clients\test-dental\config.json
```

### Monitoring loop falla
- Espera 1-2 minutos para que n8n inicie completamente
- Verifica que n8n responde: `curl http://localhost:5679/healthz`
- Revisa logs de n8n: `docker logs n8n-test-dental`

---

## 🎯 Resultado Esperado

Al final de esta prueba deberías tener:

1. ✅ Un cliente `test-dental` funcionando
2. ✅ n8n accesible local y públicamente
3. ✅ Orquestador monitoreando el cliente
4. ✅ API REST respondiendo correctamente
5. ✅ Logs mostrando health checks cada 30s

---

## 📝 Siguiente Paso

Una vez que todo funcione:
1. Crea un workflow simple en n8n
2. Observa los logs del monitoring loop
3. Prueba crear un segundo cliente con otro puerto
4. Verifica que el orquestador detecta ambos

---

**¿Listo para empezar?** Ejecuta los comandos del Paso 1 y avísame si encuentras algún problema.
