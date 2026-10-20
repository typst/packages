#import "lang.typ": get-labels
#import "@preview/cuti:0.4.0": show-cn-fakebold

// Main template function
#let ntust-thesis(
  // Language: "en" or "zh"
  lang: "zh",
  // Thesis metadata (from my-names.typ)
  info: (:),
  // Abstracts (zh/en content blocks)
  abstracts: (zh: none, en: none),
  // Acknowledgement
  acknowledgement: none,
  // Logo (image)
  logo: none,
  // Fonts
  fonts: ("Liberation Serif", "TW-MOE-Std-Kai"),
  // Recommendation form (image)
  recommendation-form: none,
  // Committee approval form (image)
  committee-form: none,
  // Copyright form (image)
  copyright-form: none,
  // Body
  body,
) = {
  show: show-cn-fakebold
  // Language labels
  let l = get-labels(lang)

  // Document metadata
  set document(
    title: info.title.en,
    author: info.author.en,
  )

  // Page setup
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 2cm, left: 3cm, right: 3cm),
    numbering: "1",
    number-align: center + bottom,
  )

  set text(
    font: fonts,
    size: 12pt,
    lang: if lang == "zh" { "zh" } else { "en" },
    region: if lang == "zh" { "TW" } else { "US" },
  )

  set par(
    leading: 1em,
    first-line-indent: (amount: 2em, all: true),
    spacing: 1.5em,
    justify: true,
  )

  // Heading configuration
  // Language-dependent heading numbering:
  //   zh: 第一章 / 一、 / （一） / 1. / (1)
  //   en: Chapter 1 / 1.1 / 1.1.1 / 1.1.1.1
  // This numbering function is also used by outline() for ToC entries.
  let heading-numbering = if lang == "zh" {
    (..nums) => {
      let n = nums.pos()
      if n.len() == 1 {
        [第#numbering("一", n.at(0))章]
      } else if n.len() == 2 {
        [#numbering("一", n.at(1))、]
      } else if n.len() == 3 {
        [（#numbering("一", n.at(2))）]
      } else if n.len() >= 4 {
        [#numbering("1.", n.at(3))]
      }
    }
  } else {
    (..nums) => {
      let n = nums.pos()
      if n.len() == 1 { [Chapter #n.at(0)] } else { numbering("1.1", ..n) }
    }
  }

  set heading(numbering: heading-numbering)

  // Level 1: Chapter
  show heading.where(level: 1): it => {
    // Reset figure / table / equation counters per chapter
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)

    pagebreak(weak: true)
    set align(center)
    set text(size: 20pt)
    set par(first-line-indent: 0pt)
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em)
    }
    it.body
    v(20pt)
  }

  // Level 2: Section
  // zh: 一、 Title  |  en: 1.1 Title
  show heading.where(level: 2): it => {
    set text(size: 18pt)
    set par(first-line-indent: 0pt)
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.5em)
    }
    it.body
  }

  // Level 3: Subsection
  // zh: （一） Title  |  en: 1.1.1 Title
  show heading.where(level: 3): it => {
    set text(size: 14pt)
    set par(first-line-indent: 0pt)
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.5em)
    }
    it.body
  }

  // Level 4: Sub-subsection
  // zh: 1. Title  |  en: 1.1.1.1 Title
  show heading.where(level: 4): it => {
    set text(size: 12pt)
    set par(first-line-indent: 0pt)
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.5em)
    }
    it.body
  }

  // Figure & Table numbering (chapter-relative: e.g. "1-2")
  show figure.where(kind: image): set figure(
    numbering: n => {
      let c = counter(heading.where(level: 1)).get().first(default: 0)
      [#c\-#n]
    },
  )

  show figure.where(kind: table): set figure(
    numbering: n => {
      let c = counter(heading.where(level: 1)).get().first(default: 0)
      [#c\-#n]
    },
  )

  // Equation numbering: (chapter-n)
  set math.equation(
    numbering: n => {
      let c = counter(heading.where(level: 1)).get().first(default: 0)
      [#c\-#n]
    },
  )

  // COVER PAGE (no page number)
  page(
    numbering: none,
    margin: (top: 4cm, bottom: 3cm, left: 3cm, right: 3cm),
  )[
    #set align(center)
    #set par(first-line-indent: 0pt)

    // Logo + University + Department
    #grid(
      columns: (auto, 1fr),
      align: (left + horizon, center + horizon),
      column-gutter: 0.5cm,
      if logo != none {
        set image(width: 3cm)
        logo
      } else {
        set align(center)
        circle(width: 3cm, height: 3cm, fill: luma(180))[logo placeholder]
      },
      {
        text(size: 28pt, weight: "bold")[#info.university.zh \ #info.department.zh]
      },
    )

    #line(length: 100%, stroke: 3pt)

    // Degree thesis
    #text(size: 28pt)[#info.degree.at(lang) #l.degree-thesis]
    #v(1fr)

    // Titles
    #text(size: 18pt)[#info.title.zh]
    #v(.5em)
    #text(size: 18pt)[#info.title.en]
    #v(1fr)

    // Student name
    #text(size: 18pt)[#info.author.at(lang)\ #info.student-id]

    #v(1cm)

    // Advisor(s)
    #{
      set text(size: 18pt)
      set align(center)
      let first = info.advisors.at(0, default: (:))
      let rest = if info.advisors.len() > 1 { info.advisors.slice(1) } else { () }
      grid(
        columns: (auto, auto),
        align: (right, left),
        column-gutter: 0cm,
        row-gutter: 0.3cm,
        l.advisor-label, first.at(lang, default: ""),
        ..rest.map(a => ([], a.at(lang, default: ""))).flatten(),
      )
    }

    #v(1fr)

    // Date (ROC calendar)
    #text(size: 18pt)[
      中華民國 #info.date.year 年 #info.date.month 月
    ]
  ]

  // FRONT MATTER — roman page numbering
  set page(numbering: "I")
  counter(page).update(1)

  // Recommendation letter placeholder
  {
    heading(level: 1, numbering: none)[#l.recommendation-form]
    v(1fr)
    if recommendation-form != none {
      align(center, recommendation-form)
    } else {
      align(center, text(fill: luma(180), size: 14pt)[
        （此頁請放入已簽名之推薦書 / Insert signed recommendation letter here）
      ])
    }
    v(1fr)
  }

  // Committee approval placeholder
  {
    heading(level: 1, numbering: none)[#l.committee-form]
    v(1fr)
    if committee-form != none {
      align(center, committee-form)
    } else {
      align(center, text(fill: luma(180), size: 14pt)[
        （此頁請放入已簽名之審定書 / Insert signed qualification form here）
      ])
    }
    v(1fr)
  }

  // Chinese abstract
  if abstracts.at("zh", default: none) != none {
    heading(level: 1, numbering: none)[#l.c-abstract]
    abstracts.zh
  }

  // English abstract
  if abstracts.at("en", default: none) != none {
    heading(level: 1, numbering: none)[#l.e-abstract]
    abstracts.en
  }

  // Acknowledgement
  if acknowledgement != none {
    heading(level: 1, numbering: none)[#l.acknowledgement]
    acknowledgement
  }

  // Table of Contents
  outline(
    title: l.toc,
    depth: 3,
    indent: 2em,
  )

  // List of Figures
  outline(
    title: l.lof,
    target: figure.where(kind: image),
  )

  // List of Tables
  outline(
    title: l.lot,
    target: figure.where(kind: table),
  )

  // MAIN BODY — arabic page numbering
  set page(numbering: "1")
  counter(page).update(1)

  body

  // Copyright form placeholder
  heading(level: 1, numbering: none)[#l.copyright-form]
  v(1fr)
  if copyright-form != none {
    align(center, copyright-form)
  } else {
    align(center, text(fill: luma(180), size: 14pt)[
      （此頁請放入已簽名之授權書 / Insert signed letter of authority here）
    ])
  }
  v(1fr)
}
