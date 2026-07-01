#import "info.typ": *
#import "font.typ": *
#import "word_spacing.typ": 单倍行距

#let set-footnote(body) = {
  set footnote(numbering: "①")
  set footnote.entry(indent: 0em, clearance: 12pt, gap: 单倍行距, separator: line(length: 30%, stroke: 0.5pt) + v(0.3em))
  show footnote.entry: it => {
    set text(size: font-size.小五)
    set par(hanging-indent: 1.5em, first-line-indent: 0em, leading: 单倍行距, spacing: 单倍行距)
    let loc = it.note.location()
    par(numbering(it.note.numbering, ..counter(footnote).at(loc)) + h(0.5em) + it.note.body)
  }
  body
}
