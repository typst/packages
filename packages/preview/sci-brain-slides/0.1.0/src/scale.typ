// Three content sizes; smaller type is reserved for captions and metadata.
#let sizes = (
  xlarge: 36pt,
  large: 24pt,
  normal: 20pt,
  caption: 14pt,
  chrome: 12pt,
)

// Absolute sizes avoid compounding when components contain other components.
#let type-scale(text-size: 20pt, overrides: (:)) = {
  let valid(size) = type(size) == length and size.em == 0 and size > 0pt
  assert(valid(text-size), message: "text-size must be a positive absolute length, such as 22pt")
  assert(type(overrides) == dictionary, message: "sizes must be a dictionary of size overrides")
  for (key, value) in overrides {
    assert(key in sizes, message: "unknown size token: " + key)
    assert(valid(value), message: "sizes." + key + " must be a positive absolute length")
  }
  sizes.pairs().map(((key, value)) => (key, value * (text-size / sizes.normal))).to-dict() + overrides
}
