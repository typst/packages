///! Radial coordinate system.

#import "../utils/errors.typ": fail-enum, fail-type
#import "../utils/types.typ": is-native-numeric
#import "contract.typ": coord-base
#import "expand.typ": apply-expand
#import "../utils/radial.typ": (
  ARC-STEP, arc-steps, polar-canvas, radial-ctx, radial-point,
)
#import "../render/panel-radial.typ": (
  draw-radial-background, draw-radial-foreground, prepare-radial,
)

// The `(u, v)` axis positions with points inserted along each edge whose theta
// sweep reaches `ARC-STEP`, linear in `(u, v)` as ggplot2 munches in
// transformed space: at constant radius the edge becomes an arc. `t` is the
// index of the theta position in each pair. `closed` also densifies the edge
// from the last point back to the first, whose points come last.
#let _densify(uvs, t, closed) = {
  let n = uvs.len()
  if n < 2 { return uvs }
  let out = ()
  for i in range(if closed { n } else { n - 1 }) {
    let a = uvs.at(i)
    let b = uvs.at(calc.rem(i + 1, n))
    out.push(a)
    let sweep = b.at(t) - a.at(t)
    if calc.abs(sweep) < ARC-STEP { continue }
    let steps = arc-steps(sweep)
    for k in range(1, steps) {
      let f = k / steps
      out.push((
        a.at(0) + (b.at(0) - a.at(0)) * f,
        a.at(1) + (b.at(1) - a.at(1)) * f,
      ))
    }
  }
  if not closed { out.push(uvs.last()) }
  out
}

/// Radial coordinate system.
///
/// `theta = "x"` (default) distributes categories around the circle for rose / radar layouts; `theta = "y"` turns stacked y values into wedges for pie / donut layouts.
///
/// Lines, paths, steps, areas, ribbons, segments, spokes, `geom-abline`, `geom-errorbar`, `geom-errorbarh`, `geom-linerange`, `geom-pointrange`, and the lines of `geom-smooth` and `geom-function` curve along the polar grid. Polygons keep straight edges. `geom-violin` and `geom-density-ridges` fail under this coord. An edge that crosses the seam at `start` (12 o'clock by default) sweeps the long way round the circle, as in ggplot2.
///
/// - theta: Which axis is angular: `"x"` (default) or `"y"`. The radial axis (the other one) automatically drops its lo-side expansion to zero so bars meet at radius 0; pass an explicit `expand:` on the radial scale to override.
/// - start: Offset in radians from 12 o'clock for the first slice.
/// - end: Offset in radians from 12 o'clock for the sweep end. `none` (default) means a full sweep in the requested `direction`. On a full sweep where the angular domain endpoints land on the same canvas angle, the two ticks merge into a single `"end/start"` label.
/// - direction: `1` (default) advances clockwise; `-1` counter-clockwise.
/// - clip: `false` (default) lets marks render past the panel rectangle; `true` clips.
///
/// Returns: Coordinate dictionary consumed by `plot`.
///
/// See also: `plot`, `geom-col`.
///
/// Pie chart from a stacked column.
///
/// ```typst
/// #let d = (
///   (slice: "all", value: 30, kind: "A"),
///   (slice: "all", value: 20, kind: "B"),
///   (slice: "all", value: 50, kind: "C"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "slice", y: "value", fill: "kind"),
///   layers: (geom-col(width: 1, position: "stack"),),
///   coord: coord-radial(theta: "y"),
///   width: 7cm,
///   height: 7cm,
/// )
/// ```
#let coord-radial(
  theta: "x",
  start: 0,
  end: none,
  direction: 1,
  clip: false,
) = {
  if theta not in ("x", "y") {
    fail-enum("coord-radial", "theta", theta, ("x", "y"))
  }
  if direction not in (1, -1) {
    fail-enum("coord-radial", "direction", direction, (1, -1))
  }
  if not is-native-numeric(start) {
    fail-type("coord-radial", "start", start, "a number of radians")
  }
  if end != none and not is-native-numeric(end) {
    fail-type("coord-radial", "end", end, "`none` or a number of radians")
  }
  if type(clip) != bool {
    fail-type("coord-radial", "clip", clip, "a boolean")
  }
  // The radial axis, the one theta does not run along: "y" for rose/radar and
  // "x" for pie. Expansion runs before trained scales exist, so it cannot
  // route through `radial-ctx`.
  let radial-axis = if theta == "x" { "y" } else { "x" }
  // The keys `radial-ctx` reads off a radial coord. `frame` closes over them
  // because the coord dict is not yet built when its closures are.
  let own = (
    theta: theta,
    start: start,
    end: end,
    direction: direction,
    clip: clip,
  )
  (
    coord-base("radial")
      + own
      + (
        train: trained => apply-expand(trained, zero-lo-axis: radial-axis),
        frame: (
          x-trained,
          y-trained,
          px-range,
          py-range,
          label-bounds: (),
          tick-cm: 0.0,
        ) => radial-ctx(
          own,
          x-trained,
          y-trained,
          px-range,
          py-range,
          label-bounds: label-bounds,
          tick-cm: tick-cm,
        ),
        prepare: prepare-radial,
        supports: geom-name => geom-name not in ("violin", "density-ridges"),
        unsupported-hint: "Draw this layer under coord-cartesian or coord-flip.",
        draw-background: draw-radial-background,
        draw-foreground: draw-radial-foreground,
        axis-range: (ctx, axis) => if axis == theta {
          ctx.radial.theta-range
        } else { ctx.radial.r-range },
        to-canvas: (ctx, u, v) => {
          let (t, r) = if ctx.radial.cat-is-theta { (u, v) } else { (v, u) }
          polar-canvas(ctx.radial, t, r)
        },
        densify: (ctx, uvs, closed: false) => _densify(
          uvs,
          if theta == "x" { 0 } else { 1 },
          closed,
        ),
        // Kept on `radial-point` rather than the generic route, so the radial
        // float path stays the one every golden was drawn with.
        project: (ctx, xv, yv) => radial-point(xv, yv, ctx.radial),
      )
  )
}
