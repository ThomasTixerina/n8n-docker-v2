# Guía de Configuración MCP para n8n

## 📋 Resumen

Esta guía explica cómo está configurado el Model Context Protocol (MCP) para trabajar con n8n de manera continua en este proyecto, incluyendo la integración con el **n8n MCP Server** externo (`leonardsellem/n8n-mcp-server` v0.1.8).

## 🎯 Objetivo

Configurar el entorno para que el MCP de n8n pueda:
- Reconocer automáticamente todos los archivos del proyecto
- Mantener la URL de n8n siempre disponible
- Trabajar de forma continua sin interrupciones
- Publicar workflows automáticamente
- **Permitir a asistentes AI gestionar workflows vía MCP** (nuevo)

## 📁 Archivos de Configuración

### 1. `.agent/mcp-config.yaml`
Configuración principal del MCP que incluye:
- URL del servidor n8n
- Asociaciones de extensiones de archivo
- Variables de entorno
- Herramientas disponibles
- Configuración de publicación

### 2. `.vscode/settings.json`
Configuración de VSCode para:
- Asociar extensiones de archivo con sus lenguajes
- Configurar formateo automático
- Establecer variables de entorno
- Excluir directorios innecesarios

### 3. `.env`
Variables de entorno del proyecto:
- Tokens de autenticación
- URLs de servicios
- Credenciales de base de datos
- Configuración SSH

## 🔌 n8n MCP Server (Nuevo)

### ¿Qué es?

