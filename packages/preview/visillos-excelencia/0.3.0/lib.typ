#import "@preview/wordometer:0.1.6": word-count-of

//// Funciones ////

// Extrae el texto plano de un contenido sencillo (para los metadatos del PDF).
#let a-texto(c) = {
  if type(c) == str { c }
  else if type(c) != content { str(c) }
  else if c == [ ] { " " }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(a-texto).join() }
  else if c.has("body") { a-texto(c.body) }
  else { "" }
}

// ¿Está esta ubicación dentro de los anexos? (después de la marca que pone `anexos`)
#let en-anexos(ubicacion) = query(selector(<visillos-anexos>).before(ubicacion)).len() > 0

// Prefijo de la numeración por capítulo: el número del capítulo,
// o el del anexo en romanos si estamos en los anexos.
#let prefijo(ubicacion) = {
  let h = counter(heading).at(ubicacion)
  if en-anexos(ubicacion) and h.len() > 1 and h.at(1) > 0 {
    numbering("I", h.at(1))
  } else {
    str(h.first())
  }
}

// Número "capítulo.n" de una figura/tabla/ecuación, calculado en SU ubicación
// (así las referencias y las listas muestran el capítulo correcto).
#let numero-en-capitulo(contador, ubicacion, ecuacion: false) = {
  let n = prefijo(ubicacion) + "." + str(contador.at(ubicacion).first())
  if ecuacion { "(" + n + ")" } else { n }
}

#let insertar-imagen(
  anchura: auto,
  altura: auto,
  borde: none,
  ubicacion: none, // la imagen, p. ej. image("Imágenes/foto.png")
  descripcion: none,
) = {
  figure(
    box(stroke: borde, {
      // Aplica anchura/altura salvo que la imagen ya traiga los suyos
      set image(width: anchura, height: altura)
      ubicacion
    }),
    caption: descripcion
  )
}

// Anexos: se activa con `#show: anexos` antes de incluirlos. Cada `==` es un
// anexo ("Anexo I.", "Anexo II."…), con sus figuras numeradas I.1, I.2…
// y citable con @etiqueta ("Anexo I").
#let anexos(body) = {
  [#metadata(none) <visillos-anexos>]
  // Los títulos sin numerar no avanzan el contador: se avanza a mano para que
  // los anexos empiecen en I aunque el último capítulo tenga apartados.
  counter(heading).step(level: 1)
  set heading(numbering: (..n) => {
    let p = n.pos()
    if p.len() == 2 { "Anexo " + numbering("I", p.at(1)) + "." }
    else if p.len() > 2 { numbering("I.1.", ..p.slice(1)) }
  })
  show heading.where(level: 1): set heading(numbering: none)
  // Cada anexo reinicia la numeración de figuras, tablas y ecuaciones
  show heading.where(level: 2): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    it
  }
  body
}

