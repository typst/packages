// ===========================================================================
//  faboxyst/lace.typ — the guilloche line families.
//
//  Four ways of drawing security-print lace over a w × h field, shared by
//  `book-cover(style: "guilloche")` (its `lace` parameter) and `lacebox`.
//  Everything is stroked in one paint at hairline weight; the consumer
//  clips, so the patterns may run past the field freely.
//
//    "spiral"  cubics sweeping out on golden ratios — the banknote whirl
//    "engine"  engine-turned barleycorn: close circles crossed by spokes
//    "braid"   two phased families of cubic waves, woven across the page
//    "moire"   two circle families whose rings interfere into moiré
// ===========================================================================

#let _pol(cx, cy, r, deg) = (
  cx + r * calc.cos(deg * 1deg),
  cy + r * calc.sin(deg * 1deg),
)

/// Draw one lace family over a `w` × `h` field, origin at its top-left.
#let lace(pattern, w, h, paint, thickness: 0.1pt) = {
  if not ("spiral", "engine", "braid", "moire").contains(pattern) {
    panic("unknown lace pattern: " + pattern)
  }
  let st = (paint: paint, thickness: thickness)
  let cx = w / 2
  let cy = h / 2
  if pattern == "spiral" {
    // one path of cubic sweeps, each ring a tenth wider than the last
    let ops = ()
    for k in range(0, 41) {
      let ri = (1 + k * 0.1) * 1cm
      for a in range(0, 360, step: 15) {
        ops += (
          curve.move(_pol(cx, cy, ri, a)),
          curve.cubic(
            _pol(cx, cy, ri * 3, a + 90),
            _pol(cx, cy, ri * 3, a - 90),
            _pol(cx, cy, ri * 4, a + 180),
          ),
        )
      }
    }
    curve(stroke: st, ..ops)
  } else if pattern == "engine" {
    // barleycorn: concentric circles, then the spokes that cut them
    for k in range(0, 46) {
      let r = (0.6 + k * 0.34) * 1cm
      place(top + left, dx: cx - r, dy: cy - r,
        circle(radius: r, stroke: st, fill: none))
    }
    let ops = ()
    for a in range(0, 360, step: 3) {
      ops += (
        curve.move(_pol(cx, cy, 0.6cm, a)),
        curve.line(_pol(cx, cy, w, a)),
      )
    }
    curve(stroke: (paint: paint, thickness: thickness * 0.8), ..ops)
  } else if pattern == "braid" {
    // two wave families, half a row and half a phase apart
    let ops = ()
    let seg = w / 6
    for phase in (0, 1) {
      for r in range(0, 34) {
        let y = (r * 1.15 + phase * 0.575) * 1cm
        ops += (curve.move((0cm, y)),)
        for s in range(0, 6) {
          let sgn = if calc.rem(s + phase, 2) == 0 { -1.0 } else { 1.0 }
          ops += (curve.cubic(
            (seg * s + seg * 0.3, y + sgn * 0.85cm),
            (seg * s + seg * 0.7, y + sgn * 0.85cm),
            (seg * (s + 1), y),
          ),)
        }
      }
    }
    curve(stroke: st, ..ops)
  } else {
    // moiré: two centres, rings a hair apart in step
    for c in ((w * 0.32, h * 0.42), (w * 0.68, h * 0.58)) {
      for k in range(0, 40) {
        let r = (0.5 + k * 0.42) * 1cm
        place(top + left, dx: c.at(0) - r, dy: c.at(1) - r,
          circle(radius: r, stroke: st, fill: none))
      }
    }
  }
}
