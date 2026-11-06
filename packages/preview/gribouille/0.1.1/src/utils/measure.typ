// Text-measurement helpers shared by the renderer to size axis tick labels
// from their actual rendered glyph extents instead of character-count heuristics.
// Callers must already be inside a `context { ... }` block; Typst's
// `measure()` requires it. Cetz canvas closures do not expose layout
// measurement, so any caller has to invoke these before building the canvas.

// Measure a single label string at the given font size and return its
// width and height in cm as plain floats.
#let measure-text-cm(label, size) = {
  let m = measure(text(size: size)[#label])
  (
    width: m.width / 1cm,
    height: m.height / 1cm,
  )
}

// Walk a list of labels, measure each at `size`, and return the max width
// and max height observed (cm). Returns `(0.0, 0.0)` for an empty list.
#let measure-labels-cm(labels, size) = {
  let max-w = 0.0
  let max-h = 0.0
  for label in labels {
    let m = measure-text-cm(label, size)
    if m.width > max-w { max-w = m.width }
    if m.height > max-h { max-h = m.height }
  }
  (width: max-w, height: max-h)
}
