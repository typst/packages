// Aesthetic mapping resolution.
//
// Aesthetic mapping values arrive in three shapes:
//
// - A plain column-name string: `aes(x: "col")`.
// - A `mapping-ref` produced by `as-factor`/`as-numeric`: forces the
//   scale type without changing the resolved value.
// - A `typst-markup` produced by `typst()`: marks the value for
//   evaluation as Typst markup wherever the scale renders text.
//
// The two tagged shapes compose: `typst(as-factor("col"))` is a
// `typst-markup` whose `source` is a `mapping-ref`, and the helpers
// below walk such chains innermost-first.

#import "typst-markup.typ": eval-as-markup
#import "late-binding.typ": is-late-binding
#import "errors.typ": fail
#import "colour-resolve.typ": (
  resolve-alpha, resolve-linewidth, resolve-size, resolve-stroke-colour,
  resolve-stroke-width,
)
#import "fill-resolve.typ": resolve-fill-colour
#import "linetype-resolve.typ": resolve-linetype

/// Strip `mapping-ref` wrappers but preserve `typst-markup` intent.
///
/// Returns the value with every `mapping-ref` collapsed to its inner reference; if a `typst-markup` is present at any level the result is a single `typst-markup` whose `source` is the underlying column name or value. Plain strings and unrecognised values pass through.
///
/// - spec: An aesthetic mapping value.
///
/// Returns: A column-name string, a `typst-markup` dict, or `spec` unchanged when neither tag applies.
#let unwrap-mapping-refs(spec) = {
  if type(spec) != dictionary { return spec }
  let kind = spec.at("kind", default: none)
  if kind == "mapping-ref" {
    return unwrap-mapping-refs(spec.at("var", default: none))
  }
  if kind == "typst-markup" {
    let source = spec.at("source", default: none)
    let inner = unwrap-mapping-refs(source)
    if (
      type(inner) == dictionary
        and inner.at("kind", default: none) == "typst-markup"
    ) {
      return inner
    }
    if inner == source { return spec }
    return (kind: "typst-markup", source: inner)
  }
  spec
}

/// Return the underlying column name from an aesthetic mapping value.
///
/// Walks both `mapping-ref` and `typst-markup` wrappers and returns the innermost string. Returns the input unchanged when no tag applies, or `none` for `none`.
///
/// - spec: An aesthetic mapping value.
///
/// Returns: The column-name string or `none`.
#let aes-col(spec) = {
  if spec == none { return none }
  if is-late-binding(spec) { return none }
  let unwrapped = unwrap-mapping-refs(spec)
  if (
    type(unwrapped) == dictionary
      and unwrapped.at("kind", default: none) == "typst-markup"
  ) {
    let src = unwrapped.source
    if type(src) == str { return src }
    return none
  }
  if type(unwrapped) == str { return unwrapped }
  none
}

/// Build a stat output mapping by preserving the input's grouping aesthetics (`fill`, `colour`, `group`, `linetype`, `shape`, ...) and overriding only the synthesised columns the stat publishes.
///
/// Falls back to an empty dict when `input-mapping` is `none`, so callers can still publish their synthesised x/y/etc. columns to downstream layers.
///
/// - input-mapping: Aesthetic mapping or `none`.
/// - overrides: Dictionary of `(aes-name, column-name)` pairs to apply on top of the preserved mapping.
///
/// Returns: Mapping dict suitable for a stat's `apply()` return.
#let stat-output-mapping(input-mapping, overrides) = {
  let out = if input-mapping == none { (:) } else { input-mapping }
  for (key, value) in overrides {
    out.insert(key, value)
  }
  out
}

