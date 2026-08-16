#import "colour-resolve.typ": (
  _resolve-channel-source, apply-alpha, resolve-alpha,
)
#import "late-binding.typ": after-scale-source, apply-after-scale

/// Resolve a fill colour for a row sample.
///
/// Priority order: 1. `layer.params.fill == none` → returns `none` (user disabled the fill). 2. Fixed `layer.params.fill` when it is not `auto`. 3. The fill scale, when `fill-mapping` is `true`, a fill mapping is set, and the fill scale is trained. 4. `default-fill` otherwise.
///
/// `colour-fallback` is off by default: the `colour` aesthetic drives strokes, not fills, and must be opted into explicitly when a geom truly wants the colour-as-fill fallback.
///
/// Applies the per-row alpha (mapped or fixed) via `apply-alpha` as the final step.
///
/// - layer: The layer dictionary providing `params.fill` and `params.alpha`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// - sample-row: The row used to read the fill or colour value.
/// - default-fill: The colour used when no scale resolution applies.
/// - fill-mapping: Whether to consult the fill mapping and scale.
/// - colour-fallback: Whether to fall back to the colour scale when fill is unmapped.
/// - default-alpha: Fallback opacity passed through to `resolve-alpha` when no pin or mapping applies.
///
/// Returns: A fill colour with alpha applied.
#let resolve-fill-colour(
  layer,
  mapping,
  ctx,
  sample-row,
  default-fill,
  fill-mapping: true,
  colour-fallback: false,
  default-alpha: 1,
) = {
  let fill-param = layer.params.at("fill", default: auto)
  if fill-param == none { return none }
  let fill-spec = if fill-mapping { mapping.at("fill", default: none) } else {
    none
  }
  let resolved = if fill-param != auto {
    fill-param
  } else if not fill-mapping {
    if colour-fallback {
      _resolve-channel-source(
        "colour",
        mapping.at("colour", default: none),
        ctx,
        sample-row,
        default-fill,
      )
    } else { default-fill }
  } else if fill-spec != none {
    _resolve-channel-source(
      "fill",
      after-scale-source(fill-spec),
      ctx,
      sample-row,
      default-fill,
    )
  } else if colour-fallback {
    _resolve-channel-source(
      "colour",
      mapping.at("colour", default: none),
      ctx,
      sample-row,
      default-fill,
    )
  } else { default-fill }
  resolved = apply-after-scale(resolved, fill-spec, ctx, sample-row)
  let alpha = resolve-alpha(
    layer,
    mapping,
    ctx,
    sample-row,
    default-alpha: default-alpha,
  )
  apply-alpha(resolved, alpha)
}
