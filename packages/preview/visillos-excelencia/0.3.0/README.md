# Visillos Excelencia

An unofficial Typst template for Excellence Baccalaureate research projects at IES Carmen Martín Gaite (Spain).

Plantilla no oficial para la redacción y formateo de los Proyectos del Bachillerato de Excelencia, diseñada específicamente para el IES Carmen Martín Gaite (Navalcarnero).

![Portada de la plantilla](https://github.com/13Stokes31/visillos-excelencia/raw/v0.3.0/thumbnail.png)

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
- `Archivos/`: Una carpeta pre-organizada con los diferentes capítulos (Abstract, Introducción, Capítulo 1, etc.) una subcarpeta para tus imágenes y otra, `Datos/`, con el CSV de las medidas.

Los capítulos traen un **trabajo de ejemplo inventado** («¿Cuánto tarda en enfriarse un café?») que usa casi todo lo que se puede hacer: citas bibliográficas, notas al pie, listas, recuadros, ecuaciones numeradas y citadas, tablas, imágenes, gráficas con `lilaq` leídas de un CSV, anexos y glosario. Cada fichero explica en comentarios cómo se hace cada cosa. Sustitúyelo por tu trabajo.

Los capítulos **no necesitan importar la plantilla**: basta con el `#import` del `main.typ`. Así, para pasar el proyecto a otra versión (o a otra plantilla con la misma configuración) solo se cambia esa línea. Si en un capítulo quieres usar una función del paquete, como `insertar-imagen`, impórtala en ese capítulo.

## Configuración del proyecto

En el archivo `main.typ`, encontrarás la función `proyecto` que configura todo el documento. Puedes modificar los siguientes parámetros:

- `titulo`: El título de tu investigación.
- `autor`: Tu nombre completo.
- `supervisor`: El nombre de tu tutor/a del proyecto.
- `instituto`: Por defecto, "IES Carmen Martín Gaite".
- `lugar`: Por defecto, "Navalcarnero".
- `fecha`: La fecha de entrega o defensa.
- `logo`: La imagen del logo para la portada (por defecto `image("Logo.svg", width: 30%)`).
- `convocatoria`: Texto opcional al pie de la portada, por ejemplo el premio al que se presenta el proyecto.
- `fuente`: La tipografía del documento. Se recomienda "Libertinus Serif" (incluida en Typst) o "Times New Roman" si la tienes instalada localmente.
- `fuente-portada`: Tipografía solo para la portada (por defecto, la misma que `fuente`).
- `tamano-fuente`: Tamaño del texto (por defecto `12pt`). Los títulos escalan con él.
- `interlineado`: Interlineado del texto (por defecto `1em`).
- `color-acento`: Color de los títulos de capítulo (por defecto `rgb("#279985")`).
- `abstract`, `resumen`, `agradecimientos`: Las páginas iniciales. La plantilla les pone título, página propia, numeración romana y entrada en el índice.
- `bibliografia`: La bibliografía, p. ej. `bibliography("referencias.yaml", style: "apa", title: "Bibliografía")`. Va al final del documento.
- `lista-figuras`, `lista-tablas`: Las listas van al final, después de la bibliografía. Por defecto (`auto`) cada una aparece solo si el documento tiene figuras/tablas; con `true` aparece siempre y con `false` nunca.

Cualquier pieza opcional (abstract, resumen, agradecimientos, bibliografía y listas) se quita igual: con `false` o `none`.
- `doble-cara`: Por defecto `false`. Ponlo a `true` si vas a imprimir a doble cara: cada capítulo abrirá en página impar (insertando páginas en blanco donde haga falta) y los números de página irán en el lado exterior.
- `contar-palabras`: Por defecto `false`. Con `true`, debajo del índice aparece la extensión del trabajo: las palabras desde el primer capítulo hasta el final de los anexos. No cuenta portada, páginas iniciales, índice, bibliografía, listas, figuras, tablas ni ecuaciones.

## Anexos

Escribe `#show: anexos` en el `main.typ` justo antes de incluir los anexos. A partir de ahí:

- el título `= Anexos` sale sin número;
- cada `==` es un anexo numerado: «Anexo I. Título», «Anexo II. Título»…;
- las figuras, tablas y ecuaciones se numeran con el anexo: Figura I.1, Tabla II.3…;
- si pones una etiqueta al anexo (`== Fotografías <anexo-fotos>`), `@anexo-fotos` escribe «Anexo II» con enlace.

Además, la plantilla numera figuras, tablas y ecuaciones **por capítulo** (Figura 2.1, ecuación (3.1)…), rellena el título y el autor en las propiedades del PDF, y muestra el capítulo actual en la cabecera de cada página.

## Figuras: borde y nota

La plantilla trae en `Archivos/funciones.typ` una función `figura` para poner
borde y nota con un argumento. Se importa al principio del capítulo que la use:

```typst
#import "funciones.typ": figura

#figura(
  "Imágenes/foto.png",          // ruta desde la carpeta Archivos
  titulo: [Título de la figura],
  ancho: 80%,                   // opcional
  borde: true,                  // opcional: true (borde negro) o false
  nota: [Elaboración propia.],  // opcional: «Nota. Elaboración propia.», estilo APA
) <fig-foto>
```

En lugar de la ruta puede ir una tabla o una gráfica: `#figura(table(…), titulo: […], nota: […])`.
La nota sale debajo, en letra pequeña y con «*Nota.*» delante, y admite citas
(`@etiqueta`). El `#figure` normal de Typst sigue funcionando igual.

`funciones.typ` no depende de la plantilla: el cambio de una plantilla a otra sigue
siendo solo la línea del `#import` del `main.typ`.

## Ejemplo de main.typ

```typst
#import "@preview/visillos-excelencia:0.3.0": *

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
// Añade el resto de tus capítulos aquí...

#show: anexos
#include "Archivos/04_Anexos.typ"
```

## Plantilla hermana: luisito-u

[luisito-u](https://github.com/13Stokes31/luisito-u) acepta exactamente la misma configuración con otra portada (la de los premios de ciencia para Bachillerato). Un proyecto escrito con una se pasa a la otra cambiando solo la línea del `#import`.

## Licencia

Este proyecto está distribuido bajo la licencia MIT.
