# Guía Completa de Configuración de n8n con Docker y Cloudflare

Esta guía proporciona instrucciones paso a paso para configurar n8n en Docker con un túnel seguro de Cloudflare.

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Configuración Inicial](#configuración-inicial)
3. [Configuración de Cloudflare Tunnel](#configuración-de-cloudflare-tunnel)
4. [Instalación y Despliegue](#instalación-y-despliegue)
5. [Verificación y Pruebas](#verificación-y-pruebas)
6. [Seguridad y Mejores Prácticas](#seguridad-y-mejores-prácticas)
7. [Mantenimiento](#mantenimiento)
8. [Solución de Problemas](#solución-de-problemas)

---

## 📦 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

### Software Necesario

- **Docker**: versión 20.10 o superior
  ```bash
  docker --version
  ```

- **Docker Compose**: versión 2.0 o superior
  ```bash
  docker-compose --version
  ```

- **Git**: para clonar el repositorio
  ```bash
  git --version
  ```

### Cuenta de Cloudflare

- Cuenta activa en [Cloudflare](https://cloudflare.com)
- Dominio agregado a Cloudflare (con DNS configurado)
- Acceso a [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)

### Recursos del Sistema

- **RAM**: Mínimo 2GB, recomendado 4GB+
- **Disco**: Mínimo 10GB de espacio libre
- **CPU**: 2 núcleos o más recomendado
- **SO**: Linux (Ubuntu, Debian, CentOS), macOS, o Windows con WSL2

---

## 🚀 Configuración Inicial

### Paso 1: Clonar el Repositorio

```bash
# Clonar el repositorio
git clone https://github.com/ThomasTixerina/n8n-docker-v2.git
cd n8n-docker-v2
```

### Paso 2: Crear Archivo de Configuración

```bash
# Copiar el archivo de ejemplo
cp .env.example .env
```

### Paso 3: Configurar Variables de Entorno

Edita el archivo `.env` con tu editor preferido:

```bash
nano .env
# o
vim .env
# o
code .env
```

#### Variables Críticas a Configurar:

1. **Zona Horaria**
   ```env
   GENERIC_TIMEZONE=America/Mexico_City
   ```

2. **Base de Datos (Cambiar contraseñas)**
   ```env
   POSTGRES_PASSWORD=tu_contraseña_segura_aqui
   DB_POSTGRESDB_PASSWORD=tu_contraseña_segura_aqui
   ```

3. **Clave de Encriptación**
   
   Genera una clave segura:
   ```bash
   openssl rand -base64 32
   ```
   
   Añádela al archivo `.env`:
   ```env
   N8N_ENCRYPTION_KEY=tu_clave_generada_aqui
   ```

4. **URL de n8n** (se configurará después con Cloudflare)
   ```env
   N8N_HOST=https://tu-subdominio.tu-dominio.com
   WEBHOOK_URL=https://tu-subdominio.tu-dominio.com
   ```

---

## 🌐 Configuración de Cloudflare Tunnel

### Paso 1: Acceder a Cloudflare Zero Trust

1. Ve a [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Selecciona tu cuenta
3. Ve a **Access** → **Tunnels**

### Paso 2: Crear un Nuevo Túnel

1. Click en **"Create a tunnel"**
2. Selecciona **"Cloudflared"** como tipo de túnel
3. Ingresa un nombre para el túnel, por ejemplo: `n8n-production`
4. Click en **"Save tunnel"**

### Paso 3: Configurar el Túnel

**⚠️ IMPORTANTE**: Guarda el token que te proporciona Cloudflare. Lo necesitarás en el siguiente paso.

### Paso 4: Configurar el Hostname Público

1. En la sección **"Public Hostname"**:
   - **Subdomain**: Ingresa tu subdominio (ej: `n8n`)
   - **Domain**: Selecciona tu dominio (ej: `midominio.com`)
   - **Service**: 
     - Type: `HTTP`
     - URL: `n8n:5678`

2. Click en **"Save hostname"**

### Paso 5: Agregar Token al Archivo .env

Edita el archivo `.env` y agrega el token:

```env
TUNNEL_TOKEN=tu_token_de_cloudflare_aqui
```

### Paso 6: Actualizar URLs en .env

Actualiza las URLs con tu dominio configurado:

```env
N8N_HOST=https://n8n.midominio.com
WEBHOOK_URL=https://n8n.midominio.com
```

---

## 🐳 Instalación y Despliegue

### Paso 1: Verificar la Configuración

Antes de iniciar, verifica que tu archivo `.env` esté completo:

```bash
# Verificar que las variables críticas están configuradas
grep -E "(POSTGRES_PASSWORD|N8N_ENCRYPTION_KEY|TUNNEL_TOKEN|N8N_HOST)" .env
```

### Paso 2: Iniciar los Contenedores

```bash
# Iniciar en modo detached (segundo plano)
docker-compose up -d
```

### Paso 3: Verificar el Estado de los Contenedores

```bash
# Ver el estado de los contenedores
docker-compose ps

# Ver los logs en tiempo real
docker-compose logs -f
```

Deberías ver tres contenedores corriendo:
- `n8n-postgres` (Base de datos)
- `n8n` (Aplicación principal)
- `n8n-cloudflared` (Túnel de Cloudflare)

### Paso 4: Esperar a que los Servicios Estén Listos

```bash
# Ver logs de n8n específicamente
docker-compose logs -f n8n
```

Espera a ver mensajes como:
```
n8n ready on 0.0.0.0, port 5678
Editor is now accessible via:
https://n8n.midominio.com
```

---

## ✅ Verificación y Pruebas

### Prueba 1: Verificar Salud de los Contenedores

```bash
# Verificar salud de todos los contenedores
docker-compose ps

# Verificar salud del contenedor de n8n específicamente
docker inspect --format='{{.State.Health.Status}}' n8n
```

Debería mostrar `healthy` para todos los servicios.

### Prueba 2: Verificar Conectividad de Base de Datos

```bash
# Conectarse a la base de datos
docker-compose exec postgres psql -U n8n_user -d n8n_db -c "\dt"
```

Deberías ver las tablas de n8n creadas.

### Prueba 3: Verificar Túnel de Cloudflare

```bash
# Ver logs del túnel
docker-compose logs cloudflared
```

Busca mensajes como:
```
Connection registered connIndex=0
Connection registered connIndex=1
```

### Prueba 4: Acceder a la Interfaz Web

1. Abre tu navegador
2. Ve a `https://n8n.midominio.com`
3. Deberías ver la página de configuración inicial de n8n
4. Crea tu cuenta de administrador

### Prueba 5: Crear un Workflow de Prueba

1. Inicia sesión en n8n
2. Crea un nuevo workflow
3. Añade un nodo "Schedule Trigger" (cada 5 minutos)
4. Añade un nodo "HTTP Request" para probar conectividad
5. Activa el workflow
6. Verifica que se ejecute correctamente

---

## 🔒 Seguridad y Mejores Prácticas

### 1. Gestión de Contraseñas

- ✅ Usa contraseñas fuertes (mínimo 16 caracteres)
- ✅ Nunca compartas tu archivo `.env` en Git
- ✅ Usa un gestor de contraseñas para almacenar credenciales
- ✅ Rota las contraseñas regularmente (cada 90 días)

### 2. Clave de Encriptación

⚠️ **CRÍTICO**: La clave de encriptación es fundamental para la seguridad de tus credenciales en n8n.

```bash
# Generar una clave nueva
openssl rand -base64 32

# Guardarla de forma segura (NO en el repositorio Git)
```

**Si pierdes esta clave, perderás acceso a todas las credenciales almacenadas en n8n.**

### 3. Configuración de Firewall

Si estás en un servidor Linux, configura el firewall:

```bash
# Permitir solo SSH y bloquear acceso directo al puerto de n8n
sudo ufw allow 22/tcp
sudo ufw enable

# El acceso a n8n debe ser SOLO a través del túnel de Cloudflare
# No expongas el puerto 5678 directamente
```

### 4. Autenticación Básica (Opcional)

Para una capa adicional de seguridad durante la configuración inicial:

```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=tu_contraseña_basica
```

**Nota**: Desactiva esto una vez que hayas configurado la autenticación de usuario en n8n.

### 5. Actualización de Cloudflare Access Policies (Opcional)

Para mayor seguridad, puedes configurar políticas de acceso en Cloudflare:

1. Ve a **Access** → **Applications**
2. Crea una nueva aplicación para tu dominio de n8n
3. Configura políticas basadas en:
   - Dirección de correo electrónico
   - País
   - Redes específicas

### 6. Backups Regulares

```bash
# Crear un backup de la base de datos
docker-compose exec postgres pg_dump -U n8n_user n8n_db > backup_$(date +%Y%m%d).sql

# Crear un backup de los datos de n8n
docker run --rm -v n8n-docker-v2_n8n_data:/data -v $(pwd):/backup ubuntu tar czf /backup/n8n_data_backup_$(date +%Y%m%d).tar.gz /data
```

### 7. Monitoreo de Logs

```bash
# Monitorear logs en busca de actividad sospechosa
docker-compose logs --tail=100 -f n8n | grep -i "error\|fail\|unauthorized"
```

---

## 🔧 Mantenimiento

### Actualización de n8n

```bash
# 1. Detener los contenedores
docker-compose down

# 2. Hacer backup antes de actualizar
docker-compose exec postgres pg_dump -U n8n_user n8n_db > backup_pre_update.sql

# 3. Actualizar las imágenes
docker-compose pull

# 4. Iniciar con las nuevas imágenes
docker-compose up -d

# 5. Verificar que todo funcione
docker-compose logs -f n8n
```

### Limpieza de Logs y Datos Temporales

```bash
# Limpiar logs antiguos de Docker
docker system prune -a --volumes -f

# Esto eliminará:
# - Contenedores detenidos
# - Redes no utilizadas
# - Imágenes huérfanas
# - Volúmenes no utilizados (¡CUIDADO con esto!)
```

### Reinicio de Servicios

```bash
# Reiniciar todos los servicios
docker-compose restart

# Reiniciar solo n8n
docker-compose restart n8n

# Reiniciar solo el túnel de Cloudflare
docker-compose restart cloudflared
```

### Verificación de Salud Periódica

Crea un script de monitoreo (`health_check.sh`):

```bash
#!/bin/bash

echo "=== Health Check n8n Docker Setup ==="
echo ""

echo "1. Container Status:"
docker-compose ps
echo ""

echo "2. n8n Health:"
docker inspect --format='{{.State.Health.Status}}' n8n
echo ""

echo "3. Database Connectivity:"
docker-compose exec -T postgres pg_isready -U n8n_user
echo ""

echo "4. Disk Usage:"
df -h | grep -E "Filesystem|/$"
echo ""

echo "5. Memory Usage:"
docker stats --no-stream n8n n8n-postgres n8n-cloudflared
echo ""

echo "=== Health Check Complete ==="
```

Hazlo ejecutable y ejecútalo:
```bash
chmod +x health_check.sh
./health_check.sh
```

---

## 🆘 Solución de Problemas

### Problema 1: El contenedor de n8n no arranca

**Síntomas**:
```bash
docker-compose ps
# n8n muestra "Restarting" constantemente
```

**Soluciones**:

1. Verificar logs:
   ```bash
   docker-compose logs n8n
   ```

2. Verificar configuración de base de datos:
   ```bash
   docker-compose exec postgres psql -U n8n_user -d n8n_db -c "SELECT 1;"
   ```

3. Verificar que la clave de encriptación esté configurada:
   ```bash
   grep N8N_ENCRYPTION_KEY .env
   ```

4. Recrear contenedores:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Problema 2: No puedo acceder a través del túnel de Cloudflare

**Síntomas**: Error 502 o 503 al acceder a la URL

**Soluciones**:

1. Verificar estado del túnel:
   ```bash
   docker-compose logs cloudflared | grep -i "error\|connection"
   ```

2. Verificar que el token sea correcto:
   ```bash
   grep TUNNEL_TOKEN .env
   ```

3. Verificar conectividad interna:
   ```bash
   docker-compose exec cloudflared wget -O- http://n8n:5678/healthz
   ```

4. Verificar configuración en Cloudflare:
   - Ve a Zero Trust Dashboard
   - Verifica que el túnel esté activo
   - Verifica que el hostname esté correctamente configurado

### Problema 3: Error de base de datos "password authentication failed"

**Soluciones**:

1. Verificar que las contraseñas coincidan en `.env`:
   ```bash
   grep POSTGRES_PASSWORD .env
   ```

2. Recrear la base de datos:
   ```bash
   docker-compose down -v  # ⚠️ Esto BORRARÁ todos los datos
   docker-compose up -d
   ```

3. Si tienes datos importantes, haz backup primero:
   ```bash
   docker-compose exec postgres pg_dump -U n8n_user n8n_db > backup_before_fix.sql
   ```

### Problema 4: "Disk full" o problemas de espacio

**Soluciones**:

1. Verificar espacio en disco:
   ```bash
   df -h
   ```

2. Limpiar logs de Docker:
   ```bash
   docker system prune -a -f
   ```

3. Limpiar ejecuciones antiguas de n8n (desde la interfaz web):
   - Settings → Executions → Delete old executions

### Problema 5: Workflows no se ejecutan

**Soluciones**:

1. Verificar que el workflow esté activado (toggle verde)

2. Verificar logs de ejecución en n8n:
   - Abre el workflow
   - Ve a "Executions"
   - Revisa los errores

3. Verificar límite de concurrencia:
   ```bash
   grep N8N_CONCURRENCY_PRODUCTION_LIMIT .env
   ```

4. Verificar recursos del sistema:
   ```bash
   docker stats n8n
   ```

### Problema 6: Perdí mi clave de encriptación

**Consecuencias**: Todas las credenciales almacenadas se perderán.

**Soluciones**:

1. Si tienes backup de la clave, restáurala en `.env`

2. Si no tienes backup:
   ```bash
   # Generar nueva clave
   openssl rand -base64 32
   
   # Actualizar en .env
   # Tendrás que reconfigurar todas las credenciales en n8n
   ```

### Problema 7: Puerto ya en uso

**Síntomas**:
```
Error starting userland proxy: listen tcp4 0.0.0.0:5678: bind: address already in use
```

**Soluciones**:

1. Cambiar el puerto en `docker-compose.yml`:
   ```yaml
   ports:
     - "127.0.0.1:5679:5678"  # Cambiar 5678 a 5679 o cualquier otro
   ```

2. O detener el servicio que está usando el puerto:
   ```bash
   # Encontrar qué está usando el puerto
   lsof -i :5678
   
   # Detener el proceso
   kill -9 <PID>
   ```

---

## 📚 Recursos Adicionales

### Documentación Oficial

- [n8n Documentation](https://docs.n8n.io/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### Comunidad

- [n8n Community Forum](https://community.n8n.io/)
- [n8n Discord](https://discord.gg/n8n)

### Workflows de Ejemplo

- [n8n Workflow Templates](https://n8n.io/workflows/)

---

## 📞 Soporte

Si encuentras problemas no cubiertos en esta guía:

1. Revisa los logs detalladamente:
   ```bash
   docker-compose logs --tail=100 -f
   ```

2. Busca en el [n8n Community Forum](https://community.n8n.io/)

3. Crea un issue en el repositorio con:
   - Descripción del problema
   - Logs relevantes (sin información sensible)
   - Pasos para reproducir el error
   - Información del sistema (OS, versión de Docker, etc.)

---

## 📄 Licencia

Este proyecto está bajo la licencia especificada en el repositorio.

---

**¡Felicidades!** 🎉 Ahora tienes una instalación completamente funcional de n8n con Docker y Cloudflare Tunnel.
