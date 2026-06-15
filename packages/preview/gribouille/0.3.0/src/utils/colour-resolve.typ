#import "./level-resolve.typ": (
  continuous-numeric, discrete-index, discrete-numeric, spec-range,
)
#import "./palette.typ": spec-palette
#import "./types.typ": parse-number
#import "./late-binding.typ": after-scale-source, apply-after-scale
#import "../theme/theme.typ": resolve-geom-defaults, resolve-geom-linewidth

/// Resolve `source-col` for `channel` through the channel's trained scale, returning `default` when either is missing.
///
/// - channel: Channel name (`"colour"`, `"fill"`).
/// - source-col: Column to read from the row, or `none`.
/// - ctx: Renderer context exposing `trained`, `resolve-colour`, and `palette`.
/// - row: The current row.
/// - default: Fallback value.
///
/// Returns: The scale-resolved colour, or `default`.
#let _resolve-channel-source(channel, source-col, ctx, row, default) = {
  if source-col == none { return default }
  let trained = ctx.trained.at(channel, default: none)
  if trained == none { return default }
  ((ctx.resolve-colour)(trained, ctx.palette))(
    row.at(source-col, default: none),
  )
}

/// Apply an alpha transparentise to an already-resolved colour.
///
/// Returns `colour` unchanged when `alpha` is `>= 1`, otherwise returns `colour.transparentize((1 - alpha) * 100%)`.
///
/// - colour: A resolved colour value.
/// - alpha: Opacity in `[0, 1]`.
///
/// Returns: The colour with alpha applied.
#let apply-alpha(colour, alpha) = {
  if colour == none { return none }
  if alpha == none { return colour }
  if alpha < 1 { colour.transparentize((1 - alpha) * 100%) } else { colour }
}

#let _clamp(x, lo, hi) = {
  if x < lo { lo } else if x > hi { hi } else { x }
}

/// Resolve a per-row alpha value.
///
/// Priority order: 1. `layer.params.alpha == none` → returns `1` (user opted out of transparency). 2. Pinned `layer.params.alpha` when it is not `auto`. 3. The trained alpha scale (continuous/discrete/identity), if `mapping.alpha` is set. 4. `default-alpha` otherwise (defaults to `1`, geoms with intrinsic translucency pass their own).
///
/// - layer: The layer dictionary providing `params.alpha`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`.
/// - sample-row: The row used to read the alpha value.
/// - default-alpha: Fallback opacity when no pin or mapping applies.
///
/// Returns: A scalar alpha in `[0, 1]`.
#let resolve-alpha(layer, mapping, ctx, sample-row, default-alpha: 1) = {
  let pinned = layer.params.at("alpha", default: auto)
  if pinned == none { return 1 }
  if pinned != auto {
    return _clamp(pinned, 0, 1)
  }
  let fallback = _clamp(default-alpha, 0, 1)
  let spec = if mapping == none { none } else {
    mapping.at("alpha", default: none)
  }
  let col = after-scale-source(spec)
  let trained = ctx.trained.at("alpha", default: none)
  let scaled = if col == none or trained == none { fallback } else {
    let raw = sample-row.at(col, default: none)
    if raw == none { fallback } else if trained.type == "identity" {
      let v = parse-number(raw)
      if v == none { fallback } else { _clamp(v, 0, 1) }
    } else {
      let range = spec-range(trained, (0.1, 1))
      let resolved = if trained.type == "continuous" {
        let v = parse-number(raw)
        if v == none { fallback } else { continuous-numeric(trained, v, range) }
      } else {
        let pal = spec-palette(trained, none)
        if pal != none and pal.len() > 0 {
          let idx = discrete-index(trained, raw)
          if idx == none { fallback } else { pal.at(calc.rem(idx, pal.len())) }
        } else { discrete-numeric(trained, raw, range) }
      }
      if resolved == none { fallback } else { _clamp(resolved, 0, 1) }
    }
  }
  apply-after-scale(scaled, spec, ctx, sample-row)
}

/// Read `col` through the trained linewidth scale, falling back to `default-thickness` when the column or scale is missing.
///
/// - col: Source column name or `none`.
/// - ctx: Plot context exposing `trained`.
/// - sample-row: The row to read.
/// - default-thickness: Fallback length.
///
/// Returns: A Typst length suitable for `stroke.thickness`.
#let _resolve-linewidth-natural(col, ctx, sample-row, default-thickness) = {
  let trained = ctx.trained.at("linewidth", default: none)
  if col == none or trained == none { return default-thickness }
  let raw = sample-row.at(col, default: none)
  if raw == none { return default-thickness }
  if trained.type == "identity" {
    if type(raw) == length { return raw }
    let v = parse-number(raw)
    if v == none { return default-thickness }
    return v * 1pt
  }
  let range = spec-range(trained, (0.4pt, 1.4pt))
  let resolved = if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return default-thickness }
    continuous-numeric(trained, v, range)
  } else {
    let pal = spec-palette(trained, none)
    if pal != none and pal.len() > 0 {
      let idx = discrete-index(trained, raw)
      if idx == none { return default-thickness }
      pal.at(calc.rem(idx, pal.len()))
    } else {
      discrete-numeric(trained, raw, range)
    }
  }
  if resolved == none { default-thickness } else { resolved }
}

