///! Centred tiles at `(x, y)` with optional `width` and `height`.
///!
///! Mapping provides `x` and `y`; `width` and `height` may be mapped or fixed.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": radial-wedge
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../utils/band.typ": axis-band
#import "../theme/theme.typ": (
  geom-colour-default, geom-default, geom-defaults, geom-fill-default,
  geom-linewidth,
)

/// Tile layer: filled rectangle centred at `(x, y)` per row.
///
/// `width` and `height` default to 1 in data units; both may be mapped
/// via \@aes or fixed via the layer parameters.
///
/// \@category Geoms
/// \@subcategory Rectangles and bins
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `y`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param width Default tile width in data units when not mapped.
///
/// \@param height Default tile height in data units when not mapped.
///
/// \@param colour Fixed outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
///
/// \@param fill Fixed fill colour. `auto` resolves via the fill scale or a neutral default.
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
/// \@examples Heatmap of `v` values across an integer grid.
/// ```
/// //| alt: "Heatmap of a 5 by 4 integer grid with tiles centred at each (x, y) shaded by the sum v = x + y via the fill aesthetic."
/// #let d = ()
/// #for x in range(0, 5) {
///   for y in range(0, 4) {
///     d.push((x: x, y: y, v: x + y))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: as-factor("x"), y: as-factor("y"), fill: "v"),
///   layers: (geom-tile(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pair the heatmap with a viridis scale for a perceptually
/// uniform palette.
/// ```
/// //| alt: "Heatmap of a 5 by 4 grid of tiles centred at (x, y) coloured by the product v = x * y via the magma palette."
/// #let d = ()
/// #for x in range(0, 5) {
///   for y in range(0, 4) {
///     d.push((x: x, y: y, v: x * y))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: as-factor("x"), y: as-factor("y"), fill: "v"),
///   layers: (geom-tile(),),
///   scales: (scale-fill-viridis-c(option: "magma"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-rect
#let geom-tile(
  mapping: none,
  data: none,
  width: 1,
  height: 1,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "tile",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    height: height,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let width-col = mapping.at("width", default: none)
  let height-col = mapping.at("height", default: none)
  let g-defaults = geom-defaults(ctx.theme)
  let default-thickness = geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    geom-colour-default(g-defaults, role: none),
    geom-fill-default(g-defaults, role: "tint"),
  )

  // `axis-band` is axis-agnostic despite its name: it builds a centred (lo, hi)
  // pair from a half-width given in data units (continuous) or slot fractions
  // (discrete). Reused here for both x and y.
  let radial = ctx.at("radial", default: none)
  for row in data {
    let x = row.at(x-col, default: none)
    let y = row.at(y-col, default: none)
    if x == none or y == none { continue }
    let w = if width-col != none {
      parse-number(row.at(width-col, default: none))
    } else { layer.params.width }
    let h = if height-col != none {
      parse-number(row.at(height-col, default: none))
    } else { layer.params.height }
    if w == none or h == none { continue }

    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
      colour-fallback: false,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )

    if radial != none {
      let cat-is-theta = radial.cat-is-theta
      let xe = axis-band(x-trained, x, w / 2, if cat-is-theta {
        radial.theta-range
      } else { radial.r-range })
      let ye = axis-band(y-trained, y, h / 2, if cat-is-theta {
        radial.r-range
      } else { radial.theta-range })
      if xe == none or ye == none { continue }
      let (theta-lo, theta-hi, r-lo, r-hi) = if cat-is-theta {
        (xe.at(0), xe.at(1), ye.at(0), ye.at(1))
      } else {
        (ye.at(0), ye.at(1), xe.at(0), xe.at(1))
      }
      if r-lo > r-hi { (r-lo, r-hi) = (r-hi, r-lo) }
      let pts = radial-wedge(theta-lo, theta-hi, r-lo, r-hi, radial)
      cetz.draw.line(
        ..pts,
        close: true,
        fill: final-fill,
        stroke: stroke-spec,
      )
    } else {
      let xe = axis-band(x-trained, x, w / 2, ctx.px-range)
      let ye = axis-band(y-trained, y, h / 2, ctx.py-range)
      if xe == none or ye == none { continue }
      let (cx0, cx1) = xe
      let (cy0, cy1) = ye
      cetz.draw.rect(
        (cx0, cy0),
        (cx1, cy1),
        fill: final-fill,
        stroke: stroke-spec,
      )
    }
  }
}
