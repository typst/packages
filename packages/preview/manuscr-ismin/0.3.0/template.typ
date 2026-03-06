// fonctions
#let violet-emse = rgb("#5F259F")
#let gray-emse = rgb("#5C6670")
#let blue-imt = rgb("#00B8DE")
#let lining(it) = text(number-type: "lining", it)
#let arcosh = math.op(limits: false, "arcosh")

#let conf-data = yaml("template/conf.yaml")

#let body-font = conf-data.fonts.body.font
#let body-options = conf-data.fonts.body.options
#let code-font = conf-data.fonts.code.font
#let code-options = conf-data.fonts.code.options
#let math-font = conf-data.fonts.math.font
#let math-options = conf-data.fonts.math.options
#let mono-font = conf-data.fonts.mono.font
#let mono-options = conf-data.fonts.mono.options
#let sans-font = conf-data.fonts.sans.font
#let sans-options = conf-data.fonts.sans.options

#let mono(it) = text(font: mono-font, number-type: "lining", features: mono-options, it)
#let sans(it) = text(font: sans-font, features: sans-options, it)

#let main-colour = conf-data.main-colour
#let other-colour = conf-data.other-colour

#let primary-colour = rgb(main-colour)
#let other-colour = rgb(other-colour)
#let block-colour = primary-colour.lighten(90%)
#let body-colour = primary-colour.lighten(80%)
#let header-colour = primary-colour.lighten(65%)
#let fill-colour = primary-colour.lighten(50%)

