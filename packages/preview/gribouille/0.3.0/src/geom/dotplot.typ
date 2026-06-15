///! Stacked dot-density plot.
///!
///! Bins observations along x and stacks one dot per observation inside each
///! bin. Backed by \@stat-bindot. Dot diameter is `binwidth * dotsize` in
///! data units on the x-axis and one stack-row in y units.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-position
#import "../stat/bindot.typ": stat-bindot
#import "../utils/colour-resolve.typ": apply-alpha
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": project-point
#import "../utils/types.typ": parse-number
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
)

/// Dotplot layer: one dot per observation, stacked within bins.
///
/// Bins observations along x (default 30 bins), then stacks them upward inside each bin. The dot diameter is `binwidth * dotsize` in data units on the x-axis; `stackratio` controls the vertical spacing between dots (1 means dots touch).
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - bins: Target number of bins when `binwidth` is `none`.
/// - binwidth: Fixed bin width. Overrides `bins` when set.
/// - dotsize: Multiplier on the dot diameter (1 keeps dots equal to `binwidth`).
/// - stackratio: Vertical spacing between dots, in dot diameters. 1 means touching.
/// - fill: Dot fill colour. `auto` resolves via the fill scale.
/// - colour: Dot outline colour. `auto` resolves via the colour scale; only honoured when `stroke` is non-zero.
/// - stroke: Dot outline thickness; `none` means no outline.
/// - alpha: Dot opacity in `[0, 1]`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-bindot`, `geom-histogram`.
///
/// Twelve-bin dotplot of a synthetic distribution.
///
/// ```typst
/// #let d = range(0, 60).map(i => (
///   x: calc.sin(i * 0.27) * 3 + i * 0.08,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-dotplot(bins: 12),),
///   width: 12cm,
///   height: 9cm,
/// )
/// ```
#let geom-dotplot(
  mapping: none,
  data: none,
  bins: 30,
  binwidth: none,
  dotsize: 1.0,
  stackratio: 1.0,
  fill: auto,
  colour: auto,
  stroke: none,
  alpha: auto,
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "dotplot",
  mapping: mapping,
  data: data,
  params: (
    fill: fill,
    colour: colour,
    stroke: stroke,
    alpha: alpha,
    dotsize: dotsize,
  ),
  stat: stat-bindot(bins: bins, binwidth: binwidth, stackratio: stackratio),
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults),
    resolve-geom-fill(g-defaults, role: "ink"),
  )

  // Bin width is uniform across the partition, so the canvas-radius is a
  // plot-wide constant — compute once from the first row and reuse.
  let first = data.at(0, default: none)
  if first == none { return }
  let bin-width = first.at("width", default: none)
  if bin-width == none { return }
  let first-x = parse-number(first.at(mapping.x))
  if first-x == none { return }
  let cx-anchor = map-position(x-trained, first-x, ctx.px-range)
  let cx-edge = map-position(
    x-trained,
    first-x + bin-width / 2,
    ctx.px-range,
  )
  if cx-anchor == none or cx-edge == none { return }
  let radius-cm = (cx-edge - cx-anchor) * layer.params.dotsize
  if radius-cm <= 0 { return }
  let dot-radius = radius-cm * 1cm

  for row in data {
    let p = project-point(ctx, row.at(mapping.x), row.at(mapping.y))
    if p == none { continue }
    let (cx, cy) = p

    let body-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let alpha = resolve-channel("alpha", layer, mapping, ctx, row, 1)
    let outline = if layer.params.stroke == none { none } else {
      (
        paint: apply-alpha(default-colour, alpha),
        thickness: layer.params.stroke,
      )
    }

    cetz.draw.circle(
      (cx, cy),
      radius: dot-radius,
      fill: apply-alpha(body-fill, alpha),
      stroke: outline,
    )
  }
}
