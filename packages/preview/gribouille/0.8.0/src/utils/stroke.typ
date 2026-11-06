#import "colour-resolve.typ": (
  is-opaque, resolve-stroke-colour, resolve-stroke-width,
)
#import "../theme/theme.typ": default-stroke-thickness

/// Build a CeTZ stroke dictionary by injecting `paint` into a thickness-only stroke spec, or returns `none` when the layer disabled the stroke.
///
/// Accepts the layer's `stroke` parameter in any of three forms:
///
/// - `none` or `0pt`: no stroke is drawn, returns `none`.
/// - a `length`: wraps it into `(paint: stroke-paint, thickness: stroke-param)`.
/// - a dictionary: returns it as is, only filling in `paint` if absent.
///
/// - stroke-param: The layer's `params.stroke` value.
/// - stroke-paint: The resolved stroke colour.
///
/// Returns: A CeTZ stroke dictionary or `none`.
#let build-stroke(stroke-param, stroke-paint) = {
  if stroke-param == none { return none }
  if stroke-paint == none { return none }
  if type(stroke-param) == length {
    if stroke-param == 0pt { return none }
    return (paint: stroke-paint, thickness: stroke-param)
  }
  if type(stroke-param) == dictionary {
    let merged = stroke-param
    if merged.at("paint", default: none) == none {
      merged.insert("paint", stroke-paint)
    }
    return merged
  }
  stroke-param
}

/// Resolve the per-row stroke spec for a dual-aesthetic geom in one step: looks up `params.stroke`, resolves the stroke paint via the colour scale, and wraps the pair via `build-stroke`.
///
/// Returns `none` when the layer disabled the stroke (`params.stroke == none`) or when `default-colour` is `none` (the exclusive-default rule suppressed the stroke because only `fill` is set).
///
/// - params: The layer's resolved parameters, providing `stroke` and `colour`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// - sample-row: The row used to read the colour value.
/// - default-colour: The colour used when no scale resolution applies, or `none` to suppress the stroke entirely.
/// - default-thickness: Fallback stroke thickness when `params.stroke == auto` and no `linewidth` mapping resolves; defaults to `default-stroke-thickness`.
///
/// Returns: A CeTZ stroke dictionary or `none`.
#let resolve-stroke-spec(
  params,
  mapping,
  ctx,
  sample-row,
  default-colour,
  default-thickness: default-stroke-thickness,
) = {
  let stroke-param = params.stroke
  if stroke-param == none { return none }
  let paint = resolve-stroke-colour(
    params,
    mapping,
    ctx,
    sample-row,
    default-colour,
  )
  // When `stroke:` is `auto`, resolve the thickness via the stroke aesthetic
  // (mapping or `default-thickness`). Pinned lengths and dictionaries pass
  // through build-stroke unchanged.
  let resolved-param = if stroke-param == auto {
    resolve-stroke-width(params, mapping, ctx, sample-row, default-thickness)
  } else { stroke-param }
  build-stroke(resolved-param, paint)
}

/// Width of the seam-sealing stroke.
///
/// A centred stroke paints half this width outside the shape, so an abutting neighbour drawn later covers that much of the shape before it. Halving the width to `0.6pt` reopens a faint lattice in dense cell grids at 96 ppi: `geom-bin-2d`, `geom-contour-filled`, and `stat-summary-2d` each show hairlines up to 15/255 lighter than the cells they part. Marks that must not touch, such as dodged bars, take a gap from their position adjustment instead of a thinner seal.
#let seam-seal-thickness = 1.2pt

/// Whether a mark seals its seams: it has no stroke of its own, it can share an edge with another mark, and its fill is fully opaque.
///
/// - stroke-spec: The resolved stroke (from `resolve-stroke-spec`) or `none`.
/// - fill: The resolved fill colour or `none`.
/// - abutting: Whether this mark can share an edge with another.
///
/// Returns: `true` when the seal applies.
#let seals-seam(stroke-spec, fill, abutting: true) = (
  stroke-spec == none and abutting and is-opaque(fill)
)

/// Seal the antialiasing seams between abutting filled shapes.
///
/// The rasteriser antialiases every shared edge of adjacent fills (tiles, hexes, stacked bars and areas, iso-band cells) independently, bleeding the background through as a hairline lattice. When the caller resolved no stroke and the fill is fully opaque, stroke the shape with its own fill so the seams disappear; the same-colour edge is invisible. Translucent fills keep their `none` stroke, as the fill/stroke overlap would darken their rims.
///
/// The seal only pays for itself where marks touch. Elsewhere it eats the whitespace the geom left on purpose: a `geom-tile` grid drawn at `width: 0.9` loses more than half its gap. Callers pass `abutting: false` for marks that cannot touch, such as a tile below its full slot, a bar that neither stacks nor fills, and an unstacked ribbon.
///
/// Stacked bars of `geom-col` do not use this stroke, on a Cartesian panel or under `coord-radial`. The stroke paints outside every side of a bar or a wedge, so a stacked segment would spill onto the bar next to it and into its category gap. Those segments overlap their neighbours by `seam-seal-thickness` instead, where `seals-seam` answers `true`.
///
/// - stroke-spec: The resolved stroke (from `resolve-stroke-spec`) or `none`.
/// - fill: The resolved fill colour or `none`.
/// - abutting: Whether this mark can share an edge with another. `false` suppresses the seal.
///
/// Returns: The stroke to draw with: the input when set, a fill-paint hairline when sealing applies, `none` otherwise.
#let seal-seam(stroke-spec, fill, abutting: true) = {
  if stroke-spec != none { return stroke-spec }
  if not seals-seam(stroke-spec, fill, abutting: abutting) { return none }
  build-stroke(seam-seal-thickness, fill)
}