// template
#let manuscr-ismin(
  school: (),
  title: "",
  subtitle: "",
  course: (),
  supervisors: (),
  authors: (),
  mentor1: (),
  mentor2: (),
  logo: image("template/assets/MSE-IMT_Hor_RVB.svg", width: 7.3cm),
  date: "",
  academic-year: "",
  header: "",
  show-imt-triangle: true,
  body,
) = {
  let count = authors.len()
  let ncols = calc.min(count, 3)

  set document(title: title)

  set text(lang: "fr")

  set page(margin: 1.75in)

  // police de texte
  set text(font: body-font, features: body-options)

  // titres
  show heading: set text(fill: primary-colour)
  show heading: set block(above: 1.4em, below: 1em)

  // page de garde
  set page(margin: 0%)

  place(left, rect(fill: primary-colour, height: 100%))
  if show-imt-triangle { place(top + right, dx: 1cm, dy: -1cm, rotate(45deg, square(fill: other-colour, height: 2cm))) }

  place(top + right, dx: -2cm, dy: 2cm, logo)
  v(4cm)
  align(right + horizon)[
    #box(width: 70%, height: 70%)[
      #set align(center)
      #h(1fr)
      #box[
        #set align(right)
        #set text(size: 9pt)
        #if school.name != "" {
          upper(school.name)
        }
        #v(-.1cm)
        #if school.subname != "" {
          upper(school.subname)
        }
      ]

      #v(.2fr)

      #box[
        #set align(left)
        #if course.ue != "" or course.ecue != "" {
          grid(
            rows: 2,
            columns: 2,
            row-gutter: .3cm,
            column-gutter: .3cm,
            align: (x, y) => if x == 0 { right } else { left },
            [#course.ue :], [#if course.name != "" { course.name }],
            [#course.ecue :], [#if course.subname != "" { course.subname }],
          )
        }
      ]
      #h(1fr)

      #v(.2fr)

      #box(width: 60%)[
        #set align(left)
        #text(size: 22pt, weight: "bold", title)
        #v(-.4cm)
        #text(size: 18pt, subtitle)
        #set align(bottom + center)
        #line(length: 13%, stroke: (5pt + violet-emse))
      ]
      #h(2cm)

      #v(.2fr)

      #grid(
        columns: (1fr,) * ncols,
        row-gutter: 24pt,
        ..authors.map(author => [
          #author.name \
          #if author.affiliation != "" { author.affiliation } \
          #if author.email != "" { link("mailto:" + author.email, mono(author.email)) }
        ]),
      )

      #v(1fr)
      #grid(
        columns: 2,
        row-gutter: .3cm,
        column-gutter: .3cm,
        align: (x, y) => if x == 0 { right } else { left },
        [#if mentor1.role != "" [ #mentor1.role :]],
        if mentor1.email != "" and mentor1.name != "" {
          link("mailto:" + mentor1.email)[#mentor1.name]
        } else if mentor1.name != "" [name],

        [#if mentor2.role != "" [ #mentor2.role :]],
        if mentor2.email != "" and mentor2.name != "" {
          link("mailto:" + mentor2.email)[#mentor2.name]
        } else if mentor2.name != "" [#mentor2.name],

        [], [],
        [#if academic-year != "" [Année scolaire :]], [#if academic-year != "" { academic-year }],
        [#if date != "" [Date :]], [#if date != "" { date }],
      )
    ]
    #h(2cm)
  ]

  pagebreak()

  // table des matières
  set page(
    margin: auto,
    numbering: (n, ..) => [#n],
    number-align: center,
  )

  // Footer
  set page(footer: context {
    let i = counter(page).at(here()).first()

    let is-odd = calc.odd(i)
    let aln = if is-odd {
      right
    } else {
      left
    }

    let target = heading.where(level: 1)
    if query(target).any(it => it.location().page() == i) {
      return align(aln)[#i]
    }

    let before = query(target.before(here()))
    if before.len() > 0 {
      let current = before.last()
      let gap = 1.75em
      let chapter = smallcaps(lower(text(
        size: 0.68em,
        tracking: 0.5pt,
        fill: primary-colour,
        current.body,
      )))
      if is-odd {
        align(aln)[#chapter #h(gap) #text(number-type: "lining")[#i]]
      } else {
        align(aln)[#text(number-type: "lining")[#i] #h(gap) #chapter]
      }
    }
  })

  // contenu
  set page(header: [
    #text(size: 9pt)[
      #set align(right)
      #header
      #line(length: 100%, stroke: 0.4pt + black)
    ]
  ])

  // réglage des titres
  set heading(numbering: (..n) => text(number-type: "lining", numbering("1.1. ", ..n)))
  show heading: set text(fill: primary-colour)
  show heading: set block(above: 1.4em, below: 1em)

  // l'affichage des listes
  set enum(
    indent: 1em,
    numbering: n => [#text(fill: rgb(main-colour), numbering("1.", n))],
  )

  set list(
    indent: 1em,
    marker: ([#text(fill: primary-colour)[--]], [#text(fill: primary-colour)[•]], [#text(fill: primary-colour)[‣]]),
  )

  // réglages paragraphes
  set par(
    leading: 0.55em,
    spacing: 1em,
    first-line-indent: (all: true, amount: 1.8em),
    justify: true,
  )

  // le séparateur dans la légende des figures
  set figure.caption(separator: [ : ])

  show figure.caption: it => [
    #smallcaps[
      #it.supplement #context it.counter.display(it.numbering)
    ]
    #it.separator
    #it.body
  ]

  // permet de casser l'affichage des figures
  show figure: set block(breakable: false)

  // on règle l'affichage du code
  show raw: it => {
    text(
      font: code-font,
      features: code-options,
      it,
    ) // police pour les blocs de texte brut
  }

  // on règle l'affichage des blocs de code
  show raw.where(block: true): block.with(
    fill: block-colour,
    radius: 0.5em,
    inset: 1em,
    stroke: 0.1pt,
    width: 100%,
  )

  // on règle l'affichage du code en ligne
  show raw.where(block: false): box.with(
    fill: block-colour,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 3pt,
  )

  // on règle l'affichage des équations en ligne
  show math.equation: set text(font: math-font, features: math-options)

  // on règle l'affichage des blocs d'équation
  show math.equation: it => {
    show regex("\d+\.\d+"): it => {
      show ".": { "," + h(0pt) }
      it
    }
    it
  } // permet d'utiliser les virgules comme séparateur décimal

  // on règle l'affichage des liens
  show link: it => {
    if type(it.dest) == str {
      text[
        #it#super(
          typographic: false,
          size: 0.75em,
          text(fill: blue, sym.circle.small),
        )
      ]
    } else {
      text[
        #it#super(
          typographic: false,
          size: 0.75em,
          text(fill: fill-colour, sym.square),
        )
      ]
    }
  }

  // bloc de citation
  show quote.where(block: true): it => {
    v(-5pt)
    block(
      fill: block-colour,
      inset: 5pt,
      radius: 1pt,
      stroke: (left: 3pt + fill-colour),
      width: 100%,
      outset: (left: -5pt, right: -5pt, top: 5pt, bottom: 5pt),
    )[#it]
    v(-5pt)
  }

  // tableaux
  show table: set table(
    stroke: 0.6pt + primary-colour,
    fill: (x, y) => if y == 0 {
      body-colour
    } else if calc.even(y) {
      block-colour
    } else {
      none
    },
    inset: (x: 0.4em, y: 0.4em),
  )
  show table.cell.where(y: 0): set text(
    style: "normal",
    weight: "bold",
  )
  show table: set text(number-type: "lining")

  // on règle l'affichage des équations en ligne
  show math.equation: set text(font: math-font)

  // réglages figures
  show figure: set block(breakable: true)
  show figure.where(kind: table): set figure(supplement: [Tabl.])
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.where(kind: raw): set figure(supplement: [List.])
  show figure.where(kind: raw): set align(left)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.caption.where(kind: raw): set align(center)

  show figure.where(kind: "equation"): set figure(supplement: [Équ.])

  body
}
