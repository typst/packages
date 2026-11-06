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
- `custom-outline`: Optional, if not present defaults to the table of contents. If present, the user can specify anything that is placed between the title and the first chapter
- `appendix`: Optional, can be used to create an appendix with different heading numbering before the bibliography.

## Fonts

Fonts for the following elements can be customized independently, for example:

- `cover-font`: `"Poppins"`,
- `heading-font`: `"Poppins"`,
- `text-font`: `"Libertinus Serif"`

**Refer to the following link to know how to install new fonts**:

https://typst.app/docs/reference/text/text/#parameters-font

## Opinionated stilying

Add `#show: opinionated-polito-style` at the top of your document to apply the following changes to the document:

- Equation numbering resets after each chapter
- First line of each paragraph is indented
- Remove numbering from level 4 headings
- Automatic figure placement (to the top and bottom of the pages)

## Colors

You can import the default suggested colors from this same template as

- `polito-black`
- `polito-blue`
- `polito-orange`

# Example

```typ
#import "@preview/polito-thesis:0.1.3": polito-black, polito-blue, polito-orange, polito-thesis, opinionated-polito-style

#show: polito-thesis.with(
  title: [Tesi di Laurea],
  subtitle: [With support for English and Italian],
  degree-name: "Typst Engineering",
  academic-year: "2025/2026",
  graduation-session: "May 2026",
  student-name: "Mario Rossi",
  supervisors: (
    [
      #set align(right)
      Mario Rossi\
      (Politecnico di Torino)
    ],
    [
      #set align(right)
      Maria Bianchi \
      (Company)
    ],
  ),
  // supervisors: ("mario", "gianni"),
  cover-font: "Poppins",
  heading-font: "Poppins",
  text-font: "Libertinus Serif",
  custom-outline: [
    // Outline has roman numeral and features both the table of contents and abbreviation list
    #counter(page).update(1)
    #show heading: set text(size: 2em)
    #set page(numbering: "i")
    #outline()
  ],
  appendix: [
    = Appendix

    == Lorem <appendix>
    #lorem(300)

    == Lorem2
    #lorem(30)
  ]
)

#show: opinionated-polito-style

= How to use this package

Please refer to this page on how to use Politecnico's image propertly, which are the suggested fonts and where to download them (see below for more information about using different fonts in typst):

#show link: set text(fill: blue)
#link("https://www.polito.it/ateneo/chi-siamo/immagine-coordinata-e-marchio")

*By default mandatory missing fields of the cover page will default to a #text(fill: red)[red warning]. In case you want to remove the whole field (for example you do not want to show the graduation session) you can set it to `none` (e.g. `graduation-session: none`)*

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
- `custom-outline`: Optional, if not present defaults to the table of contents. If present, the user can specify anything that is placed between the title and the first chapter
- `appendix`: Optional, can be used to create an appendix with different heading numbering before the bibliography.

== Fonts <fonts>

Fonts for the following elements can be customized independently, for example:

- `cover-font`: `"Poppins"`,
- `heading-font`: `"Poppins"`,
- `text-font`: `"Libertinus Serif"`

*Refer to the following link to know how to install new fonts*:

#link("https://typst.app/docs/reference/text/text/#parameters-font")

== Opinionated stilying

Add `#show: opinionated-polito-style` at the top of your document to apply the following changes to the document:
- Equation numbering resets after each chapter
- First line of each paragraph is indented
- Remove numbering from level 4 headings
- Automatic figure placement (to the top and bottom of the pages)

== Colors

You can import the default suggested colors from this same template as
- #text(`polito-black`, fill: polito-black)
- #text(`polito-blue`, fill: polito-blue)
- #text(`polito-orange`, fill: polito-orange)

Check them out in @fig:colors

#figure(
  table(
    stroke: none,
    columns: 3,
    column-gutter: 1em,
    row-gutter: 1em,
    rect(fill: polito-black),
    rect(fill: polito-blue),
    rect(fill: polito-orange),
    [`polito-black`],[`polito-blue`], [`polito-orange`]
  ),
  caption: [Available colors.]
) <fig:colors>

== Example sub-chapter


==== A level 4 heading

#lorem(40)

=== #lorem(10)
#lorem(15)

= Another chapter

Check out the @appendix

#lorem(500)


```

# Rights

The file `polito.png` belongs to Politecnico di Torino, please refer to the following link to know more:

https://www.polito.it/ateneo/chi-siamo/immagine-coordinata-e-marchio
