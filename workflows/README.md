# Workflows de n8n

Este directorio contiene los workflows de n8n para integración con MCP (Model Context Protocol).

## Estructura

Los workflows se organizan por categoría:

- **mcp/**: Workflows relacionados con MCP
- **automation/**: Workflows de automatización general
- **integrations/**: Workflows de integración con servicios externos

## Formato

Los workflows se guardan en formato JSON, exportados desde n8n.

## Cómo usar

1. Importar workflows en n8n desde la interfaz web
2. Activar los workflows necesarios
3. Configurar las credenciales requeridas

## Exportar workflows

Para exportar workflows desde n8n:
1. Ir a Workflows en n8n
2. Seleccionar un workflow
3. Click en "..." y seleccionar "Download"
4. Guardar el archivo en este directorio

## Importar workflows

Para importar workflows a n8n:
1. Ir a Workflows en n8n
2. Click en "Import from File"
3. Seleccionar el archivo JSON del workflow
