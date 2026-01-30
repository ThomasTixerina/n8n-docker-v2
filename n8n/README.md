# Configuración de n8n

Este directorio contiene archivos de configuración específicos de n8n.

## Archivos

- **config.json**: Configuración principal de n8n
- **credentials.json**: (Generado automáticamente) Credenciales encriptadas

## Descripción

Los archivos de este directorio se montan en el contenedor de Docker en `/home/node/.n8n/config/`

### config.json

Este archivo contiene la configuración de:
- Ejecuciones (guardado de datos)
- Seguridad (autenticación básica)
- Endpoints (REST API, webhooks)
- Zona horaria

## Notas de Seguridad

⚠️ **IMPORTANTE**: No subir archivos con credenciales reales al repositorio. 
Usar variables de entorno o archivos `.env` para información sensible.
