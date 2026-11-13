/// Replaces a color in an SVG, returning bytes ready for `image`.
///
/// - data (bytes): SVG content, from `read(path, encoding: none)`.
/// - from (str): Color to replace.
/// - to (str): Replacement color.
/// -> bytes
#let recolor(source, from, to) = bytes(str(source).replace(from, to))
