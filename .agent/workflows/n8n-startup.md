---
description: Iniciar entorno n8n con MCP y Cloudflare
---

# Workflow de Inicio de n8n

Este workflow inicia automáticamente el entorno completo de n8n con todas las configuraciones necesarias.

## Pasos de Ejecución

// turbo-all

### 1. Verificar que Docker está corriendo
```powershell
docker ps
```

### 2. Navegar al directorio del proyecto
```powershell
cd C:\Users\Thomas Tixerina\MCP\n8n-infrastructure
```

### 3. Iniciar los contenedores de n8n y Cloudflare
```powershell
docker-compose up -d
```

### 4. Verificar el estado de los contenedores
```powershell
docker-compose ps
```

### 5. Obtener la URL de Cloudflare
```powershell
docker logs n8n-tunnel 2>&1 | Select-String -Pattern "https://.*\.trycloudflare\.com"
```

### 6. Mostrar los logs de n8n
```powershell
docker logs n8n-v2 --tail 50
```

## Variables de Entorno Importantes

- **WEBHOOK_URL**: URL pública de Cloudflare para webhooks
- **N8N_MCP_TOKEN**: Token de autenticación para MCP
- **GITHUB_TOKEN**: Token para integración con GitHub

## URLs del Proyecto

- **Editor n8n**: https://activated-arrangements-divine-power.trycloudflare.com/
- **Webhooks**: La URL se genera dinámicamente al iniciar cloudflared

## Notas

- Los contenedores están configurados con `restart: always` para reiniciarse automáticamente
- El túnel de Cloudflare se regenera cada vez que se inicia
- Todos los datos se persisten en el volumen `n8n_data`
