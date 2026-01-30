# n8n Docker v2 🚀

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![n8n](https://img.shields.io/badge/n8n-FF6D5A?style=for-the-badge&logo=n8n&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)

## 📖 Descripción

Este repositorio proporciona una configuración completa y lista para producción de **n8n** (herramienta de automatización de workflows) ejecutándose en contenedores Docker, con:

- ✅ **PostgreSQL** como base de datos persistente
- ✅ **Cloudflare Tunnel** para acceso seguro sin exponer puertos
- ✅ **Docker Compose** para gestión simplificada
- ✅ **Scripts de utilidad** para backup, restore y monitoreo
- ✅ **Documentación completa** en español

## 🎯 Características Principales

- **Fácil de configurar**: Solo necesitas editar un archivo `.env`
- **Seguro por defecto**: Túnel Cloudflare, encriptación de credenciales, sin puertos expuestos
- **Producción lista**: PostgreSQL, health checks, logging configurado
- **Respaldos automatizables**: Scripts incluidos para backup y restauración
- **Bien documentado**: Guía paso a paso completa

## 🚀 Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/ThomasTixerina/n8n-docker-v2.git
cd n8n-docker-v2
```

### 2. Configurar variables de entorno

```bash
# Copiar el archivo de ejemplo
cp .env.example .env

# Editar con tus valores
nano .env
```

**Variables críticas a configurar:**
- `POSTGRES_PASSWORD`: Contraseña segura para PostgreSQL
- `N8N_ENCRYPTION_KEY`: Generar con `openssl rand -base64 32`
- `TUNNEL_TOKEN`: Token de tu Cloudflare Tunnel
- `N8N_HOST`: Tu URL de Cloudflare (ej: https://n8n.tudominio.com)

### 3. Iniciar los servicios

```bash
docker-compose up -d
```

### 4. Verificar el estado

```bash
./health_check.sh
```

### 5. Acceder a n8n

Abre tu navegador y ve a la URL configurada en `N8N_HOST` (ej: https://n8n.tudominio.com)

## 📚 Documentación Completa

Para una guía detallada paso a paso, consulta:

### [📖 SETUP_GUIDE.md](./SETUP_GUIDE.md)

Esta guía incluye:
- ✅ Requisitos previos detallados
- ✅ Configuración de Cloudflare Tunnel paso a paso
- ✅ Configuración de todas las variables de entorno
- ✅ Instrucciones de instalación completas
- ✅ Verificación y pruebas
- ✅ Seguridad y mejores prácticas
- ✅ Mantenimiento y actualizaciones
- ✅ Solución de problemas comunes

## 🛠️ Scripts Incluidos

Este repositorio incluye varios scripts de utilidad:

### `health_check.sh`
Verifica el estado de salud de todos los componentes del sistema.

```bash
./health_check.sh
```

**Verifica:**
- Estado de Docker y Docker Compose
- Variables de entorno configuradas
- Estado de contenedores (n8n, PostgreSQL, Cloudflared)
- Conectividad de base de datos
- Uso de disco y recursos
- Errores recientes en logs

### `backup.sh`
Crea un backup completo del sistema.

```bash
./backup.sh
```

**Incluye:**
- Dump completo de la base de datos PostgreSQL
- Todos los datos de n8n (workflows, credenciales, ejecuciones)
- Archivo de configuración `.env`
- Metadata del backup

### `restore_backup.sh`
Restaura un backup previamente creado.

```bash
./restore_backup.sh ./backups/n8n_backup_YYYYMMDD_HHMMSS.tar.gz
```

⚠️ **Advertencia**: Esta operación elimina todos los datos actuales.

## 📁 Estructura del Proyecto

```
n8n-docker-v2/
├── .env.example              # Plantilla de variables de entorno
├── .gitignore               # Archivos a ignorar en Git
├── docker-compose.yml       # Configuración de Docker Compose
├── README.md                # Este archivo
├── SETUP_GUIDE.md          # Guía de configuración detallada
├── health_check.sh         # Script de verificación de salud
├── backup.sh               # Script de backup
└── restore_backup.sh       # Script de restauración
```

## 🔒 Seguridad

Este setup incluye varias capas de seguridad:

1. **Túnel Cloudflare**: No se exponen puertos directamente a Internet
2. **Encriptación**: Todas las credenciales se guardan encriptadas en n8n
3. **Base de datos separada**: PostgreSQL en contenedor aislado
4. **Variables de entorno**: Credenciales nunca en código
5. **Health checks**: Monitoreo automático de la salud de los servicios

### Mejores Prácticas de Seguridad

- ✅ Usa contraseñas fuertes (16+ caracteres)
- ✅ Guarda tu `N8N_ENCRYPTION_KEY` de forma segura
- ✅ Haz backups regulares
- ✅ Mantén Docker y las imágenes actualizadas
- ✅ Revisa los logs regularmente
- ✅ Configura políticas de acceso en Cloudflare

## 🔄 Actualización

Para actualizar n8n a la última versión:

```bash
# Detener servicios
docker-compose down

# Hacer backup (recomendado)
./backup.sh

# Actualizar imágenes
docker-compose pull

# Reiniciar servicios
docker-compose up -d

# Verificar
./health_check.sh
```

## 🐛 Solución de Problemas

### Los contenedores no arrancan

```bash
# Ver logs
docker-compose logs -f

# Ver logs específicos
docker-compose logs -f n8n
```

### No puedo acceder a través de Cloudflare

1. Verifica que el túnel esté activo en Cloudflare Dashboard
2. Verifica el token: `grep TUNNEL_TOKEN .env`
3. Revisa logs: `docker-compose logs cloudflared`

### Error de base de datos

```bash
# Verificar conectividad
docker-compose exec postgres psql -U n8n_user -d n8n_db -c "SELECT 1;"
```

Para más problemas, consulta la sección de [Solución de Problemas](./SETUP_GUIDE.md#-solución-de-problemas) en la guía completa.

## 📊 Monitoreo

Para monitorear el uso de recursos:

```bash
# Ver estadísticas en tiempo real
docker stats n8n n8n-postgres n8n-cloudflared

# O usar el script de health check
./health_check.sh
```

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo tu licencia preferida. Revisa el archivo LICENSE para más detalles.

## 🔗 Enlaces Útiles

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 📞 Soporte

Si tienes problemas o preguntas:

1. Revisa la [guía completa](./SETUP_GUIDE.md)
2. Consulta la sección de [solución de problemas](./SETUP_GUIDE.md#-solución-de-problemas)
3. Abre un issue en este repositorio

---

**Hecho con ❤️ para la comunidad de n8n**
