#import "./utils/fecha.typ": fecha_str
#import "./utils/math.typ": sty-math

#let doc-tesis(
  titulo: none,
  asesor: none,
  co-asesor: none,
  fecha: none,
  autores: (),
  titulo-documento: [TESIS],
  /// school specific
  titulo-academico-label: [Para optar al título profesional de],
  titulo-academico: [Ingeniero Informático y de Sistemas],
  facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  escuela: [Ingeniería Informática y de Sistemas],
  ///
  duplex: false,
  binding-margin: 0%,
  doc,
) = {
  let margin = 2.54cm
  let margins = if duplex {
    (
      inside: margin + binding-margin,
      outside: margin - binding-margin,
    )
  } else {
    (
      left: margin + binding-margin,
    )
  }

  //================================ {General} =================================
  set page(
    paper: "a4",
    margin: (
      ..margins,
      rest: margin,
    ),
    // header: align(right + horizon)[
    //   _ #titulo _
    // ],
    // numbering: "1",
  )
  set text(
    font: "TeX Gyre Termes",
    spacing: 0.35em,
    lang: "es",
    region: "pe",
  )
  set text(size: 12pt)
  set document()

  //=============================== {Overrides} ================================
  let _THM_KINDS = ("definicion", "teorema", "corolario")
  show outline.entry: it => {
    /// INSPIRED BY: https://typst.app/universe/package/outrageous
    let repeat(gap: none, body) = layout(size => context {
      let width = measure(body).width
      let count = calc.floor((size.width + gap) / (width + gap))
      ((box(body),) * count).intersperse(h(gap)).join()
    })

    let fill_dots = repeat(gap: 6pt)[.]
    let el = it.element

    let (prefix, body, fill, page) = if el.func() == heading {
      if el.level == 1 {
        (it.prefix(), strong(upper(el.body)), h(1fr), strong(upper(it.page())))
      } else {
        (it.prefix(), it.body(), box(width: 1fr, fill_dots), sym.wj + it.page())
      }
    } else if (el.func() == figure and (el.kind == table or el.kind == image)) {
      let num_str = context numbering(
        el.numbering,
        ..counter(figure.where(kind: el.kind)).at(el.location()),
      )
      (
        strong([#el.caption.supplement #num_str]),
        el.caption.body,
        box(width: 1fr, fill_dots),
        sym.wj + it.page(),
      )
    } else if el.func() == math.equation {
      let metas = query(<eq-tag>).filter(m => m.value != "")
      let ep = el.location().position()
      let matched = metas.filter(m => {
        let mp = m.location().position()
        mp.page == ep.page and mp.y >= ep.y
      })
      let tag = if matched.len() > 0 { matched.first().value } else { "?" }
      (
        strong(el.supplement),
        strong(tag),
        box(width: 1fr, fill_dots),
        sym.wj + it.page(),
      )
    } else if el.func() == figure and el.kind in _THM_KINDS {
      let metas = query(<thm-tag>).filter(m => m.value != "")
      let ep = el.location().position()
      let matched = metas.filter(m => {
        let mp = m.location().position()
        mp.page == ep.page and mp.y >= ep.y
      })
      let tag = if matched.len() > 0 { matched.first().value } else { "?" }
      (
        strong(el.supplement),
        strong(tag),
        box(width: 1fr, fill_dots),
        sym.wj + it.page(),
      )
    } else {
      (
        strong(it.prefix()),
        it.body(),
        box(width: 1fr, fill_dots),
        sym.wj + it.page(),
      )
    }

    link(el.location(), it.indented(prefix, [#body #fill #page]))
  }

  show heading.where(level: 2): set block(above: 2.5em, below: 2.0em)
  show heading.where(level: 3): set block(above: 2em, below: 1.5em)
  show heading.where(level: 3): it => text(
    weight: "bold",
    style: "italic",
    it,
  )

  set list(indent: 1.2em, spacing: 2.4em)
  set enum(indent: 1.2em, spacing: 2.4em)
  show table.cell: it => {
    set par(
      justify: false,
      first-line-indent: 1em,
      leading: 0.65em,
      spacing: 1em,
    )
    set list(indent: 0.5em, spacing: 0.6em)
    set enum(indent: 0.5em, spacing: 0.6em)
    it
  }

  /// TODO: https://github.com/typst/typst/issues/905
  set enum(
    full: true,
    numbering: (..args) => {
      let nums = args.pos()
      let style_per_level = ("1.", "a)", "(i)")
      numbering(
        style_per_level.at(nums.len() - 1, default: "1."),
        nums.at(nums.len() - 1),
      )
    },
  )

  show figure: it => [
    #align(left)[#it.caption]
    #it.body
  ]
  show figure.caption: it => {
    set align(left)
    set par(justify: false, first-line-indent: 0em, leading: 0.65em)
    block(width: 100%)[
      #text(weight: "bold", style: "italic")[
        #it.supplement #context it.counter.display(it.numbering)
      ] \
      #emph(it.body)
    ]
  }

  set table(
    stroke: (_, y) => (
      top: if y < 2 { 1pt } else { none },
      bottom: 0.5pt,
      left: none,
      right: none,
    ),
  )
  show table: it => block(stroke: (bottom: 1pt), inset: 0pt, it)

  //================================ {Caratula} ================================
  page(
    margin: (
      rest: margin,
    ),
  )[
    #place(
      float: true,
      auto,
      scope: "parent",
      clearance: 2em,
    )[
      #set par(first-line-indent: 0em)

      #block(height: 8.35cm)[
        #image("imgs/unsaac_logo.png"),
      ]

      #text(1.23em, upper[
        Universidad Nacional de San Antonio Abad Del Cusco
      ])

      #v(1fr)

      #text(1.23em)[
        #titulo-documento

        #line(length: 100%, stroke: 2.5pt)
        #smallcaps([*#titulo*])
        #line(length: 100%, stroke: 2.5pt)
      ]

      #v(1.5fr)
      #text(1.1em)[
        #set par(justify: false)

        #grid(
          columns: 1,
          row-gutter: 1.2em,
          align: left,
          [
            #titulo-academico-label: \
            #h(1em) #smallcaps(titulo-academico) \
          ],
          [
            Presentado Por: \
            #for autor in autores [
              #h(1em) #smallcaps(autor) \
            ]
          ],
          if asesor != none [
            Asesor: \
            #h(1em) #smallcaps(asesor) \
          ],
          if co-asesor != none [
            Co-Asesor: \
            #h(1em) #smallcaps(co-asesor) \
          ],
        )
      ]

      #v(2fr)
      #[
        #text(1.1em, [
          Perú,
          #if fecha != none [
            fecha
          ] else [
            #fecha_str(datetime.today())
          ]
        ])

        #v(0.35em)

        #text(0.91em, upper[
          Escuela Profesional de #escuela
        ])

        #text(0.78em, upper[
          Facultad de #facultad
        ])
      ]
    ]
  ]
  pagebreak(weak: true)

  set heading(numbering: "1.")
  set par(
    first-line-indent: 1.5em,
    spacing: 2em,
    leading: 0.71cm,
    justify: true,
  )
  show: sty-math

  doc
}

