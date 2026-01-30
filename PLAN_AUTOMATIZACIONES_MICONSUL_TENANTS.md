# Plan de Implementación: Automatizaciones para MiConsul y Tenants

## 🎯 Objetivo

Permitir que **MiConsul** (como plataforma) tenga sus propias automatizaciones de gestión, y que cada **Tenant** (cliente) pueda tener sus automatizaciones personalizadas de negocio.

---

## 🏗️ Arquitectura Propuesta

```
┌─────────────────────────────────────────────────────────────────┐
│                    SERVIDOR MICONSUL                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         INSTANCIA MICONSUL (Gestión de Plataforma)         │ │
│  │  • n8n Master (puerto 5677)                                │ │
│  │  • Workflows de gestión de tenants                         │ │
│  │  • Workflows de facturación                                │ │
│  │  • Workflows de monitoreo global                           │ │
│  │  • Workflows de onboarding                                 │ │
│  │  • PostgreSQL compartido                                   │ │
│  │  • Redis compartido (Event Bus)                            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              │ (API REST + Event Bus)           │
│                              ▼                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         AGENT ORCHESTRATOR (Cerebro Central)               │ │
│  │  • Monitoring Loop (30s)                                   │ │
│  │  • Optimization Loop (5min)                                │ │
│  │  • Predictive Loop (1min)                                  │ │
│  │  • Learning Loop (1h)                                      │ │
│  │  • Maintenance Loop (24h)                                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│         ┌────────────────────┼────────────────┐                │
│         │                    │                │                │
│    ┌────▼────┐          ┌───▼────┐      ┌───▼────┐            │
│    │ C+Dental│          │Dental  │      │Dental X│            │
│    │ Tenant  │          │ABC     │      │ Tenant │            │
│    ├─────────┤          ├────────┤      ├────────┤            │
│    │ n8n     │          │ n8n    │      │ n8n    │            │
│    │ :5678   │          │ :5679  │      │ :5680  │            │
│    │ • Fidelización     │ • Reportes    │ • Custom│            │
│    │ • Citas │          │ • WhatsApp    │ • Workflows│         │
│    │ • Reportes         │ • Email       │        │            │
│    │ postgres│          │ postgres      │ postgres│            │
│    │ GitHub  │          │ GitHub │      │ GitHub │            │
│    └─────────┘          └────────┘      └────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Fase 1: Instancia MiConsul Master

### Objetivo
Crear una instancia n8n dedicada para MiConsul que gestione la plataforma completa.

### Tareas

#### 1.1 Crear Instancia MiConsul Master
```powershell
# Crear directorio para MiConsul Master
New-Item -ItemType Directory -Path "clients/miconsul-master" -Force

