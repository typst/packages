// chord.typ - Chord diagrams showing flows between entities
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-chord-data
#import "../primitives/container.typ": chart-container
#import "../primitives/polar.typ": arc-points, place-wedge, polar-pt, separator-stroke
#import "../primitives/polar-labels.typ": place-outside-labels, polar-fit-radius, wrap-label
#import "../primitives/layout.typ": resolve-size

/// Renders a chord diagram showing relationships and flows between entities
/// arranged around a circular ring.
///
/// Each entity is drawn as an arc whose length is proportional to its total
/// flow (sum of outgoing and incoming values). Curved bands (chords) connect
/// pairs of entities, with the band width at each end proportional to the
/// individual flow value. Chords are translucent tints of the source entity's
/// color; the largest are drawn first so small flows stay visible on top.
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
) = context {
  layout(avail => {
  validate-chord-data(data, "chord-diagram")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let labels = data.labels
  let matrix = data.matrix
  let n = labels.len()
  let (cx, cy) = (size / 2, size / 2)

  // Total flow per entity: outgoing (row) plus incoming (column)
  let totals = array.range(n).map(i => {
    matrix.at(i).sum() + array.range(n).map(j => matrix.at(j).at(i)).sum()
  })
  let grand-total = totals.sum()

  // Nothing to draw if all flows are zero
  if grand-total == 0 {
    return align(center, chart-container(size, size, title, t)[
      #box(width: size, height: size)[
        #place(center + horizon, text(size: t.axis-label-size, fill: t.text-color-light)[No flow data])
      ]
    ])
  }

  // Each entity's arc: a proportional share of what the gaps leave of the circle
  let arc-spans = totals.map(tot => (360 - gap * n) * tot / grand-total)
  let arc-starts = {
    let out = ()
    let cursor = 0.0
    for span in arc-spans {
      out.push(cursor)
      cursor += span + gap
    }
    out
  }

  // Labels beside their arcs; the ring is as large as they leave room for
  let label-size = if n > 12 { t.axis-label-size } else { t.legend-size }
  let items = if show-labels {
    array.range(n).filter(i => arc-spans.at(i) > 0).map(i => (
      angle: arc-starts.at(i) + arc-spans.at(i) / 2,
      priority: arc-spans.at(i),
      body: wrap-label(text(size: label-size, fill: t.text-color, top-edge: "cap-height", bottom-edge: "descender")[#labels.at(i)],
        calc.max(60pt, size * 0.3), arc-starts.at(i) + arc-spans.at(i) / 2),
    ))
  } else { () }
  let outer-r = if show-labels { polar-fit-radius(items, cx, cy, size, size, gap: 5pt) } else { size / 2 - 1pt }
  let inner-r = outer-r - calc.min(arc-width, outer-r * 0.25)

  // Each chord takes its slice of both arcs; `cursor` is how much of an arc is used
  let deg-per-unit = array.range(n).map(i => if totals.at(i) > 0 { arc-spans.at(i) / totals.at(i) } else { 0 })
  let cursor = array.range(n).map(_ => 0.0)
  let chords = ()
  for i in array.range(n) {
    for j in array.range(n) {
      let val = matrix.at(i).at(j)
      if val <= 0 { continue }
      let src = (arc-starts.at(i) + cursor.at(i), arc-starts.at(i) + cursor.at(i) + val * deg-per-unit.at(i))
      cursor.at(i) += val * deg-per-unit.at(i)
      let dst = (arc-starts.at(j) + cursor.at(j), arc-starts.at(j) + cursor.at(j) + val * deg-per-unit.at(j))
      cursor.at(j) += val * deg-per-unit.at(j)
      chords.push((from: i, to: j, val: val, src: src, dst: dst))
    }
  }

  // A chord: the source arc, a curve through the centre to the target arc,
  // the target arc, and the curve back
  let curve(from-deg, to-deg, via: (cx, cy)) = {
    let (p0, p2) = (polar-pt(cx, cy, inner-r, from-deg), polar-pt(cx, cy, inner-r, to-deg))
    array.range(1, 21).map(s => {
      let (f, inv) = (s / 20, 1 - s / 20)
      (inv * inv * p0.at(0) + 2 * inv * f * via.at(0) + f * f * p2.at(0),
       inv * inv * p0.at(1) + 2 * inv * f * via.at(1) + f * f * p2.at(1))
    })
  }

  // One entity's flow to itself: a petal hanging from its arc (the usual
  // chord would fold flat onto itself)
  let petal(c) = {
    let mid = (c.src.at(0) + c.dst.at(1)) / 2
    (..arc-points(cx, cy, inner-r, c.src.at(0), c.dst.at(1), steps: 14),
     ..curve(c.dst.at(1), c.src.at(0), via: polar-pt(cx, cy, inner-r * 0.3, mid)))
  }
  align(center, chart-container(size, size, title, t)[
    #box(width: size, height: size)[
      // Chords, largest first, behind the arcs: translucent tints of their
      // source colour, so crossings stay readable and no outline is needed
      #for c in chords.sorted(key: c => -c.val) {
        place(left + top, polygon(
          fill: get-color(t, c.from).transparentize(55%),
          stroke: none,
          ..if c.from == c.to { petal(c) } else {
            (..arc-points(cx, cy, inner-r, c.src.at(0), c.src.at(1), steps: 10),
             ..curve(c.src.at(1), c.dst.at(0)),
             ..arc-points(cx, cy, inner-r, c.dst.at(0), c.dst.at(1), steps: 10),
             ..curve(c.dst.at(1), c.src.at(0)))
          },
        ))
      }
      // Entity arcs
      #for i in array.range(n) {
        place-wedge(cx, cy, inner-r, outer-r, arc-starts.at(i), arc-starts.at(i) + arc-spans.at(i), get-color(t, i),
          stroke: separator-stroke(t, thickness: 0.75pt))
      }
      #place-outside-labels(items, cx, cy, outer-r, (left: 0pt, right: size, top: 0pt, bottom: size), gap: 5pt,
        leader-stroke: 0.5pt + t.text-color-light)
    ]
  ])
  })
}