#let sty-tesis-pre(doc) = {
  counter(page).update(2)
  set page(numbering: "I")
  show heading.where(level: 1): set heading(numbering: none)
  show heading.where(level: 1): it => {
    set align(center)
    colbreak(weak: true)
    upper(it.body)
  }
  doc
}

#let sty-tesis-base(doc) = {
  counter(page).update(1)
  counter(heading).update(0)
  set page(numbering: "1")
  set heading(numbering: "1.")
  show heading.where(level: 1): set heading(numbering: "1")
  show heading.where(level: 1): it => [
    #set align(center)
    #colbreak(weak: true)
    #upper([
      Capítulo #counter(heading).display("I") \
      #it.body
    ])
  ]
  doc
}

#let sty-tesis-post(doc) = {
  show heading.where(level: 1): set heading(numbering: none)
  show heading.where(level: 1): it => {
    set align(center)
    colbreak(weak: true)
    upper(it.body)
  }
  doc
}

#let sty-tesis-anexos(doc) = {
  counter(heading).update(0)
  set table(stroke: 0.5pt)
  show table: it => it
  show heading.where(level: 1): set heading(numbering: none)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    page(
      header: none,
      footer: none,
      numbering: none,
    )[
      #set align(center + horizon)
      #text(size: 1.5em, weight: "bold")[#upper(it.body)]
    ]
  }
  show heading.where(level: 2): set heading(
    numbering: (..nums) => {
      let nums = nums.pos()
      numbering("A", nums.last())
    },
  )
  doc
}
