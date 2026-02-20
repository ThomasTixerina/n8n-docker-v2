# Workflow: Ticket de Caja — Notificación Email + WhatsApp

## Descripción General
Este workflow se dispara automáticamente cada vez que se completa una venta en MiConsulUno. Genera un comprobante de pago profesional en HTML y lo envía al paciente por **Email** y/o **WhatsApp** (vía YCloud), dependiendo de qué datos de contacto tenga registrados.

## ¿Cómo se activa?
Se activa mediante un **Webhook POST** que MiConsulUno (PHP) dispara al completar una venta. La URL del webhook es:
```
POST https://[tunel].trycloudflare.com/webhook/ticket-caja
```
El payload esperado:
```json
{
  "event": "sale_created",
  "data": {
    "sale_id": 12345,
    "customer_id": 678
  }
}
```

## Pasos del Flujo (Paso a Paso)

| # | Nodo | Descripción |
|---|------|-------------|
| 1 | **Webhook: Venta Completada** | Recibe el evento POST desde MiConsulUno cuando se cierra una venta. |
| 2 | **Config: Clínica** | Variables de personalización: nombre, logo, colores, teléfono, email, redes sociales, sender de WhatsApp y templates de YCloud. **Editar aquí para cada clínica.** |
| 3 | **MySQL: Datos de la Venta** | Consulta el header de la venta: paciente, doctor, recepcionista, sucursal, totales. |
| 4 | **MySQL: Servicios del Ticket** | Obtiene el detalle línea por línea de los servicios/productos vendidos. |
| 5 | **MySQL: Forma de Pago** | Recupera los métodos de pago (efectivo, tarjeta, transferencia) y montos. |
| 6 | **Code: Construir Ticket** | Código JavaScript que genera: (a) un email HTML profesional con tabla de servicios, totales, forma de pago, y branding de la clínica; (b) un mensaje corto de WhatsApp con resumen del ticket. Detecta si es anticipo o pago completo. |
| 7 | **¿Tiene Email?** | Condicional: si el paciente tiene correo registrado → envía email. |
| 8 | **¿Tiene WhatsApp?** | Condicional: si el paciente tiene teléfono registrado → envía WhatsApp. |
| 9 | **Enviar Email: Ticket** | Envía el HTML del comprobante por SMTP (Gmail configurado). |
| 10 | **Enviar WhatsApp: YCloud** | Envía template aprobado por Meta vía API de YCloud con datos del ticket. |
| 11 | **Log: Resultado** | Registra en consola el resultado del envío para auditoría. |
| 12 | **Respuesta Webhook** | Responde al servidor PHP confirmando que el ticket fue procesado. |

## Credenciales Requeridas
| Credencial | Tipo | Configurar en n8n |
|---|---|---|
| **MySQL MiConsulUno** | MySQL | ✅ Ya configurada |
| **Gmail SMTP** | SMTP | ⚠️ Configurar en n8n → Credentials → SMTP |
| **YCloud API Key** | HTTP Header Auth | ⚠️ Configurar en n8n → Credentials → Header Auth (header: `X-API-Key`) |

## Personalización por Clínica
Edita el nodo **"Config: Clínica"** para personalizar:
- `clinica_nombre` — Nombre de la clínica
- `clinica_slogan` — Slogan para el email
- `clinica_color_primario` / `clinica_color_secundario` — Colores de marca (hex)
- `clinica_tel` / `clinica_email` / `clinica_web` / `clinica_instagram` — Contacto
- `email_from` — Dirección del remitente de emails
- `whatsapp_sender` — Número de WhatsApp Business registrado en YCloud
- `ycloud_template_ticket` / `ycloud_template_anticipo` — Nombres de templates aprobados

## Flujo Visual
```
                    ┌─ Config: Clínica
                    │
Webhook POST ───────┤
                    │
                    └─ MySQL: Venta ─┬─ MySQL: Servicios ─┐
                                     │                     │
                                     └─ MySQL: Pagos ──────┘
                                                           │
                                              Code: Construir Ticket
                                                     │
                                           ┌─────────┴─────────┐
                                           │                     │
                                    ¿Tiene Email?          ¿Tiene WhatsApp?
                                       │    │                 │    │
                                      Sí   No               Sí   No
                                       │    │                 │    │
                                   Enviar   │            Enviar    │
                                   Email    │           WhatsApp   │
                                       │    │                 │    │
                                       └────┴────── Log ──────┴────┘
                                                    │
                                            Respuesta Webhook
```

## Acceso desde Internet
1. Este workflow se activa mediante webhook. **No requiere acceso manual** del administrador.
2. Para **activarlo**: abre el workflow en n8n → activa el toggle verde (arriba derecha).
3. Para **probarlo manualmente**: desde n8n, haz click en el nodo Webhook → copia la "Test URL" → envía un POST con un `sale_id` válido.
4. Para **integrarlo a MiConsulUno**: en el código PHP de cierre de venta, agregar un `curl POST` a la URL del webhook con el `sale_id`.

## Notas de Seguridad
- El webhook es accesible solo a través del túnel Cloudflare (no es público directo).
- Los datos del paciente (email, teléfono) nunca salen del contenedor Docker excepto para el envío directo.
- El template de WhatsApp debe estar **aprobado por Meta** antes de poder enviarse.
