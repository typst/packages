// The shared shape of every coord. The renderer calls these functions rather
// than reading the coord name, so each constructor overrides only the steps
// that differ from the cartesian defaults.

#import "../scale/train.typ": map-position
#import "../render/panel-cartesian.typ": draw-cartesian-background
#import "expand.typ": apply-expand

// `train` rewrites the trained positional scales once scale training is done,
// and `panel-size` turns the box the chrome leaves into the inner panel size.
// The default `train` applies the scale expansion that every coord shares.
//
// `frame` builds the bundle the panel hands geoms as `ctx.radial`, `none` on a
// cartesian panel. `axis-range` is the canvas range one axis maps into, and
// `to-canvas` turns a pair of mapped axis positions into a canvas point.
// A coord that keeps the cartesian `draw-background` must accept the panel
// record in `axis-range` as well as a draw context, since that background
// reads its ranges through it too.
// `project` runs once per row, so the default reads `ctx.px-range` and
// `ctx.py-range` directly rather than calling `axis-range` and `to-canvas`.
// A coord that overrides either of them must override `project` too.
//
// `densify` takes the `(u, v)` axis positions of a path, before `to-canvas`,
// and returns them with the points the coord needs between them for each edge
// to follow its grid. A linear coord needs none, so the default is the
// identity. `closed` names the edge from the last point back to the first.
//
// `prepare` runs on the panel record (GLOSSARY.md "panel") before `frame`, and
// returns the `label-bounds` and `tick-cm` that `frame` takes. A coord may add
// its own fields for its draws; the panel merges the whole result into the
// record, so `ctx.radial` keeps its own shape.
// `draw-background` draws the furniture under the geoms, `draw-foreground`
// what sits above them, and `clip` says whether the geoms are clipped to the
// panel. `supports` says whether the coord can draw the geom of that name, and
// the panel fails for a layer it refuses, with `unsupported-hint` as the hint.
#let coord-base(name) = (
  kind: "coord",
  name: name,
  flipped: false,
  train: apply-expand,
  panel-size: (trained, w, h) => (w, h),
  frame: (
    x-trained,
    y-trained,
    px-range,
    py-range,
    label-bounds: (),
    tick-cm: 0.0,
  ) => none,
  prepare: panel => (label-bounds: (), tick-cm: 0.0),
  draw-background: draw-cartesian-background,
  draw-foreground: panel => none,
  clip: true,
  supports: geom-name => true,
  unsupported-hint: none,
  axis-range: (ctx, axis) => if axis == "x" { ctx.px-range } else {
    ctx.py-range
  },
  to-canvas: (ctx, u, v) => (u, v),
  densify: (ctx, uvs, closed: false) => uvs,
  project: (ctx, xv, yv) => {
    let xt = ctx.trained.at("x", default: none)
    let yt = ctx.trained.at("y", default: none)
    if xt == none or yt == none { return none }
    let cx = map-position(xt, xv, ctx.px-range)
    let cy = map-position(yt, yv, ctx.py-range)
    if cx == none or cy == none { return none }
    (cx, cy)
  },
)
