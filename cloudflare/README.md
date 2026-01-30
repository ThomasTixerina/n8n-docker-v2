# Configuración de Cloudflare

Este directorio contiene la configuración para el túnel de Cloudflare, que permite
exponer n8n de forma segura a través de una conexión cifrada.

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

Para ejecutar el túnel completo junto con n8n, es necesario usar ambos docker-compose:

```bash
# Desde el directorio raíz del proyecto
cd docker
docker-compose up -d

cd ../cloudflare  
docker-compose up -d
```

**Nota**: El túnel de Cloudflare depende de que n8n esté corriendo en la red `n8n_network` 
que se crea automáticamente con el docker-compose principal.

## Notas de Seguridad

⚠️ **IMPORTANTE**: 
- No subir `credentials.json` al repositorio
- Usar variables de entorno para tokens sensibles
- Mantener actualizado cloudflared
