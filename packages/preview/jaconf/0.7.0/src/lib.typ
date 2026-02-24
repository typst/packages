// import third-party packages
#import "@preview/codly:1.3.0": codly-init
#import "@preview/ctheorems:1.1.3": thmplain, thmproof, thmrules
#import "@preview/cjk-unbreak:0.2.2": remove-cjk-break-space

// Theorem environments
#let thmja = thmplain.with(base: {}, separator: [#h(0.5em)], titlefmt: strong, inset: (top: 0em, left: 0em))
#let definition = thmja("definition", context{text(font: query(<heading-font>).first().value)[定義]})
#let lemma = thmja("lemma", context{text(font: query(<heading-font>).first().value)[補題]})
#let theorem = thmja("theorem", context{text(font: query(<heading-font>).first().value)[定理]})
#let corollary = thmja("corollary", context{text(font: query(<heading-font>).first().value)[系]})
#let proof = thmproof("proof", context{text(font: query(<heading-font>).first().value)[証明]}, separator: [#h(0.9em)], titlefmt: strong, inset: (top: 0em, left: 0em))

#let jaconf(
  // 基本 Basic
  title: [タイトル],
  title-en: [Title in English],
  authors: [著者],
  authors-en: [Authors in English],
  abstract: none,
  keywords: (),
  // フォント名 Font family
  font-heading: "Noto Sans CJK JP",  // サンセリフ体、ゴシック体などの指定を推奨
  font-main: "Noto Serif CJK JP",  // セリフ体、明朝体などの指定を推奨
  font-latin: "New Computer Modern",
  font-math: "New Computer Modern Math",
  // 外観 Appearance
  paper-margin: (top: 20mm, bottom: 27mm, left: 20mm, right: 20mm),
  paper-columns: 2,  // 1: single column, 2: double column
  page-number: none,  // e.g. "1/1"
  column-gutter: 4%+0pt,
  spacing-heading: 1.2em,
  front-matter-order: ("title", "authors", "title-en", "authors-en", "abstract", "keywords"),  // 独自コンテンツの追加も可能
  front-matter-spacing: 1.5em,
  front-matter-margin: 2.0em,
  abstract-margin: (top: 1em, bottom: 1em, left: 0.7cm, right: 0.7cm),
  abstract-language: "en",  // "ja" or "en"
  keywords-margin: (top: 1em, bottom: 1em, left: 0.7cm, right: 0.7cm),
  keywords-language: "en",  // "ja" or "en"
  bibliography-style: "sice.csl",  // "sice.csl", "rsj.csl", "ieee", etc.
  // 見出し Headings
  heading-abstract: [*Abstract--*],
  heading-keywords: [*Keywords*: ],
  heading-bibliography: [参　考　文　献],
  heading-appendix: [付　録],
  // フォントサイズ Font size
  font-size-title: 16pt,
  font-size-title-en: 12pt,
  font-size-authors: 12pt,
  font-size-authors-en: 12pt,
  font-size-abstract: 10pt,
  font-size-heading: 12pt,
  font-size-main: 10pt,
  font-size-bibliography: 9pt,
  // 補足語 Supplement
  supplement-image: [図],
  supplement-table: [表],
  supplement-separator: [: ],
  supplement-equation: [],  // 式、Eq. など
  // 番号付け Numbering
  numbering-headings: "1.1",
  numbering-equation: "(1)",
  numbering-appendix: "A.1",  // #show: appendix.with(numbering-appendix: "A.1") の呼び出しにも同じ引数を与えてください。
  // 本文
  body
) = {
  // Set metadata.
  [#metadata(font-heading) <heading-font>]
  [#metadata(heading-appendix) <appendix-heading>]

  // Enable packages.
  show: thmrules.with(qed-symbol: $square$)
  show: codly-init.with()

  // Set document metadata.
  set document(title: title)

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
      let num = numbering(el.numbering, ..counter(eq).at(el.location()))
      link(el.location(), [#supplement-equation #num])
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
  show heading: set text(size: font-size-main, font: font-heading, weight: "bold")
  show heading.where(level: 1): set text(size: font-size-heading)

  // Configure figures.
  show figure.where(kind: table): set figure(placement: top, supplement: supplement-table)
  show figure.where(kind: table): set figure.caption(position: top, separator: supplement-separator)
  show figure.where(kind: image): set figure(placement: top, supplement: supplement-image)
  show figure.where(kind: image): set figure.caption(position: bottom, separator: supplement-separator)

  // Title and Authors
  for item in front-matter-order {
    if item == "title" and title != [] {
      // Display the paper's title.
      align(center, text(font-size-title, title, weight: "bold", font: font-heading))
      v(front-matter-spacing, weak: true)
    } else if item == "authors" and authors != [] {
      // Display the authors list.
      align(center, text(font-size-authors, authors, font: font-main))
      v(front-matter-spacing, weak: true)
    } else if item == "title-en" and title-en != [] {
      // Display the paper's title in English.
      align(center, text(font-size-title-en, title-en, weight: "bold", font: font-latin))
      v(front-matter-spacing, weak: true)
    } else if item == "authors-en" and authors-en != [] {
      // Display the authors list in English.
      align(center, text(font-size-authors-en, authors-en, font: font-latin))
      v(front-matter-spacing, weak: true)
    } else if item == "abstract" and abstract != none {
      // Display abstract.
      v(abstract-margin.top, weak: true)
      grid(
        columns: (abstract-margin.left, 1fr, abstract-margin.right),
        [],
        {
          set par(first-line-indent: 0em)
          if abstract != none {
            set text(
              font-size-abstract,
              font: if abstract-language == "ja" { font-main }
                else { font-latin }
            )
            [#heading-abstract #h(0.5em) #remove-cjk-break-space(abstract)]
          }
        },
        []
      )
      v(abstract-margin.bottom, weak: true)
    } else if item == "keywords" and keywords != () {
      // Display index terms as keywords.
      v(keywords-margin.top, weak: true)
      grid(
        columns: (keywords-margin.left, 1fr, keywords-margin.right),
        [],
        {
          set par(first-line-indent: 0em)
          if keywords != () {
            set text(
              font-size-abstract,
              font: if keywords-language == "ja" { font-main }
                else { font-latin }
            )
            [#heading-keywords #h(0.5em) #keywords.join(", ")]
          }
        },
        []
      )
      v(keywords-margin.bottom, weak: true)
    } else {
      item
    }
  }

  v(front-matter-margin, weak: true)

  // Start two column mode and configure paragraph properties.
  show: columns.with(paper-columns, gutter: column-gutter)

  // Configure Bibliography.
  set bibliography(title: text(size: font-size-heading, heading-bibliography), style: bibliography-style)
  show bibliography: it => {
    set text(font-size-bibliography, lang: "en")
    show regex("[0-9a-zA-Z]"): set text(font: font-latin)
    it
  }

  // Display the paper's contents.
  remove-cjk-break-space(body)
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
