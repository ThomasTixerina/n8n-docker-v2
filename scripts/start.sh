#!/bin/bash
# Script para iniciar n8n con Docker

set -e

echo "🚀 Iniciando n8n con Docker..."

# Verificar que existe el archivo .env
if [ ! -f "docker/.env" ]; then
    echo "⚠️  Archivo .env no encontrado. Copiando desde .env.example..."
    cp docker/.env.example docker/.env
    echo "✏️  Por favor, edita docker/.env con tu configuración antes de continuar."
    exit 1
fi

# Crear red de Docker si no existe
if ! docker network inspect n8n_network &> /dev/null; then
    echo "🔧 Creando red de Docker: n8n_network"
    docker network create n8n_network
fi

# Iniciar n8n
echo "🐳 Iniciando contenedor de n8n..."
cd docker
docker-compose up -d

echo "✅ n8n iniciado correctamente!"
echo "📝 Accede a n8n en: http://localhost:5678"
echo ""
echo "Para ver los logs: docker-compose -f docker/docker-compose.yml logs -f"
echo "Para detener: ./scripts/stop.sh"
