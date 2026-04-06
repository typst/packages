#import "types.typ"
#import "geometry.typ"

/// Retrieve the location of a previously placed and labeled element.
/// If multiple elements have the same label, the position is relative
/// to the union of all of their boxes.
/// -> query(location)
#let position(
  /// Reference a previous element by its tag.
  /// -> label
  tag,
  /// Anchor point relative to the box in question.
  /// -> align
  at: center,
) = (type: types.query, fun: (data) => {
  if str(tag) not in data.regions {
    panic("No objects with tag <" + str(tag) + "> declared yet.")
  }
  let pos = geometry.in-region(data.regions.at(str(tag)), at)
  pos
})

/// Retrieve the width of a previously placed and labeled element.
/// If multiple elements have the same label, the resulting width
/// is the maximum top-to-bottom span.
/// -> query(length)
#let width(
  /// Reference a previous element by its tag.
  /// -> label
  tag,
  /// Apply some post-processing transformation to the value.
  /// -> ratio | function
  transform: 100%,
) = (type: types.query, fun: (data) => {
  if str(tag) not in data.regions {
    panic("No objects with tag <" + str(tag) + "> declared yet.")
  }
  let width = data.regions.at(str(tag)).width
  geometry.apply-transform(width, transform: transform)
})

/// Retrieve the height of a previously placed and labeled element.
/// If multiple elements have the same label, the resulting height
/// is the maximum left-to-right span.
/// -> query(length)
#let height(
  /// Reference a previous element by its tag.
  /// -> label
  tag,
  /// Apply some post-processing transformation to the value.
  /// -> ratio | function
  transform: 100%,
) = (type: types.query, fun: (data) => {
  if str(tag) not in data.regions {
    panic("No objects with tag <" + str(tag) + "> declared yet.")
  }
  let height = data.regions.at(str(tag)).height
  geometry.apply-transform(height, transform: transform)
})

/// Returns the size of the container.
/// -> query(size)
#let parent-size(
  /// By default, returns only the available space,
  /// but you can turn off this parameter to include the entire
  /// page including space that is not usable by MEANDER.
  /// -> bool
  clip-to-page: true,
  /// Apply a transformation to the value.
  /// -> ratio | function
  transform: 100%,
) = (type: types.query, fun: (data) => {
  // TODO
  if clip-to-page {
    data.free-size
  } else {
    data.full-size
  }
})

