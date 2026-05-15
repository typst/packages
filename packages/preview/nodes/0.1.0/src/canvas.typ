#import "@preview/cetz:0.4.2"
#import "coord.typ" as coord
#import "util.typ" as util

/// Set up a CeTZ canvas with the nodes coordinate resolver registered.
///
/// This mirrors `cetz.canvas(...)`, but additionally enables nested nodes
/// coordinates such as `(rel: (1, 2), to: (east-of: "foo"))` and is required
/// when using `node(...)` or `edge(...)`.
#let canvas(length: 1cm, baseline: none, debug: false, background: none, stroke: none, padding: none, body) = context {
  let init = (
    cetz.draw.register-coordinate-resolver(coord.resolve-node-coordinate).first(),
    ctx => {
      ctx.shared-state.insert(util.nodes-canvas-key, true)
      (ctx: ctx)
    },
  )

  cetz.canvas(
    length: length,
    baseline: baseline,
    debug: debug,
    background: background,
    stroke: stroke,
    padding: padding,
    (
      ..init,
      ..body,
    ),
  )
}
