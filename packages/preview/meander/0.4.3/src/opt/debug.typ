#import "/src/types.typ"

// Pattern with red crosses to display forbidden zones.
// -> pattern
#let pat-forbidden(
  /// Size of the tiling.
  /// -> length
  sz,
) = tiling(size: (sz, sz))[
  #place(box(width: 100%, height: 100%, stroke: none, fill: red.transparentize(95%)))
  #place(line(start: (25%, 25%), end: (75%, 75%), stroke: red + 0.1pt))
  #place(line(start: (25%, 75%), end: (75%, 25%), stroke: red + 0.1pt))
]

// Pattern with green pluses to display allowed zones.
// -> pattern
#let pat-allowed(
  /// Size of the tiling.
  /// -> length
  sz,
) = tiling(size: (sz, sz))[
  #place(box(width: 100%, height: 100%, stroke: none, fill: green.transparentize(95%)))
  #place(line(start: (25%, 50%), end: (75%, 50%), stroke: green + 0.1pt))
  #place(line(start: (50%, 25%), end: (50%, 75%), stroke: green + 0.1pt))
]

#let new-config(..opts) = {
  ((type: types.opt.pre, field: "debug", payload: opts.named()),)
  //opts.named()
}

/// No visible effect.
/// -> option
#let release() = new-config(
  objects: true,
  content: true,
  layout-boundary: (:),
  obstacle-regions: (:),
  obstacle-contours: (:),
  container-regions: (:),
  container-contours: (:),
)

/// Does not show obstacles or content.
/// Displays forbidden regions in red and allowed regions in green.
/// -> option
#let minimal() = new-config(
  objects: false,
  content: false,
  layout-boundary: (stroke: orange),
  obstacle-regions: (stroke: yellow, fill: none),
  obstacle-contours: (stroke: red, fill: pat-forbidden(30pt)),
  container-regions: (stroke: blue, fill: none),
  container-contours: (stroke: green, fill: pat-allowed(30pt)),
)

/// Shows obstacles but not content.
/// Displays forbidden regions in red and allowed regions in green.
/// -> option
#let pre-thread() = new-config(
  objects: true,
  content: false,
  layout-boundary: (stroke: orange),
  obstacle-regions: (stroke: yellow, fill: none),
  obstacle-contours: (stroke: red, fill: pat-forbidden(30pt)),
  container-regions: (stroke: blue, fill: none),
  container-contours: (stroke: green, fill: pat-allowed(30pt)),
)

/// Shows obstacles and content.
/// Displays forbidden regions in red and allowed regions in green (non-invasive).
/// -> option
#let post-thread() = new-config(
  objects: true,
  content: true,
  layout-boundary: (stroke: orange),
  obstacle-regions: (:),
  obstacle-contours: (stroke: red, fill: pat-forbidden(30pt)),
  container-regions: (:),
  container-contours: (stroke: green),
)

#let default = (
  debug: release().at(0).payload,
)

