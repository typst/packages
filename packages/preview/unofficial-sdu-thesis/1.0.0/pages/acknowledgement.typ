#import "../styles/heading.typ": none-heading
#import "../styles/fonts.typ": fonts, fontsize

#let acknowledgement-page(
  body,
) = {
  pagebreak(weak: true)
  show: none-heading
  set page(footer:none)
  heading(level: 1)[*致#h(2em)谢*]
  set text(font: fonts.宋体, size: fontsize.小四)
  set par(first-line-indent: 2em, leading: 23pt - 1em, spacing: 23pt - 1em, justify: true)
  body
  pagebreak(weak: true)
}
