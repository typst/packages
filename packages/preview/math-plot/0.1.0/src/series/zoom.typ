// Zoom/spy inset series constructor.

#import "../transform.typ": to-cm

/// Creates a magnified inset (spy plot) of a rectangular region of the main
/// plot. The source region is highlighted and connected to the inset by
/// optional guide lines.
#let zoom(

  /// Source region as `(x1, y1, x2, y2)` in data coordinates. Required
  /// unless both `center` and `size` are given.
  /// -> auto | array
  region: auto,

  /// Center of the source region as `(x, y)` in data coordinates. Used
  /// together with `size` as an alternative to `region`.
  /// -> auto | array
  center: auto,

  /// Half-extent of the source region (as a length) when using `center`.
  /// -> auto | length
  size: auto,

  /// Position `(x, y)` in data coordinates where the inset box is placed.
  /// When `auto`, positioned automatically.
  /// -> auto | array
  at: auto,

  /// Width of the inset box. When `auto`, derived from `magnification`.
  /// -> auto | length
  width: auto,

  /// Height of the inset box. When `auto`, derived from `magnification`.
  /// -> auto | length
  height: auto,

  /// Magnification factor for the inset. When `auto`, computed from the
  /// inset box size and source region extent.
  /// -> auto | float
  magnification: auto,

  /// Shape of the source-region highlight: `"rect"` or `"circle"`.
  /// -> str
  lens-shape: "rect",

  /// Whether to draw guide lines connecting the source region to the inset.
  /// -> bool
  connect: true,

  /// Accent color for the region highlight, inset border, and connectors.
  /// -> color
  accent: rgb("#4a90d9"),

  /// Fill color for the source-region highlight. When `auto`, derived from
  /// `accent` with transparency.
  /// -> auto | color | none
  region-fill: auto,

  /// Stroke style for the source-region highlight. When `auto`, derived
  /// from `accent`.
  /// -> auto | stroke
  region-stroke: auto,

  /// Stroke style for the inset box border. When `auto`, derived from
  /// `accent`.
  /// -> auto | stroke
  box-stroke: auto,

  /// Fill color for the inset box background.
  /// -> color
  box-fill: white,

  /// Stroke style for the connector lines. When `auto`, derived from
  /// `accent`.
  /// -> auto | stroke | none
  connector-stroke: auto,

  /// Fill color for the connector polygon. `none` disables fill.
  /// -> color | none
  connector-fill: none,

  /// Drop shadow behind the inset box. When `auto`, a subtle shadow is
  /// applied.
  /// -> auto | none | dictionary
  shadow: auto,

  /// Whether to draw a coordinate grid inside the inset.
  /// -> bool
  show-inset-grid: true,

  /// Whether to display the magnification factor as a label on the inset.
  /// -> bool
  show-magnification: false,

  /// Legend label for this element. `none` omits it from the legend.
  /// -> content | none
  label: none,
) = {
  assert(region != auto or (center != auto and size != auto),
    message: "zoom() requires either 'region: (x1,y1,x2,y2)' or both 'center' and 'size'")
  let eff-region = if region != auto {
    region
  } else {
    let (cx, cy) = center
    (cx, cy, cx, cy)
  }
  let spec = (
    zoom-region: eff-region,
    at: at,
    lens-shape: lens-shape,
    connect: connect,
    accent: accent,
    connector-fill: connector-fill,
    show-inset-grid: show-inset-grid,
    show-magnification: show-magnification,
    label: label,
  )
  if center != auto           { spec.insert("zoom-center", center) }
  if size != auto             { spec.insert("zoom-size-cm", to-cm(size)) }
  if width != auto            { spec.insert("zoom-width", to-cm(width)) }
  if height != auto           { spec.insert("zoom-height", to-cm(height)) }
  if magnification != auto    { spec.insert("magnification", magnification) }
  if region-fill != auto      { spec.insert("region-fill", region-fill) }
  if region-stroke != auto    { spec.insert("region-stroke", region-stroke) }
  if box-stroke != auto       { spec.insert("box-stroke", box-stroke) }
  spec.insert("box-fill", box-fill)
  if connector-stroke != auto { spec.insert("connector-stroke", connector-stroke) }
  if shadow != auto           { spec.insert("shadow", shadow) }
  spec
}
