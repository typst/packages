#import "validation.typ": *

#let _vadd(u, v) = (u.at(0) + v.at(0), u.at(1) + v.at(1))
#let _vsub(u, v) = (u.at(0) - v.at(0), u.at(1) - v.at(1))
#let _vscale(v, k) = (v.at(0) * k, v.at(1) * k)
#let _hypot(v) = (
  calc.sqrt(
    (v.at(0) / 1pt) * (v.at(0) / 1pt)
      + (v.at(1) / 1pt)
        * (
          v.at(1) / 1pt
        ),
  )
    * 1pt
)

// Resolve a scalar (length, ratio, or relative) against `basis`.
#let _resolve-scalar(val, basis) = {
  if type(val) == length { val } else if type(val) == ratio {
    basis * (val / 100%)
  } else if type(val) == relative {
    basis * (val.ratio / 100%) + val.length
  } else { val }
}

#let _rel-is-zero(val) = {
  if type(val) == length { val == 0pt } else if type(val) == ratio {
    val == 0%
  } else if type(val) == relative {
    val.length == 0pt and val.ratio == 0%
  } else { false }
}

// Splits an inset side value into absolute + ratio components.
#let _split-inset(val) = {
  if type(val) == length { (a: val, r: 0%) } else if (
    type(val) == ratio
  ) { (a: 0pt, r: val) } else { (a: val.length, r: val.ratio) }
}

// Solves for the axis length whose rect-style padded content comes out to
// exactly `body-dim`: padded = (body + Σabs) / (1 − Σratio), matching how
// Typst's own `rect`/`box` auto-size with a ratio inset.
#let _resolve-auto-dim(body-dim, side-a, side-b) = {
  let sa = _split-inset(side-a)
  let sb = _split-inset(side-b)
  let abs = sa.a + sb.a
  let rat = sa.r + sb.r
  if rat >= 100% {
    _fail("inset exceeds the box size")
  }
  (body-dim + abs) / ((100% - rat) / 100%)
}

// Figma's "Corner Smoothing" algorithm: a, b, c, d are Bezier handle lengths
// for the straight-edge lead-in/lead-out cubics, and arc-measure is the
// surviving sweep of the corner's circular arc (90deg at smoothing = 0,
// shrinking to 0deg at smoothing = 1). `budget` is this corner's own
// rounding-and-smoothing budget, from `_budgets`.
// https://www.figma.com/blog/desperately-seeking-squircles/
// https://github.com/phamfoo/figma-squircle (reference implementation)
#let _corner-params(r, s, budget, preserve-smoothing) = {
  if r <= 0pt {
    (
      a: 0pt,
      b: 0pt,
      c: 0pt,
      d: 0pt,
      p: 0pt,
      angle-alpha: 45deg,
    )
  } else {
    let p = (1 + s) * r
    // false (default, matches Figma/figma-squircle): clamp `s` itself up
    // front via `s = min(s, budget/r - 1)`, same formula figma-squircle's
    // draw.ts uses. Cheap and matches Figma's own rendering, but past some
    // radius/budget ratio the clamp bites silently -- sliding `s` higher
    // has no visible effect since it's already capped.
    // true: leave `s` (and the arc-measure/angle-beta/c/d math below) at
    // the requested value untouched, and only if the corner still ends up
    // over budget, reshape the a/b Bezier handles further down instead
    // (see the `preserve-smoothing and p > budget` branch) -- shortens the
    // handle lengths while keeping the arc/smoothing-angle terms fixed, so
    // the requested smoothing is honored at the cost of handle geometry.
    if not preserve-smoothing {
      s = calc.min(s, budget / r - 1)
      p = calc.min(p, budget)
    }
    let arc-measure = 90deg * (1 - s)
    let arc-len = calc.sin(arc-measure / 2) * r * calc.sqrt(2)
    let angle-alpha = (90deg - arc-measure) / 2
    let p3-p4 = r * calc.tan(angle-alpha / 2)
    let angle-beta = 45deg * s
    let c = p3-p4 * calc.cos(angle-beta)
    let d = c * calc.tan(angle-beta)
    let b = (p - arc-len - c - d) / 3
    let a = 2 * b
    if preserve-smoothing and p > budget {
      let p1-p3-max = budget - d - arc-len - c
      let min-a = p1-p3-max / 6
      let max-b = p1-p3-max - min-a
      b = calc.min(b, max-b)
      a = p1-p3-max - b
      p = budget
    }
    (
      a: a,
      b: b,
      c: c,
      d: d,
      p: p,
      angle-alpha: angle-alpha,
    )
  }
}

// The four corners in clockwise order, and, for each of them, the side and the
// corner reached by walking one step clockwise (`cw`) or counter-clockwise
// (`ccw`) around the outline. Everything that traverses the shape -- budgets,
// stroke runs, filled rings -- steps through these rather than special-casing
// corners by name.
#let _corner-order = ("top-left", "top-right", "bottom-right", "bottom-left")
#let _next-cw = (
  top-left: "top-right",
  top-right: "bottom-right",
  bottom-right: "bottom-left",
  bottom-left: "top-left",
)
#let _next-ccw = (
  top-left: "bottom-left",
  top-right: "top-left",
  bottom-right: "top-right",
  bottom-left: "bottom-right",
)
#let _side-cw = (
  top-left: "top",
  top-right: "right",
  bottom-right: "bottom",
  bottom-left: "left",
)
#let _side-ccw = (
  top-left: "left",
  top-right: "top",
  bottom-right: "right",
  bottom-left: "bottom",
)

// Figma's distributeAndNormalize: given each corner's radius and the lengths
// of the four sides, computes each corner's rounding-and-smoothing budget (the
// maximum straight-edge length available to that corner, shared fairly with
// whichever neighbor claims it first).
//
// Radii reach this point already clamped to `rect`'s limit, which is strictly
// tighter than anything this can impose, so the returned radii are unchanged
// and only the budgets matter. It is kept as the source of the per-corner
// smoothing budgets.
// https://github.com/phamfoo/figma-squircle (src/distribute.ts)
#let _budgets(radii, side-lens) = {
  let budget = (
    top-left: -1pt,
    top-right: -1pt,
    bottom-right: -1pt,
    bottom-left: -1pt,
  )
  for corner in _corner-order.sorted(key: c => -radii.at(c)) {
    let r = radii.at(corner)
    // The two sides this corner shares, each with the corner at its far end.
    let vals = (
      (_side-cw.at(corner), _next-cw.at(corner)),
      (_side-ccw.at(corner), _next-ccw.at(corner)),
    ).map(pair => {
      let (side, adj-corner) = pair
      let ar = radii.at(adj-corner)
      if r <= 0pt and ar <= 0pt { 0pt } else {
        let side-len = side-lens.at(side)
        let adj-budget = budget.at(adj-corner)
        if adj-budget >= 0pt { side-len - adj-budget } else {
          (r / (r + ar)) * side-len
        }
      }
    })
    budget.at(corner) = calc.min(..vals)
  }
  budget
}
