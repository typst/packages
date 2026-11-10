/// Retrieve the location of a previously placed and labeled element.
/// If multiple elements have the same label, the position is relative
/// to the union of all of their boxes.
/// #property(since: version(0, 2, 3))
/// -> query(location)
#let position(
  /// Reference a previous element by its tag.
  /// -> label
  tag,
  /// Anchor point relative to the box in question.
  /// -> align
  at: center,
) = {
  (
    type: query,
    mode: "pos",
    tag: tag,
    at: at,
  )
}

/// Retrieve the width of a previously placed and labeled element.
/// If multiple elements have the same label, the resulting width
/// is the maximum top-to-bottom span.
/// #property(since: version(0, 2, 3))
/// -> query(length)
#let width(
  /// Reference a previous element by its tag.
  /// -> label
  tag,
  /// Apply some post-processing transformation to the value.
  /// -> ratio | function
  transform: 100%,
) = {
  (
    type: query,
    mode: "width",
    tag: tag,
    transform: transform,
  )
}

/// Retrieve the height of a previously placed and labeled element.
/// If multiple elements have the same label, the resulting height
/// is the maximum left-to-right span.
/// #property(since: version(0, 2, 3))
/// -> query(length)
#let height(
  /// Reference a previous element by its tag.
  /// -> label
  tag,
  /// Apply some post-processing transformation to the value.
  /// -> ratio | function
  transform: 100%,
) = {
  (
    type: query,
    mode: "height",
    tag: tag,
    transform: transform,
  )
}
