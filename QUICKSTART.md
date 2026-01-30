# MiConsul Platform - Guía de Inicio Rápido

## 🚀 Instalación Inicial

### Prerrequisitos

- Docker Desktop instalado y corriendo
- Node.js 18+ (para el orquestador)
- PowerShell 7+ (Windows)
- Git
- Cuenta de GitHub

### 1. Configurar el Proyecto

```powershell
# Clonar o navegar al proyecto
cd "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure"

# Crear red Docker
docker network create miconsul-network
```

### 2. Configurar el Orquestador

```powershell
cd agents\orchestrator

# Copiar configuración de ejemplo
Copy-Item .env.example .env

# Editar .env con tus valores
# - REDIS_HOST, POSTGRES_HOST
# - GITHUB_TOKEN
# - Otros valores según necesites

# Instalar dependencias
npm install

# Compilar
npm run build
```

### 3. Iniciar Servicios del Orquestador

```powershell
# Iniciar Redis y PostgreSQL con Docker
docker-compose up -d

# Iniciar el orquestador
npm run dev
```

El orquestador estará disponible en: `http://localhost:3000`

### 4. Crear tu Primer Cliente

```powershell
# Volver al directorio raíz
cd ..\..

# Ejecutar script de provisioning
.\scripts\create_client_instance.ps1 `
  -TenantId "cdental" `
  -TenantName "C+Dental" `
  -Plan "pro" `
  -Port 5678
```

Este script:
- Crea el directorio `clients/cdental/`
- Genera configuración y credenciales
- Levanta stack Docker (n8n + PostgreSQL + Cloudflare)
- Registra el tenant en el orquestador

### 5. Verificar Instalación

```powershell
# Ver estado del orquestador
curl http://localhost:3000/api/dashboard/status

# Ver tenants registrados
curl http://localhost:3000/api/dashboard/tenants

# Ver logs de n8n
docker logs n8n-cdental -f

# Obtener URL de Cloudflare
docker logs cloudflared-cdental 2>&1 | Select-String "https://"
```

### 6. Acceder a n8n

- **Local**: http://localhost:5678
- **Pública**: URL obtenida de Cloudflare (ver logs)

---

## 📋 Comandos Útiles

### Gestión de Clientes

```powershell
# Crear nuevo cliente
.\scripts\create_client_instance.ps1 -TenantId "dental-abc" -TenantName "Dental ABC" -Plan "basic" -Port 5679

# Ver logs de un cliente
docker logs n8n-<tenant_id> -f

# Reiniciar cliente
cd clients\<tenant_id>
docker-compose restart

# Detener cliente
docker-compose down

# Eliminar cliente (con datos)
docker-compose down -v
```

### Orquestador

```powershell
cd agents\orchestrator

# Desarrollo (con hot-reload)
npm run dev

# Producción
npm run build
npm start

# Ver logs
# (Los logs se muestran en consola)

# Tests
npm test
```

### Docker

```powershell
# Ver todos los contenedores de MiConsul
docker ps --filter "label=miconsul.managed=true"

# Ver uso de recursos
docker stats

# Limpiar contenedores detenidos
docker container prune

# Limpiar volúmenes no usados
docker volume prune
```

---

## 🔧 Configuración Avanzada

### Configurar GitHub Integration

1. Crear organización en GitHub: `miconsul-workflows`
2. Generar Personal Access Token con permisos de repo
3. Agregar token al `.env` del orquestador:
   ```
   GITHUB_TOKEN=ghp_your_token_here
   ```

### Configurar Notificaciones

En `.env` del orquestador:
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
ADMIN_EMAIL=admin@miconsul.app
```

### Ajustar Intervalos de Loops

En `.env` del orquestador:
```
MONITORING_LOOP_INTERVAL=30000      # 30 segundos
OPTIMIZATION_LOOP_INTERVAL=300000   # 5 minutos
PREDICTIVE_LOOP_INTERVAL=60000      # 1 minuto
```

---

## 🐛 Solución de Problemas

### El orquestador no inicia

```powershell
# Verificar que Redis y PostgreSQL están corriendo
docker ps | Select-String "redis|postgres"

# Ver logs del orquestador
# (Revisar consola donde ejecutaste npm run dev)

# Verificar configuración
cat agents\orchestrator\.env
```

### Cliente no se crea correctamente

```powershell
# Verificar que la red Docker existe
docker network ls | Select-String "miconsul"

# Si no existe, crearla
docker network create miconsul-network

# Verificar puerto disponible
netstat -an | Select-String ":5678"

# Limpiar e intentar de nuevo
cd clients\<tenant_id>
docker-compose down -v
cd ..\..
Remove-Item -Recurse -Force clients\<tenant_id>
```

### n8n no responde

```powershell
# Ver logs
docker logs n8n-<tenant_id>

# Verificar salud
curl http://localhost:<port>/healthz

# Reiniciar
cd clients\<tenant_id>
docker-compose restart n8n-<tenant_id>
```

### Cloudflare Tunnel no conecta

```powershell
# Ver logs
docker logs cloudflared-<tenant_id>

# Reiniciar tunnel
cd clients\<tenant_id>
docker-compose restart cloudflared-<tenant_id>

# Esperar 10-15 segundos y obtener URL
docker logs cloudflared-<tenant_id> 2>&1 | Select-String "https://"
```

---

## 📊 Monitoreo

### Dashboard del Orquestador

Accede a: `http://localhost:3000/api/dashboard/status`

Verás:
- Estado general del sistema
- Número de tenants activos
- Estado de los loops
- Uptime del orquestador

### Métricas por Tenant

`http://localhost:3000/api/dashboard/tenants/<tenant_id>`

Verás:
- Uso de workflows
- Ejecuciones del mes
- Estado de salud
- Última verificación

---

## 🎓 Próximos Pasos

1. **Crear más clientes** para probar multi-tenancy
2. **Configurar GitHub** para versionado de workflows
3. **Implementar loops adicionales** (Optimization, Predictive, etc.)
4. **Configurar alertas** vía Slack o email
5. **Desarrollar workflows** personalizados para cada cliente

---

**Documentación completa**: Ver archivos en `/docs`
**Soporte**: Revisar logs y documentación técnica
