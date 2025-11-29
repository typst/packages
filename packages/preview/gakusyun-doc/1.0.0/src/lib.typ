#import "@preview/pointless-size:0.1.2": zh, zihao
#import "@preview/zebraw:0.6.1": *


#let docu(
  title: "",
  author: "",
  show-title: true,
  title-page: false,
  blank-page: true,
  show-index: false,
  index-page: false,
  column-of-index: 1,
  cjk-font: "Source Han Serif",
  emph-cjk-font: "FandolKai",
  latin-font: "New Computer Modern",
  mono-font: "Maple Mono NF",
  default-size: "小四",
  lang: "zh",
  region: "cn",
  paper: "a4",
  date: datetime.today().display("[year]年[month]月[day]日"),
  numbering: "第1页 共1页",
  column: 1,
  body,
) = {
  show: zebraw

  show raw: set text(font: mono-font)

  set text(
    font: ((name: latin-font, covers: "latin-in-cjk"), cjk-font),
    region: region,
    lang: lang,
    size: zh(default-size),
  )

  set underline(stroke: 0.5pt, offset: 1.5pt)

  show link: underline

  show link: emph

  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
  )

  show emph: set text(
    font: ((name: latin-font, covers: "latin-in-cjk"), emph-cjk-font),
  )

  set document(author: author, title: title)

  set page(
    paper: paper,
    margin: 1.5cm,
    number-align: right,
    numbering: numbering,
  )

  set heading(numbering: "1.1")

  if (type(author) != array) {
    author = (author,)
  }
  author = author.join(", ")

  if show-title {
    if title-page {
      page(numbering: none)[
        #align(center + horizon)[
          #text(
            weight: "bold",
          )[
            #v(1fr)
            #text(size: zh("初号"))[#title]
            #v(1fr)
            #text(size: zh("小初"))[#author]
            #v(3fr)
            #text(size: zh("小初"))[#date]
            #v(1fr)
          ]
        ]
      ]
      if blank-page {
        page(numbering: none)[]
      }
    } else {
      align(center)[
        #text(
          weight: "bold",
        )[

          #text(size: zh("小二"))[#title]

          #text(size: zh("小四"))[#author]

          #text(size: zh("小四"))[#date]

          #line(length: 100%, stroke: 0.8pt)
        ]
      ]
    }
  }
  if show-index {
    columns(column-of-index)[
      #outline(
        title: [目录],
        depth: 3,
        indent: auto,
      )
    ]
    if index-page {
      pagebreak()
    }
  }
  columns(column)[
    #counter(page).update(1)
    #body
  ]
}

#let en(body) = {
  text(
    region: "us",
    lang: "en",
  )[#body]
}