#let proyecto(
  titulo: [Título del proyecto],
  autor: [Nombre del Alumno],
  supervisor: [Nombre del Tutor],
  instituto: [IES Carmen Martín Gaite],
  lugar: [Navalcarnero],
  fecha: [Mayo 2026],
  logo: none,
  convocatoria: none,      // texto opcional al pie de la portada, p. ej. el premio al que se presenta
  fuente: "Libertinus Serif",
  fuente-portada: none,    // fuente de la portada; con none, la misma del texto
  tamano-fuente: 12pt,
  interlineado: 1em,
  color-acento: rgb("#279985"),
  // Todas las piezas opcionales se quitan igual: con none o con false.
  abstract: none,          // contenido para incluirlo
  resumen: none,           // contenido para incluirlo
  agradecimientos: none,   // contenido para incluirlo
  bibliografia: none,      // p. ej. bibliography("referencias.yaml", style: "apa", title: "Bibliografía")
  lista-figuras: auto,     // auto: solo si hay figuras · true: siempre · false/none: nunca
  lista-tablas: auto,      // auto: solo si hay tablas · true: siempre · false/none: nunca
  doble-cara: false,       // true: capítulos en página impar (para imprimir a doble cara)
  contar-palabras: false,  // true: muestra tras el índice las palabras del primer capítulo al último anexo
  body,
) = {
  // ¿Está apagada una pieza opcional? (none y false funcionan igual)
  let apagado(v) = v == none or v == false

  // Metadatos del PDF
  set document(title: a-texto(titulo), author: a-texto(autor))

  // Salto de sección: solo fuerza página impar si se imprime a doble cara
  let salto = () => pagebreak(weak: true, to: if doble-cara { "odd" } else { none })
  // A doble cara el número de página va al lado exterior; a una cara, a la derecha
  let lado-de(pagina) = if doble-cara and calc.even(pagina) { left } else { right }

  // Configuración de página
  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )

  set text(tamano-fuente, font: fuente, lang: "es")

  // Numeración por capítulo: Figura 2.1, Tabla 3.2, ecuación (1.4)
  // (en los anexos, con el número del anexo: Figura I.1)
  set math.equation(numbering: n => context "(" + prefijo(here()) + "." + str(n) + ")")
  set figure(numbering: n => context prefijo(here()) + "." + str(n))

  // Referencias cruzadas: el capítulo se calcula en la ubicación del elemento
  show ref: it => {
    let el = it.element
    if el == none { return it }
    let ubi = el.location()
    if el.func() == math.equation {
      link(ubi, numero-en-capitulo(counter(math.equation), ubi, ecuacion: true))
    } else if el.func() == figure {
      link(ubi, [#el.supplement #numero-en-capitulo(counter(figure.where(kind: el.kind)), ubi)])
    } else if el.func() == heading and el.level == 2 and en-anexos(ubi) {
      link(ubi, [Anexo #numbering("I", counter(heading).at(ubi).at(1))])
    } else {
      it
    }
  }

  // Portada
  {
    set text(font: fuente-portada) if fuente-portada != none
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

    if not apagado(convocatoria) {
      v(1fr)
      align(center, text(12pt, convocatoria))
    }
  }
  salto()

  // Numeración romana para las páginas iniciales y el índice
  set par(justify: true, leading: interlineado, spacing: 20pt)
  counter(page).update(1)
  set page(numbering: "I", footer: context {
    let pagina = counter(page).get().first()
    align(lado-de(pagina), counter(page).display("I"))
  })

  // Estilos de encabezado (capítulos, portadillas iniciales y títulos de índice)
  show heading.where(level: 1): it => [
    #salto()
    #counter(figure.where(kind: image)).update(0)
    #counter(figure.where(kind: table)).update(0)
    #counter(math.equation).update(0)
    #v(10pt)
    #set text(size: tamano-fuente + 4pt, fill: color-acento)
    #it
  ]

  show heading.where(level: 2): it => [
    #v(5pt)
    #set text(size: tamano-fuente + 2pt, weight: "bold", fill: rgb("#2a2a2a"))
    #it
  ]

  show heading.where(level: 3): it => [
    #set text(size: tamano-fuente, weight: "regular", style: "italic", fill: black)
    #it
  ]

  set heading(numbering: "1.")

  // Nota debajo de una figura o tabla, al estilo APA. En el cuerpo de la figura,
  // después de la imagen: #[Elaboración propia.] <nota>  →  «Nota. Elaboración propia.»
  show <nota>: it => block(width: 100%, above: 0.8em, align(left, {
    set par(first-line-indent: 0pt)
    text(size: tamano-fuente - 2pt)[_Nota._ #it]
  }))

  // Formato de las descripciones de figuras y tablas
  show figure.caption: set align(left)
  set figure.caption(position: top)

  show figure.caption: it => block(width: 100%)[
    #set text(size: tamano-fuente - 2pt)
    #set par(spacing: 1em)
    #strong[#it.supplement #context it.counter.display(it.numbering)]
    #emph[#it.body]
  ]

  // Páginas iniciales: cada una con su título, en su página y en el índice
  let portadilla(nombre, cuerpo) = {
    heading(level: 1, numbering: none, outlined: true, nombre)
    cuerpo
  }
  if not apagado(abstract) { portadilla([Abstract], abstract) }
  if not apagado(resumen) { portadilla([Resumen], resumen) }
  if not apagado(agradecimientos) { portadilla([Agradecimientos], agradecimientos) }

  // Índice general (capítulos en negrita)
  {
    show outline.entry.where(level: 1): it => {
      v(12pt, weak: true)
      strong(it)
    }
    outline(depth: 2, indent: auto)
  }

  // Extensión del trabajo: cuenta el texto del cuerpo (capítulos y anexos), sin
  // figuras, tablas ni ecuaciones; las páginas iniciales y la bibliografía van aparte.
  if contar-palabras {
    let palabras = word-count-of(body, exclude: figure).words
    v(1.5em)
    align(right, text(style: "italic")[Extensión del trabajo: #palabras palabras])
  }

  // Cuerpo del documento: numeración arábiga y cabecera con el capítulo actual
  set page(
    numbering: "1",
    header: context {
      let pagina = here().page()
      // En la página donde arranca un capítulo no hay cabecera
      if query(heading.where(level: 1)).any(h => h.location().page() == pagina) { return }
      let previos = query(selector(heading.where(level: 1)).before(here()))
      if previos.len() == 0 { return }
      let capitulo = previos.last()
      let numero = if capitulo.numbering == none { [] } else {
        [#numbering("1.", counter(heading).at(capitulo.location()).first()) ]
      }
      align(lado-de(pagina), text(tamano-fuente - 2pt, style: "italic", numero + capitulo.body))
    },
    footer: context {
      let pagina = counter(page).get().first()
      align(lado-de(pagina), counter(page).display("1"))
    },
  )
  counter(page).update(1)

  // AQUÍ SE VOLCARÁ EL TEXTO DEL ALUMNO
  body

  // Bibliografía
  if not apagado(bibliografia) { bibliografia }

  // Listas finales de figuras y tablas, con el número "capítulo.n" de cada una.
  // Con auto, la lista solo aparece si el documento tiene elementos de su tipo.
  let lista-de(nombre, tipo, modo) = context {
    if modo == true or (modo == auto and query(figure.where(kind: tipo)).len() > 0) {
      heading(level: 1, numbering: none, outlined: true, nombre)
      show outline.entry: it => context {
        let el = it.element
        v(12pt, weak: true)
        strong(it.indented(
          [#el.supplement #numero-en-capitulo(counter(figure.where(kind: tipo)), el.location())],
          it.inner(),
        ))
      }
      outline(title: none, target: figure.where(kind: tipo))
    }
  }
  lista-de([Lista de figuras], image, lista-figuras)
  lista-de([Lista de tablas], table, lista-tablas)
}
