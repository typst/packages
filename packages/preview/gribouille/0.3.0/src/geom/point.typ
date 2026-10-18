///! Scatterplot markers.
///!
///! Draws one shape per row at the `(x, y)` position from the aesthetic
///! mapping. `fill` paints the marker body; `colour` paints the outline.
///! Size, shape, and alpha can each be mapped or set as fixed layer
///! parameters.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/palette.typ": default-shapes, palette-at, spec-palette
#import "../utils/level-resolve.typ": bin-index
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": project-point
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../guide/draw-marker.typ": draw-marker
#import "../utils/late-binding.typ": after-scale-source, apply-after-scale
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

/// Scatterplot layer drawing a marker for each row at `(x, y)`.
///
/// Default `stat` is `"identity"` and default `position` is `"identity"`. `fill` paints the marker body; `colour` paints the outline. Shape and alpha can be mapped via `aes` or set to fixed values through the layer parameters below.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Marker size (a Typst length).
/// - colour: Fixed marker outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Marker body fill. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Marker outline thickness (a Typst length) or stroke dictionary; `none` disables the outline and the `colour` aesthetic.
/// - alpha: Marker opacity in `[0, 1]`.
/// - shape: Marker shape keyword (e.g., `"circle"`, `"square"`, `"triangle"`). `auto` honours the shape scale.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - stat: Statistical transform name. Usually left at `"identity"`.
/// - position: Position adjustment name. Usually left at `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-line`, `geom-text`, `scale-shape`, `aes`.
///
/// Default scatter, mapping `fill` to a categorical column.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "a"),
///   (x: 4, y: 5, sp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "sp"),
///   layers: (geom-point(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `shape` and `size` alongside `fill` to encode three dimensions on the same scatter.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a", w: 1),
///   (x: 2, y: 4, sp: "b", w: 2),
///   (x: 3, y: 3, sp: "a", w: 3),
///   (x: 4, y: 5, sp: "b", w: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "sp", shape: "sp", size: "w"),
///   layers: (geom-point(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// The classic penguins scatter: flipper length vs body mass, coloured and shaped by species.
///
/// ```typst
/// #plot(
///   data: penguins,
///   mapping: aes(
///     x: "flipper-len",
///     y: "body-mass",
///     fill: "species",
///     shape: "species",
///   ),
///   layers: (geom-point(size: 2pt, alpha: 0.85),),
///   labs: labs(
///     x: "Flipper Length (mm)",
///     y: "Body Mass (g)",
///     fill: "Species",
///     shape: "Species",
///   ),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
///
/// A second layer passes a function as `data`; it receives the plot data and returns the subset to emphasise, here the heaviest penguins.
///
/// ```typst
/// #plot(
///   data: penguins,
///   mapping: aes(x: "flipper-len", y: "body-mass"),
///   layers: (
///     geom-point(alpha: 0.4),
///     geom-point(
///       data: rows => rows.filter(r => {
///         let mass = r.at("body-mass", default: none)
///         mass != none and mass >= 5500
///       }),
///       size: 3pt,
///       colour: orange,
///     ),
///   ),
///   labs: labs(x: "Flipper Length (mm)", y: "Body Mass (g)"),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
#let geom-point(
  mapping: none,
  data: none,
  size: auto,
  colour: auto,
  fill: auto,
  stroke: auto,
  alpha: auto,
  shape: auto,
  key: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "point",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
    shape: shape,
  ),
  key: key,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  if layer.params.shape == none { return }
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults),
    resolve-geom-fill(g-defaults, role: "paper"),
  )

  let shape-param = layer.params.shape
  let shape-pinned = shape-param != auto
  let shape-spec = mapping.at("shape", default: none)
  let shape-col = after-scale-source(shape-spec)
  let shape-trained = ctx.trained.at("shape", default: none)
  let shape-palette = spec-palette(shape-trained, default-shapes)
  let default-shape-kind = if shape-pinned { shape-param } else { "circle" }

  // Hoist layer-constant fields used by the per-row binned-shape resolver.
  let shape-scale-spec = if shape-trained == none { none } else {
    shape-trained.at("spec", default: none)
  }
  let shape-binned = (
    shape-scale-spec != none and shape-scale-spec.at("binned", default: false)
  )
  let shape-bin-lo = if shape-binned { shape-trained.domain.at(0) } else { 0 }
  let shape-bin-hi = if shape-binned { shape-trained.domain.at(1) } else { 0 }
  let shape-bin-n = if shape-binned {
    shape-scale-spec.at("n-breaks", default: 4)
  } else { 4 }

  for row in data {
    let projected = project-point(
      ctx,
      row.at(mapping.x, default: none),
      row.at(mapping.y, default: none),
    )
    if projected == none { continue }
    let (cx, cy) = projected
    let size = resolve-channel("size", layer, mapping, ctx, row, 1.5pt)
    let body-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )
    let shape-kind = if shape-pinned {
      shape-param
    } else if shape-col == none or shape-trained == none {
      default-shape-kind
    } else if shape-trained.type == "identity" {
      let v = row.at(shape-col, default: none)
      if v == none or v == "" { default-shape-kind } else { str(v) }
    } else if shape-binned {
      let raw = row.at(shape-col, default: none)
      if raw == none { default-shape-kind } else {
        palette-at(
          shape-palette,
          bin-index(raw, shape-bin-lo, shape-bin-hi, shape-bin-n),
        )
      }
    } else {
      let idx = shape-trained.domain.position(v => (
        v == str(row.at(shape-col, default: none))
      ))
      if idx == none { default-shape-kind } else {
        palette-at(shape-palette, idx)
      }
    }
    let final-shape = apply-after-scale(shape-kind, shape-spec, ctx, row)
    draw-marker((cx, cy), final-shape, size, body-fill, stroke-spec)
  }
}
