# Workflows de Fidelización MiConsul

## Descripción General
El sistema de fidelización de MiConsul incluye **3 workflows** que trabajan en conjunto para retener pacientes nuevos mediante comunicación automatizada por email y WhatsApp.

---

## 1. Fidelización: Pacientes Nuevos (Deep Persuasion)
**Archivo:** `fidelizacion_pacientes_nuevos.json`

### ¿Cómo funciona?
Se activa al detectar una nueva venta en la tabla `ospos_sales`. Si es la **primera compra** del paciente (`venta_count = 1`), le envía un email de bienvenida con ofertas exclusivas.

### Pasos:
| # | Nodo | Descripción |
|---|------|-------------|
| 1 | **Trigger: Nueva Venta** | Monitorea la tabla de ventas cada minuto buscando nuevos registros. |
| 2 | **¿Es su primera vez?** | Cuenta cuántas ventas tiene este `customer_id`. |
| 3 | **Filtrar: Nuevo Paciente** | Solo continúa si `venta_count = 1`. |
| 4 | **Datos del Paciente** | Obtiene nombre, email y teléfono del paciente. |
| 5 | **Email: Fidelización** | Envía email de bienvenida con: limpieza gratis + garantía doble. |

### Ofertas incluidas:
- 🎁 **Limpieza de Regalo** en la próxima visita
- 🛡️ **Garantía Doble**: compra 5 años, recibe 10 años gratis

---

## 2. Fidelización: Email + WhatsApp (YCloud)
**Archivo:** `fidelizacion_ycloud.json`

### ¿Cómo funciona?
Se activa mediante un **Webhook POST** cuando MiConsulUno envía un evento `sale_created`. Verifica si es paciente nuevo y envía **tanto email como WhatsApp** usando YCloud.

### Pasos:
| # | Nodo | Descripción |
|---|------|-------------|
| 1 | **Webhook: Evento de Venta** | Recibe POST con `{ event: "sale_created", data: { customer_id } }`. |
| 2 | **¿Es una Venta?** | Filtra solo eventos tipo `sale_created`. |
| 3 | **Verificar Primera Venta** | Cuenta ventas del paciente en MySQL. |
| 4 | **¿Es Paciente Nuevo?** | Solo continúa si es la primera venta. |
| 5 | **Datos del Paciente** | Obtiene información de contacto. |
| 6 | **Enviar Email** | Email de bienvenida vía SMTP. |
| 7 | **Enviar WhatsApp (YCloud)** | Template `bienvenida_miconsul` vía API YCloud. |

### Webhook URL:
```
POST https://[tunel].trycloudflare.com/webhook/mi-consul-events
```

---

## 3. Fidelización: Email + WhatsApp (Evolution API)
**Archivo:** `fidelizacion_email_whatsapp.json`

### ¿Cómo funciona?
Igual que la versión YCloud, pero usa **Evolution API** como proveedor de WhatsApp en lugar de YCloud. Útil si se usa un número de WhatsApp estándar (no Business API).

### Diferencias con la versión YCloud:
| Característica | YCloud | Evolution API |
|---|---|---|
| WhatsApp API | YCloud (Business API) | Evolution API (instancia propia) |
| Templates Meta | Sí (requiere aprobación) | No (mensaje directo) |
| Costo | Por mensaje | Auto-hospedado |

---

## Credenciales Requeridas (para los 3 workflows)
| Credencial | Tipo | Uso |
|---|---|---|
| **MySQL MiConsulUno** | MySQL | ✅ Configurada |
| **Gmail SMTP** | SMTP | ⚠️ Para envío de emails |
| **YCloud API Key** | HTTP Header Auth | ⚠️ Para WhatsApp vía YCloud |
| **WhatsApp API Key** | HTTP Header Auth | ⚠️ Para WhatsApp vía Evolution API |

## Acceso desde Internet
1. Los 3 workflows se gestionan desde el panel de n8n vía Cloudflare.
2. Los basados en Webhook requieren que PHP envíe un POST al cerrar una venta.
3. El basado en polling (Pacientes Nuevos) se activa automáticamente con el toggle.

## Notas
- Solo 1 de los 3 workflows de fidelización debería estar activo a la vez para evitar envíos duplicados.
- Recomendación: usar **Fidelización YCloud** si ya tienes WhatsApp Business API configurado.
