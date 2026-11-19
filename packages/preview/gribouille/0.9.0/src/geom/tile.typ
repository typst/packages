///! Centred tiles at `(x, y)` with optional `width` and `height`.
///!
///! Mapping provides `x` and `y`; `width` and `height` may be mapped or fixed.

#import "../position/apply.typ": assert-position
#import "../utils/errors.typ": assert-alpha
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": mapping-ref-col
#import "../utils/types.typ": parse-number
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": radial-wedge
#import "../utils/stroke.typ": resolve-stroke-spec, seal-seam
#import "../utils/band.typ": axis-band
#import "../utils/flip.typ": user-axes, user-columns, user-point
#import "../utils/resolution.typ": resolution
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

// Outer edges of the drawn tiles, `(lo, hi)` per position axis, or `none`
// for an axis with no numeric centre. A row is skipped when its width or
// height is missing, the same as in `draw`.
#let _extents(params, mapping, data) = {
  let col(key) = mapping-ref-col(mapping.at(key, default: none))
  let (x-col, y-col) = (col("x"), col("y"))
  if x-col == none or y-col == none { return (x: none, y: none) }
  let (width-col, height-col) = (col("width"), col("height"))
  let size(row, size-col, fallback) = if size-col == none {
    parse-number(fallback)
  } else { parse-number(row.at(size-col, default: none)) }
  let fold(acc, centre, size) = {
    if centre == none { return acc }
    let (lo, hi) = (centre - size / 2, centre + size / 2)
    if acc == none { return (calc.min(lo, hi), calc.max(lo, hi)) }
    (calc.min(acc.at(0), lo, hi), calc.max(acc.at(1), lo, hi))
  }
  let (x-ext, y-ext) = (none, none)
  for row in data {
    let w = size(row, width-col, params.at("width", default: 1))
    let h = size(row, height-col, params.at("height", default: 1))
    if w == none or h == none { continue }
    x-ext = fold(x-ext, parse-number(row.at(x-col, default: none)), w)
    y-ext = fold(y-ext, parse-number(row.at(y-col, default: none)), h)
  }
  (x: x-ext, y: y-ext)
}

#let spec = (
  reads: ("x", "y", "width", "height", "colour", "fill", "alpha", "stroke"),
  extents: _extents,
)

/// Tile layer: filled rectangle centred at `(x, y)` per row.
///
/// `width` and `height` default to 1 in data units; both may be mapped via `aes` or fixed via the layer parameters.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Default tile width in data units when not mapped. Under `coord-flip`, the width still spans the user's x axis.
/// - height: Default tile height in data units when not mapped. Under `coord-flip`, the height still spans the user's y axis.
/// - colour: Fixed outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Fixed fill colour. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Fill opacity in `[0, 1]`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-rect`.
///
/// Heatmap of `v` values across an integer grid.
///
/// ```typst
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
/// Pair the heatmap with a viridis scale for a perceptually uniform palette.
///
/// ```typst
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
///   scales: scales(fill: scale-viridis-c(option: "magma")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
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
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-tile", position)
  assert-alpha("geom-tile", alpha)
  make-layer(
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
    )
      + split-aes-params("geom-tile", args, spec.reads),
    stat: stat,
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

/// Spacing between neighbouring tile centres on one axis, or `none` when the axis holds a single centre and so has no neighbour to abut.
///
/// One slot on a discrete axis, the smallest gap between distinct values on a continuous one, matching the units `axis-band` reads a half-width in.
///
/// - trained: Trained scale dict for the axis.
/// - values: Tile centres on that axis, one per row.
#let _axis-pitch(trained, values) = {
  let distinct = values.filter(v => v != none).dedup()
  if distinct.len() < 2 { return none }
  if trained.type == "discrete" { return 1 }
  let nums = distinct.map(parse-number).filter(v => v != none)
  if nums.len() < 2 { return none }
  resolution(nums, zero: false)
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  // `width` spans the user's x axis and `height` the user's y axis, so the
  // tile reads its columns and scales in the user's x/y space, which
  // coord-flip draws along the y/x axes.
  let cols = user-columns(mapping, ctx)
  let (x-col, y-col) = (cols.x, cols.y)
  if x-col == none or y-col == none { return }
  let axes = user-axes(ctx)
  if axes == none { return }
  let (x-trained, y-trained) = (axes.x-trained, axes.y-trained)

  let width-col = mapping.at("width", default: none)
  let height-col = mapping.at("height", default: none)
  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults, role: none),
    resolve-geom-fill(g-defaults, role: "tint"),
  )

  // A tile shares an edge only when it fills its slot on both axes. Below
  // that the grid carries deliberate whitespace, which a seam seal would
  // eat, so the seal is suppressed even though it leaves the seams on an
  // axis that does fill its slot.
  let x-pitch = _axis-pitch(x-trained, data.map(r => r.at(
    x-col,
    default: none,
  )))
  let y-pitch = _axis-pitch(y-trained, data.map(r => r.at(
    y-col,
    default: none,
  )))

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
    let abutting = (
      x-pitch != none
        and y-pitch != none
        and w >= x-pitch - 1e-9
        and h >= y-pitch - 1e-9
    )

    let final-fill = resolve-channel(
      "fill",
      layer.params,
      mapping,
      ctx,
      row,
      default-fill,
      colour-fallback: false,
    )
    let stroke-spec = resolve-stroke-spec(
      layer.params,
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
        stroke: seal-seam(stroke-spec, final-fill, abutting: abutting),
      )
    } else {
      let xe = axis-band(x-trained, x, w / 2, axes.x-range)
      let ye = axis-band(y-trained, y, h / 2, axes.y-range)
      if xe == none or ye == none { continue }
      cetz.draw.rect(
        user-point(ctx, xe.at(0), ye.at(0)),
        user-point(ctx, xe.at(1), ye.at(1)),
        fill: final-fill,
        stroke: seal-seam(stroke-spec, final-fill, abutting: abutting),
      )
    }
  }
}
