#import "@preview/i-figured:0.2.4"
#import "font.typ": ziti, zihao
#let figures(
  appendix: false,
  body,
) = {
  show figure: set align(center)
  show table: set align(center)

  show heading: i-figured.reset-counters.with(extra-kinds: ("image",))
  show figure: i-figured.show-figure.with(
    extra-prefixes: (
      image: "img:",
      algorithm: "algo:",
    ),
    numbering: if not appendix { "1.1" } else { "A1" },
  )
  show math.equation: i-figured.show-equation.with(
    numbering: if not appendix { "(1.1)" } else { "(A1)" },
    level: if not appendix { 2 } else { 1 },
  )
  set math.equation(supplement: [公式])

  set figure.caption(separator: [#h(1em)])
  show figure.caption: set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
  show figure.where(kind: "table"): set figure.caption(position: top)
  show figure: set block(breakable: true)

  show table: set text(size: zihao.wuhao, weight: "regular")
  set table(
    stroke: (x, y) => {
      if y == 0 {
        none
      } else {
        none
      }
    },
  )
  body
}

#let tablex(
  ..body,
  header: (),
  columns: auto,
  rows: auto,
  colnum: int,
  caption: none,
  label-name: "",
  alignment: center,
) = {
  let nxt = state("tablex" + label-name, false)
  [
    #let new-label = label(label-name)
    #let head-label = label("tbl:" + label-name)
    #set figure.caption(position: top)
    #figure(
      table(
        columns: columns,
        table.header(
          table.cell(
            colspan: colnum,
            {
              context if nxt.get() {
                set align(left)
                set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
                [续#ref(head-label)]
                nxt.update(false)
              } else {
                v(-0.9em)
                nxt.update(true)
              }
            },
          ),
          table.hline(),
          ..header,
          table.hline(stroke: 0.5pt),
        ),
        ..body,
        table.hline()
      ),
      caption: caption,
      kind: "table",
      supplement: [表],
    )#new-label
  ]
}

#let algox(
  content,
  caption: none,
  label-name: "",
  breakable: true,
) = {
  let nxt = state("algox" + label-name, false)
  [
    #let new-label = label(label-name)
    #let head-label = label("algo:" + label-name)

    #context {
      [
        #figure(
          [],
          kind: "algorithm",
          supplement: [算法],
        )#new-label
        #v(-1.25em)
      ]

      table(
        columns: 1fr,
        align: left,
        table.header(
          table.cell(
            colspan: 1,
            {
              context if nxt.get() {
                set align(left)
                set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
                [续#ref(head-label)]
                nxt.update(false)
              } else {
                set align(left)
                set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
                line(start: (-5pt, 0pt), length: 100% + 10pt)
                v(-0.5em)
                [
                  #set par(first-line-indent: 0em)
                  #ref(head-label)#h(1em)#caption
                ]
                nxt.update(true)
              }
            },
          ),
          table.hline(),
        ),
        content,
        table.hline()
      )
    }
  ]
}
