# Guía - Configuración del Webhook en YCloud

## 🎯 Objetivo
Configurar YCloud para que envíe todos los mensajes entrantes de WhatsApp a tu workflow de n8n.

## 📍 URL del Webhook
Esta es la URL que vamos a configurar en YCloud:
```
https://activated-arrangements-divine-power.trycloudflare.com/webhook/ycloud
```

---

## 🔧 Pasos para Configurar el Webhook en YCloud

### Paso 1: Acceder a la Consola de YCloud
1. Abre tu navegador y ve a: https://www.ycloud.com/console
2. Inicia sesión con tu cuenta

### Paso 2: Navegar a WhatsApp Settings
1. En el menú lateral izquierdo, busca la sección **"WhatsApp"**
2. Haz clic en **"Settings"** o **"Configuration"** (puede variar según la interfaz)
3. También puede estar en **"Developer"** > **"Webhooks"** o **"API"** > **"Webhooks"**

### Paso 3: Configurar el Webhook
1. Busca la sección **"Webhook Configuration"** o **"Callback URL"**
2. Encontrarás un campo para ingresar la URL del webhook
3. **Pega esta URL exactamente**:
   ```
   https://activated-arrangements-divine-power.trycloudflare.com/webhook/ycloud
   ```

### Paso 4: Configurar los Eventos (Event Types)
Asegúrate de que los siguientes eventos estén **activados/seleccionados**:
- ✓ **Message Received** / **whatsapp.inbound_message** (Este es el más importante)
- ✓ **Message Status** / **whatsapp.message.status** (opcional, para ver estados de entrega)

### Paso 5: Método HTTP
- Selecciona: **POST**
- Esto es estándar para webhooks de WhatsApp

### Paso 6: Guardar la Configuración
1. Haz clic en **"Save"** o **"Update"** o **"Apply"**
2. YCloud puede pedirte que verifiques el webhook:
   - Algunos proveedores envían una petición de verificación
   - Si te pide un "Verification Token", puedes dejar el campo vacío o usar cualquier valor (n8n no requiere verificación adicional)

### Paso 7: Probar el Webhook (Opcional pero Recomendado)
Si YCloud tiene un botón de **"Test Webhook"** o **"Send Test Message"**:
1. Úsalo para enviar un mensaje de prueba
2. Ve a tu n8n y verifica que el workflow se haya ejecutado
3. Puedes ver las ejecuciones en: n8n > "Executions" en el panel lateral

---

## 📱 Alternativa: Si no encuentras la sección de Webhooks

### Opción A: Buscar en "Developer" o "API"
Algunos dashboards de YCloud tienen los webhooks en:
- **Developer** > **API Configuration** > **Webhooks**
- **Settings** > **Integration** > **Webhooks**

### Opción B: Verificar en WhatsApp Business API
Si usas WhatsApp Business API directamente:
1. Ve a **WhatsApp** > **Phone Numbers**
2. Selecciona tu número de teléfono (+528113090909)
3. Busca la opción **"Webhook"** o **"Callback URL"**

---

## ✅ Verificación Final

Una vez configurado, puedes probar enviando un mensaje de WhatsApp a tu número de negocio (+528113090909):

1. Envía un mensaje desde tu WhatsApp personal
2. El mensaje debería:
   - Llegar a YCloud
   - YCloud lo reenvía a tu webhook de n8n
   - n8n procesa el mensaje con OpenAI
   - OpenAI genera una respuesta
   - n8n envía la respuesta de vuelta vía YCloud
   - Recibes la respuesta en WhatsApp

---

## 🚨 Notas Importantes

### URL Dinámica de Cloudflare
⚠️ **IMPORTANTE**: La URL de Cloudflare Tunnel que estamos usando es **temporal y cambia cada vez que reinicias n8n**.

**Solución a Largo Plazo:**
1. Considera usar un túnel permanente de Cloudflare (requiere cuenta de Cloudflare)
2. O usa un servicio como ngrok con URL fija
3. O despliega n8n en un servidor con dominio propio

**Por ahora:**
- Cada vez que reinicies n8n, obtén la nueva URL ejecutando: `.\monitor-n8n.ps1`
- Actualiza el webhook en YCloud con la nueva URL

### Seguridad del Webhook
Si YCloud te permite configurar:
- **Webhook Secret**: Puedes dejarlo vacío por ahora
- **Authentication**: Selecciona "None" o deja por defecto

---

## 🆘 ¿Problemas?

Si tienes dificultades para encontrar la configuración de webhooks en YCloud:
1. Busca en la documentación de YCloud: https://docs.ycloud.com
2. O comparte una captura de pantalla de tu dashboard de YCloud y te guío exactamente dónde está

---

**¿Listo para probar?** Envía un mensaje a tu WhatsApp de negocio y mira la magia suceder! 🎉
