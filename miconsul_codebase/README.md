# MiConsul Legacy API

## Descripción
API PHP moderna para integrar el sistema legacy MiConsul con n8n workflows.

## Estructura

```
miconsul_codebase/
├── api/
│   └── n8n.php          # Endpoint principal API
├── includes/
│   ├── EnvLoader.php    # Cargador de variables de entorno
│   ├── Security.php     # Utilidades de seguridad
│   ├── Database.php     # Wrapper PDO para base de datos
│   └── Webhook.php      # Helper para enviar webhooks a n8n
├── .env.example         # Plantilla de configuración
└── README.md            # Esta documentación
```

## Instalación

1. Copiar el directorio `miconsul_codebase` al servidor
2. Crear archivo `.env` basado en `.env.example`
3. Configurar las credenciales de base de datos y n8n
4. Apuntar el servidor web a la carpeta `api/`

## Configuración (.env)

```env
# Base de datos
DB_HOST=localhost
DB_PORT=3306
DB_NAME=miconsul
DB_USER=root
DB_PASS=your_password

# n8n
N8N_WEBHOOK_URL=https://your-n8n.trycloudflare.com/webhook
N8N_API_TOKEN=your_secure_token
```

## Endpoints API

Todos los endpoints requieren autenticación Bearer Token.

### GET `/api/n8n.php?action=health`
Verificar estado de la API.

### GET `/api/n8n.php?action=get_patient_history&patient_id=123`
Obtener historial completo de un paciente (visitas, pagos).

### GET `/api/n8n.php?action=get_daily_sales&date=2025-01-29`
Obtener ventas de un día específico.

### GET `/api/n8n.php?action=get_appointments&date=2025-01-29`
Obtener citas de un día específico.

### GET `/api/n8n.php?action=get_birthdays&date=2025-01-29`
Obtener pacientes con cumpleaños en fecha específica.

### GET `/api/n8n.php?action=get_doctor_availability&doctor_id=5&date=2025-01-29`
Obtener disponibilidad de un doctor.

### GET `/api/n8n.php?action=check_first_visit&patient_id=123`
Verificar si es la primera visita del paciente (para fidelización).

### POST `/api/n8n.php?action=create_appointment`
Crear nueva cita.
```json
{
  "patient_id": 123,
  "doctor_id": 5,
  "date": "2025-01-30",
  "time": "10:00:00",
  "type": "consulta",
  "notes": "Primera consulta"
}
```

### POST `/api/n8n.php?action=update_patient`
Actualizar información del paciente.
```json
{
  "patient_id": 123,
  "nombre": "Juan",
  "apellido": "Pérez",
  "email": "juan@email.com",
  "telefono": "5551234567"
}
```

## Autenticación

Todas las peticiones deben incluir el header:
```
Authorization: Bearer YOUR_API_TOKEN
```

## Rate Limiting

- 100 peticiones por minuto por IP
- Respuesta 429 si se excede

## Uso del Webhook Helper en código legacy

```php
<?php
require_once 'includes/Webhook.php';

// Cuando se registra una primera venta
Webhook::triggerFirstSale($patientId, [
    'amount' => 500.00,
    'products' => ['limpieza dental'],
    'doctor_id' => 5
]);

// Para eventos personalizados
Webhook::triggerCustom('patient_registered', [
    'patient_id' => 123,
    'source' => 'website'
]);
```

## Seguridad

- ✅ Prepared statements (prevención SQL injection)
- ✅ Sanitización de inputs
- ✅ Autenticación con tokens
- ✅ Rate limiting
- ✅ Variables sensibles en .env

## Versión
- **Versión**: 2.0
- **Fecha**: 2026-01-29
- **Estado**: Listo para despliegue
