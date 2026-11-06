#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.1": zh

#let abstract-en(
  twoside: false,
  outline-title: "Abstract",
  outlined: true,
  info: (:),
  keywords: (),
  body
) = {
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
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
    #text(font: "Times New Roman", size: 14pt, weight: "bold")[
      #info.title-en.join("")
    ]
    #v(2em)
    #text(size: 12pt, font: "Times New Roman", weight: "bold")[Abstract]
    ]
    #set text(size: 12pt, font: "Times New Roman")
    #set par(
      justify: true,
      first-line-indent: 2em,
      spacing: 1.5 * 15.6pt - 0.7em,
      leading: 1.5 * 15.6pt - 0.7em)
    #body

    #text(font: "Times New Roman", size: 12pt)[*Key words:* #keywords.join("; ")]
  ]
}
