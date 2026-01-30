#!/bin/bash
# Script para hacer backup de n8n

set -e

BACKUP_DIR="backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="n8n_backup_${DATE}.tar.gz"

echo "💾 Creando backup de n8n..."

# Crear directorio de backups si no existe
mkdir -p $BACKUP_DIR

# Hacer backup del volumen de datos
docker run --rm \
    -v n8n_data:/data \
    -v $(pwd)/$BACKUP_DIR:/backup \
    alpine tar czf /backup/$BACKUP_FILE -C /data .

echo "✅ Backup creado: $BACKUP_DIR/$BACKUP_FILE"
