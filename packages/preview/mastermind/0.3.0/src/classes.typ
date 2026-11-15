#import "@preview/cetz:0.5.2"

#let source(path, center: (0, 0)) = {
  return (
    path: path,
    center: center,
  )
}

/// Class object.
/// -> dictionary
#let class(
  /// Name of the class.
  /// -> string
  name,
  /// Center of the class.
  /// -> array
  center: (0, 0),
  /// Type of the class.
  /// -> string | none
  type: none,
  /// Attributes of the class.
  /// -> array
  attributes: (),
  /// Methods of the class.
  /// -> array
  methods: (),
) = {
  return (
    name: name,
    type: type,
    attributes: attributes,
    methods: methods,
    center: center,
  )
}

/// Utility to draw the given classes in a row.
/// -> array
#let row(
  /// Center of the row of classes.
  /// -> array
  center,
  /// Gap between classes.
  /// -> length
  gap,
  /// The classes to draw.
  /// -> class
  ..classes,
) = {
  let class_list = classes.pos()
  let n = class_list.len()
  let middle = (n - 1) / 2

  return class_list
    .enumerate()
    .map(((i, c)) => {
      let offset = (i - middle) * gap
      let (cx, cy) = center
      c.insert("center", (cx + offset, cy))
      c
    })
}

/// Utility to draw the given classes in a column.
/// -> array
#let column(
  /// Center of the row of classes.
  /// -> array
  center,
  /// Gap between classes.
  /// -> length
  gap,
  /// The classes to draw.
  /// -> class
  ..classes,
) = {
  let class_list = classes.pos()
  let n = class_list.len()
  let middle = (n - 1) / 2

  return class_list
    .enumerate()
    .map(((i, c)) => {
      let offset = (i - middle) * gap
      let (cx, cy) = center
      c.insert("center", (cx, cy + offset))
      c
    })
}

/// Utility to group the given classes.
/// -> array
#let group(
  /// Center of the group of classes.
  /// -> array
  center,
  /// The classes to draw.
  /// -> class
  ..classes,
) = {
  return classes
    .pos()
    .map(c => {
      c.insert("center", (c.center.at(0) + center.at(0), c.center.at(1) + center.at(1)))
      c
    })
}
