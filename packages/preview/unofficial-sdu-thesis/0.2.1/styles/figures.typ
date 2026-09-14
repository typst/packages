#import "@preview/i-figured:0.2.4"
#import "fonts.typ": fonts, fontsize

#let c_red = rgb("c00000")

#let figures(
  appendix: false,
  body,
) = {
  // 提示：有关heading计数器重置的代码在main-matter中放置
  // image and table figure setting
  show figure: set align(center)
  show figure: set text(font: fonts.宋体, size: fontsize.五号, weight: "bold")
  show figure: set block(breakable: true)
  show table: set align(center)
  set figure.caption(separator: [#h(.2em)])
  show figure: i-figured.show-figure.with(
    extra-prefixes: (
      image: "img:",
      algorithm: "algo:",
    ),
    numbering: if not appendix { "1-1" } else { "1" },
    level: if not appendix { 1 } else { 0 },
  )
  show figure.where(kind: "table"): set figure.caption(position: top)
  show figure.caption: c => [
    #text(fill: c_red, weight: "bold")[
      // c.supplement 为 "图"/"表" , counter为序号
      #c.supplement #context c.counter.display(c.numbering)
    ]
    #c.separator#c.body
  ]
  show table: set text(size: fontsize.五号, weight: "regular")
  set table(
    stroke: (x, y) => {
      if y == 0 {
        none
      } else {
        none
      }
    },
  )

  // math figure setting
  show math.equation: i-figured.show-equation.with(
    numbering: if not appendix { "(1-1)" } else { "(A1)" },
    // level: if not appendix { 2 } else { 1 },
    level: 1,
  )
  set math.equation(supplement: [式])

  body
}

#let tablex(
  ..body,
  supplement: "表",
  header: (),
  columns: auto,
  rows: auto,
  colnum: int,
  caption: none,
  label-name: "",
) = {
  let nxt = state(label-name, false)
  [
    #let new-label = label(label-name)
    #let head-label = label("tbl:" + label-name)
    #set figure.caption(position: top)
    #set par(justify: false, leading: .25em)
    #v(1.3em)
    #figure(
      supplement: supplement,
      caption: caption,
      kind: table,
      table(
        inset: .15em,
        align: alignment.horizon,
        columns: columns,
        table.header(
          table.cell(
            colspan: colnum,
            {
              context if nxt.get() {
                set align(center)
                text(font: fonts.宋体, size: fontsize.五号, weight: "bold", fill: c_red)[续#ref(head-label) ]
                text(font: fonts.宋体, size: fontsize.五号, weight: "bold")[#caption]
                v(0.9em)
                nxt.update(false)
              } else {
                nxt.update(true)
                // v(-0.9em)
              }
            },
          ),
          table.hline(stroke: 1.5pt),
          ..header,
          table.hline(stroke: 0.75pt),
        ),
        ..body,
        table.hline(stroke: 1.5pt)
      ),
    )#new-label
  ]
}

#let algox(
  content,
  caption: none,
  label-name: "",
  breakable: true,
) = {
  let nxt = state("algox", false)
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
        align: (left),
        table.header(
          table.cell(
            colspan: 1,
            {
              context if nxt.get() {
                set align(center)
                set text(font: fonts.黑体, size: fontsize.五号, weight: "bold", fill: c_red)
                [续#ref(head-label)]
                set text(fill: black)
                caption
                nxt.update(false)
              } else {
                set align(center)
                set text(font: fonts.黑体, size: fontsize.五号, weight: "bold")
                line(start: (-5pt, 0pt), length: 100% + 10pt)
                v(-0.5em)
                text(font: fonts.黑体, size: fontsize.五号, weight: "bold", fill: c_red)[#ref(head-label)#h(1em)]
                caption
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
