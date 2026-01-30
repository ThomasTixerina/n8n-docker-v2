#!/bin/bash
# Script para detener n8n

set -e

echo "🛑 Deteniendo n8n..."

cd docker
docker-compose down

echo "✅ n8n detenido correctamente!"
