# tlacuache-thesis-msc-pcm-unam

🇺🇸 [English](./README.en.md)

Esta es una plantilla para tesis de maestría del Posgrado en Ciencias Matemáticas de la Universidad Nacional Autónoma de México (UNAM).

El diseño está basado en el template [tlacuache-thesis-fc-unam](https://github.com/davidalencia/tlacuache-thesis-fc-unam), originalmente desarrollado para la licenciatura en la Facultad de Ciencias. La portada ha sido adaptada para cumplir (de manera aproximada) con los lineamientos del programa de posgrado.

## Uso

~⚠️ Nota: Actualmente este template no se encuentra en el repositorio oficial de paquetes de Typst.~

ILa Plantilla ya se encuentra en Typst Universe, puede usarla importandola desde `@preview` : 
```typst
#import "@preview/tlacuache-thesis-msc-pcm-unam:0.1.1":*
```
o inciando un nuevo archivo con `typst init`:
```bash
typst init @preview/tlacuache-thesis-msc-pcm-unam:0.1.1 mi-tesis
cd mi-tesis
typst watch main.typ
```


## Configuración

Para configurar tu tesis puedes usar estas líneas al inicio de tu archivo principal.

```typ
#import "@preview/tlacuache-thesis-msc-pcm-unam:0.1.1": *

#show: thesis.with(
  titulo: [Título de la tesis],
  autor: (nombre: "Nombre completo", genero: "fem"),
  asesor: (
    nombre: "Nombre completo",
    genero: "masc",
    adscripcion: "Instituto de Matemáticas",
  ),
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: bibliography("references.bib"),
  abstract: include "abstract.typ",
  agradecimientos: include "agradecimientos.typ",
)

// Tu tesis va aquí
```

### Parámetros de la portada

| Parámetro | Descripción | Valor por defecto |
| --------- | ----------- | ----------------- |
| `titulo`  | Título de la tesis | `[Titulo]` |
| `autor`   | Diccionario con `nombre` y `genero` (`"fem"` o `"masc"`). El género determina "MAESTRA EN CIENCIAS" o "MAESTRO EN CIENCIAS". | `(nombre: "Nombre autor", genero: "fem")` |
| `asesor`  | Diccionario con `nombre`, `genero` (`"fem"` o `"masc"`) y `adscripcion`. El género determina "DIRECTORA DE TESIS" o "DIRECTOR DE TESIS". | `(nombre: "Nombre", genero: "fem", adscripcion: "Adscripción")` |
| `lugar`   | Ciudad y país donde se presenta la tesis | `[Ciudad de México, México]` |
| `agno`    | Año de presentación | Año actual |

### Parámetros de contenido

| Parámetro | Descripción | Valor por defecto |
| --------- | ----------- | ----------------- |
| `bibliography` | Referencia al archivo de bibliografía (`bibliography(...)`) | `none` (ninguna) |
| `abstract` | Resumen de la tesis, se coloca antes del índice | `none` (ninguno) |
| `agradecimientos` | Agradecimientos, se colocan antes del índice | `none` (ninguno) |

## Apéndices

Puedes añadir información extra en un apéndice de la siguiente forma:
```typst
#show: appendix
#include "anexo.typ"
```



## Características

- Portada con los datos del autor, asesor y programa.
- Numeración romana en preliminares (agradecimientos, resumen, índice) y árabe en el cuerpo.
- Los capítulos y apéndices comienzan en página impar.
- Encabezados alternados: título del capítulo en páginas pares y de la sección en páginas nones.
- Índice a tres niveles con las entradas de capítulo y apéndice en negritas.
- Bibliografía al final del documento (`bibliography: bibliography("references.bib")`).


## 🫶 Agradecimientos

- [David Valencia Rodríguez](https://github.com/davidalencia) por el desarrollo del template original.

## 🚨 Disclaimer

Este template no es oficial y no está afiliado al Posgrado en Ciencias Matemáticas de la UNAM. Su uso es bajo responsabilidad del usuario.