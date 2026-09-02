/// typograph — a neutral diagram engine for Typst: generic node/edge
/// constructors, Bézier curve controls, wire clipping to true silhouettes,
/// ports, reusable fragments, and layered style resolution. It has no
/// opinion about what a node should look like; a document supplies that
/// through a theme (see the `theme()` function) or per-call styling.
///
/// Typical usage (diagram coordinates are math-convention: x right, y up):
/// ```typc
/// #import "@preview/typograph:0.3.0" as typ
///
/// #typ.diagram({
///   let a = typ.node(0, 0, label: [A], style: (shape: typ.shapes.circle, fill: aqua))
///   let b = typ.node(1, 0, label: [B], style: (shape: typ.shapes.circle, fill: aqua))
///   typ.edge(a, b)
///   typ.edge(a, (-1, 0))
///   typ.edge(b, (2, 0))
/// })
/// ```
///
/// For complete, ready-to-use visual languages built on this engine, see
/// `typograph-zx` for ZX-calculus notation and `typograph-circuit` for
/// quantum-circuit and continuous-variable circuit notation.

#import "node.typ": (
  make-node, node-type, node, box, gate, port,
  // Advanced/testing helpers: build and measure a resolved outline directly,
  // without laying out a whole diagram. A theme package's own geometry
  // snapshot tests are the main reason these are public rather than
  // internal to this module.
  shape-outline, shape-radius, node-outline, outline-size,
)
#import "edge.typ": edge, edge-type, smooth, line, quad, cubic, rel, ref
#import "position.typ": offset
#import "content.typ": place-item as place, group
#import "diagram.typ": diagram
#import "config.typ": config
#import "style.typ": node-defaults, resolve-node-style, edge-defaults, resolve-edge-style
#import "theme.typ": theme, neutral-theme
// Shape builders are namespaced so `import typ: *` does not shadow Typst's
// native circle/rect/polygon functions.
#import "shape.typ" as shapes
#let fit-box = shapes.fit-box
#let polygon-outline = shapes.polygon-outline
#import "geometry.typ": rotate-point
