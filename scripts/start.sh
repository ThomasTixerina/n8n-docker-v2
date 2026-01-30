#!/bin/bash
# Script para iniciar n8n con Docker

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Iniciando n8n con Docker..."

# Change to project root
cd "$PROJECT_ROOT"

# Verificar que existe el archivo .env
if [ ! -f "docker/.env" ]; then
    echo "⚠️  Archivo .env no encontrado. Copiando desde .env.example..."
    cp docker/.env.example docker/.env
    echo "✏️  Por favor, edita docker/.env con tu configuración antes de continuar."
    echo "    Debes configurar N8N_USER y N8N_PASSWORD"
    exit 1
fi

# Check if required environment variables are set
if ! grep -q "N8N_USER=." docker/.env || ! grep -q "N8N_PASSWORD=." docker/.env; then
    echo "⚠️  Por favor, configura N8N_USER y N8N_PASSWORD en docker/.env"
    exit 1
fi

# Iniciar n8n
echo "🐳 Iniciando contenedor de n8n..."
cd docker
docker-compose up -d

echo "✅ n8n iniciado correctamente!"
echo "📝 Accede a n8n en: http://localhost:5678"
echo ""
echo "Para ver los logs: cd docker && docker-compose logs -f"
echo "Para detener: ./scripts/stop.sh"
