# Plantilla para documentos de grado de la UPSA

Plantilla para trabajos de grado de la Universidad Privada de Santa Cruz de la Sierra (UPSA), Bolivia. El repositorio incluye el código de formato y un **Starter Kit** con documentos editables y ejemplos de citas, tablas, figuras y estructura académica. Adaptá el contenido a tu disciplina.

## Qué incluye

- Formato para páginas preliminares, capítulos, índices y bibliografía.
- Documentos necesarios para la entrega de tesis, BIME, propuesta, y currículum.
- Entrega BIME con tesis, carátula, lomo, resumen y referencias bibliográficas.
- En el repositorio de GitHub:
  - Tareas de generación y actualización automática, fuentes y opciones de exportación configuradas.
  - Ajustes y extensiones recomendadas para VS Code.
  - Ejemplo de un «Estudio de factibilidad»

## Preparar tu documento

La plantilla inicializa los documentos necesarios para tu trabajo. Seguí las indicaciones dentro de cada documento para completar tus datos y reemplazar el contenido de demostración.

### Fuentes y exportación

La distribución de Universe no incluye fuentes. Descargá las familias indicadas en [Tipografía](#tipografía) si no están disponibles en tu entorno. En la aplicación web, subí los archivos `.otf` o `.ttf` al proyecto. En tu equipo, instalalos o indicá su ubicación al compilar.

La combinación usada en los documentos de ejemplo necesita Reforma 1918, Reforma 2018, TeX Gyre Pagella Math e IBM Plex Mono. El currículum usa además Source Sans 3 y Source Serif 4. Las advertencias de fuente desconocida indican sustituciones que pueden cambiar el diseño. Elegir otro conjunto con `typeface` también requiere disponer de sus fuentes.

Consultá el archivo `Taskfile.yaml` en la raíz del repositorio para ver los comandos de compilación y sus opciones. Si trabajás desde Universe, adaptá las rutas a tu proyecto y a la ubicación de tus fuentes.

La entrega BIME reúne la tesis, las cubiertas, el resumen y las referencias bibliográficas del trabajo. Usa Bundle, una función experimental de Typst cuya interfaz puede cambiar. Revisá los metadatos y las indicaciones del documento de entrega antes de generarla.

## Empezar desde el repositorio de GitHub

Necesitás [Typst](https://typst.app/) y [Task](https://taskfile.dev/). Si usás [Visual Studio Code](https://code.visualstudio.com/), el repositorio incluye su configuración. Consultá las páginas oficiales para instalar estas herramientas.

Creá tu copia con **Use this template** y abrí la raíz del repositorio. Empezá por [documents/thesis.typ](documents/thesis.typ): cambiá los datos de `settings.with(...)` y reemplazá el contenido de demostración por tu trabajo.

Los ejemplos contienen datos ficticios y texto de relleno que debés sustituir antes de entregar.

## Generar documentos desde el repositorio

Elegí la tarea correspondiente en el archivo `Taskfile.yaml` de la raíz del repositorio: allí se describen los documentos, los modos de generación y las opciones de exportación. Ejecutá las tareas desde la raíz del repositorio. En VS Code también podés ejecutarlas desde la vista de la extensión **Task**, incluida entre las recomendaciones del proyecto.

Los archivos generados quedan junto a los documentos fuente y no se incluyen en Git.

## Aprendé con los ejemplos

Los documentos inicializados incluyen ejemplos y comentarios junto a los datos, las páginas preliminares y la bibliografía. Seguí esas indicaciones para adaptar tu trabajo y preparar la entrega BIME.

## Personalizar la plantilla

### Tipografía

El formato usa Alegreya por defecto. Los documentos de ejemplo seleccionan Reforma explícitamente; la página de agradecimientos incluye su crédito tipográfico en el pie al usarla.

Los documentos de ejemplo combinan [Reforma 1918 y Reforma 2018](https://pampatype.com/reforma/), de PampaType, [TeX Gyre Pagella Math](https://www.gust.org.pl/projects/e-foundry/tex-gyre) e [IBM Plex Mono](https://www.ibm.com/plex/). También podés elegir entre:

- [TeX Gyre Termes y Heros](https://www.gust.org.pl/projects/e-foundry/tex-gyre), alternativas a Times New Roman y Arial/Helvetica.
- [Alegreya](https://htfonts.com/en/fonts/alegreya/) y [Alegreya Sans](https://htfonts.com/en/fonts/alegreya-sans/).
- Adobe Source: [Sans](https://github.com/adobe-fonts/source-sans), [Serif](https://github.com/adobe-fonts/source-serif) y [Code Pro](https://github.com/adobe-fonts/source-code-pro).
- [Piazzolla](https://htfonts.com/en/fonts/piazzolla/) y [Andada](https://htfonts.com/en/fonts/andada/).
- [New Computer Modern](https://www.ctan.org/pkg/newcomputermodern).
- Arial, Helvetica, Helvetica Neue y Times New Roman, si están instaladas en tu sistema.

El ejemplo de currículum usa además Source Sans 3 y Source Serif 4; si no están instaladas, su paquete puede mostrar advertencias de sustitución. Las combinaciones disponibles están en [lib/typeface.typ](lib/typeface.typ). En `typeface-options`, `text` es obligatorio; `display` es opcional y usa `text` como valor predeterminado. `math` y `mono` también son opcionales y solo personalizan fórmulas y código cuando se proporcionan. Los roles opcionales `title-page` (texto complementario) y `title-page-title` (título del trabajo) se configuran en el mismo diccionario y también usan `text` como valor predeterminado.

### Bibliografía

Se configura en cada documento. La plantilla incluye estilos APA y ASCE, además de funciones para generar referencias de tu trabajo en BibLaTeX y Hayagriva.

El parámetro `supervisor` acepta un nombre único, que se muestra con el rol predeterminado «Guía», o una lista plana de pares rol y nombre. Por ejemplo, el Starter Kit muestra cómo añadir director, asesora y coasesor. Los pares aparecen en una tabla sin bordes en la portada y en la tabla del abstracto.

## Recursos y consultas

- [Documentación de Typst en español](https://jassielof.github.io/typst/).
- [Accesibilidad de la plantilla](ACCESSIBILITY.md).
- [Historial de cambios](CHANGELOG.md).
- [Issues](https://github.com/FAI-UPSA/thesis-template/issues) para errores y [Discussions](https://github.com/FAI-UPSA/thesis-template/discussions) para consultas.

## Licencia

El código de la plantilla se distribuye bajo [Apache 2.0](LICENSE.txt). El contenido de los trabajos pertenece a sus autores. El logo y los elementos de identidad visual de la UPSA pertenecen a la institución y están sujetos a sus propias licencias.
