// chord.typ - Chord diagrams showing flows between entities
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-chord-data
#import "../primitives/container.typ": chart-container

/// Renders a chord diagram showing relationships and flows between entities
/// arranged around a circular ring.
///
/// Each entity is drawn as an arc whose length is proportional to its total
/// flow (sum of outgoing and incoming values). Curved bands (chords) connect
/// pairs of entities, with the band width at each end proportional to the
/// individual flow value. Chords use the source entity's color at reduced
/// opacity.
///
/// - data (dictionary): Must contain `labels` (array of strings) and `matrix`
///   (square array of arrays — `matrix.at(i).at(j)` is the flow from entity
///   *i* to entity *j*).
/// - size (length): Diameter of the outer ring
/// - arc-width (length): Thickness of the outer entity arcs
/// - title (none, content): Optional chart title
/// - show-labels (bool): Display entity name labels outside the arcs
/// - gap (int, float): Degrees of gap between adjacent entity arcs
/// - theme (none, dictionary): Theme overrides
/// -> content
#let chord-diagram(
  data,
  size: 300pt,
  arc-width: 15pt,
  title: none,
  show-labels: true,
  gap: 2,
  theme: none,
) = {
  validate-chord-data(data, "chord-diagram")
  let t = resolve-theme(theme)

  let labels = data.labels
  let matrix = data.matrix
  let n = labels.len()

  // ── Compute total flow per entity ────────────────────────────────────
  // Total = sum of row (outgoing) + sum of column (incoming)
  let totals = array.range(n).map(i => {
    let row-sum = matrix.at(i).fold(0, (a, v) => a + v)
    let col-sum = array.range(n).fold(0, (a, j) => a + matrix.at(j).at(i))
    row-sum + col-sum
  })

  let grand-total = totals.fold(0, (a, v) => a + v)

  // Guard: nothing to draw if all flows are zero
  if grand-total == 0 {
    return chart-container(size, size, title, t)[
      #box(width: size, height: size)[
        #place(center + horizon, text(size: 9pt, fill: t.text-color)[No flow data])
      ]
    ]
  }

  let radius = size / 2
  let outer-r = radius - 2pt          // outer edge of arcs
  let inner-r = outer-r - arc-width   // inner edge of arcs (chord attachment)
  let center-x = radius
  let center-y = radius

  // ── Compute arc spans in degrees ─────────────────────────────────────
  let total-gap = gap * n             // total degrees consumed by gaps
  let avail-deg = 360 - total-gap     // degrees available for arcs

  // Each entity gets a proportional share of avail-deg
  let arc-spans = totals.map(tot => avail-deg * (tot / grand-total))

  // Start angles for each entity arc
  let arc-starts = array.range(n).map(_ => 0.0)
  {
    let cursor = 0.0
    for i in array.range(n) {
      arc-starts.at(i) = cursor
      cursor = cursor + arc-spans.at(i) + gap
    }
  }

  // ── Helper: point on circle at angle (degrees) ───────────────────────
  let pt = (cx, cy, r, angle-deg) => {
    let a = angle-deg * 1deg
    (cx + r * calc.cos(a), cy + r * calc.sin(a))
  }

  // ── Helper: arc as polygon points ────────────────────────────────────
  let arc-points = (cx, cy, r, start-deg, end-deg, steps) => {
    array.range(steps + 1).map(s => {
      let frac = s / steps
      let a = start-deg + (end-deg - start-deg) * frac
      pt(cx, cy, r, a)
    })
  }

  // ── Pre-compute outgoing offsets per entity ──────────────────────────
  // For entity i, we step through columns j=0..n-1 and allocate degrees
  // within i's arc for the chord to j.
  // Similarly for incoming: entity j receives flows from i.
  // We track both as angular offsets within each entity's arc.
  //
  // out-cursor.at(i) = degrees already used on entity i's arc for outgoing chords
  // in-cursor.at(i) = degrees already used on entity i's arc for incoming chords
  //
  // Layout: first half of entity arc = outgoing, second half = incoming
  // But simpler: interleave. We'll allocate outgoing flows first, then incoming.

  // Degree size per unit flow for entity i
  let deg-per-unit = array.range(n).map(i => {
    if totals.at(i) > 0 { arc-spans.at(i) / totals.at(i) } else { 0 }
  })

  // Track cursor within each entity's arc (in degrees from arc start)
  let cursor = array.range(n).map(_ => 0.0)

  // ── Render ───────────────────────────────────────────────────────────
  chart-container(size, size, title, t, extra-height: 30pt)[
    #box(width: size, height: size)[
      // --- Draw chords first (behind arcs) ---
      #for i in array.range(n) {
        for j in array.range(n) {
          let val = matrix.at(i).at(j)
          if val <= 0 { continue }

          // Degrees this chord occupies on entity i (source)
          let src-deg = val * deg-per-unit.at(i)
          let src-start = arc-starts.at(i) + cursor.at(i)
          let src-end = src-start + src-deg
          cursor.at(i) = cursor.at(i) + src-deg

          // Degrees this chord occupies on entity j (target)
          let dst-deg = val * deg-per-unit.at(j)
          let dst-start = arc-starts.at(j) + cursor.at(j)
          let dst-end = dst-start + dst-deg
          cursor.at(j) = cursor.at(j) + dst-deg

          // Build chord polygon:
          // 1. Arc on source (inner-r) from src-start to src-end
          // 2. Bezier curve from src-end to dst-start through center
          // 3. Arc on destination (inner-r) from dst-start to dst-end
          // 4. Bezier curve from dst-end back to src-start through center

          let seg = 20
          let chord-pts = ()

          // Source arc (inner radius)
          chord-pts = chord-pts + arc-points(center-x, center-y, inner-r, src-start, src-end, 10)

          // Curve from source end to destination start (quadratic Bezier through center)
          let p0 = pt(center-x, center-y, inner-r, src-end)
          let p2 = pt(center-x, center-y, inner-r, dst-start)
          for s in array.range(1, seg + 1) {
            let frac = s / seg
            // Quadratic Bezier: (1-t)^2 * P0 + 2(1-t)t * C + t^2 * P2
            // where C = center
            let inv = 1.0 - frac
            let x = inv * inv * p0.at(0) + 2 * inv * frac * center-x + frac * frac * p2.at(0)
            let y = inv * inv * p0.at(1) + 2 * inv * frac * center-y + frac * frac * p2.at(1)
            chord-pts.push((x, y))
          }

          // Destination arc (inner radius)
          chord-pts = chord-pts + arc-points(center-x, center-y, inner-r, dst-start, dst-end, 10)

          // Curve from destination end back to source start
          let p3 = pt(center-x, center-y, inner-r, dst-end)
          let p5 = pt(center-x, center-y, inner-r, src-start)
          for s in array.range(1, seg + 1) {
            let frac = s / seg
            let inv = 1.0 - frac
            let x = inv * inv * p3.at(0) + 2 * inv * frac * center-x + frac * frac * p5.at(0)
            let y = inv * inv * p3.at(1) + 2 * inv * frac * center-y + frac * frac * p5.at(1)
            chord-pts.push((x, y))
          }

          let chord-color = get-color(t, i).transparentize(60%)

          place(left + top, polygon(
            fill: chord-color,
            stroke: none,
            ..chord-pts,
          ))
        }
      }

      // --- Draw outer arcs ---
      #for i in array.range(n) {
        let color = get-color(t, i)
        let start = arc-starts.at(i)
        let span = arc-spans.at(i)
        if span <= 0 { continue }

        // Build arc as a thick annular segment (outer - inner)
        let steps = calc.max(int(span / 2), 8)
        let outer-pts = arc-points(center-x, center-y, outer-r, start, start + span, steps)
        let inner-pts = arc-points(center-x, center-y, inner-r, start, start + span, steps)

        let arc-poly = outer-pts + inner-pts.rev()

        place(left + top, polygon(
          fill: color,
          stroke: 0.5pt + color.darken(20%),
          ..arc-poly,
        ))
      }

      // --- Labels ---
      #if show-labels {
        for i in array.range(n) {
          let span = arc-spans.at(i)
          if span <= 0 { continue }

          let mid-angle = arc-starts.at(i) + span / 2
          let label-r = outer-r + 12pt
          let pos = pt(center-x, center-y, label-r, mid-angle)

          // Determine text alignment based on angle quadrant
          let lx = pos.at(0)
          let ly = pos.at(1)

          // Offset for centering the text
          let dx = lx - 20pt
          let dy = ly - 6pt

          place(left + top,
            dx: dx,
            dy: dy,
            box(width: 40pt, align(center,
              text(size: 7pt, fill: t.text-color, str(labels.at(i)))
            )),
          )
        }
      }
    ]
  ]
}
