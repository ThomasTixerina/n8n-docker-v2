# 📚 Índice de Documentación - Proyecto n8n

## 🎯 Inicio Rápido

1. **[README.md](README.md)** - Documentación principal del proyecto
2. **[GUIA_MCP.md](GUIA_MCP.md)** - Guía de configuración MCP completa
3. **[.env.template](.env.template)** - Plantilla de variables de entorno

## 🚀 Scripts de Automatización

### Scripts PowerShell

| Script | Descripción | Uso |
|--------|-------------|-----|
| `start-n8n.ps1` | Inicia el entorno completo de n8n | `.\start-n8n.ps1` |
| `monitor-n8n.ps1` | Monitorea el estado del sistema | `.\monitor-n8n.ps1` |
| `setup-autostart.ps1` | Configura inicio automático | `.\setup-autostart.ps1` (Admin) |

### Workflows Automatizados

| Workflow | Archivo | Descripción |
|----------|---------|-------------|
| Inicio de n8n | `.agent/workflows/n8n-startup.md` | Proceso completo de inicio |
| Publicación | `.agent/workflows/publish-workflow.md` | Publicar workflows a producción |

## 📋 Workflows de n8n

### Workflows de Producción

| Nombre | Archivo | Propósito |
|--------|---------|-----------|
| Fidelización Email/WhatsApp | `fidelizacion_email_whatsapp.json` | Envío combinado de mensajes |
| Fidelización YCloud | `fidelizacion_ycloud.json` | Mensajería WhatsApp vía YCloud |
| Pacientes Nuevos | `fidelizacion_pacientes_nuevos.json` | Bienvenida a nuevos pacientes |
| Hub de Eventos | `mi_consul_hub_eventos.json` | Centro de distribución de eventos |
| Reporte Diario | `reporte_diario_doctores.json` | Reportes automáticos |

### Workflows de Prueba

| Nombre | Archivo | Propósito |
|--------|---------|-----------|
| Test Webhook | `webhook_test_workflow.json` | Pruebas de webhooks |
| Test Fidelización | `test_fidelizacion_manual.json` | Pruebas manuales |

## 📖 Guías y Documentación

| Documento | Descripción |
|-----------|-------------|
| `guia_whatsapp.md` | Guía de integración WhatsApp |
| `guia_ycloud_whatsapp.md` | Guía específica de YCloud |
| `modernizacion_plan.md` | Plan de modernización del sistema |

## ⚙️ Archivos de Configuración

### Configuración Principal

| Archivo | Propósito |
|---------|-----------|
| `.env` | Variables de entorno (NO subir a Git) |
| `.env.template` | Plantilla de variables |
| `docker-compose.yml` | Configuración de Docker |
| `.gitignore` | Archivos excluidos de Git |

### Configuración MCP

| Archivo | Propósito |
|---------|-----------|
| `.agent/mcp-config.yaml` | Configuración MCP principal |
| `.vscode/settings.json` | Configuración de VSCode |

## 🌐 URLs del Proyecto

| Servicio | URL |
|----------|-----|
| Editor n8n | https://postcards-actor-logging-procedure.trycloudflare.com/ |
| Health Check | https://postcards-actor-logging-procedure.trycloudflare.com/healthz |
| Webhooks | Variable (ver logs de Cloudflare) |

## 🔧 Comandos Frecuentes

### Docker

```powershell
# Iniciar servicios
docker-compose up -d

# Ver logs
docker logs n8n-v2 -f
docker logs n8n-tunnel -f

# Reiniciar
docker-compose restart

# Detener
docker-compose down

# Ver estado
docker-compose ps
```

### Monitoreo

```powershell
# Estado completo
.\monitor-n8n.ps1

# Logs de n8n
docker logs n8n-v2 --tail 50

# URL de Cloudflare
docker logs n8n-tunnel 2>&1 | Select-String "https://"
```

### Validación

```powershell
# Validar workflows
Get-ChildItem -Filter "*.json" | ForEach-Object {
    Get-Content $_.FullName | ConvertFrom-Json
}

# Health check
curl https://postcards-actor-logging-procedure.trycloudflare.com/healthz
```

### Git

```powershell
# Agregar cambios
git add *.json *.md

# Commit
git commit -m "Update workflows"

# Push
git push origin main
```

## 📁 Estructura del Proyecto

