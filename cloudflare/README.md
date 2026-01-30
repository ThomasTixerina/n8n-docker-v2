# Configuración de Cloudflare

Este directorio contiene la configuración para el túnel de Cloudflare, que permite
exponer n8n de forma segura a través de un puerto seguro.

## Cloudflare Tunnel

Cloudflare Tunnel proporciona una conexión segura entre tu servidor y Cloudflare sin 
necesidad de abrir puertos en tu firewall.

## Configuración

### Requisitos previos

1. Cuenta de Cloudflare
2. Dominio configurado en Cloudflare
3. Cloudflared instalado

### Archivo de configuración

- **config.yml**: Configuración del túnel de Cloudflare
- **credentials.json**: (No incluir en git) Credenciales del túnel

### Instalación de cloudflared

```bash
# Linux/Mac
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/

# Docker (ver docker-compose en este directorio)
```

### Crear un túnel

```bash
cloudflared tunnel login
cloudflared tunnel create n8n-tunnel
cloudflared tunnel route dns n8n-tunnel n8n.tu-dominio.com
```

### Ejecutar el túnel

```bash
cloudflared tunnel --config cloudflare/config.yml run
```

O usando Docker Compose (recomendado).

## Notas de Seguridad

⚠️ **IMPORTANTE**: 
- No subir `credentials.json` al repositorio
- Usar variables de entorno para tokens sensibles
- Mantener actualizado cloudflared
