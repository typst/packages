#import "../colors/palettes.typ": palette


#let citation-block(content: none, author: none, palette: palette.slate, offset: 0em) = {
  v(offset)
  align(center + horizon)[
    #line(length: 30%, stroke: 0.5pt + palette.medium)
    #v(0.6em)
    #text(size: 1.3em, style: "italic")[#content]
    #v(0.6em)
    #text(size: 0.85em, fill: palette.dark)[#author]
    #v(0.4em)
    #line(length: 30%, stroke: 0.5pt + palette.medium)
  ]
}