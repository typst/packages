///! One-line annotations attached to a single inline observation.
///!
///! `annotate(geom, ..fields)` builds a layer whose data is a single row,
///! whose mapping points each aesthetic kwarg name at the matching column,
///! and whose `inherit-aes` is `false`. Use it for ad-hoc reference marks
///! (a labelled point, a vertical guide line, a corner caption, ...) that
///! should not be driven by the plot-level data or mapping.

#import "aes.typ": aes
#import "geom/text.typ": geom-text
#import "utils/errors.typ": fail, fail-enum
#import "geom/typst.typ": geom-typst
#import "geom/point.typ": geom-point
#import "geom/label.typ": geom-label
#import "geom/segment.typ": geom-segment
#import "geom/rect.typ": geom-rect
#import "geom/vline.typ": geom-vline
#import "geom/hline.typ": geom-hline
#import "geom/abline.typ": geom-abline
#import "utils/typst-markup.typ": is-typst-markup, typst

// Default kwarg names treated as aesthetic mappings (everything else is
// forwarded to the geom constructor as a layer parameter, e.g., `stroke`,
// `fontsize`).
#let _default-aes-keys = (
  "x",
  "y",
  "xend",
  "yend",
  "xmin",
  "xmax",
  "ymin",
  "ymax",
  "colour",
  "fill",
  "size",
  "alpha",
  "shape",
  "linetype",
  "label",
  "group",
  "slope",
  "intercept",
)

// `text` and `label` geoms take `size` as a Typst length layer parameter
// (the text size), not an aesthetic mapping; route it accordingly.
#let _aes-keys-for(geom) = {
  if geom == "text" or geom == "label" or geom == "typst" {
    _default-aes-keys.filter(k => k != "size")
  } else {
    _default-aes-keys
  }
}

#let _geom-table = (
  text: geom-text,
  typst: geom-typst,
  point: geom-point,
  label: geom-label,
  segment: geom-segment,
  rect: geom-rect,
  vline: geom-vline,
  hline: geom-hline,
  abline: geom-abline,
)

// Geoms that do not accept a `data` / `mapping` pair. Every kwarg must go
// straight to the constructor as a layer parameter for these.
#let _params-only = ("vline", "hline", "abline")

/// Build a one-row annotation layer dispatching to a named geom.
///
/// Splits keyword arguments into two groups: those whose names match an aesthetic channel (see `_aes-keys`) become a single-row inline dataset plus an aesthetic mapping pointing each channel at the matching column, and the remainder are forwarded verbatim to the geom constructor as layer parameters. The resulting layer always has `inherit-aes: false` so it does not pick up the plot-level mapping.
///
/// - geom: Geom name to dispatch to. One of `"text"`, `"point"`, `"label"`, `"segment"`, `"rect"`, `"vline"`, `"hline"`, `"abline"`.
/// - clip: Whether the annotation is clipped to the plot area. `true` (default) clips like any other layer; `false` lets the annotation overflow the panel, e.g., a corner inset or a mark placed past the axis limits. Unclipped annotations are drawn above every clipped layer regardless of their position in `layers`, so they read as deliberate overlays. A `clip: false` annotation is also exempt from the out-of-range pre-pass, so a position outside the scale `limits` is kept instead of dropped.
/// - fields: Named arguments split between aesthetics and layer parameters. Aesthetic names are `x`, `y`, `xend`, `yend`, `xmin`, `xmax`, `ymin`, `ymax`, `colour`, `fill`, `size`, `alpha`, `shape`, `linetype`, `label`, `group`, `slope`, `intercept`. For `geom = "text"` and `geom = "label"`, `size` is treated as a layer parameter (the text size, a Typst length) rather than an aesthetic. Anything else (e.g., `stroke`, `fontsize`, `xintercept`, `yintercept`) is forwarded to the geom constructor as a layer parameter.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `aes`, `geom-text`, `geom-point`, `geom-label`, `geom-segment`, `geom-rect`, `geom-vline`, `geom-hline`, `geom-abline`.
///
/// Inline text plus a vertical reference line at the same x.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     annotate("text", x: 5, y: 4, label: "peak"),
///     annotate("vline", xintercept: 5, colour: rgb("#cc0000")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Highlight a region with a translucent rectangle and a boxed label callout.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     annotate(
///       "rect",
///       xmin: 3, xmax: 6, ymin: 1, ymax: 3.5,
///       fill: rgb("#fff7e6"), alpha: 0.5,
///     ),
///     geom-point(size: 2pt),
///     annotate("label", x: 4.5, y: 3.2, label: "window"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let annotate(geom, ..fields) = {
  if geom not in _geom-table {
    fail-enum("annotate", "geom", geom, _geom-table.keys())
  }
  if fields.pos().len() != 0 {
    fail(
      "annotate",
      "positional arguments are not supported",
      hint: "Use named arguments.",
    )
  }

  let constructor = _geom-table.at(geom)

  // `clip` is a layer-level field, not a geom parameter; pull it out so it never
  // reaches the constructor (which would reject the unexpected argument) and
  // stamp it on the built layer instead.
  let named = fields.named()
  let clip = named.at("clip", default: true)
  let _ = named.remove("clip", default: none)
  let with-clip = layer => {
    layer.clip = clip
    layer
  }

  if geom in _params-only {
    return with-clip(constructor(..named, inherit-aes: false))
  }

  let aes-keys = _aes-keys-for(geom)
  let row = (:)
  let mapping-args = (:)
  let layer-args = (:)
  for (k, v) in named.pairs() {
    if k in aes-keys {
      // Preserve a `typst()` tag on the column reference so the geom
      // evaluates the value as Typst markup; the row stores the unwrapped
      // source string.
      if is-typst-markup(v) {
        row.insert(k, v.source)
        mapping-args.insert(k, typst(k))
      } else {
        row.insert(k, v)
        mapping-args.insert(k, k)
      }
    } else {
      layer-args.insert(k, v)
    }
  }

  let mapping = if mapping-args.len() > 0 { aes(..mapping-args) } else { none }
  let data = if row.len() > 0 { (row,) } else { none }

  with-clip(constructor(
    ..layer-args,
    data: data,
    mapping: mapping,
    inherit-aes: false,
  ))
}
