#import "cover-bg.typ": cover-bg
#import "abstracts-bg.typ": abstracts-bg
#import "utils.typ": balanced-cols

#let school-color-recto = blue
#let school-color-verso = rgb("0054a0")

#let cover(
  title-en: "",
  title-fr: "",
  author: "",
  affiliation: "",
  defense-place: "",
  defense-date: "",
  jury-content: [],
) = {
  set page(
    margin: (left: 20mm, right: 25mm, top: 30mm, bottom: 30mm),
    numbering: none,
  )
  set text(font: "TeX Gyre Heros", fill: black)

  place(dx: -20mm, dy: 30mm, cover-bg(school-color-recto))
  place(dx: 100mm, dy: -15mm, image("/assets/UR.png", width: 6cm))
  place(dx: 0mm, dy: -15mm, image("/assets/logo.png", width: 7.5cm))

  v(2.1cm)
  text(size: 2em, smallcaps[Thèse de doctorat de])
  v(2.25cm)

  set text(fill: white)
  text(size: 1.5em, smallcaps[l'Université de Rennes])
  v(.01cm)
  text(size: 1.2em)[
    #smallcaps[École Doctorale N° 601] \
    _Mathématiques, Télécommunications, Informatique, \
    Signal, Systèmes, Électronique_ \
    Spécialité : Informatique \
    #v(.1cm) #h(.6cm) Par \
  ]
  v(0em)
  h(.6cm)
  text(size: 1.9em)[*#author* \ ]
  v(.1cm)

  // Add a blue background with the width of the page
  context {
    let y-start = locate(<cover:title-en>).position().y - .5cm
    let y-end = locate(<cover:defense-info>).position().y + measure(query(<cover:defense-info>).first()).height + .5cm
    let height = 5em

    place(
      top + left,
      dy: y-start - page.margin.top,
      dx: -page.margin.left,
      float: false,
      block(width: page.width, height: y-end - y-start, fill: school-color-recto),
    )
  }

  // Title + defense info block
  text(size: 1.6em)[*#title-en*<cover:title-en>]
  parbreak()
  text(size: 1.4em, title-fr)
  parbreak()

  text(size: 1.1em)[
    *Thèse présentée et soutenue à #defense-place, le #defense-date* \
    *Unité de recherche : #affiliation*
    <cover:defense-info>
  ]


  set text(fill: black)

  v(.5em)
  jury-content
}

#let abstracts(
  title-fr: "",
  keywords-fr: "",
  abstract-fr: [],
  title-en: "",
  keywords-en: "",
  abstract-en: [],
) = {
  set page(
    margin: (left: 20mm, right: 30mm, top: 30mm, bottom: 30mm),
    numbering: none,
    header: none,
  )
  set text(font: "TeX Gyre Heros", fill: black)

  pagebreak()
  pagebreak()

  place(dx: -20mm, dy: -65mm, abstracts-bg(school-color-verso))
  place(dx: 100mm, dy: -15mm, image("/assets/UR.png", width: 6cm))
  place(dx: 0mm, dy: -15mm, image("/assets/logo.png", width: 7.5cm))

  v(2.7cm)
  line(length: 100%, stroke: .2cm + school-color-verso)
  v(.4cm)

  [
    #text(school-color-verso)[*Titre :*] #title-fr

    *Mots clés :* #keywords-fr
  ]

  balanced-cols(2, gutter: 11pt)[*Résumé :* #abstract-fr]

  v(1cm)
  line(length: 100%, stroke: .2cm + school-color-verso)
  v(.4cm)

  [
    #text(school-color-verso)[*Title:*] #title-en

    *Keywords:* #keywords-en
  ]

  balanced-cols(2, gutter: 11pt)[*Abstract:* #abstract-en]
}

#let matisse-thesis(
  jury-content: [],
  author: "",
  affiliation: "",
  title-en: "",
  title-fr: "",
  keywords-fr: "",
  keywords-en: "",
  abstract-en: [],
  abstract-fr: [],
  acknowledgements: [],
  defense-place: "",
  defense-date: "",
  draft: true,
  body,
) = {
  let draft-string = ""
  if draft {
    draft-string = "DRAFT - "
  }

  set document(author: author, title: draft-string + title-en)
  set heading(numbering: "1.")
  set page(
    "a4",
    numbering: (..numbers) => text(
      font: "New Computer Modern",
      size: 4.5mm,
      numbering("1", numbers.pos().at(0)),
    ),
    number-align: center,
  )
  set par(justify: true)

  cover(
    title-en: draft-string + title-en,
    title-fr: draft-string + title-fr,
    author: author,
    affiliation: affiliation,
    defense-place: defense-place,
    defense-date: defense-date,
    jury-content: jury-content,
  )

  set text(font: "New Computer Modern", fill: black)

  set page(
    margin: (outside: 20mm, inside: 30mm, top: 50mm, bottom: 50mm),
    header: context {
      // get the page number
      let i = counter(page).get().first()

      // if the page starts a chapter, display nothing
      let all-chapters = query(heading.where(level: 1))
      if all-chapters.any(it => it.location().page() == i) {
        return
      }

      // if the page is odd, display the chapter
      if calc.odd(i) {
        let chapter-stack = query(
          selector(heading.where(level: 1)).before(here()),
        )
        if chapter-stack != () {
          let last-chapter = chapter-stack.last()
          let title = last-chapter.body
          let nb = counter(heading).at(last-chapter.location()).first()
          text(0.35cm)[Chapter #nb -- _ #title _]
          //chapter-stack.first()
        }
      }

      // if the page is even, display the section
      if calc.even(i) {
        let chapter-stack = query(
          selector(heading.where(level: 2)).before(here()),
        )
        if chapter-stack != () {
          let last-section = chapter-stack.last()
          let title = last-section.body
          let nb = counter(heading).at(last-section.location()).map(it => str(it)).join(".")
          align(right, text(0.35cm)[_ #nb. #title _])
          //chapter-stack.first()
        }
      }

      // horizontal rule
      v(-.3cm)
      line(length: 100%, stroke: .2mm)
    },
  )

  // chapters
  show heading.where(level: 1): it => {
    // always start on odd pages
    // pagebreak(to: "odd")
    // if chaptering is enabled, display chapter number
    set align(right)
    v(-.8cm)
    if it.numbering != none {
      context text(
        smallcaps[Chapter #counter(heading).get().first() \ ],
        size: .45cm,
        weight: "regular",
        font: "New Computer Modern",
      )
      v(0cm)
    }
    // chapter name
    text(smallcaps(it.body), font: "TeX Gyre Heros", size: .9cm)
    set align(left)
    // horizontal rule
    v(.7cm)
    line(length: 100%, stroke: .2mm)
    v(.7cm)
  }

  // table of contents
  show outline.entry.where(level: 1): it => {
    v(5mm, weak: true)
    strong(it)
  }

  // footnotes
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering(
      "1. ",
      ..counter(footnote).at(loc),
    )
    it.note.body
  }

  // show page number
  context counter(page).update(here().page())

  body

  abstracts(
    title-fr: title-fr,
    keywords-fr: keywords-fr,
    abstract-fr: abstract-fr,
    title-en: title-en,
    keywords-en: keywords-en,
    abstract-en: abstract-en,
  )
}