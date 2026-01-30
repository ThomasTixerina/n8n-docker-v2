#!/bin/bash

# ===========================================
# n8n Docker Restore Script
# ===========================================
# Este script restaura backups creados con backup.sh
# ===========================================

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar argumentos
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No se especificó archivo de backup${NC}"
    echo ""
    echo "Uso: $0 <archivo_backup.tar.gz>"
    echo ""
    echo "Backups disponibles:"
    ls -lh ./backups/*.tar.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    exit 1
fi

BACKUP_FILE=$1

# Verificar que el archivo exista
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Archivo de backup no encontrado: $BACKUP_FILE${NC}"
    exit 1
fi

echo "=========================================="
echo "   n8n Docker Setup - Restore"
echo "=========================================="
echo ""
echo "Archivo de backup: $BACKUP_FILE"
echo ""

# Advertencia
echo -e "${YELLOW}⚠ ADVERTENCIA ⚠${NC}"
echo "Esta operación:"
echo "  - Detendrá todos los contenedores"
echo "  - ELIMINARÁ todos los datos actuales"
echo "  - Restaurará los datos del backup"
echo ""
read -p "¿Estás seguro de continuar? (escribe 'SI' para continuar): " CONFIRM

if [ "$CONFIRM" != "SI" ]; then
    echo "Operación cancelada"
    exit 0
fi

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
echo ""
echo "Extrayendo backup en directorio temporal..."
tar xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Encontrar el directorio del backup
BACKUP_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "n8n_backup_*" | head -1)

if [ -z "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Estructura de backup no válida${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "${GREEN}✓ Backup extraído${NC}"

# Mostrar metadata si existe
if [ -f "$BACKUP_DIR/metadata.txt" ]; then
    echo ""
    echo "Información del backup:"
    echo "----------------------------------------"
    cat "$BACKUP_DIR/metadata.txt"
    echo "----------------------------------------"
    echo ""
    read -p "Presiona Enter para continuar..."
fi

# 1. Detener contenedores
echo ""
echo "1. Deteniendo contenedores..."
docker-compose down
echo -e "   ${GREEN}✓ Contenedores detenidos${NC}"

# 2. Restaurar base de datos
echo ""
echo "2. Restaurando base de datos..."

# Iniciar solo PostgreSQL
docker-compose up -d postgres

# Esperar a que PostgreSQL esté listo
echo "   Esperando a que PostgreSQL esté listo..."
sleep 10

# Verificar si la base de datos existe y eliminarla
docker-compose exec -T postgres psql -U n8n_user -d postgres -c "DROP DATABASE IF EXISTS n8n_db;" 2>/dev/null || true
docker-compose exec -T postgres psql -U n8n_user -d postgres -c "CREATE DATABASE n8n_db;" 2>/dev/null

# Restaurar el dump
cat "$BACKUP_DIR/database.sql" | docker-compose exec -T postgres psql -U n8n_user -d n8n_db

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Base de datos restaurada${NC}"
else
    echo -e "   ${RED}✗ Error al restaurar base de datos${NC}"
    docker-compose down
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 3. Restaurar datos de n8n
echo ""
echo "3. Restaurando datos de n8n..."

# Eliminar volumen existente
docker volume rm n8n-docker-v2_n8n_data 2>/dev/null || true

# Crear nuevo volumen
docker volume create n8n-docker-v2_n8n_data

# Restaurar datos
docker run --rm \
    -v n8n-docker-v2_n8n_data:/data \
    -v "$BACKUP_DIR:/backup" \
    ubuntu tar xzf /backup/n8n_data.tar.gz -C / 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Datos de n8n restaurados${NC}"
else
    echo -e "   ${RED}✗ Error al restaurar datos de n8n${NC}"
    docker-compose down
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 4. Restaurar .env (opcional)
echo ""
echo "4. Archivo .env..."
if [ -f "$BACKUP_DIR/.env.backup" ]; then
    echo -e "   ${YELLOW}Se encontró un backup de .env${NC}"
    echo "   Tu archivo .env actual NO será modificado"
    echo "   Si necesitas restaurar .env, cópialo manualmente:"
    echo "   cp $BACKUP_DIR/.env.backup .env"
else
    echo -e "   ${YELLOW}No se encontró backup de .env${NC}"
fi

# 5. Iniciar todos los servicios
echo ""
echo "5. Iniciando todos los servicios..."
docker-compose up -d

echo ""
echo "Esperando a que los servicios estén listos..."
sleep 15

# Verificar estado
echo ""
docker-compose ps

# Limpiar directorio temporal
rm -rf "$TEMP_DIR"

echo ""
echo "=========================================="
echo "   Restauración Completada"
echo "=========================================="
echo ""
echo "Verifica que todo funcione correctamente:"
echo "  - Accede a tu URL de n8n"
echo "  - Verifica tus workflows"
echo "  - Ejecuta: ./health_check.sh"
echo ""
echo "=========================================="
