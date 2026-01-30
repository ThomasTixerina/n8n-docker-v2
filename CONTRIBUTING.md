# Guía de Contribución

¡Gracias por tu interés en contribuir a n8n-docker-v2! Esta guía te ayudará a entender cómo puedes colaborar con este proyecto.

## 🤝 Formas de Contribuir

Hay muchas formas de contribuir a este proyecto:

1. **Reportar bugs**: Si encuentras un error, abre un issue
2. **Sugerir mejoras**: Ideas para nuevas funcionalidades o mejoras
3. **Mejorar documentación**: Corregir typos, añadir ejemplos, mejorar claridad
4. **Añadir features**: Nuevos scripts, mejoras en configuración
5. **Compartir experiencias**: Comparte casos de uso interesantes

## 🐛 Reportar Bugs

Si encuentras un bug, por favor abre un issue con:

### Plantilla de Bug Report

```markdown
## Descripción del Bug
[Descripción clara del problema]

## Pasos para Reproducir
1. [Primer paso]
2. [Segundo paso]
3. [...]

## Comportamiento Esperado
[Qué esperabas que sucediera]

## Comportamiento Actual
[Qué sucedió en realidad]

## Información del Sistema
- OS: [ej. Ubuntu 22.04]
- Docker version: [ej. 24.0.5]
- Docker Compose version: [ej. 2.20.2]

## Logs Relevantes
```
[Pega aquí los logs relevantes, sin información sensible]
```

## Capturas de Pantalla
[Si es aplicable]
```

## 💡 Sugerir Mejoras

Para sugerir una mejora, abre un issue con:

### Plantilla de Feature Request

```markdown
## Descripción de la Mejora
[Descripción clara de lo que propones]

## Motivación
[¿Por qué es útil esta mejora?]

## Solución Propuesta
[Cómo implementarías esto]

## Alternativas Consideradas
[Otras opciones que pensaste]

## Información Adicional
[Cualquier contexto adicional]
```

## 🔧 Contribuir con Código

### Preparación del Entorno

1. **Fork el repositorio**
   ```bash
   # Haz click en "Fork" en GitHub
   ```

2. **Clona tu fork**
   ```bash
   git clone https://github.com/TU-USUARIO/n8n-docker-v2.git
   cd n8n-docker-v2
   ```

3. **Añade el repositorio original como upstream**
   ```bash
   git remote add upstream https://github.com/ThomasTixerina/n8n-docker-v2.git
   ```

4. **Crea una rama para tu feature**
   ```bash
   git checkout -b feature/nombre-de-tu-feature
   ```

### Desarrollo

1. **Haz tus cambios**
   - Sigue las convenciones de código existentes
   - Añade comentarios donde sea necesario
   - Actualiza la documentación si es necesario

2. **Prueba tus cambios**
   ```bash
   # Prueba que los scripts funcionen
   ./health_check.sh
   
   # Prueba el docker-compose
   docker-compose config
   docker-compose up -d
   ```

3. **Commit tus cambios**
   ```bash
   git add .
   git commit -m "feat: descripción concisa del cambio"
   ```

### Convenciones de Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Cambios de formato (no afectan el código)
- `refactor:` Refactorización de código
- `test:` Añadir o modificar tests
- `chore:` Tareas de mantenimiento

Ejemplos:
```bash
git commit -m "feat: añadir script de monitoreo de recursos"
git commit -m "fix: corregir error en backup.sh con rutas especiales"
git commit -m "docs: actualizar guía de instalación con nuevos requisitos"
```

### Pull Request

1. **Push a tu fork**
   ```bash
   git push origin feature/nombre-de-tu-feature
   ```

2. **Abre un Pull Request**
   - Ve a tu fork en GitHub
   - Click en "Pull Request"
   - Selecciona tu rama
   - Completa la descripción

### Plantilla de Pull Request

```markdown
## Descripción
[Descripción clara de los cambios]

## Tipo de Cambio
- [ ] Bug fix (cambio que corrige un issue)
- [ ] Nueva feature (cambio que añade funcionalidad)
- [ ] Breaking change (cambio que podría romper funcionalidad existente)
- [ ] Documentación
- [ ] Otro (especificar)

## ¿Cómo se ha probado?
[Describe las pruebas realizadas]

## Checklist
- [ ] He probado mi código localmente
- [ ] He actualizado la documentación
- [ ] Mis cambios no generan nuevos warnings
- [ ] He añadido comentarios donde es necesario
- [ ] He seguido las convenciones de código del proyecto
```

