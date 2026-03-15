# Plantilla Excelencia Gaite

Plantilla no oficial para la redacción y formateo de los Proyectos del Bachillerato de Excelencia, diseñada específicamente para el IES Carmen Martín Gaite (Navalcarnero).

![Portada de la plantilla](https://github.com/typst/packages/raw/main/packages/preview/plantilla-excelencia-gaite/0.1.0/thumbnail.png)

Esta plantilla automatiza la creación de la portada, los índices (general, de figuras y de tablas), el formato de página, los márgenes, la numeración de ecuaciones y la bibliografía, permitiendo a los alumnos centrarse exclusivamente en el contenido de su investigación.

## Uso

Para empezar un nuevo proyecto usando esta plantilla, simplemente abre tu terminal y ejecuta el siguiente comando:

```bash
typst init @preview/plantilla-excelencia-gaite mi-proyecto
```

Esto creará una nueva carpeta llamada mi-proyecto con la estructura de archivos necesaria y un archivo main.typ listo para ser editado.

Si usas la Typst Web App, simplemente dale a "Start from template" y busca plantilla-excelencia-gaite.
Compilar el documento

Para generar el PDF final, navega a la carpeta de tu proyecto en la terminal y ejecuta:
Bash

typst compile main.typ

Estructura generada

Al inicializar la plantilla, obtendrás una estructura de carpetas lista para trabajar:

    main.typ: El archivo principal donde configuras los datos de tu proyecto y llamas al resto de capítulos.

    Logo.svg: El logo del instituto para la portada.

    referencias.yaml: Archivo donde guardarás tu bibliografía en formato YAML o BibTeX.

    Archivos/: Una carpeta pre-organizada con los diferentes capítulos (Abstract, Introducción, Capítulo 1, etc.) y una subcarpeta para tus imágenes.

Configuración del Proyecto

En el archivo main.typ, encontrarás la función proyecto que configura todo el documento. Puedes modificar los siguientes parámetros:

    titulo: El título de tu investigación.

    autor: Tu nombre completo.

    supervisor: El nombre de tu tutor/a del proyecto.

    instituto: Por defecto, "IES Carmen Martín Gaite".

    lugar: Por defecto, "Navalcarnero".

    fecha: La fecha de entrega o defensa.

    logo: La ruta a la imagen del logo (por defecto "Logo.svg").

    fuente: La tipografía del documento. Se recomienda "Libertinus Serif" (incluida en Typst) o "Times New Roman" si la tienes instalada localmente.
    
Ejemplo de main.typ

```

#import "@preview/plantilla-excelencia-gaite:0.1.0": *

#show: proyecto.with(
  titulo: "Impacto de la Inteligencia Artificial en la Educación",
  autor: "Nombre del Alumno",
  supervisor: "Nombre del Profesor",
  fecha: "Mayo 2026",
)

#include "Archivos/00_1_Abstract.typ"
#include "Archivos/01_Introducción.typ"
// Añade el resto de tus archivos aquí...

```

Licencia

Este proyecto está distribuido bajo la licencia MIT.
