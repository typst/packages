#let template(
  title: "", institution: "", authors: [], abstract: [], keywords: [], resumen: [], palabras-clave: [], body,
) = {
  // Packages
  // Correct indent, thanks to: https://typst.app/universe/package/indenta
  import "@preview/indenta:0.0.3": fix-indent

  // General configuration
  set page(columns: 2, numbering: "1")// Set 2 columns document
  set text(font: "New Computer Modern", lang: "es") // Use Latex font, set Spanish languaje
  set par(justify: true, first-line-indent: 2em) // Justified paragraphs, indented
  set table(align: center, stroke: 0.5pt) // Centered tables
  set math.equation(numbering: "(1)") // Numbered equations
  show: fix-indent()

  place(top + center, scope: "parent", float: true, [
    #pad(x: 0.5cm)[
      #align(center, text(17pt)[
        *#title*
      ])
      #align(center)[
        #authors \
        #institution \
      ]
    ]
    #v(1.5cm)
    #pad(x: 3cm)[
      #align(center)[= Resumen] \
      #align(left)[
        #resumen \
        *Palabras clave:* #palabras-clave
      ]
      #align(center)[= Abstract] \
      #align(left)[
        #abstract \
        *Keywords* #keywords
      ]
    ]
  ])
  pagebreak()

  body
}