El **n8n MCP Server** ([leonardsellem/n8n-mcp-server](https://github.com/leonardsellem/n8n-mcp-server)) es un servidor MCP comunitario (1500+ ⭐) que permite a asistentes AI (Claude, Cursor, etc.) interactuar con n8n a través del protocolo MCP.

**Versión actual**: v0.1.8  
**Docker image**: `leonardsellem/n8n-mcp-server:latest`  
**npm package**: `@leonardsellem/n8n-mcp-server`

### Configuración Docker

El MCP server corre como servicio en `docker-compose.yml`:

```yaml
n8n-mcp-server:
  image: leonardsellem/n8n-mcp-server:latest
  container_name: n8n-mcp-server
  environment:
    - N8N_API_URL=http://n8n:5678/api/v1
    - N8N_API_KEY=${N8N_API_KEY}
    - N8N_WEBHOOK_USERNAME=${N8N_WEBHOOK_USERNAME}
    - N8N_WEBHOOK_PASSWORD=${N8N_WEBHOOK_PASSWORD}
  depends_on:
    - n8n
  restart: unless-stopped
  networks:
    - n8n_network
```

### Variables de Entorno Requeridas

Agregar a `.env`:

```bash
# n8n MCP Server
N8N_API_KEY=tu_n8n_api_key_aqui
N8N_WEBHOOK_USERNAME=tu_webhook_usuario
N8N_WEBHOOK_PASSWORD=tu_webhook_password
```

### Generar API Key de n8n

1. Abrir n8n en el navegador
2. Ir a **Settings → API → API Keys**
3. Crear nueva API key con permisos apropiados
4. Copiar la key al archivo `.env`

### Herramientas MCP Disponibles

| Herramienta | Descripción |
|-------------|-------------|
| `workflow_list` | Listar todos los workflows |
| `workflow_get` | Obtener detalles de un workflow |
| `workflow_create` | Crear un nuevo workflow |
| `workflow_update` | Actualizar un workflow existente |
| `workflow_delete` | Eliminar un workflow |
| `workflow_activate` | Activar un workflow |
| `workflow_deactivate` | Desactivar un workflow |
| `execution_run` | Ejecutar un workflow |
| `run_webhook` | Ejecutar vía webhook |
| `execution_get` | Obtener detalles de ejecución |
| `execution_list` | Listar ejecuciones |
| `execution_stop` | Detener ejecución |

### Recursos MCP

- `n8n://workflows/list` — Lista de todos los workflows
- `n8n://workflow/{id}` — Detalles de workflow específico
- `n8n://executions/{workflowId}` — Lista de ejecuciones
- `n8n://execution/{id}` — Detalles de ejecución

### Integración con Claude Desktop / VS Code

```json
{
  "mcpServers": {
    "n8n": {
      "command": "node",
      "args": ["/path/to/n8n-mcp-server/build/index.js"],
      "env": {
        "N8N_API_URL": "http://localhost:5678/api/v1",
        "N8N_API_KEY": "YOUR_N8N_API_KEY"
      }
    }
  }
}
```

### Verificar Estado del MCP Server

```bash
docker logs n8n-mcp-server
docker inspect n8n-mcp-server --format='{{.State.Status}}'
```

## 🔧 Extensiones de Archivo Asociadas

El MCP reconoce automáticamente:

### Workflows de n8n
```
*.json
*.workflow.json
fidelizacion_*.json
webhook_*.json
test_*.json
mi_consul_*.json
reporte_*.json
```

### Documentación
```
*.md
guia_*.md
README.md
```

### Configuración
```
.env
.env.template
*.yaml
*.yml
docker-compose.yml
```

### Scripts
```
*.js
*.ts
*.ps1
test_*.js
```

## 🌐 URLs Configuradas

### URL Principal de n8n
```
https://postcards-actor-logging-procedure.trycloudflare.com/
```

Esta URL está configurada en:
- `docker-compose.yml` → `N8N_HOST` y `N8N_EDITOR_BASE_URL`
- `.agent/mcp-config.yaml` → `server.url`
- `.vscode/settings.json` → `n8n.baseUrl`

### URL de Webhooks (Dinámica)
```
${WEBHOOK_URL}
```

Esta URL se actualiza automáticamente:
- Al ejecutar `start-n8n.ps1`
- Se obtiene de los logs de Cloudflare Tunnel
- Se guarda en `.env`

## 🚀 Inicio Automático

### Opción 1: Manual
```powershell
cd "C:\Users\Thomas Tixerina\MCP\n8n-infrastructure"
.\start-n8n.ps1
```

### Opción 2: Automático al Iniciar Windows
```powershell
# Ejecutar como Administrador
.\setup-autostart.ps1
```

Esto crea una tarea programada que:
- Se ejecuta al iniciar sesión
- Se ejecuta al iniciar el sistema (con retraso de 2 minutos)
- Reinicia automáticamente si falla
- Se ejecuta con privilegios elevados

## 📊 Monitoreo

### Ver Estado del Entorno
```powershell
.\monitor-n8n.ps1
```

Muestra:
- Estado de contenedores Docker
- URL de Cloudflare Tunnel
- Health check de n8n
- Lista de workflows
- Uso de recursos
- Variables de entorno

### Comandos Docker Útiles
```powershell
# Ver logs en tiempo real
docker logs n8n-v2 -f
docker logs n8n-tunnel -f

# Ver estado de contenedores
docker-compose ps

# Reiniciar servicios
docker-compose restart

# Detener servicios
docker-compose down

# Iniciar servicios
docker-compose up -d
```

## 📝 Workflows Automatizados

### Iniciar Entorno
Archivo: `.agent/workflows/n8n-startup.md`

Pasos:
1. Verificar Docker
2. Navegar al directorio
3. Iniciar contenedores
4. Verificar estado
5. Obtener URL de Cloudflare
6. Mostrar logs

### Publicar Workflows
Archivo: `.agent/workflows/publish-workflow.md`

Pasos:
1. Validar servidor activo
2. Listar workflows
3. Crear backup
4. Validar JSON
5. Commit a GitHub
6. Verificar logs

## 🔐 Seguridad

### Archivos Protegidos
El `.gitignore` excluye:
- `.env` (credenciales)
- `n8n_data/` (datos de n8n)
- `backups/` (backups locales)
- `*.log` (archivos de log)
- Certificados y claves

### Variables Sensibles
Nunca subir a Git:
- `N8N_MCP_TOKEN`
- `GITHUB_TOKEN`
- `SSH_PASSWORD`
- `DB_PASSWORD`

## 🛠️ Herramientas MCP Disponibles

### 1. Workflow Validator
Valida workflows antes de publicar:
```powershell
Get-ChildItem -Filter "*.json" | ForEach-Object {
    $null = Get-Content $_.FullName | ConvertFrom-Json
}
```

### 2. Webhook Tester
Prueba webhooks automáticamente:
```powershell
curl -X POST "${WEBHOOK_URL}/webhook/test" -H "Content-Type: application/json" -d '{}'
```

### 3. GitHub Sync
Sincroniza workflows con GitHub:
```powershell
git add *.json *.md
git commit -m "Update workflows"
git push
```

## 📦 Estructura del Proyecto

```
n8n-infrastructure/
├── .agent/
│   ├── workflows/
│   │   ├── n8n-startup.md
│   │   └── publish-workflow.md
│   ├── skills/
│   │   ├── n8n-management/        # Gestión manual de n8n
│   │   ├── n8n-mcp-server/        # Integración MCP server (v0.1.8)
│   │   ├── creating-antigravity-skills/
│   │   ├── loopic-integration/
│   │   └── brand-identity/
│   └── mcp-config.yaml
├── .vscode/
│   └── settings.json
├── backups/
├── workflows/
│   ├── fidelizacion_email_whatsapp.json
│   ├── fidelizacion_ycloud.json
│   ├── fidelizacion_pacientes_nuevos.json
│   ├── mi_consul_hub_eventos.json
│   ├── reporte_diario_doctores.json
│   └── webhook_test_workflow.json
├── scripts/
│   ├── start-n8n.ps1
│   ├── monitor-n8n.ps1
│   └── setup-autostart.ps1
├── docs/
│   ├── guia_whatsapp.md
│   ├── guia_ycloud_whatsapp.md
│   └── modernizacion_plan.md
├── .env
├── .env.template
├── .gitignore
├── docker-compose.yml
└── README.md
```

## 🔄 Flujo de Trabajo Típico

### 1. Inicio del Día
```powershell
# Verificar que todo está corriendo
.\monitor-n8n.ps1
```

### 2. Crear/Editar Workflow
1. Abrir editor n8n: https://postcards-actor-logging-procedure.trycloudflare.com/
2. Crear o editar workflow
3. Exportar como JSON
4. Guardar en el directorio del proyecto

### 3. Validar y Publicar
```powershell
# Validar JSON
Get-Content workflow.json | ConvertFrom-Json

# Crear backup
.\start-n8n.ps1  # Incluye backup automático

# Publicar a GitHub
git add workflow.json
git commit -m "Add new workflow"
git push
```

### 4. Monitoreo Continuo
```powershell
# Ver logs en tiempo real
docker logs n8n-v2 -f

# Verificar health
curl https://postcards-actor-logging-procedure.trycloudflare.com/healthz
```

## 🆘 Solución de Problemas

### n8n no inicia
```powershell
# Ver logs
docker logs n8n-v2

# Reiniciar
docker-compose restart n8n

# Verificar .env
cat .env
```

### Cloudflare Tunnel no conecta
```powershell
# Ver logs
docker logs n8n-tunnel

# Reiniciar tunnel
docker-compose restart cloudflared

# Obtener nueva URL
docker logs n8n-tunnel 2>&1 | Select-String "https://"
```

### Webhooks no funcionan
```powershell
# Verificar URL en .env
cat .env | Select-String "WEBHOOK_URL"

# Actualizar URL
.\start-n8n.ps1

# Probar webhook
curl -X POST "${WEBHOOK_URL}/webhook/test"
```

### MCP no reconoce archivos
1. Verificar `.agent/mcp-config.yaml`
2. Verificar `.vscode/settings.json`
3. Reiniciar VSCode
4. Verificar extensiones de archivo

## 📚 Referencias

- [Documentación n8n](https://docs.n8n.io)
- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Model Context Protocol](https://modelcontextprotocol.io)

## 📞 Contacto y Soporte

Para problemas o preguntas:
1. Revisar logs: `docker logs n8n-v2`
2. Ejecutar monitor: `.\monitor-n8n.ps1`
3. Consultar documentación en `/docs`
4. Revisar workflows en `.agent/workflows/`

---

**Última actualización**: 2026-02-19
**Versión**: 2.0
**Autor**: Configuración automática MCP
