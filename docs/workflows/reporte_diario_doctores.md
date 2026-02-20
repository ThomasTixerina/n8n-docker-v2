# Workflow: Reporte Diario para Doctores (8 PM)

## Descripción General
Cada noche a las **8:00 PM**, este workflow consulta automáticamente las citas programadas para el **día siguiente** y envía a cada doctor un email con su agenda personalizada. Así cada profesional llega preparado al consultorio.

## Pasos del Flujo (Paso a Paso)

| # | Nodo | Descripción |
|---|------|-------------|
| 1 | **⏰ Cron 8 PM** | Schedule Trigger que se dispara automáticamente todos los días a las 20:00 hrs. |
| 2 | **SQL: Citas Mañana** | Consulta MySQL que extrae todas las citas del día siguiente (`CURDATE() + INTERVAL 1 DAY`), incluyendo nombre del doctor, email, hora de cita, y nombre del paciente. |
| 3 | **Agrupar por Doctor** | Código JavaScript que agrupa las citas por email del doctor. Genera una lista HTML `<li>` con hora y nombre de cada paciente. |
| 4 | **Enviar Email** | Envía un email personalizado a cada doctor con su lista de citas para mañana. |

## Ejemplo de Email Generado
```
Hola, Dr. García

Este es tu resumen de citas para mañana:
• 09:00 — Juan Pérez
• 10:30 — María López
• 12:00 — Carlos Hernández

¡Que tengas un excelente día!
```

## Credenciales Requeridas
| Credencial | Tipo | Estado |
|---|---|---|
| **MySQL MiConsulUno** | MySQL | ✅ Configurada |
| **SMTP (Gmail)** | SMTP | ⚠️ Configurar en n8n → Credentials |

## Acceso desde Internet
1. Ingresa al panel de n8n vía Cloudflare.
2. Abre **Workflows** → **Reporte Diario para Doctores (8 PM)**.
3. **Activa el toggle** verde (arriba derecha) para que se ejecute automáticamente cada noche.
4. Para probarlo manualmente: haz click en **Test Workflow**.

## Tablas MySQL Consultadas
- `tevents` — Calendario de citas (start_date, doctor_id, patient_id)
- `ospos_people` — Datos de doctores y pacientes (nombre, email)

## Flujo Visual
```
⏰ Cron 8PM → SQL: Citas Mañana → Agrupar por Doctor → Enviar Email a cada Doctor
```

## Notas
- Si un doctor no tiene citas para el día siguiente, simplemente no recibe email (no se genera un correo vacío).
- El email del doctor se toma del campo `email` en `ospos_people`.
- La hora de la cita se extrae del campo `start_date` de la tabla `tevents`.
