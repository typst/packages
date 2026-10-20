#import "palette.typ": default-linetypes, palette-at, spec-palette
#import "level-resolve.typ": resolve-binned
#import "late-binding.typ": after-scale-source, apply-after-scale

/// Resolve a per-row linetype dash keyword.
///
/// Priority order: 1. `layer.params.linetype == none` → returns `"solid"` (user opted out of dashing). 2. Pinned `layer.params.linetype` when it is not `auto`. 3. The trained linetype scale, when a `linetype` mapping is set (identity, continuous via binning, or discrete via the palette). 4. `"solid"` otherwise.
///
/// - layer: The layer dictionary providing `params.linetype`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`.
/// - sample-row: The row used to read the linetype value.
///
/// Returns: A dash keyword (e.g., `"solid"`, `"dashed"`).
#let resolve-linetype(layer, mapping, ctx, sample-row) = {
  let linetype-param = layer.params.at("linetype", default: auto)
  if linetype-param == none { return "solid" }
  if linetype-param != auto { return linetype-param }

  let spec = mapping.at("linetype", default: none)
  let linetype-col = after-scale-source(spec)
  let linetype-trained = ctx.trained.at("linetype", default: none)
  let scaled = if linetype-col == none or linetype-trained == none {
    "solid"
  } else {
    let sample = sample-row.at(linetype-col, default: none)
    if linetype-trained.type == "identity" {
      if sample == none or sample == "" { "solid" } else { str(sample) }
    } else if linetype-trained.type == "continuous" {
      let resolved = if sample == none { none } else {
        resolve-binned(linetype-trained, sample, default-linetypes)
      }
      if resolved == none { "solid" } else { resolved }
    } else {
      let palette = spec-palette(linetype-trained, default-linetypes)
      let idx = linetype-trained.domain.position(v => v == str(sample))
      if idx == none { "solid" } else { palette-at(palette, idx) }
    }
  }
  apply-after-scale(scaled, spec, ctx, sample-row)
}
