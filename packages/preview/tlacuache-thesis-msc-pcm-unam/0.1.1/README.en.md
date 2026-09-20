# tlacuache-thesis-msc-pcm-unam

🇲🇽 [Español](README.md)

This is a thesis template for the Master's Program in Mathematical Sciences at the Universidad Nacional Autónoma de México (UNAM).

The design is based on the [tlacuache-thesis-fc-unam](https://github.com/davidalencia/tlacuache-thesis-fc-unam) template, originally developed for undergraduate studies at the Faculty of Sciences. The cover has been adapted to (approximately) comply with the graduate program guidelines.

## Usage

~~⚠️ Note: This template is not currently available in the official Typst package repository.~~

The template is now available on Typst Universe, you can use it by importing it from `@preview`:
```typst
#import "@preview/tlacuache-thesis-msc-pcm-unam:0.1.1":*
```
or by starting a new file with `typst init`:
```bash
typst init @preview/tlacuache-thesis-msc-pcm-unam:0.1.1 mi-tesis
cd mi-tesis
typst watch main.typ
```


## Configuration

You can configure your thesis with these lines at the beginning of your main file.

```typ
#import "@preview/tlacuache-thesis-msc-pcm-unam:0.1.1": *

#show: thesis.with(
  titulo: [Thesis title],
  autor: (nombre: "Full name", genero: "fem"),
  asesor: (
    nombre: "Full name",
    genero: "masc",
    adscripcion: "Institute of Mathematics",
  ),
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: bibliography("references.bib"),
  abstract: include "abstract.typ",
  agradecimientos: include "agradecimientos.typ",
)

// Your thesis goes here
```

### Cover parameters

| Parameter | Description | Default value |
| --------- | ----------- | ------------- |
| `titulo`  | Thesis title | `[Titulo]` |
| `autor`   | Dictionary with `nombre` and `genero` (`"fem"` or `"masc"`). The gender selects "MAESTRA EN CIENCIAS" or "MAESTRO EN CIENCIAS". | `(nombre: "Nombre autor", genero: "fem")` |
| `asesor`  | Dictionary with `nombre`, `genero` (`"fem"` or `"masc"`) and `adscripcion`. The gender selects "DIRECTORA DE TESIS" or "DIRECTOR DE TESIS". | `(nombre: "Nombre", genero: "fem", adscripcion: "Adscripción")` |
| `lugar`   | City and country where the thesis is presented | `[Ciudad de México, México]` |
| `agno`    | Year of presentation | Current year |

### Content parameters

| Parameter | Description | Default value |
| --------- | ----------- | ------------- |
| `bibliography` | Reference to the bibliography file (`bibliography(...)`) | `none` (none) |
| `abstract` | Thesis abstract, placed before the table of contents | `none` (none) |
| `agradecimientos` | Acknowledgements, placed before the table of contents | `none` (none) |

## Appendices

You can add extra information in an appendix as follows:
```typst
#show: appendix
#include "anexo.typ"
```



## Features

- Cover page with the author, advisor and program information.
- Roman numerals in the front matter (acknowledgements, abstract, table of contents) and Arabic numerals in the body.
- Chapters and appendices start on odd pages.
- Alternating headers: chapter title on even pages and section title on odd pages.
- Three-level table of contents with chapter and appendix entries in bold.
- Bibliography at the end of the document (`bibliography: bibliography("references.bib")`).


## 🫶 Acknowledgements

- [David Valencia Rodríguez](https://github.com/davidalencia) for developing the original template.

## 🚨 Disclaimer

This template is not official and is not affiliated with the Mathematical Sciences Graduate Program at UNAM. Use at your own discretion.
