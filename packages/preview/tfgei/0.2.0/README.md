
# TFGEI
This template is used to make bachelor thesis works for the [degree in Computer Engineering](https://esei.uvigo.es/es/estudos/grao-en-enxenaria-informatica/) at 
Universidade de Vigo ([UVigo](https://www.uvigo.gal/)). 

## Quick start
In order to use it, just import it and apply a `show` rule: 

```typst
#import "@preview/tfgei:0.2.0": tfgei
#show: tfgei.with(
  titulo: "Título do Traballo de Fin de Grado",
  alumno: "D. Nome Alumna/o",
  tutor: "Nome do meu titor",
  area: "Área de coñecemento",
  departamento: "Departamento",
  tfgnum: "Número do TFG",
  fecha: "Data de presentación",
  idioma: "gl",
)
```

## Parameters
The main entrypoint is `tfgei`. These are the supported parameters:

| Name | Type | Notes |
| --- | --- | --- |
| `titulo` | string | Title shown on cover. |
| `alumno` | string | Author name on cover. |
| `tutor` | string | Tutor name on cover. |
| `tfgnum` | string | TFG number. |
| `area` | string | Knowledge area. |
| `departamento` | string | Department. |
| `fecha` | string | Submission date. |
| `resumen` | content | Optional. Set to `none` to hide the resumen page. |
| `pclave` | content | Keywords line under resumen. Ignored if `resumen` is `none`. |
| `agradecimientos` | content | Optional. Set to `none` to hide acknowledgements. |
| `idioma` | string | Labels language: `gl` or `es`. |
| `salto-capitulo` | bool | If `true`, each level-1 heading starts on a new page. If `false`, chapters continue in flow. |
| `indice-contenido` | dictionary | Table of contents configuration. Keys: `enabled` (bool), `profundidad` (int). |
| `indice-figuras` | dictionary | Figure index configuration. Keys: `enabled` (bool), `titulo` (string). |
| `indice-tablas` | dictionary | Table index configuration. Keys: `enabled` (bool), `titulo` (string). |
| `indice-listados` | dictionary | Listings index configuration. Keys: `enabled` (bool), `titulo` (string). |
| `numeracion` | dictionary | Per-level numbering toggle. Keys are level numbers as strings (`"1"`, `"2"`, `"3"`), values are bool. Default: show all. Example: `("3": false)` hides numbering for level 3 headings. |
| `encabezado` | int | Header mode: `0` (default, shows student name + thesis title), `1` (shows current chapter number + name with bottom line), `2` (even pages: chapter number + name with line; odd pages: only chapter name). |

## Optional sections
To hide optional pages:

```typst
#show: tfgei.with(
  resumen: none,
  agradecimientos: none,
)
```