## 📖 Mejorar Documentación

La documentación es crucial. Puedes mejorarla:

1. **Corregir errores**: Typos, enlaces rotos, información desactualizada
2. **Añadir ejemplos**: Casos de uso, configuraciones específicas
3. **Mejorar claridad**: Reescribir secciones confusas
4. **Traducir**: Si hablas otros idiomas, puedes ayudar con traducciones
5. **Añadir capturas**: Screenshots que ayuden a entender mejor

Para cambios en documentación:
```bash
git checkout -b docs/descripcion-del-cambio
# Hacer cambios
git commit -m "docs: descripción del cambio"
git push origin docs/descripcion-del-cambio
# Abrir PR
```

## 🎨 Guía de Estilo

### Scripts de Bash

- Usar `#!/bin/bash` al inicio
- Usar `set -e` para detener en errores
- Añadir comentarios descriptivos
- Usar nombres de variables descriptivos en MAYÚSCULAS para constantes
- Añadir mensajes de output coloreados para mejor UX
- Validar inputs y mostrar mensajes de error claros

Ejemplo:
```bash
#!/bin/bash
set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Validar argumentos
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Falta argumento${NC}"
    exit 1
fi

echo -e "${GREEN}Operación exitosa${NC}"
```

### Docker Compose

- Usar version 3.8 o superior
- Añadir health checks cuando sea posible
- Usar networks para aislar servicios
- Usar volumes nombrados
- Añadir comentarios explicativos
- Mantener consistencia en naming

### Documentación (Markdown)

- Usar títulos jerárquicos (h1, h2, h3)
- Incluir tabla de contenidos en documentos largos
- Usar bloques de código con syntax highlighting
- Añadir emojis para mejorar legibilidad (moderadamente)
- Incluir ejemplos prácticos
- Usar admonitions (⚠️, ✅, ℹ️) para destacar información importante

## 🧪 Testing

Antes de enviar tu PR:

1. **Prueba localmente**
   ```bash
   # Limpia entorno anterior
   docker-compose down -v
   
   # Prueba instalación desde cero
   cp .env.example .env
   # Configura .env con valores de prueba
   docker-compose up -d
   ./health_check.sh
   ```

2. **Verifica scripts**
   ```bash
   # Prueba todos los scripts
   ./health_check.sh
   ./backup.sh
   # (No pruebes restore.sh a menos que tengas un backup)
   ```

3. **Valida configuración**
   ```bash
   docker-compose config
   ```

## ❓ Preguntas

Si tienes preguntas sobre cómo contribuir:

1. Revisa primero la documentación existente
2. Busca en issues existentes por preguntas similares
3. Abre un issue con la etiqueta "question"
4. O contacta a los mantenedores

## 🙏 Agradecimientos

Toda contribución, grande o pequeña, es valiosa y apreciada. ¡Gracias por ayudar a mejorar este proyecto!

## 📜 Código de Conducta

### Nuestro Compromiso

Este proyecto se compromete a proporcionar una experiencia libre de acoso para todos, independientemente de:
- Edad
- Tamaño corporal
- Discapacidad
- Etnia
- Identidad y expresión de género
- Nivel de experiencia
- Nacionalidad
- Apariencia personal
- Raza
- Religión
- Identidad u orientación sexual

### Comportamiento Esperado

- Usar lenguaje acogedor e inclusivo
- Respetar puntos de vista y experiencias diferentes
- Aceptar críticas constructivas con gracia
- Enfocarse en lo mejor para la comunidad
- Mostrar empatía hacia otros miembros

### Comportamiento Inaceptable

- Uso de lenguaje o imágenes sexualizadas
- Trolling, comentarios insultantes/despectivos
- Acoso público o privado
- Publicar información privada de otros sin permiso
- Otra conducta que podría considerarse inapropiada en un entorno profesional

### Aplicación

Los mantenedores del proyecto tienen el derecho y la responsabilidad de eliminar, editar o rechazar comentarios, commits, código, ediciones de wiki, issues y otras contribuciones que no estén alineadas con este Código de Conducta.

---

¡Gracias por leer y por tus contribuciones! 🎉
