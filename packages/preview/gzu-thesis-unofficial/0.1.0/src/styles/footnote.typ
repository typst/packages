#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ"


#let footnote-style(body) = {
  set footnote(numbering: "①")
  show footnote.entry: it => {
    set text(font: fonts.serif, size: zh(5))
    h(it.indent)
    numbering(it.note.numbering, ..counter(footnote).at(it.note.location()))
    h(0.25em, weak: true)
    it.note.body
  }
  body
}
