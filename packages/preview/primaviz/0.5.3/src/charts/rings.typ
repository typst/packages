// rings.typ - Donut progress / fitness rings chart (Apple Watch style)
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-ring-data
#import "../primitives/container.typ": chart-container, container-inset
#import "../primitives/layout.typ": resolve-size

/// Concentric ring progress chart (fitness rings).
/// Outermost ring = first entry, innermost = last.
/// Rings that exceed 100 % wrap around (overlap).
#let ring-progress(
  entries,          // Array of dicts: ((name: "Move", value: 75, max: 100), ...)
  size: 150pt,
  title: none,
  ring-width: 12pt,
  gap: 4pt,
  show-labels: true,
  show-values: true,
  theme: none,
) = context {
  layout(avail => {
  validate-ring-data(entries, "ring-progress")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let n = entries.len()

  // Total width needed for labels column — scale with ring size
  let label-col-width = if show-labels { calc.max(70pt, size * 0.5) } else { 0pt }

  // Margin to prevent ring strokes from clipping at the container edge
  let margin = ring-width / 2 + 2pt

  // Shrink if total width exceeds available space
  let container-inset = 2 * container-inset
  let avail-w = if type(avail.width) == length and avail.width > 0pt { avail.width } else { none }
  let total-w = size + margin * 2 + label-col-width
  if avail-w != none and total-w + container-inset > avail-w {
    size = avail-w - container-inset - margin * 2 - label-col-width
    if size < 80pt {
      size = (avail-w - container-inset - margin * 2) * 0.6
      label-col-width = (avail-w - container-inset - margin * 2) - size
    }
  }

  // Pre-compute ring colours (one per entry from the palette)
  let colors = array.range(n).map(i => get-color(t, i))

  // Dimmed background colour helper — mix with background at 20 % opacity
  let bg = if t.background != none { t.background } else { white }
  let dim = (c) => {
    color.mix((c, 20%), (bg, 80%))
  }

  // Number of line-segment samples per full circle
  let samples-per-circle = 72

  align(center, chart-container(size + margin * 2 + label-col-width, size + margin * 2, title, t)[
    #box(width: size + margin * 2 + label-col-width, height: size + margin * 2)[
      // ── Draw rings ───────────────────────────────────────────────
      #for (i, entry) in entries.enumerate() {
        let radius = size / 2 - ring-width / 2 - i * (ring-width + gap)
        if radius < ring-width / 2 { /* skip if too small */ } else {
          let cx = size / 2 + margin
          let cy = size / 2 + margin
          let ring-color = colors.at(i)
          let bg-color = dim(ring-color)

          let progress = entry.value / entry.max  // may exceed 1.0

          // ── Background ring (full circle) ──────────────────────
          // Draw as line segments so it matches the foreground style
          {
            let seg-count = samples-per-circle
            for j in array.range(seg-count) {
              let a1 = -90deg + (j / seg-count) * 360deg
              let a2 = -90deg + ((j + 1) / seg-count) * 360deg
              let x1 = cx + radius * calc.cos(a1)
              let y1 = cy + radius * calc.sin(a1)
              let x2 = cx + radius * calc.cos(a2)
              let y2 = cy + radius * calc.sin(a2)
              place(
                left + top,
                line(start: (x1, y1), end: (x2, y2), stroke: bg-color + ring-width)
              )
            }
          }

          // ── Foreground progress arc ────────────────────────────
          if progress > 0 {
            // Clamp drawing to one full wrap-around maximum (could extend if needed)
            let draw-progress = calc.min(progress, 2.0)
            let arc-degrees = draw-progress * 360
            let seg-count = calc.max(int(draw-progress * samples-per-circle), 1)

            for j in array.range(seg-count) {
              let a1 = -90deg + (j / seg-count) * arc-degrees * 1deg
              let a2 = -90deg + ((j + 1) / seg-count) * arc-degrees * 1deg
              let x1 = cx + radius * calc.cos(a1)
              let y1 = cy + radius * calc.sin(a1)
              let x2 = cx + radius * calc.cos(a2)
              let y2 = cy + radius * calc.sin(a2)
              place(
                left + top,
                line(start: (x1, y1), end: (x2, y2), stroke: ring-color + ring-width)
              )
            }

            // Round start cap (top-center, 12-o'clock)
            place(
              left + top,
              dx: cx - ring-width / 2,
              dy: cy - radius - ring-width / 2,
              circle(radius: ring-width / 2, fill: ring-color, stroke: none)
            )

            // Round end cap
            let end-angle = -90deg + arc-degrees * 1deg
            let end-x = cx + radius * calc.cos(end-angle)
            let end-y = cy + radius * calc.sin(end-angle)
            place(
              left + top,
              dx: end-x - ring-width / 2,
              dy: end-y - ring-width / 2,
              circle(radius: ring-width / 2, fill: ring-color, stroke: none)
            )
          }
        }
      }

      // ── Labels (to the right of the rings) ─────────────────────
      #if show-labels {
        for (i, entry) in entries.enumerate() {
          let ring-color = colors.at(i)
          let label-x = size + margin * 2 + 8pt
          let label-y = size / 2 + margin - (n / 2 - i) * (t.legend-swatch-size + 12pt)

          // Colour swatch
          place(
            left + top,
            dx: label-x,
            dy: label-y,
            rect(width: t.legend-swatch-size, height: t.legend-swatch-size, fill: ring-color, radius: 2pt)
          )

          // Name
          place(
            left + top,
            dx: label-x + t.legend-swatch-size + 4pt,
            dy: label-y - 1pt,
            text(size: t.legend-size, fill: t.text-color, weight: "bold")[#entry.name]
          )

          // Value / max
          if show-values {
            let pct = calc.round(entry.value / entry.max * 100, digits: 0)
            place(
              left + top,
              dx: label-x + t.legend-swatch-size + 4pt,
              dy: label-y + t.legend-swatch-size,
              text(size: t.value-label-size, fill: t.text-color-light)[
                #entry.value / #entry.max (#pct%)
              ]
            )
          }
        }
      }
    ]
  ])
  })
}
