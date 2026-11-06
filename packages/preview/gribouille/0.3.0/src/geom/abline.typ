///! Oblique reference line from slope and intercept.
///!
///! Requires continuous x and y scales. The line is drawn across the full
///! trained x domain using `y = slope * x + intercept`. Under non-identity
///! axis transformations the line is sampled as a 64-point polyline so it
///! follows the warped axis correctly.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-axis-data, transform-inv
#import "../utils/colour-resolve.typ": apply-alpha
#import "../utils/radial.typ": radial-point
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

/// Straight reference line described by slope and intercept.
///
/// The line runs across the full trained x domain. Requires continuous x and y scales; discrete scales are skipped silently.
///
/// - slope: Line slope.
/// - intercept: Line y intercept.
/// - colour: Line colour. `auto` inherits the theme `ink`.
/// - stroke: Line thickness (a Typst length).
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. Defaults to `"solid"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-hline`, `geom-vline`, `geom-smooth`.
///
/// The `y = x` identity reference line over a noisy point cloud.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i + calc.rem(i, 2)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-abline(slope: 1, intercept: 0, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Adjust `slope` and `intercept` to anchor a custom regression reference.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: 0.7 * i + 1 + calc.sin(i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-abline(slope: 0.7, intercept: 1, colour: rgb("#1b9e77")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-abline(
  slope: 1,
  intercept: 0,
  colour: auto,
  stroke: auto,
  alpha: auto,
  linetype: "solid",
  inherit-aes: false,
) = make-layer(
  "abline",
  params: (
    slope: slope,
    intercept: intercept,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    linetype: linetype,
  ),
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let flipped = ctx.at("flipped", default: false)
  // Under flip, the renderer has already swapped trained.x and trained.y so
  // the user's original x scale lives on trained.y and vice versa. The
  // slope/intercept are in user-space, so user_x is sampled along the
  // user's original x domain (which is now `trained.y.domain`) and the
  // resulting user_y is mapped through the user's y scale (now trained.x).
  let user-x-trained = ctx.trained.at(
    if flipped { "y" } else { "x" },
    default: none,
  )
  let user-y-trained = ctx.trained.at(
    if flipped { "x" } else { "y" },
    default: none,
  )
  if user-x-trained == none or user-y-trained == none { return }
  if (
    user-x-trained.type != "continuous" or user-y-trained.type != "continuous"
  ) {
    return
  }
  // Sample slope/intercept in data space, regardless of any pre-stat warp.
  let _data-domain(t) = if t.at("pre-transformed", default: false) {
    let n = t.at("transform", default: "identity")
    (transform-inv(n, t.domain.at(0)), transform-inv(n, t.domain.at(1)))
  } else { t.domain }
  let (x-lo, x-hi) = _data-domain(user-x-trained)
  let slope = float(layer.params.slope)
  let intercept = float(layer.params.intercept)
  let colour = if layer.params.colour == auto {
    resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  } else { layer.params.colour }
  let mapping = (ctx.resolve-mapping)(layer)
  let alpha = resolve-channel("alpha", layer, mapping, ctx, (:), 1)
  let fill = apply-alpha(colour, alpha)
  let thickness = resolve-channel(
    "linewidth",
    layer,
    mapping,
    ctx,
    (:),
    0.6pt,
  )
  let stroke-spec = (
    paint: fill,
    thickness: thickness,
    dash: layer.params.linetype,
  )
  // user_x maps to the horizontal axis when not flipped, and to the vertical
  // axis when flipped; `_pos` returns the cetz `(cx, cy)` for a user-space
  // point and routes each coordinate to the right pixel range.
  let _pos(ux, uy) = if flipped {
    (
      map-axis-data(user-y-trained, uy, ctx.px-range),
      map-axis-data(user-x-trained, ux, ctx.py-range),
    )
  } else {
    (
      map-axis-data(user-x-trained, ux, ctx.px-range),
      map-axis-data(user-y-trained, uy, ctx.py-range),
    )
  }
  let radial = ctx.at("radial", default: none)
  if radial != none {
    let n = 128
    let pts = range(0, n)
      .map(i => {
        let t = i / (n - 1)
        let x = x-lo + t * (x-hi - x-lo)
        let y = slope * x + intercept
        radial-point(x, y, radial)
      })
      .filter(p => p != none)
    if pts.len() < 2 { return }
    cetz.draw.line(..pts, stroke: stroke-spec)
    return
  }
  let x-transform = user-x-trained.at("transform", default: "identity")
  let y-transform = user-y-trained.at("transform", default: "identity")
  if x-transform != "identity" or y-transform != "identity" {
    let n = 64
    let pts = range(0, n).map(i => {
      let t = i / (n - 1)
      let x = x-lo + t * (x-hi - x-lo)
      let y = slope * x + intercept
      _pos(x, y)
    })
    cetz.draw.line(..pts, stroke: stroke-spec)
  } else {
    let y-at-lo = slope * x-lo + intercept
    let y-at-hi = slope * x-hi + intercept
    cetz.draw.line(
      _pos(x-lo, y-at-lo),
      _pos(x-hi, y-at-hi),
      stroke: stroke-spec,
    )
  }
}
