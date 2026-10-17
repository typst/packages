# luisito-u

Plantilla no oficial de Typst para **proyectos de investigación de Bachillerato
presentados a premios de ciencia**: portada con el título grande, los datos del
equipo y la convocatoria al pie; páginas iniciales (abstract, resumen,
agradecimientos), índice, capítulos, anexos numerados, bibliografía y listas de
imágenes y tablas.

Unofficial Typst template for Spanish baccalaureate research projects submitted to
science contests.

![Portada de la plantilla](https://github.com/13Stokes31/luisito-u/raw/v0.1.0/thumbnail.png)

> No es una plantilla oficial de ningún premio ni universidad. Comprueba las bases
> de tu convocatoria (extensión, formato, datos de la portada) antes de entregar.

## Empezar un proyecto

**En typst.app:** «Start from template» y busca `luisito-u`.

**En tu ordenador:**

```bash
typst init @preview/luisito-u mi-proyecto
cd mi-proyecto
typst compile main.typ
```

Se crea esta estructura:

- `main.typ`: los datos del proyecto y la lista de capítulos. Es el único fichero que
  importa la plantilla.
- `Logo.svg`: un logo de muestra. Cámbialo por el que necesites (o borra la línea
  `logo:` del `main.typ`).
- `referencias.yaml`: la bibliografía (también vale un `.bib`).
- `Archivos/`: un fichero por capítulo, la carpeta `Imágenes/` y la carpeta `Datos/` con
  el CSV de las medidas.

Los capítulos traen un **trabajo de ejemplo inventado** («¿Cuánto tarda en enfriarse un
café?») que usa casi todo lo que se puede hacer: citas bibliográficas, notas al pie,
listas, recuadros, ecuaciones numeradas y citadas, tablas, imágenes, gráficas con
`lilaq` leídas de un CSV, anexos y glosario. Cada fichero explica en comentarios
cómo se hace cada cosa. Sustitúyelo por tu trabajo.

## Configuración

Todo se configura en el `#show: proyecto.with(...)` del `main.typ`:

| Parámetro | Qué hace | Por defecto |
|---|---|---|
| `titulo` | Título; en la portada sale en mayúsculas | — |
| `autor` | Autores (en la portada: «Autores: …») | — |
| `supervisor` | Tutor (en la portada: «Tutor: …») | — |
| `instituto` | Centro educativo | — |
| `lugar`, `fecha` | Si se ponen, salen en la portada como «Lugar, fecha» | `none` |
| `logo` | Imagen al pie de la portada, p. ej. `image("Logo.svg", width: 3.5cm)` | `none` |
| `convocatoria` | Texto al pie de la portada, p. ej. `[Proyecto presentado para el \ *Premio …*]` | `none` |
| `fuente` | Tipografía del texto | Libertinus Serif |
| `fuente-portada` | Tipografía de la portada (`none`: la del texto) | `none` |
| `tamano-fuente` | Tamaño del texto; los títulos escalan con él | `12pt` |
| `interlineado` | Interlineado | `0.65em` |
| `color-acento` | Color de los títulos de capítulo | `rgb("#279985")` |
| `abstract`, `resumen`, `agradecimientos` | Páginas iniciales, p. ej. `include "Archivos/00_1_Abstract.typ"` | `none` |
| `bibliografia` | p. ej. `bibliography("referencias.yaml", style: "apa", title: "Bibliografía")` | `none` |
| `lista-figuras`, `lista-tablas` | `auto`: solo si hay figuras/tablas · `true`: siempre · `false`: nunca | `auto` |
| `doble-cara` | Capítulos en página impar y número de página al lado exterior | `false` |
| `contar-palabras` | Muestra tras el índice las palabras del primer capítulo al último anexo | `false` |

Cualquier pieza opcional se quita con `none` o `false`, o borrando su línea.

**Logo.** El de la plantilla es una muestra. Pon el tuyo (en typst.app, súbelo al
proyecto) y cambia el nombre en `logo: image("…")`. Los logos de universidades e
instituciones no se pueden incluir en el paquete sin permiso de sus titulares.

**Fuentes.** Por defecto, Libertinus Serif, que viene con Typst y está siempre,
también en typst.app. El proyecto original usaba Times New Roman en el texto y
Calibri en la portada: para ese aspecto, pon `fuente: "Times New Roman"` y
`fuente-portada: "Calibri"`. Si no las tienes, Typst avisa y usa Libertinus (o sus
clones libres, Liberation Serif y Carlito, si los tienes instalados y los añades:
`fuente: ("Times New Roman", "Liberation Serif")`).

**Contador de palabras.** Cuenta el texto de los capítulos y los anexos, títulos
incluidos. No cuenta la portada, las páginas iniciales, el índice, la bibliografía,
las listas, las figuras, las tablas ni las ecuaciones.

## Anexos

Escribe `#show: anexos` en el `main.typ` justo antes de incluir los anexos. A partir
de ahí:

- el título `= Anexos` sale sin número;
- cada `==` es un anexo numerado: «Anexo I. Título», «Anexo II. Título»…;
- las figuras, tablas y ecuaciones se numeran con el anexo: Figura I.1, Tabla II.3…;
- si pones una etiqueta al anexo (`== Fotografías <anexo-fotos>`), `@anexo-fotos`
  escribe «Anexo II» con enlace.

En los capítulos, las figuras, tablas y ecuaciones se numeran por capítulo (Figura
2.1, ecuación (3.1)…).

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

## Plantilla hermana: visillos-excelencia

[visillos-excelencia](https://github.com/13Stokes31/visillos-excelencia) acepta
exactamente la misma configuración con otra portada (la de los proyectos del
Bachillerato de Excelencia). Un proyecto escrito con una se pasa a la otra
cambiando solo la línea del `#import`.

## Licencia

MIT.
