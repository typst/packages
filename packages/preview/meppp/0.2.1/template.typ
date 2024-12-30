#import "table.typ": meppp-tl-table

#import "@preview/cuti:0.2.1": show-cn-fakebold

#let meppp-lab-report(
  title: "",
  author: "",
  info: [],
  abstract: [],
  keywords: (),
  author-footnote: [],
  heading-numbering-array: ("I", "A", "1", "a"),
  heading-suffix: ". ",
  doc,
) = {

  // Fake bold for Chinese characters
  show: show-cn-fakebold

  // footnote settings
  show footnote.entry: set align(left)
  set footnote.entry(separator: {
    set align(left)
    line(length: 30%)
  })

  set page(
    paper: "a4",
    numbering: "1",
    margin: (
      top: 2cm,
      bottom: 1.6cm,
      x: 2.5cm,
    ),
  )

  set text(
    font: (
      "Times New Roman",
      "SimSun",
    ),
    lang: "zh",
  )

  set par(
    first-line-indent: 2em,
    leading: 2em,
    justify: true,
  )

  set block(spacing: 2em)

  set align(center)

  // title
  text(16pt, font: "SimHei")[
    #strong(title)\
  ]

  // author
  text(14pt, font: "STFangsong")[
    #author
  ]
  if author-footnote != [] {

    footnote(
      numbering: "*",
      author-footnote,
    )
  }
  [\ ]

  // info, e.g. school & studentid
  text(12pt, info)


  // (optional) abstract & keywords
  set align(left)
  if abstract != [] {
    pad(
      left: 2em,
      right: 2em,
      par(leading: 1.5em)[
        \
        #h(2em)
        #abstract \ \
        #text(font: "SimHei")[*关键词:*]
        #for keyword in keywords {
          keyword + [, ]
        }\
      ],
    )
  }

  // heading numbering
  set heading(
    numbering: (..args) => {
      let nums = args.pos()
      let level = nums.len() - 1
      let num = numbering(heading-numbering-array.at(level), nums.at(level))
      [#num#heading-suffix]
    },
    bookmarked: true,
  )



  // heading styling
  show heading: it => {
    set block(spacing: 2em)
    set par(first-line-indent: 0em)
    set text(
      if it.level == 1 {
        16pt
      } else if it.level == 2 {
        14pt
      } else {
        12pt
      },
      weight: "medium",
      font: ("STFangsong"),
    )
    if it.numbering != none {
      counter(heading).display(it.numbering)
    }
    it.body
  }

  // figure numbering
  set figure(supplement: "图")
  show figure.caption: set text(10pt)

  set cite(style: "gb-7714-2015-numeric")

  set text(12pt)

  set bibliography(
    style: "gb-7714-2015-numeric",
    title: none,
  )


  show bibliography: bib => {
    [\ \ ]
    align(center, line(length: 50%))
    bib
  }

  doc

}
