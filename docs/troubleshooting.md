# Solución de problemas

## Problemas comunes

### n8n no inicia

**Síntoma**: El contenedor no arranca o se detiene inmediatamente.

**Soluciones**:
1. Verificar los logs:
   ```bash
   ./scripts/logs.sh
   ```

2. Verificar que el puerto 5678 no esté en uso:
   ```bash
   sudo lsof -i :5678
   ```

3. Verificar permisos del volumen:
   ```bash
   docker volume inspect n8n_data
   ```

### No puedo acceder a n8n

**Síntoma**: La página no carga en http://localhost:5678

**Soluciones**:
1. Verificar que el contenedor está corriendo:
   ```bash
   docker ps | grep n8n
   ```

2. Verificar la red de Docker:
   ```bash
   docker network inspect n8n_network
   ```

3. Verificar firewall:
   ```bash
   sudo ufw status
   ```

### Problemas con Cloudflare Tunnel

**Síntoma**: El túnel no se conecta o falla.

**Soluciones**:
1. Verificar credenciales:
   ```bash
   cat cloudflare/credentials.json
   ```

2. Verificar configuración del túnel:
   ```bash
   cloudflared tunnel info <tunnel-name>
   ```

3. Verificar logs del túnel:
   ```bash
   docker logs cloudflared
   ```

### Error de autenticación

**Síntoma**: Credenciales rechazadas en la interfaz web.

**Soluciones**:
1. Verificar variables de entorno:
   ```bash
   cat docker/.env
   ```

2. Recrear el contenedor:
   ```bash
   ./scripts/stop.sh
   ./scripts/start.sh
   ```

### Workflows no se guardan

**Síntoma**: Los workflows desaparecen después de reiniciar.

**Soluciones**:
1. Verificar el volumen:
   ```bash
   docker volume ls | grep n8n
   ```

2. Verificar el montaje del volumen en docker-compose.yml

3. Hacer backup antes de reiniciar:
   ```bash
   ./scripts/backup.sh
   ```

## Comandos útiles de depuración

```bash
# Ver todos los contenedores
docker ps -a

# Ver logs de un contenedor específico
docker logs <container-id>

# Entrar en el contenedor
docker exec -it n8n sh

# Ver uso de recursos
docker stats

# Limpiar sistema Docker
docker system prune -a
```

## Obtener ayuda

Si el problema persiste:
1. Revisar la [documentación oficial de n8n](https://docs.n8n.io/)
2. Buscar en [n8n community forum](https://community.n8n.io/)
3. Crear un issue en el repositorio con los logs completos
