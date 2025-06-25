// import third-party packages
#import "@preview/codly:1.3.0": codly-init
#import "@preview/ctheorems:1.1.3": thmplain, thmproof, thmrules
#import "@preview/cjk-unbreak:0.1.1": remove-cjk-break-space

// Theorem environments
#let thmja = thmplain.with(base: {}, separator: [#h(0.5em)], titlefmt: strong, inset: (top: 0em, left: 0em))
#let definition = thmja("definition", context{text(font: query(<heading-font>).first().value)[定義]})
#let lemma = thmja("lemma", context{text(font: query(<heading-font>).first().value)[補題]})
#let theorem = thmja("theorem", context{text(font: query(<heading-font>).first().value)[定理]})
#let corollary = thmja("corollary", context{text(font: query(<heading-font>).first().value)[系]})
#let proof = thmproof("proof", context{text(font: query(<heading-font>).first().value)[証明]}, separator: [#h(0.9em)], titlefmt: strong, inset: (top: 0em, left: 0em))

#let jaconf(
  // 基本 Basic
  title-ja: [日本語タイトル],
  title-en: [],
  authors-ja: [著者],
  authors-en: [],
  abstract: none,
  keywords: (),
  // フォント名 Font family
  font-heading: "Noto Sans CJK JP",  // サンセリフ体、ゴシック体などの指定を推奨
  font-main: "Noto Serif CJK JP",  // セリフ体、明朝体などの指定を推奨
  font-latin: "New Computer Modern",
  font-math: "New Computer Modern Math",
  // 外観 Appearance
  paper-columns: 2,  // 1: single column, 2: double column
  page-number: none,  // e.g. "1/1"
  paper-margin: (top: 20mm, bottom: 27mm, left: 20mm, right: 20mm),
  column-gutter: 4%+0pt,
  spacing-heading: 1.2em,
  bibliography-style: "sice.csl",  // "rsj-conf.csl", "rengo.csl", "sci.csl", "ieee"
  abstract-language: "en",  // "ja" or "en"
  // 見出し Headings
  heading-abstract: [*Abstract--*],
  heading-keywords: [*Keywords*: ],
  heading-bibliography: [参　考　文　献],
  heading-appendix: [付　録],
  // フォントサイズ Font size
  font-size-title-ja: 16pt,
  font-size-title-en: 12pt,
  font-size-authors-ja: 12pt,
  font-size-authors-en: 12pt,
  font-size-abstract: 10pt,
  font-size-heading: 11pt,
  font-size-main: 10pt,
  font-size-bibliography: 9pt,
  // 補足語 Supplement
  supplement-image: [図],
  supplement-table: [表],
  supplement-separator: [: ],
  // 番号付け Numbering
  numbering-headings: "1.1",
  numbering-equation: "(1)",
  numbering-appendix: "A.1",  // #show: appendix.with(numbering-appendix: "A.1") の呼び出しにも同じ引数を与えてください。
  // main text
  body
) = {
  // Set metadata.
  [#metadata(font-heading) <heading-font>]
  [#metadata(heading-appendix) <appendix-heading>]

  // Enable packages.
  show: thmrules.with(qed-symbol: $square$)
  show: codly-init.with()

  // Set document metadata.
  set document(title: title-ja)

  // Configure the page.
  set page(
    paper: "a4",
    margin: paper-margin,
    numbering: page-number
  )
  set text(font-size-main, font: font-main, lang: "ja")
  set par(leading: 0.5em, justify: true, spacing: 0.6em, first-line-indent: (amount: 1em, all: true))

  // Configure equations.
  set math.equation(numbering: numbering-equation)
  show math.equation: it => {
    set text(font: font-math)
    it
  }

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
      if el.numbering != numbering-appendix {
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
  set heading(numbering: numbering-headings)
  show heading: set block(spacing: spacing-heading)
  show heading.where(level: 1): set text( size: font-size-heading, font: font-heading, weight: "bold", spacing: 100%)
  show heading.where(level: 2): set text( size: font-size-main, font: font-heading, weight: "bold")
  show heading.where(level: 3): set text( size: font-size-main, font: font-heading, weight: "bold")

  // Configure figures.
  show figure.where(kind: table): set figure(placement: top, supplement: supplement-table)
  show figure.where(kind: table): set figure.caption(position: top, separator: supplement-separator)
  show figure.where(kind: image): set figure(placement: top, supplement: supplement-image)
  show figure.where(kind: image): set figure.caption(position: bottom, separator: supplement-separator)

  // Display the paper's title.
  align(center, text(font-size-title-ja, title-ja, weight: "bold", font: font-heading))
  v(18pt, weak: true)

  // Display the authors list.
  align(center, text(font-size-authors-ja, authors-ja, font: font-main))
  v(1.5em, weak: true)

  // Display the paper's title in English.
  align(center, text(font-size-title-en, title-en, weight: "bold", font: font-latin))
  v(1.5em, weak: true)

  // Display the authors list in English.
  align(center, text(font-size-authors-en, authors-en, font: font-latin))
  v(1.5em, weak: true)

  // Display abstract and index terms.
  if abstract != none {
    grid(
      columns: (0.7cm, 1fr, 0.7cm),
      [],
      {
        set text(
          font-size-abstract,
          font: if abstract-language == "ja" { font-main }
            else { font-latin }
        )
        set par(first-line-indent: 0em)
        [
          #show: remove-cjk-break-space
          #heading-abstract #h(0.5em) #abstract
        ]
        if keywords != () {
          [#v(1em) #heading-keywords #h(0.5em) #keywords.join(", ")]
        }
      },
      []
    )
    v(1em, weak: false)
  }

  // Start two column mode and configure paragraph properties.
  show: columns.with(paper-columns, gutter: column-gutter)

  // Configure Bibliography.
  set bibliography(title: text(size: font-size-heading, heading-bibliography), style: bibliography-style)
  show bibliography: set text(9pt, font: font-main, lang: "en")
  show bibliography: it => {
    show regex("[0-9a-zA-Z]"): set text(font: font-latin)
    it
  }

  // Display the paper's contents.
  show: remove-cjk-break-space
  body
}

// Appendix
#let appendix(numbering-appendix: "A.1", body) = {
  counter(heading).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  // numbering expects string or function, not accepts content.
  // For this reason, numbering-appendix is set as an argument.
  set heading(numbering: numbering-appendix)
  set figure(numbering: it => {
    [#numbering(numbering-appendix, counter(heading).get().at(0)).#it]
  })
  context{
    heading(
      numbering: none,
      query(<appendix-heading>).first().value
    )
  }
  body
}
