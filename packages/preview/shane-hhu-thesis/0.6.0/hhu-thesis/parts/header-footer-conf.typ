#import "../utils/utils.typ": ziti, zihao, part-state

#let header-footer-conf(
  thesis-name: [],
  doc
) = {
  set page(
    header: {
      set align(center)
      set text(font: ziti.宋体, size: zihao.小五, lang: "zh")
      set par(first-line-indent: 0pt, leading: 1.5em, justify: true, spacing: 0.5em)

      context {
        thesis-name.heading
        line(length: 100%, stroke: (thickness: 0.5pt))
      }
      counter(footnote).update(0)
    },
    numbering: "1",
    header-ascent: 1cm,
    footer-descent: 50%,
  )

  pagebreak(weak: false)

  counter(page).update(1)
  counter(heading.where(level: 1)).update(0)
  part-state.update("正文")

  doc
}
