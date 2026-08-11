#import "@preview/unify:0.7.1": num, numrange, qty, qtyrange
#import "@preview/physica:0.9.8": *
#let longitud-resumen = 138
#let tfgei(
  titulo: "Título do Traballo de Fin de Grado",
  alumno: "D. Nome Alumna/o",
  tutor: "Nome do meu titor",
  tfgnum: "XX-XX",
  area: "Linguaxes e Sistemas Informáticos",
  departamento: "Informática",
  fecha: "Xullo, 20XX",
  resumen: lorem(longitud-resumen),
  pclave: lorem(6).replace(" ", ", ").replace(",,", ","),
  agradecimientos: quote(attribution: [Plato], block: true)[#lorem(20)],
  idioma: "gl",
  doc,
) = {
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 3cm),
    footer: none,
  )
  let etiquetas = (
    gl: (
      memoria: "Memoria do Traballo de Fin de Grao que presenta",
      titulacion: "para a obtención do Título de Graduado en Enxeñaría Informática",
      tfg_num: "Traballo de Fin de Grao Nº:",
      tutor: "Titor/a:",
      area: "Área de coñecemento:",
      departamento: "Departamento:",
      resumen: "Resumo",
      palabras_clave: "Palabras clave:",
      indice: "Índice de contenidos",
      lang: "gl",
    ),
    es: (
      memoria: "Memoria del Trabajo de Fin de Grado que presenta",
      titulacion: "para la obtención del Título de Graduado en Ingeniería Informática",
      tfg_num: "Trabajo de Fin de Grado Nº:",
      tutor: "Tutor/a:",
      area: "Área de conocimiento:",
      departamento: "Departamento:",
      resumen: "Resumen",
      palabras_clave: "Palabras clave:",
      indice: "Índice de contenidos",
      lang: "es",
    ),
  )
  let labels = etiquetas.at(idioma, default: etiquetas.gl)

  set text(size: 12.5pt, lang: labels.lang)
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
    
    #text(size: 17pt)[#strong[E]SCOLA #strong[S]UPERIOR #strong[D]E #strong[E]NXEÑARÍA #strong[I]NFORMÁTICA]
    #v(60pt)
    #text(size: 13pt)[#labels.memoria]
    #v(-10pt)
    #text(size: 15pt, weight: "bold")[#alumno]
    #v(-10pt)
    #text(size: 13pt)[#labels.titulacion]
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
            [#strong[#labels.tfg_num]#h(1.5mm) #tfgnum],
            v(22pt),
            [#strong[#labels.tutor]#h(1.5mm)  #tutor],
            [#strong[#labels.area]#h(1.5mm)  #area],
            [#strong[#labels.departamento]#h(1.5mm) #departamento],
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
  
  if (resumen != none) {
    pagebreak()
    align(top)[
      #text(fill: black, size: 18pt, weight: "regular")[#labels.resumen]
      
      #resumen
      
      #text(weight: "bold")[#labels.palabras_clave]
      #pclave
    ]
  }
  
  // text(font: "calibri", size: 18pt, fill: azulunir, weight: "light")[Índice de contenidos]
  outline(title: labels.indice)
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
