/// Create an unnumbered heading while keeping Satz's normal heading style.
///
/// The heading remains in the outline by default, so it appears in the table
/// of contents. Pass `outlined: false` to keep it out of the outline.
///
/// ```example
/// #unnumbered-heading(level: 1)[Acknowledgements]
/// ```
///
/// - body (content): the heading text
/// - level (int): heading level from 1 to 6; defaults to 1
/// - outlined (bool): include the heading in outlines; defaults to true
#let unnumbered-heading(body, level: 1, outlined: true) = {
  assert(level >= 1 and level <= 6, message: "level must be between 1 and 6")
  heading(level: level, numbering: none, outlined: outlined)[#body]
}
