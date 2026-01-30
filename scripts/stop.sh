#!/bin/bash
# Script para detener n8n

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🛑 Deteniendo n8n..."

cd "$PROJECT_ROOT/docker"

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: No se encontró docker-compose.yml"
    exit 1
fi

docker-compose down

echo "✅ n8n detenido correctamente!"
