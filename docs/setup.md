# Guía de configuración inicial

## Requisitos previos

- Docker y Docker Compose instalados
- (Opcional) Cuenta de Cloudflare para túnel seguro
- Al menos 2GB de RAM disponible

## Pasos de instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/ThomasTixerina/n8n-docker-v2.git
cd n8n-docker-v2
```

### 2. Configurar variables de entorno

```bash
cp docker/.env.example docker/.env
```

Editar `docker/.env` con tus credenciales:

```env
N8N_USER=tu_usuario
N8N_PASSWORD=tu_contraseña_segura
N8N_HOST=localhost
```

### 3. Dar permisos a los scripts

```bash
chmod +x scripts/*.sh
```

### 4. Iniciar n8n

```bash
./scripts/start.sh
```

### 5. Acceder a n8n

Abre tu navegador en: http://localhost:5678

Usa las credenciales configuradas en el archivo `.env`

## Configuración de Cloudflare (Opcional)

Si deseas exponer n8n de forma segura a través de internet:

### 1. Crear un túnel de Cloudflare

```bash
cloudflared tunnel login
cloudflared tunnel create n8n-tunnel
```

### 2. Configurar el túnel

Editar `cloudflare/config.yml` con tu ID de túnel y dominio.

### 3. Copiar las credenciales

```bash
cp ~/.cloudflared/<tunnel-id>.json cloudflare/credentials.json
```

### 4. Iniciar el túnel

```bash
cd cloudflare
docker-compose up -d
```

## Verificación

Verifica que todo esté funcionando:

```bash
docker ps
./scripts/logs.sh
```

## Próximos pasos

- Importar workflows desde el directorio `workflows/`
- Configurar credenciales en n8n para integraciones
- Explorar la documentación de n8n
