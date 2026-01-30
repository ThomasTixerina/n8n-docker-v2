# n8n-docker-v2

Este repositorio es para tener n8n instalado con workflows de su MCP (Model Context Protocol), instalado con contenedor en Docker, usando un puerto de salida seguro con Cloudflare, para poder trabajar con desarrollos propios.

## 📋 Descripción

Implementación de n8n utilizando Docker con:
- ✅ Configuración de Docker Compose
- ✅ Workflows MCP
- ✅ Túnel seguro con Cloudflare (opcional)
- ✅ Scripts de automatización
- ✅ Documentación completa

## 📁 Estructura del Proyecto

```
n8n-docker-v2/
├── docker/              # Configuración de Docker
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── .env.example
│   └── README.md
├── n8n/                 # Configuración de n8n
│   ├── config.json
│   └── README.md
├── workflows/           # Workflows de n8n y MCP
│   ├── example-workflow.json
│   └── README.md
├── cloudflare/          # Configuración de Cloudflare Tunnel
│   ├── config.yml
│   ├── docker-compose.yml
│   └── README.md
├── scripts/             # Scripts de utilidad
│   ├── start.sh
│   ├── stop.sh
│   ├── logs.sh
│   ├── backup.sh
│   └── README.md
├── docs/                # Documentación adicional
│   ├── setup.md
│   ├── troubleshooting.md
│   └── architecture.md
├── .gitignore
└── README.md
```

## 🚀 Inicio Rápido

### Requisitos previos

- Docker y Docker Compose instalados
- (Opcional) Cuenta de Cloudflare para túnel seguro
- Al menos 2GB de RAM disponible

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/ThomasTixerina/n8n-docker-v2.git
   cd n8n-docker-v2
   ```

2. **Configurar variables de entorno**
   ```bash
   cp docker/.env.example docker/.env
   # Editar docker/.env con tus credenciales
   ```

3. **Dar permisos a los scripts**
   ```bash
   chmod +x scripts/*.sh
   ```

4. **Iniciar n8n**
   ```bash
   ./scripts/start.sh
   ```

5. **Acceder a n8n**
   
   Abre tu navegador en: http://localhost:5678

## 📖 Documentación

- [Guía de configuración inicial](docs/setup.md)
- [Solución de problemas](docs/troubleshooting.md)
- [Arquitectura del sistema](docs/architecture.md)

### Documentación por componente

- [Docker](docker/README.md) - Configuración de contenedores
- [n8n](n8n/README.md) - Configuración de n8n
- [Workflows](workflows/README.md) - Workflows y MCP
- [Cloudflare](cloudflare/README.md) - Túnel seguro
- [Scripts](scripts/README.md) - Scripts de utilidad

## 🛠️ Comandos Útiles

```bash
# Iniciar n8n
./scripts/start.sh

# Detener n8n
./scripts/stop.sh

# Ver logs en tiempo real
./scripts/logs.sh

# Crear backup
./scripts/backup.sh
```

## 🔒 Seguridad

- ⚠️ **No subir archivos `.env` al repositorio**
- ⚠️ **No incluir credenciales reales en archivos de configuración**
- ✅ Usar contraseñas fuertes
- ✅ Mantener actualizado Docker y n8n
- ✅ Usar Cloudflare Tunnel para acceso remoto seguro

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia que elijas.

## 🔗 Enlaces útiles

- [Documentación oficial de n8n](https://docs.n8n.io/)
- [Docker documentation](https://docs.docker.com/)
- [Cloudflare Tunnel documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

## 📧 Contacto

Thomas Tixerina - [GitHub](https://github.com/ThomasTixerina)
