#import "body.typ": _deixis-container-data, _deixis-should-render-backlinks, deixis-native-render-single, deixis-generate-body-marker, deixis-generate-body-content, deixis-generate-backlinks
#import "../core/native.typ": _std-target

// Based on a contribution by bluelightspirit (inspiros/typst-deixis#2).

/// Render a Chicago Notes & Bibliography endnote as an indented paragraph.
/// The full-size, linked marker is followed by a period; unnumbered notes omit
/// both. Only the first line is indented, by the explicitly resolved indent or
/// 0.5in. Inherited paragraph leading, spacing and justification are preserved,
/// as are authored paragraph breaks, body styling, containers and backlinks.
/// Select with `deixis-print-endnotes(render-single: deixis-chicago-render-single)`
/// or `deixis-set(render-single: (endnote: deixis-chicago-render-single))`.
/// The default grid group stacks custom single renderers using the normal gap.
/// HTML uses the native semantic renderer without paragraph indentation.
///
/// -> content
#let deixis-chicago-render-single(
  /// Supplied live body-renderer record; preserve measurement and ownership fields.
  /// -> dictionary
  data,
  /// Width of the note's paragraph block.
  /// -> auto | relative
  inner-width: auto,
  /// Additional group-renderer arguments, ignored.
  /// -> arguments
  ..args,
) = {
  let data = _deixis-container-data(data)
  if _std-target() == "html" {
    return deixis-native-render-single(data, inner-width: inner-width, ..args.named())
  }
  let body-style = data.at("body-style", default: it => it)
  let indent = if data.at("indent-origin", default: "local") in ("factory", "fallback") {
    0.5in
  } else { data.at("indent", default: 0.5in) }
  let numbered = data.at("marker-str", default: none) not in (none, "")
  let marker = deixis-generate-body-marker(data + (
    body-marker-style: it => if numbered { [#it.] } else { it },
  ))
  let body = deixis-generate-body-content(data)
  let backlinks = if _deixis-should-render-backlinks(data) {
    super(deixis-generate-backlinks(data))
  }
  let final-note = body-style(block(width: inner-width, above: 0pt, below: 0pt, {
    // An explicit first-line space avoids hanging indentation and does not
    // insert markup whitespace between the indent and the marker.
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    [#h(indent)#marker#if numbered [ ]#body#backlinks]
  }))
  (data.container-func)(final-note, ..(data.styles + data.at("container-args", default: (:))))
}
