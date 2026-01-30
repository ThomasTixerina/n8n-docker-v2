# Security Policy

## 🔒 Política de Seguridad

La seguridad es una prioridad en este proyecto. Este documento describe cómo manejar vulnerabilidades de seguridad.

## 📢 Reportar una Vulnerabilidad

Si descubres una vulnerabilidad de seguridad, por favor **NO** la hagas pública inmediatamente. En su lugar:

### Paso 1: Contacto Privado

Envía un correo electrónico a los mantenedores del proyecto con:

- Descripción detallada de la vulnerabilidad
- Pasos para reproducirla
- Impacto potencial
- Posibles soluciones (si las conoces)

**NO** publiques la vulnerabilidad en:
- Issues públicos de GitHub
- Foros públicos
- Redes sociales
- Otros canales públicos

### Paso 2: Esperando Respuesta

- Recibirás confirmación en 48 horas
- Se te informará del progreso cada 7 días
- Se te notificará cuando se publique un fix

### Paso 3: Divulgación Coordinada

Una vez que se haya publicado un parche:
- Se dará crédito por el descubrimiento (si lo deseas)
- Se publicará un advisory de seguridad
- Se notificará a los usuarios

## 🛡️ Mejores Prácticas de Seguridad

### Para Usuarios

1. **Variables de Entorno**
   - ✅ NUNCA compartas tu archivo `.env`
   - ✅ NUNCA subas `.env` a Git
   - ✅ Usa contraseñas fuertes (16+ caracteres)
   - ✅ Rota contraseñas regularmente (cada 90 días)

2. **Clave de Encriptación**
   ```bash
   # Genera una clave fuerte
   openssl rand -base64 32
   ```
   - ✅ Guárdala de forma segura
   - ✅ Haz backup en un lugar seguro
   - ⚠️ Si la pierdes, perderás todas las credenciales de n8n

3. **Cloudflare Tunnel Token**
   - ✅ Trata el token como una contraseña
   - ✅ No lo compartas públicamente
   - ✅ Revoca y regenera si se compromete

4. **Actualizaciones**
   ```bash
   # Actualiza regularmente
   docker-compose pull
   docker-compose up -d
   ```
   - ✅ Mantén Docker actualizado
   - ✅ Mantén las imágenes actualizadas
   - ✅ Revisa changelogs de seguridad

5. **Backups**
   ```bash
   # Haz backups regulares
   ./backup.sh
   ```
   - ✅ Encripta los backups
   - ✅ Guárdalos en ubicación segura
   - ✅ Prueba la restauración periódicamente

6. **Acceso**
   - ✅ Usa autenticación de dos factores en Cloudflare
   - ✅ Configura políticas de acceso en Cloudflare
   - ✅ Limita quién tiene acceso al servidor
   - ✅ Revisa logs regularmente

### Para Contribuidores

1. **Código**
   - ✅ No hardcodees credenciales
   - ✅ Usa variables de entorno
   - ✅ Valida inputs de usuario
   - ✅ Sanitiza outputs
   - ✅ Usa conexiones HTTPS/TLS

2. **Dependencias**
   - ✅ Usa imágenes oficiales de Docker
   - ✅ Especifica versiones de imágenes
   - ✅ Revisa vulnerabilidades conocidas
   - ✅ Actualiza dependencias regularmente

3. **Secrets**
   - ✅ Nunca commitas secrets en Git
   - ✅ Usa `.gitignore` apropiadamente
   - ✅ Revisa cambios antes de push
   - ✅ Usa herramientas como `git-secrets`

## 🔍 Verificación de Seguridad

### Check Rápido

```bash
# 1. Verificar que .env no esté en Git
git ls-files | grep .env
# (No debería retornar nada)

# 2. Verificar permisos de archivos
ls -la .env
# (Debería ser 600 o similar, no 777)

# 3. Verificar configuración de firewall (Linux)
sudo ufw status
# (Puerto 5678 NO debería estar expuesto)

# 4. Verificar que solo localhost puede acceder a n8n
docker-compose ps | grep ports
# (Debería mostrar 127.0.0.1:5678->5678/tcp, NO 0.0.0.0)
```

### Escaneo de Vulnerabilidades

```bash
# Escanear imágenes Docker
docker scan n8nio/n8n:latest
docker scan postgres:15-alpine

# Verificar configuración
docker-compose config

# Verificar logs de errores de seguridad
docker-compose logs | grep -i "unauthorized\|forbidden\|security"
```

## 📋 Checklist de Seguridad

Antes de ir a producción, verifica:

- [ ] `.env` está en `.gitignore` y no en Git
- [ ] Todas las contraseñas son fuertes y únicas
- [ ] `N8N_ENCRYPTION_KEY` está configurada y respaldada
- [ ] Cloudflare Tunnel está activo y funcionando
- [ ] No hay puertos expuestos directamente (excepto a localhost)
- [ ] Firewall está configurado correctamente
- [ ] Backups automáticos están configurados
- [ ] Logs están siendo monitoreados
- [ ] Actualizaciones automáticas consideradas
- [ ] Políticas de acceso configuradas en Cloudflare
- [ ] Autenticación de dos factores habilitada
- [ ] Documentación de seguridad revisada por el equipo

## 🚨 Qué Hacer si Fuiste Comprometido

Si sospechas que tu instalación fue comprometida:

### Respuesta Inmediata

1. **Detén los servicios**
   ```bash
   docker-compose down
   ```

2. **Cambia todas las contraseñas**
   - Contraseña de PostgreSQL
   - Cloudflare Tunnel Token
   - Clave de encriptación de n8n
   - Credenciales de n8n

3. **Revoca accesos**
   - Revoca el Cloudflare Tunnel Token actual
   - Crea un nuevo túnel
   - Cambia URLs si es necesario

4. **Analiza logs**
   ```bash
   docker-compose logs > incident_logs.txt
   # Revisa para detectar actividad sospechosa
   ```

5. **Restaura desde backup limpio**
   ```bash
   # Usa un backup de antes del incidente
   ./restore_backup.sh ./backups/backup_seguro.tar.gz
   ```

### Post-Incidente

1. **Investiga la causa raíz**
   - ¿Cómo ocurrió el compromiso?
   - ¿Qué vulnerabilidad se explotó?

2. **Implementa mejoras**
   - Parchea la vulnerabilidad
   - Mejora controles de seguridad
   - Actualiza documentación

3. **Monitorea**
   - Vigila por actividad sospechosa
   - Aumenta frecuencia de revisión de logs

4. **Documenta**
   - Registra el incidente
   - Documenta las lecciones aprendidas
   - Actualiza procedimientos

## 📚 Recursos de Seguridad

### Herramientas Recomendadas

- **Docker Bench for Security**: Verificación de seguridad de Docker
  ```bash
  docker run -it --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /etc:/etc --label docker_bench_security \
    docker/docker-bench-security
  ```

- **Trivy**: Escaneo de vulnerabilidades
  ```bash
  docker run aquasec/trivy image n8nio/n8n:latest
  ```

- **git-secrets**: Prevenir commit de secrets
  ```bash
  git secrets --install
  git secrets --register-aws
  ```

### Enlaces Útiles

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [n8n Security Documentation](https://docs.n8n.io/hosting/security/)
- [Cloudflare Security](https://www.cloudflare.com/learning/security/)

## 📞 Soporte

Este documento se actualiza regularmente con nuevas recomendaciones de seguridad.

Para reportes de seguridad, contacta a los mantenedores del proyecto.

---

**La seguridad es responsabilidad de todos. ¡Gracias por ayudar a mantener este proyecto seguro!** 🛡️
