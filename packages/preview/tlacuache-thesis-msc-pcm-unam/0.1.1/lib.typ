// Función para activar el entorno de apéndices
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1.", supplement: [Apéndice])
  body
}

#let thesis(
  titulo: [Titulo],
  autor: (
    nombre: "Nombre autor",
    genero: "fem" // "fem" o "masc"
  ),
  asesor: (
    nombre: "Nombre",
    genero: "fem", // "fem" o "masc"
    adscripcion: "Adscripción",
  ),
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: none,
  abstract: none,
  agradecimientos: none,
  body,
) = {
  set document(title: titulo)

  // Resolución de género para etiquetas
  let grado-texto = if autor.at("genero", default: "masc") == "fem" {
    "MAESTRA EN CIENCIAS"
  } else {
    "MAESTRO EN CIENCIAS"
  }

  let asesor-texto = if asesor.at("genero", default: "fem") == "fem" {
    "DIRECTORA DE TESIS"
  } else {
    "DIRECTOR DE TESIS"
  }

  // Cabeceras automáticas sin state manual
  set page(
    "us-letter",
    margin: (top: 4cm, bottom: 2cm),
    header: context {
      let page-num = here().page()
      // Ocultar cabeceras en páginas preliminares o si la página actual inicia capítulo
      let ch-here = query(heading.where(level: 1)).any(h => h.location().page() == page-num)
      if page-num == 1 or ch-here { return }

      // Recuperar el capítulo y sección activos en esta página
      let cur-ch = query(heading.where(level: 1).before(here())).at(-1, default: none)
      let cur-sec = query(heading.where(level: 2).before(here())).at(-1, default: none)

      if calc.even(page-num) {
        if cur-ch != none {
          align(left)[
            #text(size: 10pt, style: "italic", cur-ch.body)
            #line(length: 100%, stroke: 0.5pt)
          ]
        }
      } else {
        if cur-sec != none {
          align(right)[
            #text(size: 10pt, style: "italic", cur-sec.body)
            #line(length: 100%, stroke: 0.5pt)
          ]
        }
      }
    }
  )

  set text(font: "New Computer Modern", lang: "es")
  set heading(numbering: "1.1.", supplement: [Capítulo])
  set math.equation(
    numbering: num => "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )
  set par(first-line-indent: 1em, justify: true, leading: 0.65em * 1.5)
  set block(spacing: 1.5em)

  // Portada
  page(margin: (top: 50pt), header: none)[
    #set align(center)
    #set par(leading: 5pt, first-line-indent: 0pt)
    #image("./escudos/logo-pccm.png", width: 120pt)
    #v(30pt)

    #text(14pt, weight: "bold", font: "Arial", [UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO])
    
    #text(12pt, font: "Arial", [PROGRAMA DE MAESTRÍA Y DOCTORADO EN CIENCIAS MATEMÁTICAS Y \
      DE LA ESPECIALIZACIÓN EN ESTADÍSTICA APLICADA])

    #v(90pt)
    #text(12pt, font: "Arial", [#titulo])
    #v(40pt)

    #text(12pt, font: "Arial", [QUE PARA OPTAR POR EL GRADO DE: \
      #grado-texto])

    #v(70pt)
    #text(12pt, font: "Arial", [PRESENTA: \ #autor.nombre])

    #v(62pt)
    #text(12pt, font: "Arial", [#asesor-texto:]) \
    #text(blue, 12pt, font: "Arial", [#asesor.nombre \ #asesor.adscripcion]) \

    #v(44pt)
    #text(12pt, font: "Arial", [#lugar, #agno.])
  ]

  // Front matter: Romanos
  set page(numbering: "i")
  counter(page).update(1)

  // Definir la regla show para encabezados nivel 1 (aplica a Front y Main matter)
  show heading.where(level: 1): it => {
    pagebreak(weak: true, to: "odd")
    v(50pt, weak: true)

    set par(first-line-indent: 0pt)

    if it.numbering != none {
      // Capítulos regulares y Apéndices numerados
      let num-display = counter(heading).display(it.numbering)
      let prefix = if it.supplement != none { it.supplement } else [Capítulo]

      text(size: 20.74pt, weight: "bold")[#prefix #num-display]
      v(20pt, weak: true)
      text(size: 24.88pt, weight: "bold", it.body)
      v(40pt, weak: true)
    } else {
      // Encabezados sin número: Resumen, Agradecimientos, Bibliografía
      text(size: 24.88pt, weight: "bold", it.body)
      v(40pt, weak: true)
    }
  }

  if agradecimientos != none {
    heading(level: 1, numbering: none, outlined: false)[Agradecimientos]
    agradecimientos
    pagebreak(weak: true)
  }

  if abstract != none {
    heading(level: 1, numbering: none, outlined: false)[Resumen]
    abstract
    pagebreak(weak: true)
  }

  show outline.entry: it => {
    let entry = link(it.element.location(), it.indented(it.prefix(), it.inner()))

    if it.level == 1 and it.element.supplement == [Apéndice] {
      context {
        let prev = query(heading.where(level: 1).before(it.element.location()))
        let is-first = prev.all(h =>
          h.location() == it.element.location() or h.supplement != [Apéndice]
        )
        if is-first {
          block(above: 1em, below: 0.6em, text(weight: "bold")[Apéndices])
        }
      }
      strong(entry)
    } else if it.level == 1 {
      strong(entry)
    } else {
      entry
    }
  }

  outline(depth: 3)
  pagebreak(weak: true, to: "odd")

  // Main matter: Arábigos
  set page(numbering: "1")
  counter(page).update(1)

  body

  if bibliography != none {
    bibliography
  }
}