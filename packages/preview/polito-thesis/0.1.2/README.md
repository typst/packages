
# How to use this package

Please refer to this page on how to use Politecnico's image propertly, which are the suggested fonts and where to download them (see below for more information about using different fonts in typst):

https://www.polito.it/ateneo/chi-siamo/immagine-coordinata-e-marchio

**By default mandatory missing fields of the cover page will default to a red warning. In case you want to remove the whole field (for example you do not want to show the graduation session) you can set it to `none` (e.g. `graduation-session: none`)**

Speficy the following fields:

- `title`: The title of your thesis
- `subtitle`: Optional subtitle
- `student-name`: Name of the student/author
- `lang`: language of the document "en" or "it"
- `student-gender`: Optional gender of the student used only if `lang = "it"`
- `degree-name`: Name of your degree
- `supervisors`: List of the supervisors (relatori), must always be a list even if there is a single name. For example `("Mario Rossi", )`
- `academic-year`: "20xx/20xx"
- `graduation-session`: Month and year of the graduation session. Set this to `none` to remove this line from the cover.
- `for-print`: Optional, if `true` the left margin of the page will be increased to account for binding
- `bibliography`: Optional, result of the `bibliography()` function of typst, this allows proper stilying of the bibliography.

## Fonts

Fonts for the following elements can be customized independently, for example:

- `cover-font`: `"Poppins"`,
- `heading-font`: `"Poppins"`,
- `text-font`: `"Libertinus Serif"`

**Refer to the following link to know how to install new fonts**:

https://typst.app/docs/reference/text/text/#parameters-font

## Colors

You can import the default suggested colors from this same template as
- `polito-black`
- `polito-blue`
- `polito-orange`

# Example

```typ
#import "@preview/polito-thesis:0.1.2": polito-black, polito-blue, polito-orange, polito-thesis

#show: polito-thesis.with(
  title: [Tesi di Laurea],
  subtitle: [With support for English and Italian],
  degree-name: "Typst Engineering",
  academic-year: "2025/2026",
  graduation-session: "May 2026",
  student-name: "Mario Rossi",
  supervisors: ("Mario Rossi", "Maria Bianchi"),
  cover-font: "Poppins",
  heading-font: "Poppins",
  text-font: "Libertinus Serif",
)

= How to use this package

Please refer to this page on how to use Politecnico's image propertly, which are the suggested fonts and where to download them (see below for more information about using different fonts in typst):

#show link: set text(fill: blue)
#link("https://www.polito.it/ateneo/chi-siamo/immagine-coordinata-e-marchio")

*By default mandatory missing fields of the cover page will default to a red warning. In case you want to remove the whole field (for example you do not want to show the graduation session) you can set it to `none` (e.g. `graduation-session: none`)*

Speficy the following fields:

- `title`: The title of your thesis
- `subtitle`: Optional subtitle
- `student-name`: Name of the student/author
- `lang`: language of the document "en" or "it"
- `student-gender`: Optional gender of the student used only if `lang = "it"`
- `degree-name`: Name of your degree
- `supervisors`: List of the supervisors (relatori), must always be a list even if there is a single name. For example `("Mario Rossi", )`
- `academic-year`: "20xx/20xx"
- `graduation-session`: Month and year of the graduation session. Set this to `none` to remove this line from the cover.
- `for-print`: Optional, if `true` the left margin of the page will be increased to account for binding
- `bibliography`: Optional, result of the `bibliography()` function of typst, this allows proper stilying of the bibliography.

== Fonts

Fonts for the following elements can be customized independently, for example:

- `cover-font`: `"Poppins"`,
- `heading-font`: `"Poppins"`,
- `text-font`: `"Libertinus Serif"`

*Refer to the following link to know how to install new fonts*:

#link("https://typst.app/docs/reference/text/text/#parameters-font")

== Colors

You can import the default suggested colors from this same template as
- #text(`polito-black`, fill: polito-black)
- #text(`polito-blue`, fill: polito-blue)
- #text(`polito-orange`, fill: polito-orange)

== Example sub-chapter

#lorem(40)

=== #lorem(10)
#lorem(15)

= Another chapter

#lorem(500)

```

# Rights

The file `polito.png` belongs to Politecnico di Torino, please refer to the following link to know more:

https://www.polito.it/ateneo/chi-siamo/immagine-coordinata-e-marchio