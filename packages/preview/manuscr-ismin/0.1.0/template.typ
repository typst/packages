// fonctions
#let violet-emse = rgb("#5f259f")
#let gray-emse = rgb("#5c6670")
#let lining(it) = text(number-type: "lining", it)
#let arcosh = math.op(limits: false, "arcosh")

// template
#let manuscr-ismin(
  title: "",
  subtitle: "",
  authors: (),
  date: "",
  logo: "",
  main-color: rgb(87,42,134),
  header-title: "",
  header-middle: "",
  header-subtitle: "",
  body-font: "Libertinus Serif",
  code-font: "Cascadia Mono",
  math-font: "New Computer Modern Math",
  mono-font: "Libertinus Mono",
  number-style: "old-style",
  body
) = {
  let primary-color = violet-emse
  let block-color = primary-color.lighten(90%)
  let body-color = primary-color.lighten(80%)
  let header-color = primary-color.lighten(65%)
  let fill-color = primary-color.lighten(50%)

  let count = authors.len()
  let ncols = calc.min(count, 3)

  set document(title: title)

  set text(lang: "fr")

  set page(margin: 1.75in)

    // police de texte
  set text(font: body-font, number-type: number-style)


  // titres
  show heading: set text(fill: primary-color)
  show heading: set block(above: 1.4em, below: 1em)

  // page de garde
  set page(margin: 0%)

  place(top + center,
    rect(width: 100%, fill: primary-color)[
      #v(2%)
      #align(center)[#image(logo, width: 50%)]
      #v(2%)
    ]
  )

  place(bottom + center, rect(width: 200%, fill: primary-color, [#v(3%)]))

  if date != "" {
    place(bottom + center, dy: -150pt, text(size: 18pt)[#date])
  }

  align(center + horizon)[
    #box(width: 70%)[
      #line(length: 100%)
      #v(15pt)
      #text(size: 25pt)[*#title*]
      #if subtitle != "" {
        linebreak()
        linebreak()
        text(size: 25pt)[#subtitle]
      }
      #v(15pt)
      #line(length: 100%)
      #v(20pt)
      #text(size: 17pt)[
        #table(
          align: center,
          stroke: none,
          column-gutter: 15pt,
          columns: (1fr,) * ncols,
          ..authors.map(author => [
            #if author.name != "" {
              strong(author.name); linebreak()
            }
            #if author.affiliation != "" and author.year != "" {
              author.affiliation; " "; author.year; linebreak()
            } else if author.affiliation != "" and author.year == "" {
              author.affiliation; linebreak()
            } else if author.affiliation == "" and author.year != "" {
              author.year; linebreak()
            }
            #if author.class != "" {
              emph(author.class)
            }
          ])
        )
      ]
    ]
  ]

  pagebreak()

  // table des matières
  set page(
    margin: auto,
    numbering: (n, ..) => [#text(number-type: "lining")[#n]],
    number-align: center
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
      return align(aln)[#text(number-type: "lining")[#i]]
    }

    let before = query(target.before(here()))
    if before.len() > 0 {
      let current = before.last()
      let gap = 1.75em
      let chapter = smallcaps(text(
        size: 0.68em,
        tracking: 0.5pt,
        fill: primary-color,
        current.body
      ))
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
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        rows: 1,
        header-title,
        [#text(weight: "bold", header-middle)],
        [#text(style: "italic", header-subtitle)]
      )
      #line(length: 100%, stroke: 0.4pt + black)
    ]
  ])

  // réglage des titres
  set heading(numbering: (..n) =>
    text(number-type: "lining", numbering("1.1  ", ..n))
  )
  show heading: set text(fill: primary-color)
  show heading: set block(above: 1.4em, below: 1em)

  // l'affichage des listes
  set enum(
    indent: 1em,
    numbering: n => [#text(fill: rgb(main-color), numbering("1.", n))]
  )

  set list(
    indent: 1em,
    marker: ([#text(fill: primary-color)[--]], [#text(fill: primary-color)[•]], [#text(fill: primary-color)[‣]])
  )

  // réglages paragraphes
  set par(
    leading: 0.55em,
    spacing: 1em,
    first-line-indent: (all: true, amount: 1.8em),
    justify: true
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
      it
    ) // police pour les blocs de texte brut
  }

  // on règle l'affichage des blocs de code
  show raw.where(block: true): block.with(
    fill: block-color,
    radius: 0.5em,
    inset: 1em,
    stroke: 0.1pt,
    width: 100%
  )

  // on règle l'affichage du code en ligne
  show raw.where(block: false): box.with(
    fill: block-color,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 3pt,
  )

  // on règle l'affichage des équations en ligne
  show math.equation: set text(font: "New Computer Modern Math")

  // on règle l'affichage des blocs d'équation
  show math.equation: it => {
    show regex("\d+\.\d+"): it => {
      show ".": {"," + h(0pt)}
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
          text(fill: blue, sym.circle.small)
        )
      ]
    } else {
      text[
        #it#super(
          typographic: false,
          size: 0.75em,
          text(fill: fill-color, sym.square)
        )
      ]
    }
  }

  // bloc de citation
  show quote.where(block: true): it => {
    v(-5pt)
    block(
      fill: block-color, inset: 5pt, radius: 1pt,
      stroke: (left: 3pt+fill-color), width: 100%,
      outset: (left:-5pt, right:-5pt, top: 5pt, bottom: 5pt)
      )[#it]
    v(-5pt)
  }

  // augmente l'espacement entre les lettres pour les smallcaps
  show smallcaps: set text(tracking: 0.5pt)

  // tableaux
  show table: set table(
    stroke: 0.6pt + primary-color,
    fill: (x, y) =>
      if y == 0 {
        body-color
      } else if calc.even(y) {
        block-color
      } else {
        none
      }
    ,
    inset: (x: 0.4em, y: 0.4em)
  )
  show table.cell.where(y: 0): set text(
    style: "normal", weight: "bold"
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

#let mono(it) = text(font: mono-font, number-type: "lining", it)