```
n8n-infrastructure/
├── 📂 .agent/                          # Configuración de agente
│   ├── 📄 mcp-config.yaml             # Config MCP
│   └── 📂 workflows/                   # Workflows automatizados
│       ├── 📄 n8n-startup.md          # Inicio automático
│       └── 📄 publish-workflow.md     # Publicación
│
├── 📂 .vscode/                         # Configuración VSCode
│   └── 📄 settings.json               # Settings del editor
│
├── 📂 workflows/ (implícito)           # Workflows de n8n
│   ├── 📄 fidelizacion_*.json         # Workflows de fidelización
│   ├── 📄 mi_consul_hub_eventos.json  # Hub de eventos
│   ├── 📄 reporte_diario_doctores.json # Reportes
│   └── 📄 webhook_test_workflow.json  # Tests
│
├── 📂 scripts/ (implícito)             # Scripts de automatización
│   ├── 📄 start-n8n.ps1               # Inicio
│   ├── 📄 monitor-n8n.ps1             # Monitoreo
│   └── 📄 setup-autostart.ps1         # Autostart
│
├── 📂 docs/ (implícito)                # Documentación
│   ├── 📄 README.md                   # Documentación principal
│   ├── 📄 GUIA_MCP.md                 # Guía MCP
│   ├── 📄 INDICE.md                   # Este archivo
│   ├── 📄 guia_whatsapp.md            # Guía WhatsApp
│   ├── 📄 guia_ycloud_whatsapp.md     # Guía YCloud
│   └── 📄 modernizacion_plan.md       # Plan de modernización
│
├── 📄 .env                             # Variables de entorno (NO GIT)
├── 📄 .env.template                    # Plantilla de .env
├── 📄 .gitignore                       # Exclusiones de Git
└── 📄 docker-compose.yml               # Configuración Docker
```

## 🔐 Seguridad

### Archivos Sensibles (NO subir a Git)

- `.env` - Contiene todas las credenciales
- `n8n_data/` - Datos de n8n
- `backups/` - Backups locales
- `*.log` - Archivos de log

### Variables Sensibles

- `N8N_MCP_TOKEN` - Token MCP
- `GITHUB_TOKEN` - Token GitHub
- `SSH_PASSWORD` - Contraseña SSH
- `DB_PASSWORD` - Contraseña DB

## 🆘 Solución de Problemas

### Problemas Comunes

| Problema | Solución | Comando |
|----------|----------|---------|
| n8n no inicia | Ver logs y reiniciar | `docker logs n8n-v2` |
| Tunnel no conecta | Reiniciar cloudflared | `docker-compose restart cloudflared` |
| Webhooks fallan | Actualizar WEBHOOK_URL | `.\start-n8n.ps1` |
| MCP no reconoce archivos | Verificar config | Ver `.agent/mcp-config.yaml` |

### Logs Útiles

```powershell
# Logs de n8n
docker logs n8n-v2 --tail 100

# Logs de Cloudflare
docker logs n8n-tunnel --tail 50

# Logs de Docker Compose
docker-compose logs
```

## 📞 Recursos Adicionales

### Documentación Externa

- [n8n Documentation](https://docs.n8n.io)
- [Docker Compose](https://docs.docker.com/compose/)
- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Model Context Protocol](https://modelcontextprotocol.io)

### Repositorios

- n8n: https://github.com/n8n-io/n8n
- Cloudflare Tunnel: https://github.com/cloudflare/cloudflared

## 🔄 Flujo de Trabajo Recomendado

### 1️⃣ Inicio del Día
```powershell
.\monitor-n8n.ps1
```

### 2️⃣ Desarrollo
1. Editar workflows en n8n
2. Exportar como JSON
3. Guardar en proyecto

### 3️⃣ Validación
```powershell
Get-Content workflow.json | ConvertFrom-Json
```

### 4️⃣ Publicación
```powershell
git add workflow.json
git commit -m "Add workflow"
git push
```

### 5️⃣ Monitoreo
```powershell
docker logs n8n-v2 -f
```

## 📊 Checklist de Configuración Inicial

- [ ] Docker Desktop instalado y corriendo
- [ ] Archivo `.env` configurado con credenciales
- [ ] Contenedores iniciados (`docker-compose up -d`)
- [ ] URL de Cloudflare obtenida
- [ ] n8n accesible en el navegador
- [ ] Webhooks funcionando
- [ ] Inicio automático configurado (opcional)
- [ ] Git configurado y sincronizado
- [ ] VSCode con extensiones instaladas

## 📝 Notas Importantes

1. **Servidor 24/7**: Este proyecto está diseñado para funcionar continuamente
2. **Auto-restart**: Los contenedores se reinician automáticamente
3. **Backups**: Se crean automáticamente antes de publicar
4. **Cloudflare**: La URL puede cambiar al reiniciar el tunnel
5. **Git**: Nunca subir el archivo `.env` al repositorio

## 🎓 Aprendizaje

### Para Nuevos Usuarios

1. Leer [README.md](README.md)
2. Revisar [GUIA_MCP.md](GUIA_MCP.md)
3. Configurar `.env` desde `.env.template`
4. Ejecutar `.\start-n8n.ps1`
5. Abrir n8n en el navegador
6. Explorar workflows existentes

### Para Desarrolladores

1. Entender la estructura del proyecto
2. Revisar workflows en `.agent/workflows/`
3. Estudiar configuración MCP
4. Practicar con workflows de prueba
5. Crear nuevos workflows
6. Documentar cambios

---

**Última actualización**: 2025-12-25  
**Versión**: 1.0  
**Mantenedor**: Thomas Tixerina  
**Proyecto**: n8n Production Server

---

## 🎯 Acceso Rápido

- **Iniciar**: `.\start-n8n.ps1`
- **Monitorear**: `.\monitor-n8n.ps1`
- **Editor**: https://postcards-actor-logging-procedure.trycloudflare.com/
- **Logs**: `docker logs n8n-v2 -f`
- **Ayuda**: Ver [GUIA_MCP.md](GUIA_MCP.md)
