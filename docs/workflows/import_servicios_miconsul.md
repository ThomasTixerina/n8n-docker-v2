# Workflow: Importar Servicios MiConsul (v2.0 — Sincronización Automática)

## Descripción General
Este workflow conecta de forma **permanente** un Google Sheet del cliente con la base de datos de MiConsulUno. El cliente solo necesita actualizar su lista de precios en Google Drive, y n8n se encarga de importar automáticamente los servicios nuevos.

## ¿Cómo funciona la conexión con Google Sheets?
El Google Sheet actúa como **documento fijo**. No se sube cada vez, sino que n8n guarda el **ID del documento** y lo consulta por internet cada vez que se ejecuta.

### Configuración del documento (una sola vez):
1. El cliente abre su Google Sheet con la lista de precios.
2. Click en **Compartir** → **"Cualquier persona con el enlace puede ver"**.
3. De la URL del documento: `https://docs.google.com/spreadsheets/d/XXXXXXXXXX/edit`
   → El **ID** es la parte `XXXXXXXXXX`.
4. Ese ID se coloca en el nodo **"⚙️ Configuración"** del workflow, en el campo `google_sheet_id`.

### ¿Qué pasa después?
- **Cada día a las 6:00 AM**, n8n automáticamente descarga el CSV más reciente del Google Sheet.
- Compara contra la base de datos existente.
- Inserta solo los servicios **nuevos** (sin duplicar los que ya existen).
- También puede ejecutarse **manualmente** en cualquier momento desde el panel de n8n.

## Pasos del Flujo (Paso a Paso)
| # | Nodo | Descripción |
|---|------|-------------|
| 1 | **▶️ Inicio Manual** | Permite ejecutar el flujo bajo demanda desde el panel de n8n. |
| 2 | **⏰ Sincronización Automática** | Trigger automático: se dispara cada día a las 6:00 AM (horario del servidor). |
| 3 | **⚙️ Configuración** | Define el `google_sheet_id` (documento fijo), `practica_id` (tenant), y valores por defecto (duración, meses, IVA). |
| 4 | **🏷️ Crear Especialidades** | Asegura que las 15 especialidades base existan en la BD (INSERT IGNORE). |
| 5 | **📋 Obtener IDs** | Recupera los IDs internos de MySQL para cada especialidad. |
| 6 | **🗺️ Construir Mapa** | Código JS que crea un diccionario `nombre → ID` con soporte para sinónimos y acentos. |
| 7 | **📥 Descargar CSV** | HTTP GET al Google Sheet público, descargando la última versión del documento en formato CSV. |
| 8 | **📊 Parsear + Mapear** | Lee el CSV línea por línea, limpia precios, asocia cada servicio con su especialidad. |
| 9 | **💾 Insertar Servicio** | SQL `INSERT ... WHERE NOT EXISTS` para cada servicio. No duplica los que ya existen. |
| 10 | **📦 Agrupar + ✅ Resumen** | Consolida resultados y emite el total de servicios procesados. |

## Acceso desde Internet
1. Ingresa a la URL del túnel Cloudflare asignado (ej: `https://[tunel].trycloudflare.com`).
2. Inicia sesión con tus credenciales.
3. Abre **Workflows** → **MiConsulUno - Importar Administración: Especialidades + Servicios**.
4. Para ejecución manual: presiona **Test Workflow**.
5. Para ejecución automática: **activa el workflow** con el toggle de la esquina superior derecha. A partir de ese momento, correrá solo cada día a las 6AM.

## Flujo de Trabajo del Cliente
```
┌─────────────────────────────────┐
│  CLIENTE                        │
│  Actualiza su Google Sheet      │
│  con la lista de precios        │
└──────────┬──────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│  GOOGLE DRIVE                   │
│  Documento fijo compartido      │
│  (solo lectura pública)         │
└──────────┬──────────────────────┘
           │  ⏰ Diario 6AM
           ▼
┌─────────────────────────────────┐
│  n8n (Docker)                   │
│  Descarga CSV → Parsea →        │
│  Compara → Inserta nuevos       │
└──────────┬──────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│  MiConsulUno (MySQL)            │
│  Servicios actualizados         │
│  sin duplicados                 │
└─────────────────────────────────┘
```

## Notas de Seguridad
- El Google Sheet solo necesita permisos de **lectura** pública. El cliente mantiene el control total de edición.
- No se exponen webhooks públicos. La sincronización es **pull** (n8n jala), no **push**.
- Las credenciales de MySQL están protegidas dentro del contenedor Docker.
