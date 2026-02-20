# Plan de Integración: YCloud WhatsApp + n8n + MiConsul

## Objetivo
Conectar MiConsulUno con YCloud para enviar y recibir mensajes de WhatsApp
a los pacientes de forma automatizada, usando n8n como orquestador y el túnel
de Cloudflare como punto de entrada para los webhooks de YCloud.

---

## Arquitectura General

```
┌──────────────┐     Webhook POST      ┌──────────────────────────┐
│   YCloud     │ ──────────────────────►│  Cloudflare Tunnel       │
│  (WhatsApp)  │     (status, inbox)    │  *.trycloudflare.com     │
│              │◄──────────────────────│                          │
│              │     API REST           └──────────┬───────────────┘
└──────────────┘     (enviar mensajes)             │
                                                    ▼
                                        ┌──────────────────────────┐
                                        │  n8n (Docker)            │
                                        │  - Recibe webhooks       │
                                        │  - Envía vía API YCloud  │
                                        │  - Procesa lógica        │
                                        └──────────┬───────────────┘
                                                    │
                                                    ▼
                                        ┌──────────────────────────┐
                                        │  MySQL (MiConsulUno)     │
                                        │  - Datos del paciente    │
                                        │  - Historial de ventas   │
                                        └──────────────────────────┘
```

---

## Fase 1: Configuración de Credenciales

### 1.1 — API Key de YCloud
- [ ] El usuario proporciona su **YCloud API Key**
- [ ] Se agrega como variable de entorno en `.env.integrated`:
  ```
  YCLOUD_API_KEY=tu_api_key_aqui
  ```
- [ ] Se crea credencial en n8n: **Settings → Credentials → New → Header Auth**
  - Name: `YCloud API Key`
  - Header Name: `X-API-Key`
  - Header Value: `{YCLOUD_API_KEY}`

### 1.2 — SMTP para Emails
- [ ] El usuario proporciona credenciales SMTP (Gmail con App Password)
- [ ] Se crea credencial en n8n: **Settings → Credentials → New → SMTP**
  - Host: `smtp.gmail.com`
  - Port: `465` (SSL) o `587` (TLS)
  - User: `tu_email@gmail.com`
  - Password: contraseña de aplicación de Google

---

## Fase 2: Webhook de YCloud → n8n

### 2.1 — Crear Webhook Receptor en n8n
- [ ] Crear nuevo workflow: **"YCloud: Webhook Receptor"**
- [ ] Nodo Webhook: `POST /webhook/ycloud-inbound`
- [ ] URL pública: `https://[tunel].trycloudflare.com/webhook/ycloud-inbound`
- [ ] Procesa eventos de YCloud:
  - `whatsapp.message.received` — Mensaje entrante del paciente
  - `whatsapp.message.updated` — Status de entrega (sent/delivered/read)

### 2.2 — Registrar Webhook en YCloud
- [ ] En el panel de YCloud → Settings → Webhooks
- [ ] URL: `https://[tunel].trycloudflare.com/webhook/ycloud-inbound`
- [ ] Eventos: `whatsapp.message.received`, `whatsapp.message.updated`
- [ ] ⚠️ **NOTA IMPORTANTE**: Cuando el túnel de Cloudflare cambie de URL
      (cada reinicio genera una nueva URL), hay que actualizar el webhook en YCloud.
      Para producción, se recomienda un dominio fijo con tunnel permanente.

---

## Fase 3: Modificar Workflows Existentes

### 3.1 — Ticket de Caja (ya tiene YCloud)
**Estado actual:** Ya usa `api.ycloud.com/v2/whatsapp/messages` ✅
**Cambios necesarios:**
- [ ] Conectar la credencial real de YCloud API Key
- [ ] Verificar que el template `ticket_pago_miconsul` exista en YCloud
- [ ] Configurar `whatsapp_sender` con el número real registrado

