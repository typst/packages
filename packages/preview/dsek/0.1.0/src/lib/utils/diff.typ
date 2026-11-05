/// Highlights content with a green background to indicate an addition (e.g. in a diff).
///
/// - content (content): The content to highlight.
/// - color (color): Highlight colour. Defaults to `rgb("#6cf06c")`.
/// -> content
#let diff-added(content, color: rgb("#6cf06c")) = highlight(fill: color, radius: 2pt, content)

/// Highlights content with a red background to indicate a deletion (e.g. in a diff).
///
/// - content (content): The content to highlight.
/// - color (color): Highlight colour. Defaults to `rgb("#ff5f56")`.
/// -> content
#let diff-deleted(content, color: rgb("#ff5f56")) = highlight(fill: color, radius: 2pt, content)

#let add = diff-added
#let remove = diff-deleted
