///! Polyline of a callable evaluated across the trained x-domain.
///!
///! Samples `n` points uniformly across the x-range and draws a line through
///! `(x, fun(x))`. The layer ignores any inherited data and mapping; it
///! generates its own samples from `fun`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/errors.typ": fail
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/radial.typ": project-point
#import "../utils/colour-resolve.typ": apply-alpha
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

/// Polyline of `fun(x)` sampled uniformly across the x-range.
///
/// The trained x-domain is used by default; pass `xlim` to override it. `n` samples are taken across that range. Sampled points where `fun` returns `none` are dropped silently.
///
/// - fun: Callable taking a numeric x and returning a numeric y, or `none` to skip.
/// - n: Number of samples taken uniformly across the x-range.
/// - xlim: Optional `(lo, hi)` overriding the trained x-domain.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` falls back to the theme `ink`.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. Defaults to `"solid"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping. Defaults to `false`.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-blank`, `geom-line`, `geom-abline`.
///
/// Sine curve sampled across the trained x-domain.
///
/// ```typst
/// #let frame = ((x: -calc.pi, y: -1), (x: calc.pi, y: 1))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-blank(),
///     geom-function(fun: x => calc.sin(x)),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pass `xlim` to override the domain when the training data does not match the function's natural range.
///
/// ```typst
/// #let frame = ((x: 0, y: 0), (x: 1, y: 1))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-blank(),
///     geom-function(
///       fun: x => calc.sin(x) * 0.5 + 0.5,
///       xlim: (0, 4 * calc.pi),
///       n: 201,
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-function(
  fun: none,
  n: 101,
  xlim: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  inherit-aes: false,
) = {
  if n < 2 {
    fail("geom-function", "n must be at least 2; got " + repr(n))
  }
  make-layer(
    "function",
    data: (),
    params: (
      fun: fun,
      n: n,
      xlim: xlim,
      stroke: stroke,
      colour: colour,
      alpha: alpha,
      linetype: linetype,
    ),
    inherit-aes: inherit-aes,
  )
}

#let draw(layer, ctx) = {
  let fun = layer.params.fun
  if fun == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }
  if x-trained.type != "continuous" or y-trained.type != "continuous" { return }

  let domain = if layer.params.xlim != none {
    layer.params.xlim
  } else { x-trained.domain }
  let (lo, hi) = (float(domain.at(0)), float(domain.at(1)))
  if hi <= lo { return }
  let n = calc.max(2, int(layer.params.n))
  let step = (hi - lo) / (n - 1)

  let pts = ()
  for i in range(0, n) {
    let x = lo + i * step
    let y = fun(x)
    if y == none { continue }
    let p = project-point(ctx, x, float(y))
    if p == none { continue }
    pts.push(p)
  }
  if pts.len() < 2 { return }

  let colour = if layer.params.colour != auto {
    layer.params.colour
  } else {
    resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  }
  let mapping = (ctx.resolve-mapping)(layer)
  let alpha = resolve-channel("alpha", layer, mapping, ctx, (:), 1)
  let final-colour = apply-alpha(colour, alpha)

  let thickness = resolve-channel(
    "linewidth",
    layer,
    mapping,
    ctx,
    (:),
    0.8pt,
  )
  cetz.draw.line(
    ..pts,
    stroke: (
      paint: final-colour,
      thickness: thickness,
      dash: layer.params.linetype,
    ),
  )
}