### 3.2 — Fidelización YCloud (ya tiene YCloud)
**Estado actual:** Ya usa `api.ycloud.com/v2/whatsapp/messages` ✅
**Cambios necesarios:**
- [ ] Conectar la credencial real de YCloud API Key
- [ ] Verificar que el template `bienvenida_miconsul` exista en YCloud
- [ ] Configurar `whatsapp_sender` con el número real registrado

### 3.3 — Fidelización Email+WhatsApp (usa Evolution API)
**Estado actual:** Usa Evolution API ❌ → Cambiar a YCloud
**Cambios necesarios:**
- [ ] Reemplazar nodo HTTP Request de Evolution API por YCloud API
- [ ] Usar mismo template que Fidelización YCloud

### 3.4 — Fidelización Pacientes Nuevos (solo email)
**Estado actual:** Solo envía email ✅
**Cambios opcionales:**
- [ ] Agregar nodo de WhatsApp vía YCloud para enviar también por WhatsApp

---

## Fase 4: Templates de WhatsApp en YCloud

Los templates deben estar **aprobados por Meta** antes de poder usarse.

### Templates necesarios:
| Template | Uso | Variables |
|----------|-----|-----------|
| `ticket_pago_miconsul` | Comprobante de pago | `folio`, `nombre`, `total`, `fecha` |
| `anticipo_miconsul` | Recibo de anticipo | `folio`, `nombre`, `total`, `fecha` |
| `bienvenida_miconsul` | Bienvenida paciente nuevo | `nombre` |

### Proceso de aprobación:
1. Crear template en YCloud → WhatsApp → Templates
2. Enviar a revisión de Meta (24-48 hrs)
3. Una vez aprobado, ya se puede usar desde n8n

---

## Fase 5: Testing

### 5.1 — Test de envío (n8n → YCloud → WhatsApp)
- [ ] Ejecutar Ticket de Caja con un `sale_id` real
- [ ] Verificar que el paciente reciba el WhatsApp
- [ ] Verificar que el email llegue correctamente

### 5.2 — Test de recepción (WhatsApp → YCloud → n8n)
- [ ] Enviar un mensaje desde un celular al número de WhatsApp Business
- [ ] Verificar que n8n reciba el webhook de YCloud
- [ ] Verificar los datos del mensaje en el log de n8n

---

## Fase 6: Producción

### 6.1 — Túnel permanente
- [ ] Configurar Cloudflare Tunnel con dominio fijo (no trycloudflare.com)
- [ ] Actualizar URL del webhook en YCloud con el dominio permanente
- [ ] Actualizar `WEBHOOK_URL` en `.env.integrated`

### 6.2 — Activar workflows
- [ ] Activar Ticket de Caja (toggle ON)
- [ ] Activar Fidelización YCloud (toggle ON)
- [ ] Activar Reporte Diario Doctores (toggle ON)
- [ ] Desactivar workflows duplicados de fidelización

---

## Datos que necesito del usuario

| # | Dato | ¿Para qué? | Estado |
|---|------|-------------|--------|
| 1 | **YCloud API Key** | Autenticación con API de YCloud | ⏳ Pendiente |
| 2 | **Número WhatsApp Business** | Sender ID en YCloud | ⏳ Pendiente |
| 3 | **Gmail SMTP** (email + app password) | Envío de emails | ⏳ Pendiente |
| 4 | **Templates aprobados en YCloud** | Nombres exactos de los templates | ⏳ Pendiente |

---

## Orden de ejecución propuesto

1. ✅ El usuario proporciona YCloud API Key + número WhatsApp
2. ✅ Configurar credencial en n8n
3. ✅ Crear workflow receptor de webhooks
4. ✅ Registrar webhook en panel de YCloud
5. ✅ Modificar workflows para usar credenciales reales
6. ✅ Test de envío
7. ✅ Test de recepción
8. ✅ Respaldo a GitHub
