# Guía Completa: Integración de YCloud WhatsApp con Mi Consul

## 🎯 Ventajas de YCloud con Coexistencia

✅ **Coexistencia:** Tu WhatsApp personal sigue funcionando normalmente  
✅ **Sin pérdida de datos:** No necesitas desinstalar la app  
✅ **Integración directa:** Vía Facebook Business Manager  
✅ **API robusta:** Perfecta para automatizaciones empresariales  

---

## 📋 Paso 1: Configuración Inicial en YCloud

### 1.1 Crear Cuenta
1. Ve a: https://www.ycloud.com/console/#/app/dashboard/account
2. Regístrate con tu email empresarial
3. Verifica tu cuenta

### 1.2 Obtener API Key
1. En el dashboard, ve a **Settings** → **API Keys**
2. Clic en **Create New API Key**
3. Copia y guarda tu API Key (la necesitarás para n8n)
   - Formato: `yk_live_xxxxxxxxxxxxxxxxxx`

---

## 📱 Paso 2: Conectar WhatsApp Business (Coexistencia)

### 2.1 Requisitos Previos
- Tener una cuenta de **Facebook Business Manager**
- Un número de teléfono dedicado para WhatsApp Business (puede ser diferente al personal)
- WhatsApp Business App instalada en tu teléfono

### 2.2 Proceso de Conexión
1. En YCloud Dashboard, ve a **WhatsApp Manager** → **Phone Numbers**
2. Clic en **Add Phone Number**
3. Selecciona **Connect via Facebook Business Manager**
4. Sigue el proceso de autorización:
   - Conecta tu Facebook Business Manager
   - Selecciona tu WhatsApp Business Account
   - Escanea el QR code con WhatsApp Business
5. ✅ ¡Listo! Tu WhatsApp está conectado sin perder datos

---

## 📝 Paso 3: Crear Template de Bienvenida

### 3.1 Acceder a Templates
1. En YCloud Dashboard: **WhatsApp Manager** → **Templates**
2. Clic en **New Template** → **Utility**

### 3.2 Configurar Template
**Nombre del Template:** `bienvenida_miconsul`  
**Categoría:** Utility  
**Idioma:** Spanish (Mexico) - `es_MX`

**Contenido del Mensaje:**
```
¡Hola {{1}}! 🦷

Gracias por confiar en Mi Consul. Como bienvenida:

🎁 Limpieza GRATIS en tu próxima visita
🛡️ Garantía de 5 años + 5 años de regalo

¡Nos vemos pronto!
- Equipo Mi Consul
```

**Nota:** El `{{1}}` será reemplazado por el nombre del paciente

### 3.3 Enviar para Aprobación
1. Clic en **Submit**
2. Espera aprobación de WhatsApp (normalmente 15-30 minutos)
3. Verifica el estado en la lista de templates

---

## 🔧 Paso 4: Configurar n8n

### 4.1 Crear Credencial de YCloud
1. En n8n, ve a **Credentials** → **Create New**
2. Busca y selecciona **HTTP Header Auth**
3. Configura:
   - **Name:** `YCloud API Key`
   - **Header Name:** `X-API-Key`
   - **Header Value:** `yk_live_xxxxxxxxxxxxxxxxxx` (tu API Key)
4. Guarda

### 4.2 Importar Workflow
1. En n8n, clic en **Import from File**
2. Selecciona: `fidelizacion_ycloud.json`
3. El workflow se importará automáticamente

### 4.3 Configurar el Nodo "Config"
1. Abre el nodo **Config**
2. Actualiza el valor de `whatsapp_sender`:
   - Formato: `+52XXXXXXXXXX` (tu número de WhatsApp Business con código de país)
   - Ejemplo: `+5218112345678`

### 4.4 Configurar Credenciales de Email
1. Abre el nodo **Enviar Email**
2. Selecciona o crea tus credenciales SMTP/Gmail
3. Guarda

---

## 🧪 Paso 5: Prueba de Fuego

### 5.1 Activar el Workflow
1. En n8n, activa el workflow (toggle en la esquina superior derecha)
2. Copia la URL del webhook (aparece en el nodo "Webhook: Evento de Venta")

### 5.2 Realizar Venta de Prueba
1. Entra a Mi Consul (desarrollo)
2. Registra una venta de prueba con:
   - Un paciente nuevo
   - Tu número de celular
   - Tu email

### 5.3 Verificar Resultados
Deberías recibir:
- ✅ Email de bienvenida
- ✅ WhatsApp con el mensaje del template

---

## 🔍 Solución de Problemas

### Error: "Template not approved"
- **Solución:** Espera a que WhatsApp apruebe el template (puede tomar hasta 24 horas)

### Error: "Invalid phone number format"
- **Solución:** Asegúrate de usar formato internacional: `+52XXXXXXXXXX`

### No llega el WhatsApp
- **Solución:** 
  1. Verifica que el template esté aprobado
  2. Confirma que el número del paciente esté en formato correcto
  3. Revisa los logs en YCloud Dashboard

---

## 📊 Monitoreo

### Ver Mensajes Enviados
1. YCloud Dashboard → **Messages**
2. Aquí verás todos los mensajes con su estado:
   - `accepted`: Aceptado por YCloud
   - `sent`: Enviado a WhatsApp
   - `delivered`: Entregado al usuario
   - `read`: Leído por el usuario

---

## 💰 Costos (Aproximados)

- **Mensajes de Template:** ~$0.005 - $0.01 USD por mensaje
- **Mensajes de Conversación:** Gratis dentro de la ventana de 24 horas
- **Sin costos fijos mensuales** (solo pagas por uso)

---

## 🚀 Próximos Pasos

Una vez que esto funcione, podemos agregar:
1. Recordatorios de citas automáticos
2. Seguimiento post-tratamiento
3. Encuestas de satisfacción
4. Promociones personalizadas

¿Listo para empezar? 🦷✨
