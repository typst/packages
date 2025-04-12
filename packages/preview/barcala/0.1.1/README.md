# barcala

![](https://img.shields.io/badge/Typst-0.13.1-blue?style=flat-square&logo=typst&logoColor=white&labelColor=239DAD&color=555555)


A report template for UNLP students, specially for engineering. Not affiliated with the university.

---

Plantilla de informe para estudiantes de la Universidad Nacional de La Plata, especialmente para ingeniería. No está afiliada a la universidad.

![Documento de ejemplo](./thumbnail.png)

## Uso

```typst
#import "@preview/barcala:0.1.1": informe

#show: informe.with(
  // parámetros del informe
)
```

- `institución`: el logo de la institución del informe.
  - `"unlp"`: Universidad Nacional de La Plata (por defecto)
  - Si se desea usar un logo diferente, basta con escribir la ruta la logo
- `unidad-academica`: el logo de la unidad académica del informe.
  - `"informática"`: Facultad de Informática
  - `"ingeniería"`: Facultad de Ingeniería
  - Si se desea usar un logo diferente, basta con escribir la ruta la logo
  - Si la unidad académica de la UNLP no está en la lista, [creá un reporte](https://github.com/JuanM04/barcala/issues/new) con el link al logo y lo agregamos a la plantilla.
- `asignatura`: el nombre de la asignatura (`str`).
- `titulo` (`content`): el título más formal del informe, como `[Trabajo Práctico Nº 3]`.
- `equipo` (`content`): el nombre del equipo, como `[Grupo 12]`.
- `autores` (`array`): los autores y autoras del proyecto. Cada autor/a tiene
  - `nombre` (`str`): el nombre del autor/a con el formato `Apellido, Nombre`; 
  - `email` (`str`, opcional): un email;
  - `legajo` (`str`, opcional): un legajo;
  - `notas` (`array` o `str`, opcional): otras notas, como `"Autor responsable del informe"`.
- `titulo-descriptivo` (`str`): el título del proyecto en sí, como `"Análisis de un sistema fluvial"`.
- `resumen` (`content`, opcional): un resumen del lo que trata el informe o el objetivo del proyecto. Es un campo libre para escribir con el formato que se desee.
- `fecha` (`date` o `str`): la fecha de entrega del informe, se puede escribir como `"2023-10-01"` (1 de octubre de 2023).
- `formato` (`dict`, opcional): otras configuraciones del informe:
  - `tipografia` (`str`, opcional): la tipografía del informe, _New Computer Modern_ por defecto;
  - `columnas` (`int`, opcional): la cantidad de columnas, una por defecto;
  - `margenes` (opcional): pueden ser
    - `"simétricos"`: los mismo márgenes de cada lado (por defecto),
    - `"anillado"`: márgenes más anchos donde iría el anillado.


### Apéndices

Para agregar apéndices al informe, se puede usar el comando `apendice` en el lugar empiezan los apéndices. Por ejemplo:

```typst
#import "@preview/barcala:0.1.1": informe, apendice

#show: informe.with(
  // parámetros del informe
)

// ... contenido del informe

#show: apendice

= Tablas de datos // Apéndice A
// ...

= Otra información // Apéndice B
// ...
```

### Tabla de símbolos

Para agregar una tabla de símbolos/nomenclatura al informe, se puede usar el comando `nomenclatura` en el lugar donde empieza la tabla. Por ejemplo:

```typst
#import "@preview/barcala:0.1.1": informe, nomenclatura

#show: informe.with(
  // parámetros del informe
)

#nomenclatura(
  ($S_1$, [Símbolo 1]),
  ($S_2$, [Símbolo 2]),
  ($S_3$, [Símbolo 3]),
)
```

## Desarrollo

Para generar el documento `main.pdf` y la imagen `thumbnail.png` de la portada, se debe cambiar

```diff
-  #import "@preview/barcala:0.1.1": ...
+  #import "../src/lib.typ": ...
```

y utilizar los siguientes comandos:

```bash
# Genera PDF
typst compile --root . --pdf-standard a-2b template/main.typ
# Genera thumbnail.png
typst compile --root . --format png --pages 1,2 template/main.typ "thumbnail-{p}.png"
magick montage "thumbnail-[1-2].png" -tile 2x1 -geometry +0+0 thumbnail.png
rm thumbnail-1.png && rm thumbnail-2.png
```