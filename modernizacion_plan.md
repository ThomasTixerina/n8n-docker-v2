<!-- cspell:locale es -->
# Plan de Modernización: Mi Consul (PHP 5.6 -> 8.3)

Este documento detalla la estrategia para actualizar el sistema dental "Mi Consul" asegurando que sea seguro, rápido y compatible con n8n.

---

## 🛑 Problema Detectado
El sistema utiliza la extensión `mysql` (obsoleta), la cual fue eliminada en PHP 7. Esto impide que el sistema corra en servidores modernos. Además, las consultas son vulnerables a ataques de Inyección SQL.

## 🛠️ Fase 1: Capa de Compatibilidad (The "Shim")
Para no tener que editar los cientos de archivos de la aplicación a la vez, crearemos un "traductor".

1.  **Nuevo Archivo `app/Core/Database.php`**: Usará **PDO** (moderno y seguro).
2.  **Nuevo Archivo `app/Core/mysql_shim.php`**: Este archivo re-definirá funciones como `mysql_query()` y `mysql_fetch_array()` pero usando PDO por debajo.
3.  **Actualización de `app/db.php`**: Se encargará de incluir estos dos archivos.

**Resultado:** El sistema podrá correr en PHP 8.3 inmediatamente sin cambiar ni una línea del código de los módulos individuales.

## 🔒 Fase 2: Seguridad y Variables
1.  **Gestión de Secretos**: Migraremos todos los datos sensibles (DB_USER, DB_PASS) a un archivo `.env` en el servidor remoto (similar al que tenemos para n8n).
2.  **Sanitización**: Implementaremos un filtro global para `$_GET` y `$_POST` para prevenir ataques básicos.

## 🚀 Fase 3: Integración Total con n8n
1.  **API Interna**: Crearemos un pequeño endpoint en PHP que n8n pueda llamar para obtener datos complejos (como reportes financieros) sin tener que hacer consultas SQL crudas desde n8n.
2.  **Webhooks de Eventos**: Cada vez que se guarde una cita, el PHP enviará un "ping" a n8n para que este dispare el mensaje de WhatsApp/Email.

---

## 📋 Siguiente Paso Inmediato
Voy a preparar el archivo de conexión modernizada. ¿Deseas que lo suba al servidor de desarrollo para probar si el sistema sigue encendiendo con el nuevo motor?
