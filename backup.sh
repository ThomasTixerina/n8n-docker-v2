#!/bin/bash

# ===========================================
# n8n Docker Backup Script
# ===========================================
# Este script crea backups de:
# - Base de datos PostgreSQL
# - Datos de n8n (.n8n directory)
# - Archivo de configuración .env
# ===========================================

set -e

# Configuración
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="n8n_backup_${DATE}"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "   n8n Docker Setup - Backup"
echo "=========================================="
echo ""

# Crear directorio de backups si no existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creando directorio de backups..."
    mkdir -p "$BACKUP_DIR"
fi

# Verificar que los contenedores estén corriendo
echo "Verificando contenedores..."
if ! docker-compose ps | grep -q "n8n.*Up"; then
    echo -e "${RED}Error: Los contenedores no están corriendo${NC}"
    echo "Ejecuta: docker-compose up -d"
    exit 1
fi

echo -e "${GREEN}Contenedores están corriendo${NC}"
echo ""

# Crear directorio específico para este backup
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"
mkdir -p "$BACKUP_PATH"

# 1. Backup de la base de datos
echo "1. Creando backup de PostgreSQL..."
docker-compose exec -T postgres pg_dump -U n8n_user n8n_db > "${BACKUP_PATH}/database.sql"
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Backup de base de datos completado${NC}"
    echo "   Tamaño: $(du -h "${BACKUP_PATH}/database.sql" | cut -f1)"
else
    echo -e "   ${RED}✗ Error al crear backup de base de datos${NC}"
    exit 1
fi

# 2. Backup de datos de n8n
echo ""
echo "2. Creando backup de datos de n8n..."
docker run --rm \
    -v n8n-docker-v2_n8n_data:/data \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    ubuntu tar czf /backup/n8n_data.tar.gz /data 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Backup de datos de n8n completado${NC}"
    echo "   Tamaño: $(du -h "${BACKUP_PATH}/n8n_data.tar.gz" | cut -f1)"
else
    echo -e "   ${RED}✗ Error al crear backup de datos de n8n${NC}"
    exit 1
fi

# 3. Backup del archivo .env (sin credenciales sensibles visibles)
echo ""
echo "3. Creando backup de configuración..."
if [ -f .env ]; then
    cp .env "${BACKUP_PATH}/.env.backup"
    echo -e "   ${GREEN}✓ Backup de .env completado${NC}"
else
    echo -e "   ${YELLOW}⚠ Archivo .env no encontrado${NC}"
fi

# 4. Crear archivo de metadata
echo ""
echo "4. Creando metadata del backup..."
cat > "${BACKUP_PATH}/metadata.txt" << EOF
===========================================
n8n Docker Backup Metadata
===========================================
Fecha de creación: $(date)
Hostname: $(hostname)
Usuario: $(whoami)

Versiones:
- n8n: $(docker-compose exec -T n8n n8n --version 2>/dev/null | tr -d '\r' || echo "No disponible")
- PostgreSQL: $(docker-compose exec -T postgres psql --version 2>/dev/null | tr -d '\r' || echo "No disponible")

Archivos incluidos:
- database.sql (Base de datos PostgreSQL)
- n8n_data.tar.gz (Datos de n8n)
- .env.backup (Configuración)
- metadata.txt (Este archivo)

===========================================
EOF

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Metadata creada${NC}"
else
    echo -e "   ${YELLOW}⚠ Error al crear metadata${NC}"
fi

# 5. Crear archivo comprimido del backup completo
echo ""
echo "5. Comprimiendo backup..."
cd "$BACKUP_DIR"
tar czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Backup comprimido${NC}"
    # Eliminar directorio temporal
    rm -rf "$BACKUP_NAME"
    cd ..
    echo "   Ubicación: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
    echo "   Tamaño final: $(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)"
else
    echo -e "   ${RED}✗ Error al comprimir backup${NC}"
    cd ..
    exit 1
fi

# Resumen
echo ""
echo "=========================================="
echo "   Backup Completado Exitosamente"
echo "=========================================="
echo ""
echo "Archivo: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo ""
echo "Para restaurar este backup:"
echo "  ./restore_backup.sh ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo ""

# Listar backups existentes
echo "Backups disponibles:"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'

echo ""
echo "=========================================="
