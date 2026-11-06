# Visillos Excelencia

An unofficial Typst template for Excellence Baccalaureate research projects at IES Carmen Martín Gaite (Spain).

Plantilla no oficial para la redacción y formateo de los Proyectos del Bachillerato de Excelencia, diseñada específicamente para el IES Carmen Martín Gaite (Navalcarnero).

![Portada de la plantilla](https://github.com/typst/packages/raw/main/packages/preview/visillos-excelencia/0.2.0/thumbnail.png)

Esta plantilla automatiza la creación de la portada, los índices (general, de figuras y de tablas), el formato de página, los márgenes, la numeración de ecuaciones y la bibliografía, permitiendo a los alumnos centrarse exclusivamente en el contenido de su investigación.

## Uso

Para empezar un nuevo proyecto usando esta plantilla, simplemente abre tu terminal y ejecuta el siguiente comando:

```bash
typst init @preview/visillos-excelencia mi-proyecto
```

Esto creará una nueva carpeta llamada `mi-proyecto` con la estructura de archivos necesaria y un archivo `main.typ` listo para ser editado.

Si usas la Typst Web App, simplemente dale a "Start from template" y busca `visillos-excelencia`.

## Compilar el documento

Para generar el PDF final, navega a la carpeta de tu proyecto en la terminal y ejecuta:

```bash
typst compile main.typ
```

## Estructura generada

Al inicializar la plantilla, obtendrás una estructura de carpetas lista para trabajar:

- `main.typ`: El archivo principal donde configuras los datos de tu proyecto y llamas al resto de capítulos.
- `Logo.svg`: El logo del instituto para la portada.
- `referencias.yaml`: Archivo donde guardarás tu bibliografía en formato YAML o BibTeX.
- `Archivos/`: Una carpeta pre-organizada con los diferentes capítulos (Abstract, Introducción, Capítulo 1, etc.) y una subcarpeta para tus imágenes.

## Configuración del proyecto

En el archivo `main.typ`, encontrarás la función `proyecto` que configura todo el documento. Puedes modificar los siguientes parámetros:

- `titulo`: El título de tu investigación.
- `autor`: Tu nombre completo.
- `supervisor`: El nombre de tu tutor/a del proyecto.
- `instituto`: Por defecto, "IES Carmen Martín Gaite".
- `lugar`: Por defecto, "Navalcarnero".
- `fecha`: La fecha de entrega o defensa.
- `logo`: La imagen del logo para la portada (por defecto `image("Logo.svg", width: 30%)`).
- `fuente`: La tipografía del documento. Se recomienda "Libertinus Serif" (incluida en Typst) o "Times New Roman" si la tienes instalada localmente.
- `tamano-fuente`: Tamaño del texto (por defecto `12pt`). Los títulos escalan con él.
- `interlineado`: Interlineado del texto (por defecto `1em`).
- `color-acento`: Color de los títulos de capítulo (por defecto `rgb("#279985")`).
- `abstract`, `resumen`, `agradecimientos`: Las páginas iniciales. La plantilla les pone título, página propia, numeración romana y entrada en el índice.
- `bibliografia`: La bibliografía, p. ej. `bibliography("referencias.yaml", style: "apa", title: "Bibliografía")`. Va al final del documento.
- `lista-figuras`, `lista-tablas`: Las listas van al final, después de la bibliografía. Por defecto (`auto`) cada una aparece solo si el documento tiene figuras/tablas; con `true` aparece siempre y con `false` nunca.

Cualquier pieza opcional (abstract, resumen, agradecimientos, bibliografía y listas) se quita igual: con `false` o `none`.
- `doble-cara`: Por defecto `false`. Ponlo a `true` si vas a imprimir a doble cara: cada capítulo abrirá en página impar (insertando páginas en blanco donde haga falta) y los números de página irán en el lado exterior.

Además, la plantilla numera figuras, tablas y ecuaciones **por capítulo** (Figura 2.1, ecuación (3.1)…), rellena el título y el autor en las propiedades del PDF, y muestra el capítulo actual en la cabecera de cada página.

## Ejemplo de main.typ

```typst
#import "@preview/visillos-excelencia:0.2.0": *

#show: proyecto.with(
  titulo: "Impacto de la Inteligencia Artificial en la Educación",
  autor: "Nombre del Alumno",
  supervisor: "Nombre del Profesor",
  fecha: "Mayo 2026",
  abstract: include "Archivos/00_1_Abstract.typ",
  resumen: include "Archivos/00_2_Resumen.typ",
  agradecimientos: include "Archivos/00_3_Agradecimientos.typ",
  bibliografia: bibliography("referencias.yaml", style: "apa", title: "Bibliografía"),
)

#include "Archivos/01_Introducción.typ"
// Añade el resto de tus archivos aquí...
```

## Licencia

Este proyecto está distribuido bajo la licencia MIT.
