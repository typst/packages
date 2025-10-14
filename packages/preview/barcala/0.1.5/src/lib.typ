#let informe(
  institucion: none,
  unidad-academica: none,
  asignatura: none,
  titulo: none,
  equipo: none,
  autores: none,
  titulo-descriptivo: none,
  resumen: none,
  fecha: datetime.today(),
  formato: (:),
  body,
) = {
  // Validación de los parámetros de entrada
  import "types.typ": parse-options
  let opts = parse-options((
    institucion: institucion,
    unidad-academica: unidad-academica,
    asignatura: asignatura,
    titulo: titulo,
    equipo: equipo,
    autores: autores,
    titulo-descriptivo: titulo-descriptivo,
    resumen: resumen,
    fecha: fecha,
    formato: formato,
  ))

  // Algunas constantes
  let margen-top = 2.5cm
  let interlineado = 0.65em
  let emails-numering = "1" // numeración de los emails en la carátula
  let notas-numering = "*" // numeración de las notas en la carátula

  // Autores - notas y referencias
  let emails = (:) // key: dirección de email, value: array de usuarios
  let notas = () // notas de los autores
  for a in opts.autores {
    if a.email != none {
      if a.email.domain in emails {
        emails.at(a.email.domain).push(a.email.user)
      } else {
        emails.insert(a.email.domain, (a.email.user,))
      }
    }
    if a.notas.len() > 0 {
      for n in a.notas {
        if not notas.contains(n) {
          notas.push(n)
        }
      }
    }
  }

  // Propiedades del documento .pdf
  set document(
    title: opts.titulo-descriptivo,
    author: opts.autores.map(a => a.apellido + ", " + a.nombre),
  )

  // Setup general de las páginas
  set page(
    paper: "a4",
    margin: (
      // "simétricos": igual margen en todas las páginas
      // "anillado":   mayor margen donde se encuaderna
      inside: if opts.formato.margenes == "simétricos" { 1.75cm } else { 2.5cm },
      outside: 1.75cm,
      top: margen-top,
      bottom: 2cm,
    ),
    header: context {
      // Header en todas las páginas menos la primera
      if (counter(page).get().at(0) != 1) {
        set text(size: 10pt)
        stack(
          dir: ltr,
          stack(
            dir: ttb,
            spacing: interlineado,
            strong(opts.asignatura),
            if opts.titulo != none {
              opts.titulo
            } else {
              opts.titulo-descriptivo
            },
          ),
          h(1fr),
          {
            set align(right)
            stack(
              dir: ttb,
              spacing: interlineado,
              [Año #opts.fecha.year()],
              smallcaps(if opts.equipo != none {
                opts.equipo
              } else {
                opts.autores.map(a => a.apellido).join(", ")
              }),
            )
          },
        )
        line(length: 100%, stroke: 0.5pt)
      }
    },
    footer: context {
      // Footer en todas las páginas
      set text(size: 10pt)
      set align(center)
      counter(page).display("1 / 1", both: true)
    },
  )

  // Formato del texto
  set text(font: opts.formato.tipografia, size: 11pt, lang: "es", region: "AR")
  set par(
    justify: true,
    linebreaks: "optimized",
    first-line-indent: (amount: 0.75cm, all: true),
  )

  // Títulos y subtítulos
  set heading(numbering: "1.1.")
  show heading.where(level: 1): it => {
    set text(size: 14pt, weight: "bold")
    v(0.35cm)
    it
    v(0.3cm)
  }
  show heading.where(level: 2): set text(size: 12pt, weight: "bold")
  show heading.where(level: 3): set text(size: 11pt, weight: "bold")

  // Figuras
  set figure(numbering: "1", supplement: [Figura])
  show figure.where(kind: table): set figure(supplement: [Tabla])
  show figure.where(kind: raw): set figure(supplement: [Código])
  show figure.caption: set text(size: 10pt)

  // Otros
  set bibliography(style: "institute-of-electrical-and-electronics-engineers")

  // Logos
  let institucion-logo = if opts.institucion == "unlp" {
    image("images/unlp.svg", height: 100%)
  } else {
    opts.institucion
  }
  let unidad-academica-logo = if opts.unidad-academica == "informática" {
    image("images/informática.png", height: 100%)
  } else if opts.unidad-academica == "ingeniería" {
    image("images/ingeniería.png", height: 100%)
  } else {
    opts.unidad-academica
  }

  // Carátula
  align(center)[
    #set par(spacing: 0pt)
    #v(-margen-top + 0.5cm)
    #block(
      height: 1.4cm,
      stack(
        dir: ltr,
        spacing: 1fr,
        align(horizon, unidad-academica-logo),
        align(horizon, institucion-logo),
      ),
    )
    #v(1em)
    #text(size: 14pt, smallcaps(opts.asignatura))
    #if opts.titulo != none {
      v(1em)
      text(size: 12pt, opts.titulo)
    }
    #v(1.5em)
    #par(
      leading: 0.4em,
      text(weight: "bold", size: 17pt, opts.titulo-descriptivo),
    )
    #v(1.5em)
    #if opts.equipo != none [
      #set text(size: 12pt)
      #underline(opts.equipo) \
    ]
    #for a in opts.autores [
      #set text(size: 12pt)
      #let refs = ()
      #if a.email != none {
        refs.push(
          numbering(
            emails-numering,
            emails.keys().position(it => it == a.email.domain) + 1,
          ),
        )
      }
      #if a.notas.len() > 0 {
        for n in a.notas {
          refs.push(
            numbering(
              notas-numering,
              notas.position(it => it == n) + 1,
            ),
          )
        }
      }
      #(a.apellido), #(a.nombre)#super(refs.join(""))
      #if a.legajo != none {
        text(size: 0.8em)[(#a.legajo)]
      } \
    ]
    #v(1em)
    #text(size: 11pt, opts.fecha.display("[day]/[month]/[year]"))
    #if emails.len() > 0 or notas.len() > 0 {
      set text(size: 10pt)
      v(2em)
      for (i, (domain, users)) in emails.pairs().enumerate() [
        #let options = users.join(",")
        #if users.len() > 1 {
          options = "{" + options + "}"
        }
        #super(numbering(emails-numering, i + 1))#raw(options + "@" + domain) \
      ]
      for (i, nota) in notas.enumerate() [
        #super(numbering(notas-numering, i + 1))#nota \
      ]
    }
  ]
  if opts.resumen != none {
    v(0.5cm)
    text(size: 10pt, opts.resumen)
  }
  v(0.5cm)
  line(length: 100%, stroke: 0.5pt)
  v(0.5cm)

  // Contenido del informe
  body
}

// Comienzo del apéndice
#let apendice(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1.")
  set text(size: 10pt)
  body
}


// Nomenclatura / símbolos
#let nomenclatura(..pairs) = {
  heading(level: 2, numbering: none)[Nomenclatura]
  pad(left: 3em)[
    #table(
      align: (center, left),
      columns: (auto, 1fr),
      column-gutter: 1em,
      inset: 5pt,
      stroke: none,
      ..pairs
        .pos()
        .map(sym => (
          [#sym.at(0)],
          [#sym.at(1)],
        ))
        .flatten(),
    )
  ]
}

