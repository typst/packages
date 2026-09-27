// Typst-markup tagging for prose surfaces and aesthetic mappings.
//
// `typst(source)` marks a value for evaluation as Typst markup at render
// time. The same helper is used in two contexts:
//
// - Static prose (titles, captions, axis titles, legend titles): the
//   wrapped string is eval'd as Typst content when the renderer reaches it.
// - Aesthetic mappings (label, colour, fill, x, y, etc.): the wrapped
//   value names the column for the mapping; raw column values drive the
//   scale's logic, and the value is eval'd as Typst markup wherever the
//   scale renders it as visible text.
//
// The tag composes with the existing `mapping-ref` annotations from
// `as-factor`/`as-numeric`: `typst(as-factor("col"))` and
// `as-factor(typst("col"))` both resolve correctly because the resolver
// walks the chain innermost-first.

#import "errors.typ": fail

/// Mark a value for Typst-markup evaluation.
///
/// Inside `aes()`, `typst("col")` names the column to use for the aesthetic mapping; the scale uses raw values for its mapping logic and evaluates each value as Typst markup wherever the scale renders text (legend swatches, axis ticks, geom labels).
///
/// In static-prose surfaces (titles, captions, axis titles, legend titles), `typst("...")` evaluates the wrapped string as markup.
///
/// `source` may be another tagged value (such as `as-factor("col")`) so the helper composes with other aes coercions; the resolver unwraps innermost-first.
///
/// - source: A markup string, a column name, or another tagged aesthetic value.
///
/// Returns: A tagged dictionary the renderer recognises as markup-bearing.
///
/// See also: `as-factor`, `as-numeric`, `aes`.
///
/// Wrap a static title so math renders.
///
/// ```typst
/// #plot(
///   data: (
///     (x: 1, y: 1),
///     (x: 2, y: 4),
///     (x: 3, y: 9),
///   ),
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(),),
///   labs: labs(title: typst("Mean $bar(x)$ over time")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Mark a `label` aesthetic so values render as markup.
///
/// ```typst
/// #plot(
///   data: (
///     (x: 1, y: 1, lab: "$alpha$"),
///     (x: 2, y: 2, lab: "$beta$"),
///     (x: 3, y: 3, lab: "$gamma$"),
///   ),
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-text(mapping: aes(label: typst("lab"))),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let typst(source) = (
  kind: "typst-markup",
  source: source,
)

/// Test whether a value carries a Typst-markup tag at any nesting depth.
///
/// Returns `true` when `value` is a `typst-markup` tagged dictionary, or when it is a `mapping-ref` whose inner `var` is itself typst-tagged. Plain strings, content, and untagged dictionaries return `false`.
///
/// - value: Aesthetic mapping value to inspect.
///
/// Returns: `true` if the value carries a typst-markup tag, else `false`.
#let is-typst-markup(value) = {
  if type(value) != dictionary { return false }
  let kind = value.at("kind", default: none)
  if kind == "typst-markup" { return true }
  if kind == "mapping-ref" {
    return is-typst-markup(value.at("var", default: none))
  }
  false
}

/// Apply Typst-markup evaluation to a value if it carries a typst tag.
///
/// String values pass through eval; content and other types pass through unchanged. Used at display surfaces to honour a typst-tagged aesthetic once a raw value has been read from a row.
///
/// - value: A raw column value (string, int, float, content, etc.).
///
/// Returns: Evaluated Typst content if `value` is a string, else `value`.
#let eval-as-markup(value) = {
  if value == none { return none }
  if type(value) == content { return value }
  eval(str(value), mode: "markup")
}

/// Resolve a static-prose value to Typst content.
///
/// - `none` returns `none`.
/// - String: returned as-is unless `eval-strings` is `true`, in which case it is evaluated as Typst markup. The flag lets callers honour a theme-driven `element-typst()` setting at the call site without a wrapper helper.
/// - Content: returned unchanged. (Typst's content interpolation already renders strings literally and content as content.)
/// - `typst-markup` tagged dictionary whose `source` is a string: the string is eval'd as markup.
/// - `typst-markup` tagged dictionary whose `source` is itself tagged (composed aes): errors, since static prose has no row context.
///
/// - x: A user-supplied prose value.
/// - eval-strings: When `true`, plain strings are evaluated as Typst markup; defaults to `false` so unmarked surfaces render strings literally.
///
/// Returns: A renderable value (string, content, or `none`).
#let resolve-prose(x, eval-strings: false) = {
  if x == none { return none }
  if type(x) == dictionary and x.at("kind", default: none) == "typst-markup" {
    let src = x.source
    if type(src) == str {
      return eval(src, mode: "markup")
    }
    if type(src) == content {
      return src
    }
    fail(
      "typst",
      "in static prose accepts a string or content; got a tagged value (kind: "
        + repr(src.at("kind", default: "?"))
        + ")",
      hint: "Use typst() on aesthetic mappings to wrap column references.",
    )
  }
  if eval-strings and type(x) == str { return eval(x, mode: "markup") }
  x
}
