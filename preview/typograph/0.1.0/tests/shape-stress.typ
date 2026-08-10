// Compile-only performance regression fixture. It intentionally avoids a
// wall-clock assertion (too environment-sensitive) while exercising many
// nodes that share one precomputed high-sided regular-polygon builder.
#import "/src/lib.typ" as typ

#let many-sided = typ.shapes.regular(vertices: 32, rotate: -90deg)
#let poly-theme = typ.theme(
  node-presets: (
    poly: (
      shape: many-sided,
      fill: luma(245),
      stroke: 0.2pt + black,
      min-size: 20pt,
      inset: 1pt,
    ),
  ),
)
#let poly = typ.node-type("poly")
#let n = 16

#typ.diagram(theme: poly-theme, scale: 0.65cm, {
  let nodes = range(n).map(row => range(n).map(col => poly(col, row)))
  for row in range(n) {
    for col in range(n) {
      let current = nodes.at(row).at(col)
      if col + 1 < n {
        typ.edge(current, nodes.at(row).at(col + 1))
      }
      if row + 1 < n {
        typ.edge(current, nodes.at(row + 1).at(col))
      }
    }
  }
})