# Copiar template y configurar
Copy-Item "templates/docker-compose.template.yml" "clients/miconsul-master/docker-compose.yml"
Copy-Item "templates/.env.template" "clients/miconsul-master/.env"
```

**Configuración específica:**
- Puerto: `5677` (antes de todos los tenants)
- Nombre: `miconsul-master`
- Base de datos: `miconsul_master_db`
- Cloudflare Tunnel: `master.miconsul.app`

#### 1.2 Workflows de Gestión de Plataforma

**Workflows a crear:**

1. **`tenant_onboarding.json`**
   - Trigger: Webhook cuando se crea nuevo tenant
   - Acciones:
     - Crear repositorio GitHub
     - Configurar webhooks
     - Enviar email de bienvenida
     - Crear registro en base de datos
     - Notificar al orquestador

2. **`tenant_health_monitor.json`**
   - Trigger: Cron cada 5 minutos
   - Acciones:
     - Consultar API del orquestador
     - Verificar salud de cada tenant
     - Enviar alertas si hay problemas
     - Registrar métricas

3. **`billing_monthly.json`**
   - Trigger: Cron mensual (día 1, 00:00)
   - Acciones:
     - Consultar uso de cada tenant
     - Calcular facturación
     - Generar invoices
     - Enviar emails de facturación

4. **`backup_orchestrator.json`**
   - Trigger: Cron diario (02:00)
   - Acciones:
     - Backup de PostgreSQL del orquestador
     - Backup de Redis
     - Subir a almacenamiento externo
     - Notificar resultado

5. **`tenant_migration.json`**
   - Trigger: Webhook manual
   - Acciones:
     - Exportar workflows del tenant
     - Crear backup completo
     - Migrar a nuevo servidor
     - Verificar integridad

---

## 📦 Fase 2: Workflows Base para Tenants

### Objetivo
Proporcionar workflows predefinidos que cada tenant puede usar y personalizar.

### Catálogo de Workflows Base

#### 2.1 Workflows de Fidelización

**`fidelizacion_primer_pago.json`**
- Trigger: Webhook desde sistema legacy PHP
- Acciones:
  - Verificar si es primer pago del paciente
  - Enviar email de bienvenida
  - Enviar WhatsApp (YCloud)
  - Registrar en CRM

**`fidelizacion_cumpleanos.json`**
- Trigger: Cron diario (08:00)
- Acciones:
  - Consultar pacientes con cumpleaños hoy
  - Enviar mensaje personalizado
  - Ofrecer descuento especial

#### 2.2 Workflows de Citas

**`recordatorio_citas_24h.json`**
- Trigger: Cron diario (18:00)
- Acciones:
  - Consultar citas del día siguiente
  - Enviar recordatorio por WhatsApp
  - Enviar recordatorio por email

**`confirmacion_cita.json`**
- Trigger: Webhook cuando se agenda cita
- Acciones:
  - Enviar confirmación inmediata
  - Agregar a calendario
  - Notificar al doctor

#### 2.3 Workflows de Reportes

**`reporte_diario_doctores.json`**
- Trigger: Cron diario (20:00)
- Acciones:
  - Consultar ventas del día
  - Consultar citas del día
  - Generar reporte PDF
  - Enviar por email a doctores

**`reporte_semanal_admin.json`**
- Trigger: Cron semanal (lunes 08:00)
- Acciones:
  - Métricas de la semana
  - Comparación con semana anterior
  - Gráficas de tendencias
  - Enviar a administración

---

## 📦 Fase 3: Sistema de Plantillas y Personalización

### Objetivo
Permitir que cada tenant personalice los workflows base según sus necesidades.

### 3.1 Estructura de Plantillas

```
templates/
├── workflows/
│   ├── base/                    # Workflows base sin modificar
│   │   ├── fidelizacion_primer_pago.json
│   │   ├── recordatorio_citas_24h.json
│   │   └── reporte_diario_doctores.json
│   │
│   └── customizations/          # Personalizaciones por tenant
│       ├── cdental/
│       │   ├── fidelizacion_primer_pago.json  # Versión personalizada
│       │   └── custom_workflow_1.json         # Workflow único
│       │
│       └── dental-abc/
│           └── custom_workflow_2.json
```

### 3.2 Workflow de Personalización

**`workflow_customization.json`** (en MiConsul Master)
- Trigger: Webhook desde panel de admin
- Acciones:
  1. Recibir solicitud de personalización
  2. Clonar workflow base
  3. Aplicar modificaciones solicitadas
  4. Validar JSON
  5. Desplegar en instancia del tenant
  6. Crear commit en GitHub
  7. Notificar al cliente

---

## 📦 Fase 4: API Interna para Comunicación

### Objetivo
Crear endpoints en el sistema legacy PHP para que n8n pueda consultar y modificar datos.

### 4.1 Endpoints a Implementar

**Archivo: `api/n8n.php`** (ya existe, expandir)

```php
<?php
// Endpoints para n8n

// GET /api/n8n.php?action=get_patient_history&patient_id=123
// Retorna historial completo del paciente

// GET /api/n8n.php?action=get_daily_sales&date=2025-01-29
// Retorna ventas del día

// GET /api/n8n.php?action=get_appointments&date=2025-01-29
// Retorna citas del día

// GET /api/n8n.php?action=get_birthdays&date=2025-01-29
// Retorna pacientes con cumpleaños

// POST /api/n8n.php?action=create_appointment
// Crea nueva cita

// POST /api/n8n.php?action=update_patient
// Actualiza datos del paciente
```

### 4.2 Seguridad

- **Autenticación**: Token Bearer en headers
- **Validación**: Sanitización de inputs con PDO
- **Rate Limiting**: Máximo 100 requests/minuto por tenant
- **Logging**: Registrar todas las llamadas API

---

## 📦 Fase 5: Integración con Orquestador

### Objetivo
Permitir que el orquestador gestione workflows de tenants automáticamente.

### 5.1 Nuevos Eventos del Event Bus

```typescript
// Eventos que el orquestador puede emitir/escuchar

enum WorkflowEvents {
  WORKFLOW_CREATED = 'workflow.created',
  WORKFLOW_UPDATED = 'workflow.updated',
  WORKFLOW_DELETED = 'workflow.deleted',
  WORKFLOW_EXECUTED = 'workflow.executed',
  WORKFLOW_FAILED = 'workflow.failed',
  WORKFLOW_OPTIMIZED = 'workflow.optimized',
}
```

### 5.2 Servicio de Gestión de Workflows

**Archivo: `agents/orchestrator/src/workflows/workflow-manager.service.ts`**

```typescript
@Injectable()
export class WorkflowManagerService {
  // Obtener workflows de un tenant
  async getTenantWorkflows(tenantId: string): Promise<Workflow[]>
  
