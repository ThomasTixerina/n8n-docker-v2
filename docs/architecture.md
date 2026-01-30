# Arquitectura del Sistema

## Visión General

Este proyecto implementa una instancia de n8n ejecutándose en Docker con acceso seguro a través de Cloudflare Tunnel.

```
┌─────────────────────────────────────────────┐
│           Internet / Cloudflare             │
└──────────────────┬──────────────────────────┘
                   │ (Cloudflare Tunnel)
                   │
┌──────────────────▼──────────────────────────┐
│         cloudflared container               │
│         (Puerto seguro)                     │
└──────────────────┬──────────────────────────┘
                   │ (Red interna Docker)
                   │
┌──────────────────▼──────────────────────────┐
│            n8n container                    │
│            Puerto: 5678                     │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  n8n Application                    │   │
│  │  - Workflows                        │   │
│  │  - Credenciales                     │   │
│  │  - Ejecuciones                      │   │
│  └─────────────────────────────────────┘   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│         Volúmenes persistentes              │
│         - n8n_data                          │
│         - workflows/                        │
│         - n8n/config                        │
└─────────────────────────────────────────────┘
```

## Componentes

### 1. n8n Container
- **Imagen**: n8nio/n8n:latest
- **Puerto**: 5678
- **Función**: Ejecuta la aplicación n8n
- **Volúmenes**:
  - `n8n_data`: Datos persistentes (workflows, credenciales, ejecuciones)
  - `workflows/`: Workflows compartidos
  - `n8n/config`: Configuración personalizada

### 2. Cloudflare Tunnel (Opcional)
- **Imagen**: cloudflare/cloudflared:latest
- **Función**: Proporciona acceso seguro desde internet
- **Conexión**: Se conecta al servicio n8n a través de la red interna de Docker

### 3. Volúmenes Docker
- **n8n_data**: Volumen Docker para datos persistentes
- **workflows/**: Directorio local montado para workflows
- **n8n/config**: Directorio local montado para configuración

## Flujo de datos

1. **Acceso local**: 
   ```
   Usuario → http://localhost:5678 → n8n
   ```

2. **Acceso remoto (con Cloudflare)**:
   ```
   Usuario → https://n8n.tu-dominio.com → Cloudflare → Tunnel → n8n
   ```

3. **Workflows**:
   ```
   n8n → Ejecuta workflows → APIs externas
   ```

4. **Webhooks**:
   ```
   API externa → Cloudflare/localhost → n8n → Procesa webhook
   ```

## Seguridad

### Capas de seguridad

1. **Autenticación básica de n8n**: Credenciales configuradas en `.env`
2. **Cloudflare Tunnel**: Cifrado end-to-end sin exponer puertos
3. **Red interna Docker**: Aislamiento de contenedores
4. **Variables de entorno**: Credenciales separadas del código

### Mejores prácticas

- No exponer el puerto 5678 directamente a internet
- Usar contraseñas fuertes en `.env`
- Mantener actualizado n8n y cloudflared
- Hacer backups regulares con `./scripts/backup.sh`
- No incluir credenciales en el repositorio

## Escalabilidad

Para escalar el sistema:

1. **Múltiples instancias**: Usar un balanceador de carga
2. **Base de datos externa**: Configurar PostgreSQL en lugar de SQLite
3. **Redis para queue**: Configurar Redis para el sistema de colas
4. **Almacenamiento externo**: Usar S3 u otro almacenamiento en la nube

## Monitoreo

Herramientas recomendadas:
- Docker stats para recursos
- Logs con `./scripts/logs.sh`
- Métricas de Cloudflare (si se usa)
- Webhooks de n8n para alertas
