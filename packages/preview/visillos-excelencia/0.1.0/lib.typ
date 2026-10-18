//// Funciones ////

#let insertar-imagen(
  anchura: auto,
  altura: auto,
  borde: none,
  ubicacion: none, // Ahora 'ubicacion' recibirá la imagen ya cargada
  descripcion: none,
) = {
  figure(
    box(stroke: borde, ubicacion), // <--- Quitamos la palabra 'image' de aquí
    caption: descripcion
  )
}

#let proyecto(
  titulo: [Título del proyecto],
  autor: [Nombre del Alumno],
  supervisor: [Nombre del Tutor],
  instituto: [IES Carmen Martín Gaite],
  lugar: [Navalcarnero],
  fecha: [Mayo 2026],
  logo: none,
  fuente: "Libertinus Serif",
  body,
) = {

  // Configuración de página
  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    number-align: right,
  )

  set math.equation(numbering: "(1)")

  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      link(el.location(), numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      ))
    } else {
      it
    }
  }

  set text(12pt, font: fuente, lang: "es")

  // Portada
  v(2fr)
  if logo != none {
    align(center, box(radius: 3pt, clip: true, logo))
  }
  v(1.6fr)
  align(center, text(14pt, "Proyecto de Excelencia"))
  v(1fr)
  align(center, text(30pt, hyphenate: false, weight: "bold", upper(titulo)))
  v(1.6fr)
  align(center, text(20pt, [Realizado por: ] + autor))
  v(1.6fr)
  align(center, text(14pt, instituto))
  v(0.6fr)
  align(center, text(14pt, smallcaps[Bachillerato de Excelencia]))
  v(1fr)
  align(center, text(14pt, lugar + [, ] + fecha))
  v(0.6fr)
  line(start: (25%, 0pt), end: (75%, 0pt))
  v(0.6fr)
  align(center, text(14pt, [Supervisado por: ] + supervisor))
  v(1.6fr)

  pagebreak(to: "odd")

  // Índices
  set par(justify: true, leading: 1em, spacing: 20pt)

  counter(page).update(1)
  set page(footer: context {
    if calc.even(counter(page).get().first()) {
      align(left, counter(page).display("I"))
    } else {
      align(right, counter(page).display("I"))
    }
  })

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  outline(depth: 2, indent: auto)
  pagebreak(to: "odd")

  outline(title: "Lista de imágenes", target: figure.where(kind: image))
  pagebreak(to: "odd")

  outline(title: "Lista de tablas", target: figure.where(kind: table))
  pagebreak(to: "odd")

  // Formato del cuerpo del documento
  counter(page).update(1)
  set page(footer: context {
    if calc.even(counter(page).get().first()) {
      align(left, counter(page).display("1"))
    } else {
      align(right, counter(page).display("1"))
    }
  })

  show heading.where(level: 1): it => [
    #pagebreak(weak: true, to: "odd")
    #v(10pt)
    #set text(size: 16pt, fill: rgb("#279985"))
    #it
  ]

  show heading.where(level: 2): it => [
    #v(5pt)
    #set text(size: 14pt, weight: "bold", fill: rgb("#2a2a2a"))
    #it
  ]

  show heading.where(level: 3): it => [
    #set text(size: 12pt, weight: "regular", fill: black)
    #it
  ]

  show figure.caption: set align(left)
  set figure.caption(position: top)

  show figure.caption: it => block(width: 100%)[
    #set text(size: 10pt)
    #set par(spacing: 1em)
    #strong[#it.supplement #context it.counter.display(it.numbering)]
    #emph[#it.body]
  ]

  set heading(numbering: "1.")

  // AQUÍ SE VOLCARÁ EL TEXTO DEL ALUMNO
  body
}
