# uniovi-epi-tfg

A Typst template that complies with [E.P.I University of Oviedo](https://epi.uniovi.es) TFG guidelines

## Quick Start

You can initialize a project directly from the CLI:

```bash
typst init @preview/uniovi-epi-tfg
```

Or copy this minimal template into your document:

```typst
#import "@preview/uniovi-epi-tfg:0.1.0": *

#show: template.with(
  school: "Escuela Politécnica de Ingeniería de Gijón",
  degree: "Grado en Ingeniería Informática",
  area: "Computer Science and Artificial Intelligence",
  title: "Título del Trabajo de Fin de Grado",

  authors: (
    (surname: "Apellidos", name: "Nombre", email: "uo00000@uniovi.es"),
  ),
  supervisor: (
    (surname: "Apellidos", name: "Nombre", email: ""),
  ),

  date: "Octubre 2026",
  institution-link: "https://www.uniovi.es",
  subject: "Trabajo de Fin de Grado",

  lang: "es",
  bibliography_style: "ieee",
)

= Introducción

Aquí comienza el contenido del TFG...
```

A full working example can be found in [template/main.typ](https://github.com/martincanga/uniovi-epi-tfg/blob/main/template/main.typ).

## Configuration

Configure the `template` function at the top of your document:

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `school` | `string` | `""` | Name of the school / faculty. |
| `degree` | `string` | `""` | Degree programme name. |
| `area` | `string` | `""` | Knowledge area or specialisation. |
| `title` | `string` | `""` | Title of the TFG. |
| `authors` | `array` | `()` | Array of `(name: "", surname: "", email: "")` dictionaries. |
| `supervisor` | `array` | `()` | Array of `(name: "", surname: "", email: "")` dictionaries. |
| `date` | `string` | `none` | Submission date (e.g. `"Octubre 2026"`). |
| `institution-link` | `string` | `"https://www.uniovi.es"` | URL linked from the institution logo. |
| `subject` | `string` | `none` | Subject or course (used in document metadata). |
| `lang` | `string` | `"es"` | Document language code: `"es"` (Spanish) or `"en"` (English). |
| `paper_size` | `string` | `"a4"` | Page format (e.g. `"a4"`, `"us-letter"`). |
| `paper_color` | `string` | `"#ffffff"` | Background colour as a hex string. |
| `text_color` | `string` | `"#000000"` | Body text colour as a hex string. |
| `text_font` | `string` | `"New Computer Modern"` | Font family for body text. |
| `text_lang` | `string` | `"es"` | Typst text language (affects hyphenation). |
| `justify` | `bool` | `true` | Whether to justify body text. |
| `heading_numbering` | `string` | `"1"` | Numbering pattern for headings. |
| `bibliography_style` | `string` | `"ieee"` | Citation style for the bibliography. |

All parameters and their defaults can be found in [src/template.typ](https://github.com/martincanga/uniovi-epi-tfg/blob/main/src/template.typ).

## Features

### Cover Page

The template automatically generates a cover page with:
- The official University of Oviedo logo.
- School, degree, knowledge area, and TFG title in a hierarchical typographic layout.
- Author and supervisor names.
- Submission date.

### Header & Footer

Every body page includes:
- **Header** – University of Oviedo logo, school name, TFG title, and a *Page X of N* counter.
- **Footer** – A subtle dividing rule followed by the authors' full names.

### Heading Hierarchy

| Level | Style |
| :--- | :--- |
| `=` (Chapter) | 28 pt, bold, starts on a new page |
| `==` (Section) | 14 pt, bold, uppercase |
| `===` (Subsection) | 12 pt, bold |
| `====` (Sub-subsection) | 12 pt, bold |

### Table of Contents

An outline is generated automatically between the cover page and the body content, with top-level entries styled in bold.

### Code Blocks

Raw code blocks are rendered with a custom dark theme (`barf.tmTheme`):

### Multi-language Support

Set `lang: "es"` or `lang: "en"` to switch the interface language automatically. Labels in headers and the cover page (e.g. *Tutor* vs. *Thesis Advisor*, *Página* vs. *Page*) update accordingly.

The full list of translatable terms is in [src/translated_terms.typ](https://github.com/martincanga/uniovi-epi-tfg/blob/main/src/translated_terms.typ).

### Third-party Packages

The template re-exports the following packages for use in your document:

| Package | Version | Purpose |
| :--- | :--- | :--- |
| [`fletcher`](https://typst.app/universe/package/fletcher) | 0.5.8 | Diagram and graph drawing |
| [`lilaq`](https://typst.app/universe/package/lilaq) | 0.6.0 | Plotting and data visualisation |
| [`cetz`](https://typst.app/universe/package/cetz) | 0.5.2 | General vector graphics |

## License

MIT © [Martín Canga (Carver)](https://github.com/martincanga)
