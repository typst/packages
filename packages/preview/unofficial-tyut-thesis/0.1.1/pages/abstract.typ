#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.1": zh

#let abstract(
  twoside: false,
  outline-title: "摘要",
  outlined: true,
  info: (:),
  keywords: (),
  font: "SimSun",
  body
) = {
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  pagebreak(weak: true, to: if twoside { "odd" })

  [
    #show: show-cn-fakebold
    #text(size: 0pt, fill: white)[
      #heading(
        numbering: none,
        level: 1,
        outlined: outlined,
        bookmarked: outlined,
        outline-title)
    ]
    #align(center)[
    #text(font: "SimHei", size: 18pt, weight: "bold")[
      #info.title.join("")
    ]
    #v(2em)
    #text(size: 14pt, font: "SimHei")[摘#h(1em)要]
    ]
    #set text(size: zh(-4), font: ("Times New Roman", font))
    #set par(
      justify: true,
      first-line-indent: 2em,
      spacing: 1.5 * 15.6pt - 0.7em,
      leading: 1.5 * 15.6pt - 0.7em)
    #body

    #text(font: "SimHei", size: zh(4))[关键词：]#text(font:("Times New Roman", font))[#keywords.join("；")]
  ]
}
