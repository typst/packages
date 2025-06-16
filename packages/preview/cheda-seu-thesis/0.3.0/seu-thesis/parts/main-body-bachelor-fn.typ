#import "../utils/states.typ": part-state
#import "../utils/fonts.typ": 字体, 字号

#let main-body-bachelor-conf(doc) = {
  set page(
    header: {
      set align(center)
      set text(font: 字体.宋体, size: 字号.小五, lang: "zh")
      set par(first-line-indent: 0pt, leading: 16pt, justify: true)
      show par: set block(spacing: 16pt)

      [东南大学本科毕业设计（论文）]
      v(-12pt)
      line(length: 100%, stroke: (thickness: 0.5pt))

      counter(footnote).update(0)
    },
    numbering: "1",
    footer: {
      set align(center)
      set text(font: 字体.宋体, size: 字号.小五, lang: "zh")
      h(16pt)
      counter(page).display()
    },
    header-ascent: 10%,
    footer-descent: 10%,
  )

  pagebreak(weak: false)


  counter(page).update(1)
  counter(heading.where(level: 1)).update(0)

  doc
}