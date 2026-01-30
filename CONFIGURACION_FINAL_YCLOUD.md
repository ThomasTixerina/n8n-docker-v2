# Guía Rápida - Configuración Final del Workflow YCloud

## ✅ Lo que ya está hecho:
- ✓ Workflow importado: "Integracion - YCloud"
- ✓ API Key de YCloud configurada: `your_ycloud_api_key_here`
- ✓ Número de WhatsApp Business: `your_whatsapp_number_here`

## 🔑 Paso Final - Configurar OpenAI en n8n

### 1. Accede a tu n8n
Abre tu navegador y ve a:
https://activated-arrangements-divine-power.trycloudflare.com/

### 2. Busca el Workflow
En el panel izquierdo, busca y abre el workflow llamado:
**"Integracion - YCloud"**

### 3. Configura las Credenciales de OpenAI
1. Busca el nodo llamado **"OpenAI Chat Model"** (tiene un ícono de OpenAI)
2. Haz clic en el nodo para abrirlo
3. En la sección "Credentials", verás un desplegable
4. Haz clic en **"Create New Credential"** o selecciona una existente si ya tienes una
5. Si creas una nueva:
   - **Name**: "OpenAI - YCloud Integration" (o el nombre que prefieras)
   - **API Key**: Pega esta clave:
     ```
     your_openai_api_key_here
     ```
6. Haz clic en **"Save"** o **"Create"**

### 4. Guarda el Workflow
1. Haz clic en el botón **"Save"** en la esquina superior derecha
2. Ya puedes cerrar el nodo de OpenAI

### 5. Activa el Workflow
1. En la parte superior derecha, verás un switch que dice **"Inactive"** o **"Active"**
2. Cambia el switch a **"Active"**
3. Esto activará el webhook para recibir mensajes de WhatsApp

## 🎉 ¡Listo!
Una vez activado, tu workflow estará funcionando y listo para:
- Recibir mensajes de WhatsApp vía YCloud
- Procesarlos con OpenAI (GPT-4.1-mini)
- Responder automáticamente a través de WhatsApp

## 📍 URL del Webhook
Tu webhook de YCloud estará disponible en:
```
https://activated-arrangements-divine-power.trycloudflare.com/webhook/ycloud
```

Esta es la URL que debes configurar en YCloud para que envíe los mensajes entrantes.

---
**Nota**: Si tienes algún problema, verifica que todas las credenciales estén correctamente guardadas.