/// Resolve a per-row stroke thickness.
///
/// Priority order: 1. `layer.params.linewidth == none` → returns `0pt` (no stroke). 2. Pinned `layer.params.linewidth` when set to a non-`auto` length. 3. The trained linewidth scale, if `mapping.linewidth` is set. 4. Pinned `layer.params.stroke` when set to a length. 5. `theme.geom.linewidth` when the layer's `stroke:` is `auto`. 6. `params.stroke-fallback` when set (used by wrapper layers like `geom-contour` / `geom-quantile` that dispatch through another geom). 7. `default-thickness` otherwise.
///
/// - layer: The layer dictionary providing `params.linewidth`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained` and `theme`.
/// - sample-row: The row used to read the linewidth value.
/// - default-thickness: Per-geom default thickness when no pin or mapping resolves.
///
/// Returns: A Typst length suitable for `stroke.thickness`.
#let resolve-linewidth(layer, mapping, ctx, sample-row, default-thickness) = {
  let pinned-lw = layer.params.at("linewidth", default: auto)
  if pinned-lw == none { return 0pt }
  if pinned-lw != auto and type(pinned-lw) == length {
    return pinned-lw
  }
  let pinned-stroke = layer.params.at("stroke", default: auto)
  let effective-default = if type(pinned-stroke) == length {
    pinned-stroke
  } else if pinned-stroke == auto {
    resolve-geom-linewidth(
      resolve-geom-defaults(ctx.theme),
      fallback: layer.params.at("stroke-fallback", default: default-thickness),
    )
  } else { default-thickness }
  let spec = if mapping == none { none } else {
    mapping.at("linewidth", default: none)
  }
  let col = after-scale-source(spec)
  let scaled = _resolve-linewidth-natural(
    col,
    ctx,
    sample-row,
    effective-default,
  )
  apply-after-scale(scaled, spec, ctx, sample-row)
}

/// Read `col` through the trained stroke scale, falling back to `default-thickness` when the column or scale is missing.
///
/// - col: Source column name or `none`.
/// - ctx: Plot context exposing `trained`.
/// - sample-row: The row to read.
/// - default-thickness: Fallback length.
///
/// Returns: A Typst length suitable for `stroke.thickness`.
#let _resolve-stroke-width-natural(col, ctx, sample-row, default-thickness) = {
  let trained = ctx.trained.at("stroke", default: none)
  if col == none or trained == none { return default-thickness }
  let raw = sample-row.at(col, default: none)
  if raw == none { return default-thickness }
  if trained.type == "identity" {
    if type(raw) == length { return raw }
    let v = parse-number(raw)
    if v == none { return default-thickness }
    return v * 1pt
  }
  let range = spec-range(trained, (0.2pt, 1.4pt))
  let resolved = if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return default-thickness }
    continuous-numeric(trained, v, range)
  } else {
    let pal = spec-palette(trained, none)
    if pal != none and pal.len() > 0 {
      let idx = discrete-index(trained, raw)
      if idx == none { return default-thickness }
      pal.at(calc.rem(idx, pal.len()))
    } else {
      discrete-numeric(trained, raw, range)
    }
  }
  if resolved == none { default-thickness } else { resolved }
}

/// Resolve a per-row marker outline thickness from the `stroke` aesthetic.
///
/// Priority order: 1. Pinned `layer.params.stroke` when set to a length. 2. Pinned stroke dictionary's `thickness` field, when one is supplied. 3. The trained stroke scale, if `mapping.stroke` is set. 4. `default-thickness` otherwise.
///
/// - layer: The layer dictionary providing `params.stroke`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`.
/// - sample-row: The row used to read the stroke value.
/// - default-thickness: Fallback thickness when no mapping or pin applies.
///
/// Returns: A Typst length suitable for `stroke.thickness`.
#let resolve-stroke-width(
  layer,
  mapping,
  ctx,
  sample-row,
  default-thickness,
) = {
  let pinned = layer.params.at("stroke", default: auto)
  if type(pinned) == length { return pinned }
  if type(pinned) == dictionary {
    return pinned.at("thickness", default: default-thickness)
  }
  let spec = if mapping == none { none } else {
    mapping.at("stroke", default: none)
  }
  let col = after-scale-source(spec)
  let scaled = _resolve-stroke-width-natural(
    col,
    ctx,
    sample-row,
    default-thickness,
  )
  apply-after-scale(scaled, spec, ctx, sample-row)
}