/// Dispatch per-row resolution to the appropriate channel resolver.
///
/// Geoms call this once per (channel, row) instead of importing each per-aesthetic resolver directly. `default` is the channel-specific fallback value (a colour for `colour`/`fill`, a length for `size`/`linewidth`/`stroke`, a scalar for `alpha`); the `linetype` channel ignores `default` because the resolver's own `"solid"` fallback covers it. Extra named arguments are forwarded to the underlying resolver, supporting `colour-fallback:` / `default-alpha:` / `fill-mapping:` on the fill path.
///
/// - channel: Channel name (`"colour"`, `"fill"`, `"size"`, `"alpha"`, `"linewidth"`, `"stroke"`, `"linetype"`).
/// - layer: The layer dictionary providing `params.<channel>`.
/// - mapping: The resolved aesthetic mapping.
/// - ctx: The plot context exposing `trained`, `resolve-colour`, and `palette`.
/// - row: The current row.
/// - default: Channel-specific fallback (ignored for `linetype`).
/// - extra: Extra named arguments forwarded to the resolver.
///
/// Returns: The resolved channel value.
#let resolve-channel(channel, layer, mapping, ctx, row, default, ..extra) = {
  if channel == "colour" {
    resolve-stroke-colour(layer, mapping, ctx, row, default)
  } else if channel == "fill" {
    resolve-fill-colour(layer, mapping, ctx, row, default, ..extra)
  } else if channel == "size" {
    resolve-size(layer, mapping, ctx, row, default)
  } else if channel == "alpha" {
    resolve-alpha(layer, mapping, ctx, row, default-alpha: default, ..extra)
  } else if channel == "linewidth" {
    resolve-linewidth(layer, mapping, ctx, row, default)
  } else if channel == "stroke" {
    resolve-stroke-width(layer, mapping, ctx, row, default)
  } else if channel == "linetype" {
    resolve-linetype(layer, mapping, ctx, row)
  } else {
    fail("resolve-channel", "unsupported channel '" + channel + "'")
  }
}

/// Resolve a break-display label by combining the scale's `labels:` override (function or array) and a typst-mark eval pass.
///
/// Resolution order:
///
/// - When `labels` is a function: call `labels(value)`.
/// - When `labels` is an array and `idx` is in range: index it.
/// - Otherwise: use `fallback`.
///
/// If the resolved label is a string and `typst-mark` is `true`, the string is evaluated as Typst markup. Content and other types pass through. Callbacks may return `none` to signal "drop this break"; the `coord-radial` cyclic-wrap merge filters `none` out of merged labels (other tick/legend sites currently render `none` as empty content).
///
/// - labels: A function, array, `auto`, or `none`.
/// - value: The break value (passed to a function callback).
/// - idx: Zero-based index of the break in its enumeration.
/// - fallback: Default label when neither callback nor array applies.
/// - typst-mark: Whether the originating aesthetic is typst-tagged.
///
/// Returns: The resolved label, possibly evaluated as Typst markup.
#let resolve-label(labels, value, idx, fallback, typst-mark: false) = {
  let txt = if type(labels) == function {
    labels(value)
  } else if type(labels) == array and idx < labels.len() {
    labels.at(idx)
  } else { fallback }
  if typst-mark and type(txt) == str { eval-as-markup(txt) } else { txt }
}

/// Merge a layer's aesthetic mapping with the plot-level mapping.
///
/// Layer keys override plot keys when present; `inherit-aes: false` on the layer drops the plot mapping entirely (so the layer mapping replaces it). `mapping-ref`/`typst-markup` annotations are preserved unchanged so downstream callers that rely on forced types still see them.
///
/// - layer: Layer dict.
/// - plot-mapping: Plot-level mapping dict (or `none`).
///
/// Returns: Merged mapping dict (or `none` when both layer and plot have no mapping).
#let merge-mapping(layer, plot-mapping) = {
  let mapping = layer.at("mapping", default: none)
  if layer.at("inherit-aes", default: true) and plot-mapping != none {
    let m = plot-mapping
    if mapping != none {
      for (k, v) in mapping.pairs() {
        if v != none { m.insert(k, v) }
      }
    }
    return m
  }
  if mapping != none { return mapping }
  plot-mapping
}
