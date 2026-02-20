# Handoff para el Agente (Opencode) — Continuación Mañana

**📌 Instrucciones para el asistente AI (Opencode) al iniciar la sesión del próximo día:**

Al iniciar la próxima sesión, el objetivo es continuar exactamente donde nos quedamos hoy con la **Integración de YCloud (WhatsApp)**. 

### 1. Resumen de lo logrado HOY:
* Se logró importar, limpiar de incompatibilidades de n8n, y documentar **7 workflows** críticos en total.
* **Workflows importados y funcionales:**
  1. *Importar Servicios* (Google Sheets Sync Diario Automático)
  2. *Importar Pacientes* (Procesó 4,837 pacientes correctamente en BD hoy)
  3. *Ticket de Caja* (Email + WhatsApp, activado por Webhook POST de MiConsulUno)
  4. *Reporte Diario Doctores* (Cronograma 8:00 PM, SQL Query)
  5. *Fidelización Pacientes Nuevos* (Deep Persuasion)
  6. *Fidelización YCloud Email + WA*
  7. *Fidelización Evolution Email + WA*
* Se creó el plan `docs/PLAN_INTEGRACION_YCLOUD.md` que será el mapa a seguir mañana.
* Se limpió el entorno borrando scripts temporales JSON (`*fixed*.json`) y `fix_json.js`.

### 2. Siguiente Tarea Inmediata (Fase 1 del Plan de Integración)
El usuario decidió que **NO** usaremos Evolution API para WhatsApp, usaremos directamente la **API de YCloud** integrándolo usando Webhooks entrantes alojados momentáneamente sobre el túnel de Cloudflare (`*.trycloudflare.com`). 

**Tus primeros pasos mañana al comunicarse contigo el usuario deben ser:**
1. Pedirle explícitamente al usuario que proporcione la **YCloud API Key** y su **Número de WhatsApp Business**.
2. Pedirle sus **credenciales de Gmail SMTP**.
3. Inyectar estas claves vía `n8n` mediante la creación de Custom Credentials en **n8n UI** (o inyectándolas en en los archivos de entorno).
4. Configurar el Webhook receptor (`/webhook/ycloud-inbound`) en un flujo de n8n y guiar al usuario para que registre ESA URL del túnel actual dentro de su panel de configuración de YCloud.
5. Empezar las pruebas de envío de WhatsApp conectándolas al workflow de "Ticket de Caja" existente usando las credenciales frescas.

**⚠️ Correcciones o precauciones para mañana:**
* Como el túnel Cloudflare cambia de host en cada reinicio del docker (`trycloudflare.com`), recuérdale al usuario que el Endpoint de Webhook configurado en YCloud tendrá que estar actualizándose, o sugiérele ya dejar anclado un dominio fijo en un túnel de producción, para que no se caiga la integración en el futuro.
* Todos los workflows de n8n ya tienen los nodos de SQL configurados apuntando a `MySQL MiConsulUno`. Si un workflow no funciona, re-verifica el ID de las credenciales de base de datos de esa instancia específica.
* NO borres los archivos `.json` base en `n8n-docker-v2/`, esos son los "Source of Truth" subidos a Git.

### Acción sugerida al inicio de la sesión:
Saludar al usuario, confirmar que leíste este documento de relevo (`HANDOFF_MAÑANA.md`) y que estás listo para aplicar el `PLAN_INTEGRACION_YCLOUD.md`. Pídele sus API Keys para comenzar el setup temporal de Cloudflare con YCloud.
