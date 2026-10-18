// Decorative drawing only: draw-chevron, draw-cursor, draw-rule. Each is
// wrapped as a PDF artifact so it contributes zero characters to the
// extracted text stream.

#import "ats.typ": artifact
#import "theme.typ": bg

// Fixed size, calibrated to read well at its dominant call site (the
// section header, 14pt) — an empirically-reverified constant once rendered,
// not a final answer derived from arithmetic alone.
#let draw-chevron(color, stroke-weight: 0.6pt) = artifact({
  let w = 8pt
  let h = 10pt
  box(width: w, height: h, baseline: h * 0.22, {
    place(line(start: (12%, 8%), end: (85%, 50%), stroke: stroke-weight + color))
    place(line(start: (85%, 50%), end: (12%, 92%), stroke: stroke-weight + color))
  })
})

// Fixed em-relative size, independent of the chevron decision above.
#let draw-cursor(color) = artifact(
  box(width: 0.6em, height: 0.7em, baseline: 0.14em, fill: color),
)

// A filled block, not line() — a horizontal line() reports ~zero height to
// the parent's auto-layout, which breaks block-spacing after it.
#let draw-rule(color, weight: 0.6pt) = artifact(
  block(width: 100%, height: weight, fill: color, above: 0pt, below: 0pt),
)

// No-logo placeholder: a small filled aperture (two concentric circles),
// inset within the cell rather than edge-to-edge, so it reads as an
// abstract placeholder mark rather than a plain filled/bordered rectangle.
// Sized off height alone. The cell size is required, not defaulted: it must
// be theme.typ's logo-width/logo-height so the placeholder occupies exactly
// the same box as a real logo, and an em-relative default re-derived here
// would resolve against whichever show rule happens to be calling (see
// theme.typ's logo-width comment).
#let draw-placeholder-logo(color, width: none, height: none) = artifact(
  box(width: width, height: height, {
    place(center + horizon, circle(radius: height * 0.3, fill: color))
    place(center + horizon, circle(radius: height * 0.12, fill: bg))
  }),
  kind: "other",
)
