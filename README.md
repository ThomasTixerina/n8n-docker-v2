# MiConsul Platform - Multi-Tenant n8n Automation Platform

## 🎯 Visión General

MiConsul es una plataforma SaaS multi-tenant que proporciona automatizaciones n8n dedicadas para consultorios dentales. Cada cliente obtiene su propia instancia aislada de n8n con workflows versionados en GitHub y monitoreo autónomo 24/7.

### Características Principales

✅ **Instancias Dedicadas** - Cada cliente tiene su propio stack Docker (n8n + PostgreSQL + Cloudflare)  
✅ **Agentes Autónomos** - Sistema de bucles continuos monitoreando y optimizando 24/7  
✅ **Versionado GitHub** - Todos los workflows en repositorios privados  
✅ **Monitoreo Predictivo** - ML detecta problemas ANTES de que ocurran  
✅ **Auto-Healing** - El sistema se repara automáticamente  
✅ **Pricing Basado en Uso** - Facturación por workflows y ejecuciones  

---

## 📋 Planes y Pricing

| Plan | Precio/mes | Workflows | Ejecuciones/mes | Características |
|------|------------|-----------|-----------------|-----------------|
| **Básico** | $99 | 5 | 1,000 | Workflows base, monitoreo básico |
| **Pro** | $199 | 15 | 5,000 | + Monitoreo predictivo, personalización |
| **Enterprise** | $399 | Ilimitado | Ilimitado | + Auto-healing, workflows a medida, SLA 99.9% |

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                  SERVIDOR MICONSUL                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         AGENT ORCHESTRATOR (Cerebro Central)         │  │
│  │  • Monitoring Loop (30s)                             │  │
│  │  • Optimization Loop (5min)                          │  │
│  │  • Predictive Loop (1min)                            │  │
│  │  • Learning Loop (1h)                                │  │
│  │  • Maintenance Loop (24h)                            │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│         ┌────────────────┼────────────────┐                │
│         │                │                │                │
│    ┌────▼────┐      ┌───▼────┐      ┌───▼────┐            │
│    │ C+Dental│      │Dental  │      │Dental X│            │
│    │ Stack   │      │ABC Stack│     │ Stack  │            │
│    ├─────────┤      ├─────────┤     ├────────┤            │
│    │ n8n     │      │ n8n     │     │ n8n    │            │
│    │ :5678   │      │ :5679   │     │ :5680  │            │
│    │cloudflare│     │cloudflare│    │cloudflare│          │
│    │postgres │      │postgres │     │postgres│            │
│    │GitHub   │      │GitHub   │     │GitHub  │            │
│    │Repo     │      │Repo     │     │Repo    │            │
│    └─────────┘      └─────────┘     └────────┘            │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │         GitHub Organization: miconsul-workflows       │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │ │
│  │  │ cdental  │  │ abc-repo │  │ dentalx  │            │ │
│  │  │ (15 wf)  │  │ (5 wf)   │  │ (∞ wf)   │            │ │
│  │  └──────────┘  └──────────┘  └──────────┘            │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Inicio Rápido

### Prerrequisitos

- Docker Desktop
- Node.js 18+
- PowerShell 7+
- Git
- Cuenta de GitHub

### 1. Configuración Inicial

```powershell
# Clonar el proyecto
git clone <repo-url>
cd n8n-infrastructure

# Crear red Docker
docker network create miconsul-network
```

### 2. Crear Primer Cliente

```powershell
.\scripts\create_client_instance.ps1 `
  -TenantId "cdental" `
  -TenantName "C+Dental" `
  -Plan "pro" `
  -Port 5678
```

Este comando:
- Crea directorio `clients/cdental/`
- Genera configuración y credenciales
- Levanta stack Docker completo
- Configura Cloudflare Tunnel
- Registra el tenant

### 3. Iniciar Orquestador

```powershell
cd agents\orchestrator

# Instalar dependencias
npm install

# Configurar
Copy-Item .env.example .env
# Editar .env con tus valores

# Iniciar
npm run dev
```

### 4. Verificar

```powershell
# Estado del sistema
curl http://localhost:3000/api/dashboard/status

# Ver tenants
curl http://localhost:3000/api/dashboard/tenants

# Acceder a n8n del cliente
# Local: http://localhost:5678
# Público: Ver logs de Cloudflare
```

---

## 📁 Estructura del Proyecto

