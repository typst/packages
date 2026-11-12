#import "design.typ": *
#let code-style(o, body) = {
  set raw(theme: syntax-theme(o.accent))
  show raw: set text(font: o.code-font, size: code-size)
  show raw.where(block: true): it => block(
    above: paragraph-gap, width: full, breakable: true,
    stroke: (top: hairline + monash-black, bottom: hairline + monash-black), inset: code-inset,
  )[
    #set text(
      font: o.code-font, top-edge: code-top-edge, bottom-edge: code-bottom-edge, size: code-size,
    )
    #set par(justify: false, leading: code-leading)
    #grid(
      columns: (auto, 1fr), column-gutter: code-number-gap,
      row-gutter: zero, rows: code-line-height,
      ..it.lines.map(l => (
        align(right, text(
          font: o.code-font, size: code-size, fill: monash-grey, str(l.number),
        )),
        align(left, text(size: code-size, l.body)),
      )).flatten(),
    )
  ]
  body
}
