// Definiciones de dimensiones
#import "/etc/variables.typ": *

#let TFC(
  titulo: "Título del Trabajo",
  alumno: "Nombre del Alumno",
  titulacion: "Grado en Ingeniería Informática - Ingeniería del Software",
  director: "Nombre del profesor tutor",
  departamento: "Lenguajes y Sistemas Informáticos",
  convocatoria: "Convocatoria de junio/julio/diciembre, curso 20XX/YY",
  dedicatoria: "Aquí la dedicatoria del trabajo",
  agradecimientos: [
    Quiero agradecer a X por...

    También quiero agradecer a Y por...
  ],
  resumen: [Incluya aquí un resumen de los aspectos generales de su trabajo, en español],
  palabrasClave: ("palabra clave 1", "palabra clave 2", "...", "palabra clave N"),
  abstract: [This section should contain an English version of the Spanish abstract.],
  keywords: ("keyword 1", "keyword 2", "...", "keyword N"),
  portadaIngles: false,
  seccionesIngles: false,
  font: "Palatino Linotype",
  doc
) = [

#import "@preview/outrageous:0.4.0"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()
#codly(zebra-fill:rgb(250,250,250), languages: codly-languages)

#set text(lang: if seccionesIngles {"en"} else {"es"}, size: 12pt, font:font, hyphenate: false)
#set list(indent: 0.75cm, spacing: 0.95em, marker: scale(140%)[#sym.square.filled.tiny])
#set enum(indent: 0.45cm, spacing: 0.95em)

// Numerado como Capitulo.contador
#set math.equation(numbering: it => numbering("(1.1)", counter(heading).get().at(0), it))
#set figure(numbering: it => numbering("1.1", counter(heading).get().at(0), it))

#set outline(depth: 3)
#set page(margin:2.75cm, )
#set par(
  first-line-indent: (amount:0.75cm, all:true),
  justify: true,
  leading: 6.2pt
)

// Portada
#[
#set align(center)
#v(1cm)
#image("/etsii_us.png")
#v(3cm)

#[#set text(size: large)
#if portadaIngles {"FINAL DEGREE PROJECT"} else {"TRABAJO FIN DE GRADO"}]
#v(-0.1in)

#[#set text(size: huge)
*#titulo*]
#v(0.0in)

#[#set text(size: large)
#if portadaIngles {"Presented by"} else {"Realizado por"} \ ]
#[#set text(size: very-large)
*#alumno*]

#v(2.5cm)

*#if portadaIngles {"For the degree of"} else {"Para la obtención del título de"}*\
#[#set text(size: large)
#titulacion]
#v(0.2in)

*#if portadaIngles {"Directed by"} else {"Dirigido por"}*\
#[#set text(size: large)
#director]
#v(0.2in)

*#if portadaIngles {"In the department of"} else {"En el departamento de"}*\
#[#set text(size: large)
#departamento]
#v(0.6in)

#[#set text(size: very-large)
*#convocatoria*]
]

// Dedicatoria

#pagebreak()
#place(center+horizon)[_#dedicatoria _]
#pagebreak()

#set page(numbering: "I")
#counter(page).update(1)

// Estilos de encabezados: tamaños, espacios, etc. Y reseteo de contadores

#show heading.where(level: 1): it => { 
  counter(figure).update(0)
  counter(math.equation).update(0)
  pagebreak(weak: true)
  block({
    let num = counter(heading)
    set text(size: huge)
    if num.get().at(0) > 0 and it.body != [Bibliografía] {num.display(); h(0.5em)}
    it.body
    block(above: 13pt, line(length:100%, stroke: 2pt) )
  }, above: -19pt, below: 35pt)
  
}

#show heading.where(level: 2, outlined: true): it => { 
    set text(size: very-large)
    block(above: 1.2cm, below: 1cm)[
      #counter(heading).display(); 
      #h(0.5em)
      #it.body
    ]
}

#show heading.where(level: 3, outlined: true): it => { 
    set text(size: large)
    block(above: 1.2cm, below: 0.75cm)[
      #counter(heading).display();
      #h(0.5em)
      #it.body
    ]
}

#show heading.where(level: 4): it => { 
    set text(size: regular)
    block(above: 1.2cm, below: 0.75cm)[
      #it.body
    ]
}

#show heading: it => {
  set par(first-line-indent: 0pt)
  it
}

// Estilo de tabla de contenidos para el paquete outrageous

#let presets = (
  outrageous-toc: (
    ..outrageous.presets.typst,
    prefix-transform: (level, prefix) => {
      // Eliminar el '.' después del número
      if level==1 {
        if prefix == none {
          [#prefix]
        } else {
          [#prefix.text.slice(0,-1)#h(5pt)]
        }
      }
    },
    fill: (repeat(".", gap:5pt), repeat(".", gap:5pt)),
  ),
  outrageous-figures: (
    ..outrageous.presets.typst,
    prefix-transform: (level, prefix) => {
      [#prefix.children.at(2)]
    },
    vspace: (none,none),
    fill: (repeat(".", gap:5pt), repeat(".", gap:5pt)),
  ),

  typst: (
  ),
)

#show outline.entry: outrageous.show-entry.with(
  ..presets.outrageous-toc,
)

// Primer nivel en la tabla de contenidos más grande y negrita

#show outline.entry.where(level: 1): it=> { 
  set text(weight:"bold", size: large)
  block(above: 18pt)[#it]
}

// Estilo de referencias. Incluyendo un enlace azul en el caso de las figuras y ecuaciones

#show ref: it => { 
  // Figuras, equaciones y encabezados
  if it.element != none and it.element.func() in (figure,math.equation,heading) {
    link(locate(it.target))[
    #it]
  // Todo lo demás (bibliografía)
  } else {
    it
  }
}

// Estilo de caption

#show figure.caption: it => context {
  v(1.5mm)
  [*#it.supplement #it.counter.display()#it.separator*#it.body]
  v(3mm)
}

// Secciones que no aparecen en la tabla de contenido

#set heading(outlined:false)

= #if seccionesIngles {"Acknowledgements"} else {"Agradecimientos"}

#agradecimientos

= Resumen
#resumen

#v(.5cm)

*Palabras clave:* #palabrasClave.join(", ")
 
= Abstract
#abstract

#v(.5cm)

*Keywords:* #keywords.join(", ")

#outline(title: if seccionesIngles {"Table of contents"} else {"Índice general"})

// Estilos para outlines secundarias

#show outline.entry: outrageous.show-entry.with(
  ..presets.outrageous-figures,
)

#show outline.entry.where(level: 1): it=> { 
  let level = counter(heading).at(it.element.location()).at(0)
  block(above: 6pt)[
    #link(it.element.location())[
      #level.#it.element.counter.at(it.element.location()).at(0).#h(5pt) #it.body() 
      #box(width: 1fr, repeat(".", gap: 5pt)) #it.page()
    ]
  ]
}

#outline(title: if seccionesIngles {"List of figures"} else {"Índice de figuras"}, target: figure.where(kind: image))
#outline(title: if seccionesIngles {"List of tables"} else {"Índice de tablas"}, target: figure.where(kind: table))
#outline(title: if seccionesIngles {"List of code extracts"} else {"Índice de extractos de código"}, target: figure.where(kind: raw))

// Cambio ahora para que la bibliografía no sea azul

#show link: it => {
  set text(fill: rgb("#0000ff"))
  it
}

#set page(numbering: "1")
#counter(page).update(1)

#set heading(outlined:true, numbering: "1.")

// Aquí comienza el documento normal

#doc

]