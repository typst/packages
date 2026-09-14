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

#import "typst-markup.typ": eval-as-markup, is-typst-markup
#import "late-binding.typ": is-late-binding
#import "colour-resolve.typ": (
  resolve-alpha, resolve-linewidth, resolve-size, resolve-stroke-colour,
  resolve-stroke-width,
)
#import "fill-resolve.typ": resolve-fill-colour
#import "linetype-resolve.typ": resolve-linetype

/// Strip `mapping-ref` wrappers but preserve `typst-markup` intent.
///
/// Returns the value with every `mapping-ref` collapsed to its inner
/// reference; if a `typst-markup` is present at any level the result is
/// a single `typst-markup` whose `source` is the underlying column name
/// or value. Plain strings and unrecognised values pass through.
///
/// \@internal
/// \@param spec An aesthetic mapping value.
/// \@returns A column-name string, a `typst-markup` dict, or `spec`
///   unchanged when neither tag applies.
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
/// Walks both `mapping-ref` and `typst-markup` wrappers and returns the
/// innermost string. Returns the input unchanged when no tag applies, or
/// `none` for `none`.
///
/// \@internal
/// \@param spec An aesthetic mapping value.
/// \@returns The column-name string or `none`.
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

/// Read an aesthetic value from a row, optionally evaluating as Typst
/// markup.
///
/// In `mode: "raw"` (the default) the underlying column value is
/// returned, regardless of whether the spec carries a `typst-markup`
/// tag. Used by scale training and the data-to-aesthetic mapping path.
///
/// In `mode: "display"` the resolver eval's the read value as Typst
/// markup when (and only when) the spec carries a `typst-markup` tag at
/// any nesting depth. Used by display surfaces (geom-text labels,
/// legend swatches, axis ticks, facet strip text).
///
/// \@internal
/// \@param spec Aesthetic mapping value (string, `mapping-ref`, or
///   `typst-markup`).
///
/// \@param row The row dictionary to read from.
///
/// \@param mode `"raw"` or `"display"`.
/// \@returns The resolved value, evaluated when in display mode and the
///   spec is typst-tagged.
#let resolve-aes-value(spec, row, mode: "raw") = {
  let col = aes-col(spec)
  if col == none { return none }
  let raw = row.at(col, default: none)
  if mode == "display" and is-typst-markup(spec) {
    return eval-as-markup(raw)
  }
  raw
}

/// Apply display-mode resolution to a pre-read break value.
///
/// Used by display surfaces that hold scale breaks rather than rows
/// (legend swatches, axis tick labels, facet strip text). Evaluates
/// `value` as Typst markup when `spec` is typst-tagged; returns the
/// value unchanged otherwise.
///
/// \@internal
/// \@param spec The originating aesthetic mapping value.
///
/// \@param value The break value to display.
/// \@returns The value, evaluated as markup when the spec is typst-tagged.
#let resolve-break-display(spec, value) = {
  if value == none { return none }
  if is-typst-markup(spec) { return eval-as-markup(value) }
  value
}

/// Build a stat output mapping by preserving the input's grouping aesthetics
/// (`fill`, `colour`, `group`, `linetype`, `shape`, ...) and overriding only
/// the synthesised columns the stat publishes.
///
/// Falls back to an empty dict when `input-mapping` is `none`, so callers can
/// still publish their synthesised x/y/etc. columns to downstream layers.
///
/// \@internal
/// \@param input-mapping Aesthetic mapping or `none`.
///
/// \@param overrides Dictionary of `(aes-name, column-name)` pairs to apply on
///   top of the preserved mapping.
/// \@returns Mapping dict suitable for a stat's `apply()` return.
#let stat-output-mapping(input-mapping, overrides) = {
  let out = if input-mapping == none { (:) } else { input-mapping }
  for (key, value) in overrides {
    out.insert(key, value)
  }
  out
}

/// Dispatch per-row resolution to the appropriate channel resolver.
///
/// Geoms call this once per (channel, row) instead of importing each
/// per-aesthetic resolver directly. `default` is the channel-specific
/// fallback value (a colour for `colour`/`fill`, a length for
/// `size`/`linewidth`/`stroke`, a scalar for `alpha`); the `linetype`
/// channel ignores `default` because the resolver's own `"solid"`
/// fallback covers it. Extra named arguments are forwarded to the
/// underlying resolver, supporting `colour-fallback:` /
/// `default-alpha:` / `fill-mapping:` on the fill path.
///
/// \@internal
/// \@param channel Channel name (`"colour"`, `"fill"`, `"size"`,
///   `"alpha"`, `"linewidth"`, `"stroke"`, `"linetype"`).
///
/// \@param layer The layer dictionary providing `params.<channel>`.
///
/// \@param mapping The resolved aesthetic mapping.
///
/// \@param ctx The plot context exposing `trained`, `resolve-colour`,
///   and `palette`.
///
/// \@param row The current row.
///
/// \@param default Channel-specific fallback (ignored for `linetype`).
///
/// \@param ..extra Extra named arguments forwarded to the resolver.
/// \@returns The resolved channel value.
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
    panic("resolve-channel: unsupported channel '" + channel + "'")
  }
}

/// Resolve a break-display label by combining the scale's `labels:`
/// override (function or array) and a typst-mark eval pass.
///
/// Resolution order:
///
/// - When `labels` is a function: call `labels(value)`.
/// - When `labels` is an array and `idx` is in range: index it.
/// - Otherwise: use `fallback`.
///
/// If the resolved label is a string and `typst-mark` is `true`, the
/// string is evaluated as Typst markup. Content and other types pass
/// through. Callbacks may return `none` to signal "drop this break"; the
/// `coord-radial` cyclic-wrap merge filters `none` out of merged labels
/// (other tick/legend sites currently render `none` as empty content).
///
/// \@internal
/// \@param labels A function, array, `auto`, or `none`.
///
/// \@param value The break value (passed to a function callback).
///
/// \@param idx Zero-based index of the break in its enumeration.
///
/// \@param fallback Default label when neither callback nor array applies.
///
/// \@param typst-mark Whether the originating aesthetic is typst-tagged.
/// \@returns The resolved label, possibly evaluated as Typst markup.
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
/// Layer keys override plot keys when present; `inherit-aes: false` on the
/// layer drops the plot mapping entirely (so the layer mapping replaces it).
/// `mapping-ref`/`typst-markup` annotations are preserved unchanged so
/// downstream callers that rely on forced types still see them.
///
/// \@internal
/// \@param layer Layer dict.
///
/// \@param plot-mapping Plot-level mapping dict (or `none`).
/// \@returns Merged mapping dict (or `none` when both layer and plot have no mapping).
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
