#import "@preview/pointless-size:0.1.2": zh, zihao
#import "@preview/zebraw:0.6.1": *


#let docu(
  title: "",
  subtitle: "",
  author: "",
  show-title: true,
  title-page: false,
  blank-page: true,
  show-index: false,
  index-page: false,
  column-of-index: 1,
  depth-of-index: 2,
  cjk-font: "Source Han Serif",
  emph-cjk-font: "FandolKai",
  latin-font: "New Computer Modern",
  mono-font: "Maple Mono NF",
  default-size: "小四",
  lang: "zh",
  region: "cn",
  paper: "a4",
  margin: (left: 3.18cm, right: 3.18cm, top: 2.54cm, bottom: 2.54cm),
  date: datetime.today().display("[year]年[month]月[day]日"),
  numbering: "第1页 共1页",
  column: 1,
  body,
) = {
  if title == none {
    title = ""
  }

  if subtitle == none {
    subtitle = ""
  }

  if author == none {
    author = ""
  }

  if date == none {
    date = ""
  }

  show: zebraw

  show raw: set text(font: mono-font, "JetBrains Mono", "Monospace", "Courier New")

  set text(
    font: (
      (name: latin-font, covers: "latin-in-cjk"),
      cjk-font,
      "Noto Serif SC",
      "Noto Serif CJK SC",
      "FandolSong",
      "SimSun",
      "STSongti",
    ),
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
    font: ((name: latin-font, covers: "latin-in-cjk"), emph-cjk-font, "KaiTi"),
  )

  set document(author: author, title: title)

  set page(
    paper: paper,
    margin: margin,
    number-align: right,
    numbering: numbering,
  )

  set heading(numbering: "1.1")

  if (type(author) != array) {
    author = (author,)
  }
  author = author.join(", ")

  if title == "" and subtitle == "" and author == "" and date == "" {
    show-title = false
  }

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

          #if title != "" {
            [
              #text(size: zh("小二"))[#title]
            ]
          }

          #if subtitle != "" {
            [
              #text(size: zh("小三"))[#subtitle]
            ]
          }

          #if author != "" and date != "" {
            [
              #text(size: zh("小四"))[作者：#author]
              #h(2fr)
              #text(size: zh("小四"))[#date]
            ]
          } else if author != "" {
            [
              #text(size: zh("小四"))[作者：#author]
            ]
          } else if date != "" {
            [
              #text(size: zh("小四"))[#date]
            ]
          }
          #line(length: 100%, stroke: 0.8pt)
        ]
      ]
    }
  }
  if show-index {
    columns(column-of-index)[
      #outline(
        title: [目录],
        depth: depth-of-index,
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