/// Read `col` through the trained size scale (with optional `area` transform), falling back to `default-size` when the column or scale is missing.
///
/// - col: Source column name or `none`.
/// - ctx: Plot context exposing `trained`.
/// - sample-row: The row to read.
/// - default-size: Fallback length.
///
/// Returns: A Typst length suitable for a marker radius.
#let _resolve-size-natural(col, ctx, sample-row, default-size) = {
  let trained = ctx.trained.at("size", default: none)
  if col == none or trained == none { return default-size }
  let raw = sample-row.at(col, default: none)
  if raw == none { return default-size }
  if trained.type == "identity" {
    if type(raw) == length { return raw }
    let v = parse-number(raw)
    if v == none { return default-size }
    return v * 1pt
  }
  let range = spec-range(trained, (1pt, 6pt))
  let size-trans = if trained.spec == none { "identity" } else {
    trained.spec.at("size-trans", default: "identity")
  }
  let resolved = if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return default-size }
    if size-trans == "area" {
      let (d-lo, d-hi) = trained.domain
      let (r-lo, r-hi) = range
      if d-hi == d-lo { return (r-lo + r-hi) / 2 }
      let t = (v - d-lo) / (d-hi - d-lo)
      let t-clamped = if t < 0 { 0 } else if t > 1 { 1 } else { t }
      r-lo + calc.sqrt(t-clamped) * (r-hi - r-lo)
    } else {
      continuous-numeric(trained, v, range)
    }
  } else {
    let pal = spec-palette(trained, none)
    if pal != none and pal.len() > 0 {
      let idx = discrete-index(trained, raw)
      if idx == none { return default-size }
      pal.at(calc.rem(idx, pal.len()))
    } else {
      discrete-numeric(trained, raw, range)
    }
  }
  if resolved == none { default-size } else { resolved }
}

/// Resolve a per-row marker size.
///
/// Priority order: 1. `layer.params.size == none` → returns `0pt` (caller should skip the marker). 2. Pinned `layer.params.size` when set to a non-`auto` length. 3. The trained size scale, if `mapping.size` is set. 4. `default-size` otherwise.
///
/// - layer: The layer dictionary providing `params.size`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`.
/// - sample-row: The row used to read the size value.
/// - default-size: Fallback length when no mapping or pin applies.
///
/// Returns: A Typst length suitable for a marker radius.
#let resolve-size(layer, mapping, ctx, sample-row, default-size) = {
  let pinned = layer.params.at("size", default: auto)
  if pinned == none { return 0pt }
  if pinned != auto and type(pinned) == length {
    return pinned
  }
  let spec = if mapping == none { none } else {
    mapping.at("size", default: none)
  }
  let col = after-scale-source(spec)
  let scaled = _resolve-size-natural(col, ctx, sample-row, default-size)
  apply-after-scale(scaled, spec, ctx, sample-row)
}

/// Resolve a stroke colour for a row sample.
///
/// Priority order: 1. `layer.params.colour == none` → returns `none` (user disabled the stroke colour). 2. Pinned `layer.params.colour` when it is not `auto`. 3. The trained colour scale, when `mapping.colour` is set. 4. `default-colour` otherwise.
///
/// Applies the per-row alpha (mapped or pinned) as a transparentise step.
///
/// - layer: The layer dictionary providing `params.colour`/`params.alpha`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// - sample-row: The row used to read the colour value (group leader or per-row).
/// - default-colour: The colour used when no scale resolution applies.
///
/// Returns: A colour ready to use as a stroke paint.
#let resolve-stroke-colour(layer, mapping, ctx, sample-row, default-colour) = {
  let colour-param = layer.params.at("colour", default: auto)
  if colour-param == none { return none }
  let spec = mapping.at("colour", default: none)
  let resolved = if colour-param != auto {
    colour-param
  } else if spec != none {
    _resolve-channel-source(
      "colour",
      after-scale-source(spec),
      ctx,
      sample-row,
      default-colour,
    )
  } else { default-colour }
  resolved = apply-after-scale(resolved, spec, ctx, sample-row)
  let alpha = resolve-alpha(layer, mapping, ctx, sample-row)
  apply-alpha(resolved, alpha)
}
