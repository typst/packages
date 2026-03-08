/// Display layouts for symbols and diacritics.

#let inline-code(input) = {
  highlight(
    fill: rgb("#f2f2f2"),
    extent: 0.05em,
    input
  )
}

#let _symbol-box(symbol) = rect(
  width: 1cm,
  height: 1cm,
  stroke: rgb("#222") + 0.25mm,
  radius: 0.2em
)[
  #set align(center + horizon)
  #set text(size: 1.5em)
  #place(
    top + left, dx: -0.1cm, dy: 0.035cm,
    line(length: 0.9cm, stroke: (paint: rgb("#bbb"), thickness: 0.25mm, dash: "dotted"))
  )
  #place(
    top + left, dx: -0.1cm, dy: 0.15cm,
    line(length: 0.9cm, stroke: (paint: rgb("#aaa"), thickness: 0.25mm, dash: "densely-dashed"))
  )
  #place(
    top + left, dx: -0.1cm, dy: 0.5cm,
    line(length: 0.9cm, stroke: (paint: rgb("#aaa"), thickness: 0.25mm, dash: "densely-dashed"))
  )
  #place(
    top + left, dx: -0.1cm, dy: 0.64cm,
    line(length: 0.9cm, stroke: (paint: rgb("#bbb"), thickness: 0.25mm, dash: "dotted"))
  )
  #symbol
]

#let display-diac(symbol, code, ipa-name, ipa-use, escape: auto, aliases: (), note: none) = block(
  width: 100%,
  breakable: false,
  above: auto,
  below: 0.25cm,
)[
  #if escape == auto {
    escape = "\u{" + lower(int-to-hex(str(symbol.replace(ipa.sym.placeholder, "")).to-unicode())) + "}"
  }
  #let aliases-str = aliases.map(it => inline-code(raw(it, lang: "typc"))).join(", ")
  #grid(columns: (1cm, 1fr), gutter: 0.25cm)[
    #_symbol-box(symbol)
  ][
    #set par(justify: false, leading: 0.5em)
    #set align(left + top)
    #set text(size: 0.85em)
    #strong(ipa-name)
    #v(0.5em, weak: true)
    #set table.cell(inset: 0cm)
    #set text(size: 0.85em)
    #let cells = (
      [Use:], [#ipa-use],
      [Name:], inline-code(raw(code, lang: "typc")),
      [Escape:], inline-code(raw(escape, lang: "typm")),
    )
    #if aliases.len() > 0 {
      if aliases.len() > 1 {
        cells.push([Aliases:])
      } else {
        cells.push([Alias:])
      }
      cells.push(aliases-str)
    }
    #if note != none {
      cells.push([Note:])
      cells.push(text(fill: black.lighten(25%), note))
    }
    #table(
      columns: (auto, 1fr),
      stroke: none, //0.05mm + gray,
      column-gutter: 0.25em,
      row-gutter: 0.5em,
      ..cells
    )
  ]
]