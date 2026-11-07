# Plantilla para documentos de grado de la UPSA

Plantilla para documentos de grado de la Universidad Privada de Santa Cruz de la Sierra (UPSA), Bolivia.

## Uso de la plantilla

El documento principal de la plantilla es `thesis.typ`. Este documento funciona como un **Starter Kit** que a la vez sirve de ejemplo de como usar la plantilla.

## Recomendaciones de uso

Hay dos maneras de usar la plantilla: mediante *GitHub Templates & Releases*, y *Typst Universe*

### Typst Universe

Usar la plantilla desde Typst Universe permite usarla sin tener que descargar o administrar la libraría de la plantilla, uno puede usarla directamente desde la Web de Typst o desde la termianl con el comando `typst init @preview/upsa-thesis`.

Es la manera más sencilla (con Typst Web App) y recomendable de usar la plantilla.

### GitHub Templates & Releases

Usar la plantilla mediante GitHub te permite descargar la plantilla junto al código fuente de la plantilla misma, es un más complejo que el método anterior, pero permite modificar la plantilla y adaptarla a tus necesidades.

Además de que ya viene con *Task* para compilar fácilmente todos los documentos.

Al usarla totalmente desde GitHub y localmente, necesitarás instalar Typst, Task, Git y un editor de texto como Visual Studio Code. En este caso, este repositorio es un *GitHub Template*, por lo que podés crear un repositorio nuevo basado en este, y luego clonar tu repositorio para trabajar localmente. Ya viene configurado con Task y extensiones de VS Code para Typst, por lo que no tendrás que configurar mucho.

## Tipografía

*Alegreya* es el conjunto predeterminado, con *Alegreya Sans* para títulos, *TeX Gyre Pagella Math* para fórmulas e *IBM Plex Mono* para código.

### Conjuntos de tipografía

Los tipos de letra usados en la plantilla son los siguientes:

- [GUST's TeX Gyre Collection of Fonts](https://www.gust.org.pl/projects/e-foundry/tex-gyre)
  - TeX Gyre *Termes*, como alternativa a Times New Roman
  - TeX Gyre *Heros*, como alternativa a Helvetica y Arial.
- [IBM Plex](https://www.ibm.com/plex/)
- PampaType: [Reforma](https://pampatype.com/reforma/)
- [New Computer Modern](https://www.ctan.org/pkg/newcomputermodern)
- Adobe Source: [Sans](https://github.com/adobe-fonts/source-sans), [Serif](https://github.com/adobe-fonts/source-serif) & [Code Pro](https://github.com/adobe-fonts/source-code-pro)
- HT Fonts:
  - [Alegreya](https://htfonts.com/en/fonts/alegreya/) & [Alegreya Sans](https://htfonts.com/en/fonts/alegreya-sans/)
  - [Andada](https://htfonts.com/en/fonts/andada/)
  - [Piazzolla](https://htfonts.com/en/fonts/piazzolla/)

Las fuentes mencionadas pueden ser instaladas tanto de sus repositorios oficiales bajo ningun costo así como desde [Google Fonts](https://fonts.google.com/). La mayoría de las fuentes están licenciadas bajo SIL Open Font License (OFL) y pueden ser usadas tranquilamente en proyectos académicos.

Adicionalmente, la plantilla permite usar las siguientes fuentes proprietarias que vienen preinstaladas en la mayoría de sistemas operativos:

- Times New Roman
- Arial
- Helvetica
- Helvetica Neue

#### Fuentes suplementarias

Para mantener la consistencia visual con los conjuntos predeterminados, algunas fuentes no cuentan con variantes para fórmulas o código. En esos casos, la plantilla ya selecciona fuentes complementarias para mantener la coherencia tipográfica. Para revisar la lista completa de fuentes con sus variantes, consultá el archivo de [Typefaces](lib/typeface.typ).

### Como instalar y usar fuentes

Hay 2 maneras de usar fuentes en Typst: instalarlas o referenciarlas dentro del proyecto. Se recomienda copiar las fuentes en la carpeta `assets/fonts` y referenciarlas en Typst, por ejemplo:

```sh
typst compile --font-path assets/fonts thesis.typ
```

Esto permite que el proyecto sea portable.

## Bibliografía y exportación

La bibliografía usa APA de forma predeterminada. Podés seleccionar otro estilo en `bibliography`. El módulo `csl-styles` expone los estilos APA y ASCE incluidos.

La plantilla ofrece funciones para componer cubiertas, lomos y resúmenes BIME, y para generar registros bibliográficos en BibLaTeX y Hayagriva. El Starter Kit muestra cómo reunir estas funciones en una exportación local mediante Bundle.

La plantilla utiliza encabezados, figuras y tablas semánticos para conservar la estructura del documento al exportar. Las descripciones alternativas y el orden lógico del contenido dependen de la autoría. Consultá la [guía de accesibilidad de Typst](https://typst.app/docs/guides/accessibility/).

## Documentación de Typst en español

Como recurso complementario, se encuentra disponible la [documentación de Typst en español](https://jassielof.github.io/typst/) tanto en version Web como en formato PDF.

## Dudas y problemas

Para dudas y problemas, usá [GitHub Issues](https://github.com/FAI-UPSA/thesis-template/issues) para reportar errores y [GitHub Discussions](https://github.com/FAI-UPSA/thesis-template/discussions) para consultas generales.

## Licencia

La plantilla se distribuye bajo la [licencia Apache 2.0](LICENSE.txt).

Esta licencia aplica solamente a la librería y código de la plantilla. El contenido generado por los tesistas con la plantilla es propiedad de los autores y no está sujeto a esta licencia. De igual forma, tampoco aplica al logo de la UPSA ni a los elementos de identidad visual de la universidad, que son propiedad de la institución y están sujetos a sus propias licencias.
