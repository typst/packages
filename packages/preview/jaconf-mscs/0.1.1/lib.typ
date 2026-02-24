#let font-size-default = 10pt
#let font-size-heading = 11pt
#let spacing-size-heading = 12pt
#let appendix-numbering = "A.1"
#let state-font-gothic = state("gothic", (:))

// import third-party packages
#import "@preview/codly:1.3.0": codly-init
#import "@preview/ctheorems:1.1.3": thmplain, thmproof, thmrules

// Theorem environments
#let thmja = thmplain.with(base: {}, separator: [#h(0.5em)], titlefmt: strong, inset: (top: 0em, left: 0em))
#let definition = thmja("definition", context{text(font: state-font-gothic.get())[定義]})
#let lemma = thmja("lemma", context{text(font: state-font-gothic.get())[補題]})
#let theorem = thmja("theorem", context{text(font: state-font-gothic.get())[定理]})
#let corollary = thmja("corollary", context{text(font: state-font-gothic.get())[系]})
#let proof = thmproof("proof", context{text(font: state-font-gothic.get())[証明]}, separator: [#h(0.9em)], titlefmt: strong, inset: (top: 0em, left: 0em))

#let jaconf(
  title-ja: [日本語タイトル],
  title-en: [],
  authors-ja: [著者],
  authors-en: [],
  abstract: none,
  keywords: (),
  font-gothic: "Noto Sans CJK JP",
  font-mincho: "Noto Serif CJK JP",
  font-latin: "New Computer Modern",
  body
) = {
  // Set the font for headings.
  state-font-gothic.update(font-gothic)

  // Enable packages.
  show: thmrules.with(qed-symbol: $square$)
  show: codly-init.with()

  // Set document metadata.
  set document(title: title-ja)

  // Configure the page.
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 27mm, x: 20mm)
  )
  set text(font-size-default, font: font-mincho)
  set par(leading: 0.5em, first-line-indent: 1em, justify: true, spacing: 0.6em)
  show "、": "，"
  show "。": "．"

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.55em)

  // Configure appearance of references
  show ref: it => {
    // Equation -> (n).
    // See https://typst.app/docs/reference/model/ref/
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      link(el.location(), numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      ))
    }
    // Sections -> n章m節l項.
    // Appendix -> 付録A.
    else if el != none and el.func() == heading {
      let sec-cnt = counter(heading).at(el.location())
      if el.numbering != appendix-numbering{
        if el.depth == 1 {
          link(el.location(), [#sec-cnt.at(0)章])
        } else if el.depth == 2{
          link(el.location(), [#sec-cnt.at(0)章#sec-cnt.at(1)節])
        } else if el.depth == 3{
          link(el.location(), [#sec-cnt.at(0)章#sec-cnt.at(1)節#sec-cnt.at(2)項])
        }
      } else {
        link(el.location(), [
          付録#numbering(el.numbering, ..sec-cnt)
        ])
      }
    } else {
      it
    }
  }

  // Configure lists.
  set enum(indent: 1em)
  set list(indent: 1em)

  // Configure headings.
  set heading(numbering: "1.1")
  show heading: it => {
    set par(first-line-indent: 0em, spacing: spacing-size-heading)
    let levels = counter(heading).get()
    if it.level == 1 {
      set text(font-size-heading, font: font-gothic)
      // Acknowledgment sections are not numbered.
      if it.numbering != none and not it.body in ([謝辞], [Acknowledgment], [Acknowledgement]) {
        numbering(it.numbering, ..levels)
        h(1em)
      }
      it.body
    } else {
      set text(font-size-default, font: font-gothic)
      if it.numbering != none {
        numbering(it.numbering, ..levels)
        h(1em)
      }
      it.body
    }
  }

  // Configure figures.
  show figure.where(kind: table): set figure(placement: top, supplement: [Table])
  show figure.where(kind: table): set figure.caption(position: top, separator: [: ])
  show figure.where(kind: image): set figure(placement: top, supplement: [Fig.])
  show figure.where(kind: image): set figure.caption(position: bottom, separator: [: ])

  // Display the paper's title.
  align(center, text(16pt, title-ja, weight: "bold", font: font-gothic))
  v(18pt, weak: true)

  // Display the authors list.
  align(center, text(12pt, authors-ja, font: font-mincho))
  v(1.5em, weak: true)

  // Display the paper's title in English.
  align(center, text(12pt, title-en, weight: "bold", font: font-latin))
  v(1.5em, weak: true)

  // Display the authors list in English.
  align(center, text(12pt, authors-en, font: font-latin))
  v(1.5em, weak: true)

  // Display abstract and index terms.
  if abstract != none {
    grid(
      columns: (0.7cm, 1fr, 0.7cm),
      [],
      [
        #set text(10pt, font: font-latin)
        #set par(first-line-indent: 0em)
        *Abstract--* #h(0.5em) #abstract
        #v(1em)
        *Key Words:* #h(0.5em) #keywords.join(", ")
      ],
      []
    )
    v(1em, weak: false)
  }

  // Start two column mode and configure paragraph properties.
  show: columns.with(2)

  // Configure Bibliography.
  set bibliography(title: text(font-size-heading)[参考文献], style: "sice.csl")
  show bibliography: it => [
    #set text(9pt, font: font-mincho)
    #show regex("[0-9a-zA-Z]"): set text(font: font-latin)
    #it
  ]

  // Display the paper's contents.
  body
}

// Appendix
#let appendix(body) = {
  set heading(numbering: appendix-numbering)
  counter(heading).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  set figure(numbering: it => {
    [#numbering("A", counter(heading).get().at(0)).#it]
  })
  v(spacing-size-heading)
  context(text(font-size-heading, font: state-font-gothic.get(), weight: "bold")[付録])
  body
}