```
n8n-infrastructure/
├── templates/                    # Plantillas para nuevos clientes
│   ├── docker-compose.template.yml
│   ├── .env.template
│   └── config.template.json
│
├── scripts/                      # Scripts de automatización
│   ├── create_client_instance.ps1
│   └── create_client_instance.sh
│
├── clients/                      # Instancias de clientes
│   ├── cdental/
│   │   ├── docker-compose.yml
│   │   ├── .env
│   │   ├── config.json
│   │   └── INSTALL_INFO.txt
│   └── dental-abc/
│
├── agents/                       # Sistema de agentes
│   └── orchestrator/
│       ├── src/
│       │   ├── events/          # Event bus (Redis)
│       │   ├── tenants/         # Gestión de clientes
│       │   ├── loops/           # Bucles autónomos
│       │   ├── agents/          # Agentes MCP
│       │   └── dashboard/       # API REST
│       ├── package.json
│       └── README.md
│
├── docs/                         # Documentación
│   ├── arquitectura_instancias_dedicadas.md
│   ├── sistema_bucle_agentico.md
│   ├── github_integration_pricing.md
│   ├── orquestador_explicacion.md
│   └── agentes_mcp_resumen.md
│
├── workflows/                    # Workflows existentes (legacy)
│   ├── fidelizacion_email_whatsapp.json
│   ├── reporte_diario_doctores.json
│   └── ...
│
├── QUICKSTART.md                 # Guía de inicio rápido
├── README.md                     # Este archivo
└── INDICE.md                     # Índice completo
```

---

## 🔄 Bucles Autónomos del Orquestador

### 1. Monitoring Loop (30 segundos)
- Verifica salud de cada tenant
- Detecta anomalías en ejecuciones
- Emite alertas si hay problemas

### 2. Optimization Loop (5 minutos)
- Analiza patrones de ejecución
- Identifica workflows lentos
- Aplica optimizaciones automáticas

### 3. Predictive Loop (1 minuto)
- Predicciones con ML
- Detecta tendencias preocupantes
- Alertas preventivas

### 4. Learning Loop (1 hora)
- Aprende de todos los tenants
- Identifica mejores prácticas
- Actualiza plantillas de workflows

### 5. Maintenance Loop (24 horas)
- Limpieza de logs
- Optimización de DB
- Backups automáticos
- Reportes semanales

---

## 🛠️ Comandos Útiles

### Gestión de Clientes

```powershell
# Crear cliente
.\scripts\create_client_instance.ps1 -TenantId "test" -TenantName "Test" -Plan "basic" -Port 5679

# Ver logs
docker logs n8n-<tenant_id> -f

# Reiniciar
cd clients\<tenant_id>
docker-compose restart

# Detener
docker-compose down

# Eliminar (con datos)
docker-compose down -v
```

### Orquestador

```powershell
cd agents\orchestrator

# Desarrollo
npm run dev

# Producción
npm run build
npm start

# Tests
npm test
```

### Docker

```powershell
# Ver todos los contenedores MiConsul
docker ps --filter "label=miconsul.managed=true"

# Ver recursos
docker stats

# Limpiar
docker system prune
```

---

## 📊 API del Orquestador

### Endpoints Disponibles

**GET** `/api/dashboard/status`
- Estado general del sistema
- Uptime, número de tenants
- Estado de loops

**GET** `/api/dashboard/tenants`
- Lista de todos los clientes
- Información completa de cada uno

**GET** `/api/dashboard/tenants/:id`
- Detalles de un cliente específico
- Métricas, uso, salud

---

## 🔐 Seguridad

- **Aislamiento**: Cada cliente en su propio stack Docker
- **Credenciales**: Generadas automáticamente, encriptadas
- **GitHub**: Repositorios privados por cliente
- **Cloudflare**: Túneles seguros HTTPS
- **Backups**: Automáticos diarios

---

## 📈 Roadmap

### ✅ Fase 1: Infraestructura (Completada)
- Plantillas Docker Compose
- Scripts de provisioning
- Sistema de gestión de puertos

### ✅ Fase 2: Orquestador Base (Completada)
- Event Bus con Redis
- Tenant Manager
- Monitoring Loop
- Dashboard API

### 🔄 Fase 3: Agentes Completos (En Progreso)
- Optimization Loop
- Predictive Loop con ML
- Learning Loop
- Maintenance Loop

### 📅 Fase 4: GitHub Integration
- Creación automática de repos
- CI/CD con GitHub Actions
- Versionado de workflows
- Sistema de facturación

### 📅 Fase 5: Producción
- Tests end-to-end
- Migración de C+Dental
- Onboarding de clientes piloto
- Launch oficial

---

## 🐛 Solución de Problemas

Ver `QUICKSTART.md` para guía detallada de troubleshooting.

**Problemas comunes:**
- Orquestador no inicia → Verificar Redis/PostgreSQL
- Cliente no se crea → Verificar red Docker y puerto
- n8n no responde → Ver logs del contenedor
- Cloudflare no conecta → Reiniciar tunnel

---

## 📚 Documentación

- `QUICKSTART.md` - Guía de inicio rápido
- `docs/` - Documentación técnica completa
- `agents/orchestrator/README.md` - Guía del orquestador
- `INDICE.md` - Índice de todos los documentos

---

## 🤝 Contribuir

Este es un proyecto interno de MiConsul. Para contribuir:
1. Crear branch desde `main`
2. Hacer cambios
3. Crear Pull Request
4. Esperar revisión

---

## 📞 Soporte

- **Documentación**: Ver `/docs`
- **Logs**: Revisar logs de Docker y orquestador
- **Issues**: Crear issue en GitHub

---

## 📄 Licencia

Propietario - MiConsul Platform © 2025

---

**Versión**: 2.0  
**Última actualización**: 2025-12-25  
**Estado**: En desarrollo activo
