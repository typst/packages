// ============================================================================
// Containers: grouping and layout structures
// ============================================================================
//
// region     - A bordered container grouping cells into a visual unit
// target     - A linked/referenced region (dashed, faded, with label)
// connector  - A vertical line linking regions
// divider    - A text separator between layout alternatives
// detail     - An explanation bar below a region
// entry-list - A vertical list of entries inside a target
// ============================================================================

/// A bordered container that groups cells into a visual unit.
///
/// Regions are the primary structural element, providing a visual background
/// and border to delineate a composite structure.
///
/// - `danger`: Thick red border (mutually exclusive with `faded`).
/// - `faded`: Dashed border, semi-transparent (mutually exclusive with `danger`).
#let region(
  body,
  fill: luma(242),
  stroke: 1pt + gray,
  radius: 4pt,
  width: auto,
  content-align: center,
  danger: false,
  faded: false,
) = {
  let actual-stroke = if danger { (paint: red, thickness: 2pt) }
    else if faded { (paint: gray, thickness: 1pt, dash: "dashed") }
    else { stroke }
  let actual-fill = if faded { fill.transparentize(60%) } else { fill }

  box(
    width: width, fill: actual-fill, stroke: actual-stroke,
    radius: radius, inset: 5pt, baseline: 30%,
    { set align(content-align); body },
  )
}

/// A linked / referenced region, drawn below a connector.
///
/// Has a dashed border with an optional bottom-right label
/// (e.g., "(heap)", "(static)").
#let target(
  body,
  fill: rgb("#FDECDC"),
  label: none,
  width: auto,
) = {
  box(
    width: width, fill: fill.transparentize(40%),
    stroke: (paint: gray, thickness: 1pt, dash: "dashed"),
    radius: 4pt, inset: 5pt,
    {
      set text(fill: black)
      set align(center)
      body
      if label != none {
        place(bottom + right, dx: 2pt, dy: 4pt,
          text(size: 0.55em, fill: gray.darken(30%), label))
      }
    },
  )
}

/// A vertical connecting line between a region and its target.
#let connector(length: 8pt, stroke: 1pt + gray) = {
  block(width: 100%, above: 2pt, below: 0pt,
    align(center, line(angle: 90deg, length: length, stroke: stroke)),
  )
}

/// A text separator between layout alternatives (e.g., "or maybe").
#let divider(body: [or]) = {
  align(center, text(size: 0.75em, style: "italic", body))
}

/// An explanation bar below a region.
#let detail(body, fill: rgb("#FFF8DC")) = {
  block(
    width: 100%, fill: fill,
    stroke: (paint: gray, thickness: 1pt),
    radius: (bottom: 3pt), inset: (x: 6pt, y: 3pt), above: -1pt,
    { set text(size: 0.75em); set align(center); body },
  )
}

/// A vertical list of labeled entries inside a target.
///
/// Used for field lists, register maps, vtables, or any structured
/// vertical listing within a referenced region.
#let entry-list(entries, fill: rgb("#DEB887"), label: none, width: auto) = {
  target(fill: fill, label: label, width: width, {
    set text(size: 0.7em)
    set align(left)
    for (i, entry) in entries.enumerate() {
      block(
        width: 100%,
        stroke: if i < entries.len() - 1 {
          (bottom: (paint: luma(230), thickness: 0.5pt))
        },
        inset: 2pt, entry,
      )
    }
  })
}
