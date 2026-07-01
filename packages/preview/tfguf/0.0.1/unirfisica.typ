#let longitud-abstract = 138
#let unirfisica(
  titulo: "Título de mi TFG",
  alumno: "Mi nombre",
  director: "Nombre de mi director",
  resumen: lorem(longitud-abstract),
  abstract: lorem(longitud-abstract),
  pclave: lorem(6).replace(" ", ", ").replace(",,", ","),
  kwords: lorem(6).replace(" ", ", ").replace(",,", ","),
  logo: none,
  doc,
) = {
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 2cm),
    header: [
      #set text(10pt)
      #align(right)[
        #alumno
        #v(-0.9em)
        #titulo
      ]
    ],
    footer: none,
  )
  set text(font: "calibri", size: 12.5pt)
  set par(linebreaks: "optimized", justify: true, spacing: 1.8em, leading: 1.2em)
  let azulunir = rgb("#0098cd")

  /*
  Estilo de los títulos de cabecera de nivel 1 (sección )
  */
  set heading(numbering: "1.")
  show heading.where(level: 1): item => {
    pagebreak()
    v(130pt)
    if item.numbering != none {
      text(azulunir, weight: "light", size: 20pt)[#context counter(heading).display()]
      " "
    }
    text(azulunir, weight: "light", 20pt)[#item.body]
    v(0.1em)
  }

  /*
  Estilo de los títulos de cabecera de nivel 2 (subsección)
  */
  show heading.where(level: 2): item => {
    v(20pt)
    text(azulunir, weight: "light", size: 15pt)[#context counter(heading).display()]
    " "
    text(azulunir, weight: "light", 15pt)[#item.body]
    v(0.1em)
  }

  /*
  Definición de la portada
  */

  align(center)[
    #logo

    #text(font: "calibri", size: 24pt)[Universidad Internacional de la Rioja
    ]

    #v(-10pt)
    #text(font: "calibri", size: 20pt)[Escuela Superior de Ingeniería y Tecnología]

    /*
    Nombre del estudio y título del trabajo
    */
    #align(center + horizon)[
      #text(size: 18pt)[Grado en Física]
      #v(-10pt)
      #text(size: 26pt, fill: azulunir, weight: "bold")[#titulo]
    ]

    #let fecha = datetime.today()

    /*
     Tabla inferior con los datos del TFG
    */
    #align(center + bottom)[
      #table(
        columns: (1fr, 1fr),
        stroke: 0.1pt,
        align: left,
        table.header[Trabajo de fin de estudio presentado por: ][#alumno],
        [Director/a:], [#director],
        [Fecha:], [#fecha.display()],
      )
    ]
  ]

  pagebreak()

  align(top)[
    #text(fill: azulunir, size: 18pt, weight: "regular", font: "calibri")[Resumen]

    #resumen

    #text(weight: "bold")[Palabras clave:]
    #pclave
  ]
  align(bottom)[
    #text(fill: azulunir, size: 18pt)[Abstract]

    #abstract

    #text(weight: "bold")[Keywords]:
    #kwords
  ]
  set page(
    footer: context [
      #set align(right)
      #set text(8pt)
      #text(13pt)[#counter(page).display()]
    ],
  )
  counter(page).update(1)
  doc
}
