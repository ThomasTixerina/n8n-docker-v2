# Docker Configuration

Este directorio contiene los archivos de configuración de Docker para n8n.

## Archivos

- **docker-compose.yml**: Configuración principal de Docker Compose para ejecutar n8n
- **Dockerfile**: Dockerfile personalizado (opcional) para extender la imagen de n8n
- **.env.example**: Ejemplo de variables de entorno necesarias

## Uso

1. Copiar `.env.example` a `.env` y configurar las variables:
   ```bash
   cp .env.example .env
   ```

2. Editar `.env` con tus credenciales y configuración

3. Iniciar n8n con Docker Compose:
   ```bash
   docker-compose up -d
   ```

4. Acceder a n8n en `http://localhost:5678`

## Detener el servicio

```bash
docker-compose down
```

## Ver logs

```bash
docker-compose logs -f n8n
```
