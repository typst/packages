#import "@preview/jaconf:0.7.1": appendix, jaconf

#let jascome(
  title: [フィルタ理論を適用した動弾性逆解析による未知量同定],
  title-en: [IDENTIFICATION OF UNKNOWNS BY ELASTODYNAMIC INVERSE ANALYSIS \
    USING FILTERING THEORY],
  authors: ([新宿 太郎], [東京 次郎], [境界 要子]),
  authors-en: ([Taro SHINJUKU], [Jiro TOKYO], [Yoko KYOKAI]),
  authors-affiliation: (
    (
      "生産大学工学部システム工学科",
      "543-4567",
      "若里市中央町4-5-6",
      "taro@homer.seisan-u.ac.jp",
    ),
    (
      "構造重工（株）",
      "380-8553",
      "新宿市西新宿2-1",
      "jiro@hero.kozo-ju.co.jp",
    ),
    (
      "生産大学大学院工学系研究科",
      "543-4567",
      "若里市中央町4-5-6",
      "yoko@homer.seisan-u.ac.jp",
    ),
  ),
  keywords: ("Inverse Analysis", "Identification", "Boundary Element Method"),
  abstract: [#lorem(100)],
  date-submit: datetime(year: 2018, month: 9, day: 14),
  date-accept: datetime(year: 2018, month: 10, day: 26),
  date-publish: datetime(year: 2018, month: 12, day: 1),
  volume: 18,
  number: none,
  body,
) = {
  show "、": "，"
  show "。": "．"
  set page(header: context [
    #set text(size: 8.8pt, font: ("New Computer Modern", "Harano Aji Gothic"))
    #if counter(page).at(here()).at(0) == 1 {
      pad(
        bottom: -1.34cm,
        [計算数理工学論文集 *Vol. #volume~(#date-publish.year()*年*#date-publish.month()*月*),* 論文*No. #number* #h(0.1fr) JASCOME],
      )
    }
  ])
  show: jaconf.with(
    // 基本 Basic
    title: [
      #set text(weight: "regular")
      #v(1.87cm)
      #title #footnote(numbering: _ => [])[
        #set text(size: 8pt)
        #h(2mm)#if (date-submit != none) {
          [#date-submit.display("[year]年[month padding:none]月[day padding:none]日")受付]
        }#if (date-accept != none) {
          [、#date-accept.display("[year]年[month padding:none]月[day padding:none]日")受理]
        }
      ]
    ],
    title-en: [#v(0.45cm)
      #set par(leading: 1.3em)
      #title-en
    ],
    authors: [
      #v(0.5cm)
      #show " ": "　"
      #(
        authors
          .enumerate(start: 1)
          .map(x => [#x.at(1)#super[#x.at(0))]])
          .join("、")
      )
    ],
    authors-en: [
      #v(0.4cm)
      #authors-en.slice(0, -1).join(", ") #if (authors-en.len() > 1) {
        [and]
      } #authors-en.at(-1)
    ],
    abstract: [
      #set align(center)
      #block(width: 12.5cm)[
        #set par(leading: 0.925em)
        #set align(left)
        #abstract
        #v(1mm)
        _*Key Words*_:~~#keywords.join(", ")
      ]
      #v(4.9mm)
    ],
    keywords: ([Typst], [conference paper writing], [manuscript format]),
    // フォント名 Font family
    font-heading: "Harano Aji Gothic", // サンセリフ体、ゴシック体などの指定を推奨
    font-main: "Harano Aji Mincho", // セリフ体、明朝体などの指定を推奨
    font-latin: "New Computer Modern",
    font-math: "New Computer Modern Math",
    // 外観 Appearance
    paper-margin: (top: 20mm, bottom: 19mm, x: 15.7mm),
    paper-columns: 2, // 1: single column, 2: double column
    page-number: none, // e.g. "1/1"
    column-gutter: 4.5% + 0pt,
    spacing-heading: 0.6em,
    front-matter-order: (
      "title",
      "title-en",
      "authors",
      "authors-en",
      [
        #v(0.2cm)
        #set text(size: 8pt)
        #set align(center)
        #let table-content = (
          authors-affiliation
            .enumerate(start: 1)
            .map(x => (
              [#x.at(0))~#x.at(1).at(0)],
              [(〒#x.at(1).at(1)],
              [#x.at(1).at(2),],
              [E-mail: #x.at(1).at(3))],
            ))
            .flatten()
            .map(x => [#align(left)[#x]])
        )
        #table(
          columns: 4,
          inset: 4pt,
          stroke: none,
          ..table-content
        )
      ],
      "abstract",
    ), // 独自コンテンツの追加も可能
    front-matter-spacing: 1em,
    front-matter-margin: 1em,
    abstract-language: "en", // "ja" or "en"
    keywords-language: "en", // "ja" or "en"
    bibliography-style: "ieee", // "sice.csl", "rsj.csl", "ieee", etc.
    // 見出し Headings
    heading-abstract: none,
    heading-keywords: [*Key* *Words*:],
    heading-bibliography: [参考文献],
    heading-appendix: [付録],
    // フォントサイズ Font size
    font-size-title: 17pt,
    font-size-title-en: 10pt,
    font-size-authors: 9.7pt,
    font-size-authors-en: 10pt,
    font-size-abstract: 8.6pt,
    font-size-heading: 8.6pt,
    font-size-main: 9pt,
    font-size-bibliography: 9pt,
    // 補足語 Supplement
    supplement-image: [Figure],
    supplement-table: [Table],
    supplement-separator: [: ],
    supplement-equation: none, // 式、Eq. など
    // 番号付け Numbering
    numbering-headings: "1.",
    numbering-equation: "(1.1)",
    numbering-appendix: "A.1", // #show: appendix.with(numbering-appendix: "A.1") の呼び出しにも同じ引数を与えてください。
  )
  let supplement-equation = none
  let numbering-appendix = "A.1"
  // Configure appearance of references
  show ref: it => {
    // Equation -> (n).
    // See https://typst.app/docs/reference/model/ref/
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      let num = numbering(el.numbering, ..counter(eq).at(el.location()))
      link(el.location(), [#supplement-equation #num])
    } // Appendix -> 付録A.
    else if el != none and el.func() == heading {
      let sec-cnt = counter(heading).at(el.location())
      if el.numbering != numbering-appendix {
        if el.depth == 1 {
          link(el.location(), [#sec-cnt.at(0)節])
        } else if el.depth == 2 {
          link(el.location(), [#sec-cnt.at(0).#sec-cnt.at(1)節])
        } else if el.depth == 3 {
          link(el.location(), [#sec-cnt.at(0).#sec-cnt.at(1).#sec-cnt.at(2)節])
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
  show bibliography: set text(lang: "en")
  set bibliography(style: "jascome.csl", title: [
    #set align(center)
    #h(3.7cm)参考文献
  ])
  set align(top)
  [
    #show heading: it => {
      set text(weight: "medium")
      v(3.2mm)
      it
      v(1.9mm)
    }
    #set par(leading: 0.88em, spacing: 1.0em)
    #body
  ]
}
