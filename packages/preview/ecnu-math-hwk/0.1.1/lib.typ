#import "utils.typ": *

#let hwk(
  title: none,
  course: "course",
  hwk-id: 0,
  author: "author",
  stu-id: 1234567890,
  watermark: "default",
  body,
) = context {
  show: show-math-format
  show: show-common-format

  set text(font: (en-font-serif, cn-font-serif), weight: 300, size: 10pt)

  let suf = " Solution"
  if text.lang == "zh" { suf = " 解答" }
  let _title = title
  if _title == none {
    _title = course + " -- HW " + str(hwk-id) + suf
  }
  set document(title: _title)

  let page-background = if watermark == "default" {
    image("./assets/logo.svg")
  } else {
    watermark
  }

  set page(
    paper: "a4",
    numbering: "1",
    background: page-background,
    header: context {
      if here().page() == 1 {
        return
      }
      box(outset: 4pt, stroke: (bottom: 0.5pt + luma(220)))[#text(font: (
          en-font-serif,
          cn-font-serif,
        ))[#_title #sym.triangle.filled.small.r #author] #h(1fr) #counter(page).display()]
    },
    footer: context {
      // 仅在第一页显示页脚页码
      if here().page() == 1 {
        align(center, {
          counter(page).display()
        })
      }
    },
  )

  align(center)[
    #block(text(weight: 500, 17pt, _title))
    #v(1.5em, weak: true)
    #text(14pt)[#author #stu-id]
    #v(1.5em, weak: true)
    #text(14pt)[#datetime.today().display("[year].[month].[day]")]
    #v(2.0em, weak: true)
  ]

  body
}
