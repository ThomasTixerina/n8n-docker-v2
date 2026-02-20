# Workflow: Importar / Actualizar Pacientes MiConsul

## Descripción General
Este workflow de n8n permite la carga masiva (o iterativa) de pacientes desde un archivo Excel (`.xlsx` o `.csv`) mediante un formulario interno. El sistema parsea los datos, busca inteligentemente en la base de datos si el paciente ya existe, y procede a crearlo o a actualizar su información (celular y correo).

## Pasos del Flujo (Paso a Paso)
1. **📤 Formulario Subir Archivo**: Punto de entrada del operador. Despliega la opción para subir el Excel y configurar el ID de la Práctica (Tenant ID).
2. **⚙️ Configuración**: Define variables de entorno del flujo de datos, inyectando el ID del tenant especificado y configuraciones de fila base.
3. **📊 Leer Archivo Excel**: Convierte los datos binarios del documento .xlsx en objetos JSON nativos de n8n.
4. **✅ Validar + Mapear Columnas**: Código de normalización exhaustiva que:
   - Identifica columnas dinámicamente usando alias (ej: `primer_nombre` = `firstname` = `nombre`).
   - Normaliza fechas al formato compatible de MySQL `YYYY-MM-DD`.
   - Normaliza teléfonos limitándolos a 10 dígitos.
   - Filtra filas vacías.
5. **🚦 ¿Hay datos válidos?**: Verifica que después de la normalización, sigan existiendo datos viables para procesar. Si no hay datos, emite una respuesta vacía.
6. **🔍 Buscar Paciente en BD**: Se conecta a la base de datos MySQL para buscar coincidencias exactas por `email` o combinación de `nombre + apellido paterno + teléfono`. Devuelve el `person_id` si existe, o `0` si es un paciente nuevo.
7. **🔀 ¿Ya Existe? (Condicional)**:
   - **Camino Verdadero (UPDATE)**:
     - 🔄 **UPDATE: ospos_people / ospos_expedientes**: Si el paciente existe, no sobreescribe ciegamente. Solo inyecta el celular, correo o apellidos faltantes en sus registros correspondientes.
   - **Camino Falso (INSERT)**:
     - ➕ **INSERT: ospos_people**: Se crea la persona en los catálogos base de la clínica.
     - 🆔 **Obtener Nuevo ID**: Se captura su nuevo ID auto-incremental generado por MySQL.
     - ➕ **INSERT: ospos_expedientes**: Se inserta un expediente en salud espejo, ligado al mismo person_id, que funcionará para consultas médicas posteriores.
8. **🔗 Unir y Agrupar**: Consolida los resultados de ambas rutas (Inserciones y Actualizaciones).
9. **📋 Reporte Final**: Levanta un resumen contable de cuantos pacientes fueron encontrados, integrados, ignorados o fallidos.

## Acceso desde Internet
La ejecución de este modelo debe llevarse de manera protegida:
1. Accede a tu túnel seguro asignado vía Cloudflare Tunnels o tu dominio configurado.
2. Inicia sesión con tus credenciales maestras.
3. Entra a la lista de **Workflows** y selecciona **Importar / Actualizar Pacientes MiConsul (.xlsx)**.
4. Puedes dar clic en el botón flotante del lienzo o hacer clic en el nodo *Formulario* y usar el **Test URL** para ejecutar su formulario sin necesidad de activar webhooks públicos globales.
