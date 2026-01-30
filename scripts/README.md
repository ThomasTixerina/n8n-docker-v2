# Scripts de utilidad

Este directorio contiene scripts de shell para facilitar la gestión de n8n.

## Scripts disponibles

### start.sh
Inicia n8n con Docker Compose.

```bash
./scripts/start.sh
```

### stop.sh
Detiene n8n.

```bash
./scripts/stop.sh
```

### logs.sh
Muestra los logs de n8n en tiempo real.

```bash
./scripts/logs.sh
```

### backup.sh
Crea un backup de los datos de n8n.

```bash
./scripts/backup.sh
```

## Permisos

Asegúrate de dar permisos de ejecución a los scripts:

```bash
chmod +x scripts/*.sh
```

## Uso

Todos los scripts deben ejecutarse desde el directorio raíz del proyecto:

```bash
# Correcto
./scripts/start.sh

# Incorrecto
cd scripts && ./start.sh
```
