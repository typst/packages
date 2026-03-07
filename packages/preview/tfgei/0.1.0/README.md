
# TFGEI
This template is used to make bachelor thesis works for the [degree in Computer Engineering](https://esei.uvigo.es/es/estudos/grao-en-enxenaria-informatica/) at 
Universidade de Vigo ([UVigo](https://www.uvigo.gal/)). 

## Quick start
In order to use it, just import it and apply a `show` rule: 

```typst
#import "@local/tfgei:0.1.0": tfgei
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

## Optional sections
To hide optional pages:

```typst
#show: tfgei.with(
  resumen: none,
  agradecimientos: none,
)
```