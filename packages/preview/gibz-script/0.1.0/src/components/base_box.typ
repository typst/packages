// A reusable visual container with sensible defaults.
// Override any style via the `style` dict.
#let base-box(body, style: (:)) = {
  let defaults = (
    width: 100%,
    fill: luma(98%),
    stroke: (paint: gray, thickness: 0.5pt),
    radius: 6pt,
    inset: 12pt,
  )

  // Merge defaults with caller-provided styles (caller wins).
  let s = defaults + style

  box(
    width: s.width,
    fill: s.fill,
    stroke: s.stroke,
    radius: s.radius,
    inset: s.inset,
    [ #body ],
  )
}