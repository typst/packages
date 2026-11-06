// Canonical list of the aesthetic-channel names that `aes()` accepts and that
// the mapping check in `src/render/validate.typ` iterates.
// `tests/unit/test-aes-keys-union.typ` checks it against the mapping keys that
// the geoms, stats, and positions read.

#let AES-KEYS = (
  "x",
  "y",
  "z",
  "colour",
  "fill",
  "size",
  "alpha",
  "linewidth",
  "group",
  "shape",
  "linetype",
  "label",
  "xmin",
  "xmax",
  "ymin",
  "ymax",
  "xend",
  "yend",
  "xintercept",
  "yintercept",
  "slope",
  "intercept",
  "weight",
  "sample",
  "lower",
  "middle",
  "upper",
  "stroke",
  "x0",
  "y0",
  "a",
  "b",
  "angle",
  "radius",
  "width",
  "height",
  "nudge-x",
  "nudge-y",
)

// Mapping keys that core code reads for every layer, whatever its geom, stat,
// or position: the layer grouping in `src/utils/group.typ` reads `x` and `y`
// and its grouping aesthetics. Geom, stat, and position modules declare the
// rest of their reads next to their code.
#let CORE-READS = ("x", "y", "group", "colour", "fill", "linetype", "shape")
