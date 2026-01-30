#!/bin/bash

# ===========================================
# n8n Docker Health Check Script
# ===========================================
# Este script verifica el estado de salud de 
# todos los componentes del sistema n8n
# ===========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "   n8n Docker Setup - Health Check"
echo "=========================================="
echo ""

# Verificar que Docker esté corriendo
echo -n "1. Verificando Docker... "
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}FAIL${NC}"
    echo "   Docker no está corriendo o no tienes permisos"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# Verificar Docker Compose (try v2 first, fall back to v1)
echo -n "2. Verificando Docker Compose... "
if docker compose version > /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif docker-compose version > /dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}FAIL${NC}"
    echo "   Docker Compose no está instalado"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# Verificar que el archivo .env exista
echo -n "3. Verificando archivo .env... "
if [ ! -f .env ]; then
    echo -e "${RED}FAIL${NC}"
    echo "   Archivo .env no encontrado"
    echo "   Ejecuta: cp .env.example .env"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# Verificar variables críticas en .env
echo -n "4. Verificando variables de entorno críticas... "
MISSING_VARS=()

if ! grep -q "^N8N_ENCRYPTION_KEY=.\\+" .env; then
    MISSING_VARS+=("N8N_ENCRYPTION_KEY")
fi

if ! grep -q "^POSTGRES_PASSWORD=.\\+" .env; then
    MISSING_VARS+=("POSTGRES_PASSWORD")
fi

if ! grep -q "^TUNNEL_TOKEN=.\\+" .env; then
    MISSING_VARS+=("TUNNEL_TOKEN")
fi

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${YELLOW}WARNING${NC}"
    echo "   Faltan las siguientes variables:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
else
    echo -e "${GREEN}OK${NC}"
fi

# Verificar estado de contenedores
echo ""
echo "5. Estado de Contenedores:"
echo "----------------------------------------"

# Obtener estado de contenedores
POSTGRES_STATUS=$($COMPOSE_CMD ps -q postgres 2>/dev/null)
N8N_STATUS=$($COMPOSE_CMD ps -q n8n 2>/dev/null)
CLOUDFLARED_STATUS=$($COMPOSE_CMD ps -q cloudflared 2>/dev/null)

if [ -z "$POSTGRES_STATUS" ] && [ -z "$N8N_STATUS" ] && [ -z "$CLOUDFLARED_STATUS" ]; then
    echo -e "   ${YELLOW}No hay contenedores corriendo${NC}"
    echo "   Ejecuta: docker-compose up -d"
else
    # PostgreSQL
    echo -n "   - PostgreSQL: "
    if [ -n "$POSTGRES_STATUS" ]; then
        HEALTH=$(docker inspect --format='{{.State.Health.Status}}' n8n-postgres 2>/dev/null || echo "no-health")
        if [ "$HEALTH" = "healthy" ]; then
            echo -e "${GREEN}Running (Healthy)${NC}"
        elif [ "$HEALTH" = "no-health" ]; then
            STATUS=$(docker inspect --format='{{.State.Status}}' n8n-postgres 2>/dev/null || echo "unknown")
            echo -e "${GREEN}Running${NC} (Status: $STATUS)"
        else
            echo -e "${YELLOW}Running (Health: $HEALTH)${NC}"
        fi
    else
        echo -e "${RED}Not Running${NC}"
    fi

    # n8n
    echo -n "   - n8n: "
    if [ -n "$N8N_STATUS" ]; then
        HEALTH=$(docker inspect --format='{{.State.Health.Status}}' n8n 2>/dev/null || echo "no-health")
        if [ "$HEALTH" = "healthy" ]; then
            echo -e "${GREEN}Running (Healthy)${NC}"
        elif [ "$HEALTH" = "no-health" ]; then
            STATUS=$(docker inspect --format='{{.State.Status}}' n8n 2>/dev/null || echo "unknown")
            echo -e "${GREEN}Running${NC} (Status: $STATUS)"
        else
            echo -e "${YELLOW}Running (Health: $HEALTH)${NC}"
        fi
    else
        echo -e "${RED}Not Running${NC}"
    fi

    # Cloudflared
    echo -n "   - Cloudflared: "
    if [ -n "$CLOUDFLARED_STATUS" ]; then
        STATUS=$(docker inspect --format='{{.State.Status}}' n8n-cloudflared 2>/dev/null || echo "unknown")
        if [ "$STATUS" = "running" ]; then
            echo -e "${GREEN}Running${NC}"
        else
            echo -e "${YELLOW}$STATUS${NC}"
        fi
    else
        echo -e "${RED}Not Running${NC}"
    fi
fi

# Verificar conectividad de base de datos
echo ""
echo -n "6. Verificando conectividad de base de datos... "
if [ -n "$POSTGRES_STATUS" ]; then
    if $COMPOSE_CMD exec -T postgres pg_isready -U n8n_user > /dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi
else
    echo -e "${YELLOW}SKIP${NC} (PostgreSQL no está corriendo)"
fi

# Verificar uso de disco
echo ""
echo "7. Uso de Disco:"
echo "----------------------------------------"
df -h | grep -E "Filesystem|/$" | awk '{printf "   %-20s %10s %10s %10s %s\n", $1, $2, $3, $4, $5}'

# Verificar uso de recursos
echo ""
echo "8. Uso de Recursos (Últimos 2 segundos):"
echo "----------------------------------------"
if [ -n "$N8N_STATUS" ] || [ -n "$POSTGRES_STATUS" ]; then
    docker stats --no-stream --format "   {{.Name}}: CPU {{.CPUPerc}}, Memoria {{.MemUsage}}" n8n n8n-postgres n8n-cloudflared 2>/dev/null || echo "   No se pudo obtener estadísticas"
else
    echo -e "   ${YELLOW}No hay contenedores corriendo${NC}"
fi

# Verificar logs recientes de errores
echo ""
echo "9. Errores Recientes en Logs (últimas 50 líneas):"
echo "----------------------------------------"
ERROR_COUNT=$($COMPOSE_CMD logs --tail=50 2>/dev/null | grep -i -E "error|fail|exception" | wc -l)
if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "   ${GREEN}No se encontraron errores${NC}"
else
    echo -e "   ${YELLOW}Se encontraron $ERROR_COUNT líneas con errores${NC}"
    echo "   Ejecuta '$COMPOSE_CMD logs -f' para ver detalles"
fi

echo ""
echo "=========================================="
echo "   Health Check Completo"
echo "=========================================="
echo ""
