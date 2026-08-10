// Performance stress test: a 20x20 grid of alternating nodes (400 nodes),
// each connected to its right and down neighbor (760 edges), plus a
// highlight on every other row. Not a diagram anyone would draw by hand —
// this exists purely to check `diagram()` scales reasonably.
#import "/src/lib.typ" as typ

#let dot-a = typ.node-type("a", base-style: (shape: typ.shapes.circle, fill: green.lighten(60%), min-size: 9pt))
#let dot-b = typ.node-type("b", base-style: (shape: typ.shapes.circle, fill: red.lighten(60%), min-size: 9pt))

#let n = 20
#let diagram = typ.diagram
#diagram(scale: 0.8cm, {
  for row in range(n) {
    for col in range(n) {
      let node = if calc.rem(row + col, 2) == 0 {
        dot-a(col, row, label: [#row])
      } else {
        dot-b(col, row, label: [#row])
      }
      node
      if col + 1 < n {
        typ.edge((col, row), (col + 1, row), highlight: if calc.rem(row, 2) == 0 { green } else { none })
      }
      if row + 1 < n {
        typ.edge((col, row), (col, row + 1))
      }
    }
  }
})
