# Workflow: Importación de Servicios MiConsul

## Descripción General
Este workflow de n8n permite automatizar la importación masiva de Servicios y Especialidades desde un archivo CSV alojado en Google Sheets hacia la base de datos MySQL de MiConsulUno.

## Pasos del Flujo (Paso a Paso)
1. **▶️ Inicio Manual**: El flujo se desencadena de manera manual por el administrador desde la consola de n8n.
2. **⚙️ Configuración**: Define las variables estáticas necesarias (el ID del Tenant/Práctica, la URL del CSV en Google Sheets, y los valores por defecto de duración, meses de garantía, e IVA).
3. **🏷️ Crear Especialidades**: Ejecuta una consulta `INSERT IGNORE` en MySQL para asegurar que las 15 especialidades base existan en la base de datos para evitar inconsistencias.
4. **📋 Obtener IDs Especialidades**: Recupera los IDs internos asignados por MySQL a esas especialidades.
5. **🗺️ Construir Mapa**: Código JavaScript que relaciona el nombre en texto de cada especialidad con su respectivo ID en MySQL, incluyendo soporte para sinónimos y normalización (acentos/mayúsculas).
6. **📥 Descargar CSV**: Efectúa una petición HTTP GET para descargar el listado de precios crudo desde la url pública de Google Sheets en formato texto (CSV).
7. **📊 Parsear CSV + Mapear**: Lee línea por línea el CSV, limpia los formatos de precio y cruza la especialidad en texto de cada fila con el mapa de IDs construido en el paso 5.
8. **💾 Insertar Servicio**: Ejecuta una consulta SQL segura para insertar o ignorar (si ya existe bajo ese mismo nombre) cada servicio procesado en la tabla `ospos_items`.
9. **📦 Agrupar y ✅ Resumen**: Consolida todos los registros insertados y emite un mensaje en pantalla indicando el número de ítems procesados.

## Acceso desde Internet
Debido a que este flujo interactúa directamente con los precios de la clínica, se restringe su ejecución bajo el contenedor fortificado de n8n:
1. Ingresa a la URL segura provista por Cloudflare o a localhost (Ej: `https://[tunel].trycloudflare.com`).
2. Introduce las credenciales maestras del entorno.
3. Entra a la lista de **Workflows** y abre **MiConsulUno - Importar Administración: Especialidades + Servicios**.
4. Presiona el botón **Test Workflow / Execute** para correr la importación bajo demanda.

*Nota: El flujo no usa Webhooks GET/POST públicos para evitar vulnerabilidades de inyección no autenticada de catálogos.*
