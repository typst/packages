#import "@preview/unify:0.7.1": num, qty, numrange, qtyrange
#import "@preview/physica:0.9.5": *
#let longitud-abstract = 138
#let esei-tfg(
  titulo: "Título do Traballo de Fin de Grado",
  alumno: "D. Nome Alumna/o",
  tutor: "Nome do meu titor",
  tfg_num: 123,
  area: "Linguaxes e Sistemas Informáticos",
  departamento: "Informática",
  fecha: "Xullo, 20XX",
  resumen: lorem(longitud-abstract),
  abstract: lorem(longitud-abstract),
  pclave: lorem(6).replace(" ", ", ").replace(",,", ","),
  kwords: lorem(6).replace(" ", ", ").replace(",,", ","),
  agradecimientos: quote(attribution: [Plato], block: true)[#lorem(20)],
  doc,
) = {
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 2cm),
    footer: none,
  )
  set text(size: 12.5pt, lang: "es")
  set par(linebreaks: "optimized", justify: true, spacing: 1.8em, leading: 1.2em)
  //let azulunir = rgb("#0098cd")

  show link: it => {
    if not (it.body.text.contains(it.dest)) {
      text(fill: blue, underline(it))
    } else { text(fill: blue, font: "IBM Plex Mono", size: 10.2pt, underline(it)) }
  }

  /*
    Longitur del abstract de ejemplo
  */
  let longitud_abstract = 130

  /*
  Estilo de los títulos de cabecera de nivel 1 (sección )
  */
  set heading(numbering: "1.")
  show heading.where(level: 1): item => {
    pagebreak()
    v(130pt)
    if item.numbering != none {
      text(black, weight: "bold", size: 20pt)[#context counter(heading).display()]
      " "
    }
    text(black, weight: "bold", 20pt)[#item.body]
    v(0.1em)
  }

  /*
  Estilo de los títulos de cabecera de nivel 2 (subsección)
  */
  show heading.where(level: 2): item => {
    v(20pt)
    text(black, weight: "bold", size: 15pt)[#context counter(heading).display()]
    " "
    text(black, weight: "bold", 15pt)[#item.body]
    v(0.1em)
  }

  /*
  Definición de la portada
  */

  align(center)[
    #v(25pt)
    #image("logo_uvigo.png", width: 45%)

    #text(size: 17pt)[
      #strong[E]SCOLA #strong[S]UPERIOR #strong[D]E #strong[E]NXEÑARÍA #strong[I]NFORMÁTICA
    ]
    #v(60pt)
    #text(size: 13pt)[Memoria do Traballo de Fin de Grao que presenta]
    #v(-10pt)
    #text(size: 15pt, weight: "bold")[#alumno]
    #v(-10pt)
    #text(size: 13pt)[para a obtención do Título de Graduado en Enxeñaría Informática]
    #v(10pt)
    #text(size: 15pt, weight: "bold")[#titulo]

    #v(145pt)
    #align(center)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 16pt,
        image("emblema_ing_informatica.png", width: 3.2cm),
        align(left)[
          #stack(
            spacing: 8pt,
            v(5pt),
            [#fecha],
            v(22pt),
            [#strong[Traballo de Fin de Grao Nº:]#h(1.5mm) #tfg_num],
            v(22pt),
            [#strong[Titor/a:]#h(1.5mm)  #tutor],
            [#strong[Área de coñecemento:]#h(1.5mm)  #area],
            [#strong[Departamento:]#h(1.5mm) #departamento],
          )
        ],
      )
    ]
  ]


  if (agradecimientos != none) {
    if (
      agradecimientos.func() == quote and agradecimientos.has("attribution") and agradecimientos.attribution == [Plato]
    ) [] else [
      #pagebreak()
      #align(center + horizon, text(size: 18pt, [#agradecimientos]))
    ]
  }

  pagebreak()

  align(top)[
    #text(fill: black, size: 18pt, weight: "regular")[Resumen]

    #resumen

    #text(weight: "bold")[Palabras clave:]
    #pclave
  ]
  align(bottom)[
    #text(fill: black, size: 18pt)[Abstract]

    #abstract

    #text(weight: "bold")[Keywords:]
    #kwords
  ]


  // text(font: "calibri", size: 18pt, fill: azulunir, weight: "light")[Índice de contenidos]
  outline(title: "Índice de contenidos")
  //pagebreak()
  set page(
    footer: context [
      #set align(right)
      #set text(8pt)
      #text(13pt)[#counter(page).display()]
    ],
    header: [
      #set text(10pt)
      #align(right)[
        #alumno
        #v(-0.9em)
        #titulo
      ]
    ],
  )
  counter(page).update(1)
  doc
}
