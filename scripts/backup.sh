#!/bin/bash
# Script para hacer backup de n8n

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BACKUP_DIR="$PROJECT_ROOT/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="n8n_backup_${DATE}.tar.gz"

echo "💾 Creando backup de n8n..."

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Verificar que el volumen existe
if ! docker volume inspect n8n_data &> /dev/null; then
    echo "❌ Error: El volumen n8n_data no existe. ¿Has iniciado n8n?"
    exit 1
fi

# Hacer backup del volumen de datos
docker run --rm \
    -v n8n_data:/data \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf /backup/"$BACKUP_FILE" -C /data .

echo "✅ Backup creado: backups/$BACKUP_FILE"
