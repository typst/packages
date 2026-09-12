///! Parametric ellipse geom: one ellipse per data row.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": project-point
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../theme/theme.typ": (
  geom-colour-default, geom-default, geom-defaults, geom-fill-default,
  geom-linewidth,
)

/// Ellipse layer: draws one closed ellipse per row from `(x0, y0, a, b, angle)`.
///
/// `x0`/`y0` give the centre in data units; `a`/`b` are the semi-major and
/// semi-minor radii in data units; `angle` is the rotation in radians from
/// the x axis. Each row is sampled into a 64-vertex polygon and rendered
/// through the polygon draw path.
///
/// \@category Geoms
/// \@subcategory Polygons and shapes
/// \@stability stable
/// \@since 0.4.0
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x0`, `y0`. `a`, `b`, and `angle` may be mapped or left to the layer-level fallbacks.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param a Layer-level semi-major radius in data units used when `aes(a: ...)` is not mapped.
///
/// \@param b Layer-level semi-minor radius in data units used when `aes(b: ...)` is not mapped.
///
/// \@param angle Layer-level rotation in radians used when `aes(angle: ...)` is not mapped.
///
/// \@param n Number of polygon vertices sampled around the ellipse.
///
/// \@param colour Fixed outline colour. `auto` resolves via the colour scale.
///
/// \@param fill Fixed fill colour. `auto` resolves via the fill scale.
///
/// \@param stroke Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
///
/// \@param alpha Fill opacity in `[0, 1]`.
///
/// \@param stat Statistical transform name. Usually `"identity"`.
///
/// \@param position Position adjustment name. Usually `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Two ellipses with different radii and rotation.
/// ```
/// //| alt: "Two filled ellipses with different centres, semi-axes a and b, and rotation angles rendered as polygons."
/// #let d = (
///   (x0: 0, y0: 0, a: 2, b: 1, angle: 0),
///   (x0: 1, y0: 1, a: 1, b: 0.5, angle: calc.pi / 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x0: "x0", y0: "y0", a: "a", b: "b", angle: "angle"),
///   layers: (geom-ellipse(alpha: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-polygon, \@geom-segment
#let geom-ellipse(
  mapping: none,
  data: none,
  a: 1,
  b: 1,
  angle: 0,
  n: 64,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "ellipse",
  mapping: mapping,
  data: data,
  params: (
    a: a,
    b: b,
    angle: angle,
    n: n,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let _row-num(row, col, fallback) = {
  if col == none { return fallback }
  let v = parse-number(row.at(col, default: none))
  if v == none { fallback } else { v }
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x0-col = mapping.at("x0", default: none)
  let y0-col = mapping.at("y0", default: none)
  if x0-col == none or y0-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let a-col = mapping.at("a", default: none)
  let b-col = mapping.at("b", default: none)
  let angle-col = mapping.at("angle", default: none)
  let a-fallback = layer.params.a
  let b-fallback = layer.params.b
  let angle-fallback = layer.params.angle
  let n = layer.params.n

  let g-defaults = geom-defaults(ctx.theme)
  let default-thickness = geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    geom-colour-default(g-defaults),
    geom-fill-default(g-defaults, role: "tint"),
  )

  for row in data {
    let x0 = _row-num(row, x0-col, none)
    let y0 = _row-num(row, y0-col, none)
    if x0 == none or y0 == none { continue }
    let a = _row-num(row, a-col, a-fallback)
    let b = _row-num(row, b-col, b-fallback)
    let theta = _row-num(row, angle-col, angle-fallback)
    let cos-t = calc.cos(theta)
    let sin-t = calc.sin(theta)

    let pts = ()
    for i in range(0, n) {
      let u = 2 * calc.pi * i / n
      let cu = calc.cos(u)
      let su = calc.sin(u)
      let dx = a * cu * cos-t - b * su * sin-t
      let dy = a * cu * sin-t + b * su * cos-t
      let p = project-point(ctx, x0 + dx, y0 + dy)
      if p == none { continue }
      pts.push(p)
    }
    if pts.len() < 3 { continue }

    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
      colour-fallback: false,
      default-alpha: 0.6,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )

    cetz.draw.line(
      ..pts,
      close: true,
      fill: final-fill,
      stroke: stroke-spec,
    )
  }
}
