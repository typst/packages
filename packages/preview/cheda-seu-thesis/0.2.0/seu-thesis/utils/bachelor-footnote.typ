// Usage: show footnote.entry: bachelor-footnote
// 需要在文档开头使用

#import "fonts.typ": 字体, 字号
#import "numbering-tools.typ": number-with-circle

#let bachelor-footnote(it) = {
  let loc = it.note.location()
  set par(leading: 14pt)
  h(2em)
  text(font: 字体.宋体, size: 字号.小五/2, weight: "regular", baseline: -0.5em, numbering(number-with-circle, ..counter(footnote).at(loc)))
  h(0.5em)
  set text(font: 字体.宋体, size: 字号.小五, weight: "regular", baseline: 0em)
  it.note.body
}