  // Desplegar workflow en tenant
  async deployWorkflow(tenantId: string, workflow: Workflow): Promise<void>
  
  // Validar workflow JSON
  async validateWorkflow(workflow: Workflow): Promise<ValidationResult>
  
  // Optimizar workflow
  async optimizeWorkflow(workflow: Workflow): Promise<Workflow>
  
  // Clonar workflow de template
  async cloneFromTemplate(templateId: string, tenantId: string): Promise<Workflow>
}
```

---

## 📦 Fase 6: Panel de Administración

### Objetivo
Interfaz web para que MiConsul y tenants gestionen sus workflows.

### 6.1 Dashboard MiConsul (Admin)

**Funcionalidades:**
- Ver todos los tenants y su estado
- Ver workflows activos por tenant
- Crear/editar workflows de plataforma
- Ver métricas de uso
- Gestionar facturación
- Ver logs del orquestador

### 6.2 Dashboard Tenant (Cliente)

**Funcionalidades:**
- Ver workflows disponibles
- Activar/desactivar workflows
- Personalizar workflows base
- Ver ejecuciones recientes
- Ver métricas de uso
- Solicitar workflows personalizados

---

## 🚀 Plan de Implementación Iterativo

### Sprint 1: Instancia MiConsul Master (1 semana)
- [ ] Crear instancia n8n para MiConsul
- [ ] Configurar Cloudflare Tunnel
- [ ] Crear workflow de onboarding básico
- [ ] Crear workflow de health monitoring

### Sprint 2: API Interna (1 semana)
- [ ] Expandir `api/n8n.php` con endpoints necesarios
- [ ] Implementar autenticación con tokens
- [ ] Implementar rate limiting
- [ ] Documentar API

### Sprint 3: Workflows Base para Tenants (2 semanas)
- [ ] Crear workflows de fidelización
- [ ] Crear workflows de citas
- [ ] Crear workflows de reportes
- [ ] Probar en tenant de prueba

### Sprint 4: Sistema de Plantillas (1 semana)
- [ ] Crear estructura de plantillas
- [ ] Implementar workflow de personalización
- [ ] Crear documentación para clientes

### Sprint 5: Integración con Orquestador (2 semanas)
- [ ] Implementar WorkflowManagerService
- [ ] Agregar eventos de workflows al Event Bus
- [ ] Crear endpoints API en orquestador
- [ ] Probar integración completa

### Sprint 6: Panel de Administración (3 semanas)
- [ ] Diseñar UI/UX
- [ ] Implementar dashboard MiConsul
- [ ] Implementar dashboard Tenant
- [ ] Integrar con API del orquestador

---

## 📊 Métricas de Éxito

### Para MiConsul
- ✅ Tiempo de onboarding de nuevo tenant < 5 minutos
- ✅ Detección de problemas < 1 minuto
- ✅ Facturación automatizada 100%
- ✅ Backups diarios exitosos 100%

### Para Tenants
- ✅ Workflows base funcionando sin configuración
- ✅ Personalización de workflows < 24 horas
- ✅ Tasa de éxito de ejecuciones > 99%
- ✅ Tiempo de respuesta de webhooks < 2 segundos

---

## 🔐 Consideraciones de Seguridad

### Aislamiento
- Cada tenant tiene su propia instancia n8n
- Bases de datos separadas
- Credenciales únicas por tenant

### Autenticación
- Tokens JWT para API
- Rotación de tokens cada 30 días
- MFA para panel de administración

### Monitoreo
- Logs de todas las operaciones
- Alertas de actividad sospechosa
- Auditoría de cambios en workflows

---

## 💡 Recomendaciones

### Para Desarrollo
1. **Empezar con MiConsul Master** - Es la base de todo
2. **Probar workflows base en un tenant de prueba** antes de desplegar a producción
3. **Documentar cada workflow** con comentarios y README
4. **Usar versionado semántico** para workflows (v1.0.0, v1.1.0, etc.)

### Para Producción
1. **No modificar workflows en producción directamente** - Usar Git
2. **Tener plan de rollback** para cada deployment
3. **Monitorear intensivamente** las primeras semanas
4. **Comunicar cambios** a los clientes con anticipación

---

**Versión**: 1.0  
**Fecha**: 2026-01-29  
**Estado**: Propuesta inicial
