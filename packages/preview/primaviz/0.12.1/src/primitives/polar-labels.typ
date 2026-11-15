// polar-labels.typ - Label rules shared by the radial charts
//
// Every radial chart answers the same four questions about a label, and
// answers them here so a fix lands everywhere:
//
//   readable?   label-ink / legible      text colour that works on a fill / the page
//   inside?     fit-wedge-label          largest size, best spot, best orientation
//   outside?    place-outside-labels     around a circle, no collisions, leader if moved
//   room?       polar-fit-radius         biggest circle that leaves room for them
//
// A label never overlaps another label or leaves its container: it fits,
// shrinks, moves (with a leader line), or is dropped (the legend, if any,
// still carries it).
//
// All functions measure text, so call them from inside `context`.

#import "polar.typ": polar-pt
#import "fonts.typ": spread-labels

// ── Colour ──────────────────────────────────────────────────────────────

// luminance and contrast-ratio live in util.typ (one WCAG implementation)
#import "../util.typ": luminance, contrast-ratio, contrast-text

/// Text colour for a label drawn on a filled mark.
///
/// Takes the theme's own text colours, darker first, and uses the first with
/// at least `min-ratio` contrast against the fill; if neither reaches it,
/// black or white, whichever is stronger. (A fixed "inverse" colour is
/// unreadable on half a palette: white on yellow is 1.7:1.)
///
/// - fill (color): The mark's fill
/// - theme (dictionary): Resolved theme
/// - min-ratio (float): Contrast ratio worth keeping a theme colour for
/// -> color
#let label-ink(fill, theme, min-ratio: 4.5) = contrast-text(fill, theme: theme, min-ratio: min-ratio)

/// The colour a mark is drawn in, nudged until text in it is readable on
/// the page: pale palette colours (yellow, pink) vanish as text on white.
///
/// - c (color): Wanted colour
/// - bg (color): What it is drawn on
/// - min-ratio (float): Contrast ratio to reach (3 is the large-text bar)
/// -> color
#let legible(c, bg, min-ratio: 3.0) = {
  let out = c
  let lighter-bg = luminance(bg) > 0.35
  for _ in range(10) {
    if contrast-ratio(out, bg) >= min-ratio { break }
    out = if lighter-bg { out.darken(12%) } else { out.lighten(12%) }
  }
  out
}

// ── Text fitting ────────────────────────────────────────────────────────

/// Largest font size in `size-min..size-max` at which `make(size)` is at most
/// `max-w` wide (`size-min` if none is).
///
/// - make (function): `size => content`
/// - max-w (length): Width to fit
/// - size-max (length): Preferred size
/// - size-min (length): Floor size
/// -> length
#let fit-text-size(make, max-w, size-max, size-min, step: 0.5pt) = {
  let s = size-max
  while s > size-min and measure(make(s)).width > max-w { s -= step }
  calc.max(s, size-min)
}

// ── Inside a wedge ──────────────────────────────────────────────────────

// Wrap an angle to [-180, 180)
#let _wrap(d) = calc.rem-euclid(d + 180, 360) - 180

// Keep text upright: an angle in [-90, 90] (so a vertical label on the left
// of a circle reads upward, on the right downward: tops face outward)
#let _upright(d) = {
  let a = _wrap(d)
  if a > 90 { a - 180 } else if a < -90 { a + 180 } else { a }
}

/// Whether a `w`×`h` label, centred at distance `r` along `mid`, lies inside
/// the wedge (`r-in..r-out`, `mid ± half-span`) with `pad` to spare.
///
/// `rot` turns the label (degrees clockwise, as on screen). Exact for
/// convex wedges (half-span < 90deg, which is any label worth fitting).
///
/// - r (length): Distance of the label centre from the chart centre
/// - mid (float): Direction of the label centre, degrees
/// - w (length): Label width
/// - h (length): Label height
/// - r-in (length): Inner radius of the wedge (0 for a pie slice)
/// - r-out (length): Outer radius of the wedge
/// - half-span (float): Half the wedge's sweep, degrees
/// - rot (float): Label rotation in degrees
/// - pad (length): Clearance to keep from every edge
/// -> bool
#let rect-in-wedge(r, mid, w, h, r-in, r-out, half-span, rot: 0, pad: 1pt) = {
  let (r, w, h, r-in, r-out, pad) = (r, w, h, r-in, r-out, pad).map(x => x / 1pt)
  let (px, py) = (r * calc.cos(mid * 1deg), r * calc.sin(mid * 1deg))
  let (cr, sr) = (calc.cos(rot * 1deg), calc.sin(rot * 1deg))
  let ok = true
  for (sx, sy) in ((-1, -1), (1, -1), (1, 1), (-1, 1)) {
    let (u, v) = (sx * w / 2, sy * h / 2)
    let (x, y) = (px + u * cr - v * sr, py + u * sr + v * cr)
    let rho = calc.sqrt(x * x + y * y)
    if rho > r-out - pad { ok = false }
    if half-span < 90 and rho > 0.001 {
      let off = calc.abs(_wrap(calc.atan2(x, y).deg() - mid))
      if off > half-span - pad / rho * 57.2958 { ok = false }
    }
  }
  if ok and r-in > 0 {
    // the rectangle's nearest point to the centre must clear the hole
    let (lu, lv) = (-px * cr - py * sr, px * sr - py * cr)
    let (du, dv) = (lu - calc.max(-w / 2, calc.min(w / 2, lu)), lv - calc.max(-h / 2, calc.min(h / 2, lv)))
    if calc.sqrt(du * du + dv * dv) < r-in + pad { ok = false }
  }
  ok
}

/// Finds the biggest label that fits inside a wedge and where it sits.
///
/// Tries `make(size)` from `size-max` down to `size-min`, horizontal first;
/// with `rotate`, a label that fits no size horizontally is tried along the
/// radius and then along the arc (turned to stay upright). At each size the
/// spot nearest `r-pref` that fits wins. Returns `none` when nothing fits:
/// the caller moves the label outside, or drops it.
///
/// - make (function): `size => content`
/// - mid (float): Direction of the wedge's middle, degrees
/// - half-span (float): Half the wedge's sweep, degrees
/// - r-in (length): Inner radius of the wedge (0 for a pie slice)
/// - r-out (length): Outer radius of the wedge
/// - size-max (length): Preferred label size
/// - size-min (length): Smallest size worth printing
/// - r-pref (auto, length): Preferred distance of the label from the centre
/// - rotate (bool): Allow turning the label
/// - pad (length): Clearance from the wedge's edges
/// -> none, dictionary with `size`, `r`, `rot`, `w`, `h`
#let fit-wedge-label(make, mid, half-span, r-in, r-out, size-max, size-min, r-pref: auto, rotate: false, pad: 1.2pt) = {
  let pref = if r-pref == auto { (r-in + r-out) / 2 } else { r-pref }
  let step = (r-out - r-in) / 10
  let radii = ()
  for k in range(0, 11) {
    for sign in (1, -1) {
      let r = pref + sign * k * step
      if r >= r-in and r <= r-out and r not in radii { radii.push(r) }
    }
  }
  let sizes = ()
  let s = size-max
  while s >= size-min { sizes.push(s); s -= 0.5pt }
  if sizes.len() == 0 { sizes.push(size-min) }
  let dims = sizes.map(s => measure(make(s)))

  let rots = ((0,),)
  if rotate { rots.push((_upright(mid), _upright(mid + 90))) }
  let found = none
  for rs in rots {
    for (i, size) in sizes.enumerate() {
      for rot in rs {
        for r in radii {
          if found == none and rect-in-wedge(r, mid, dims.at(i).width, dims.at(i).height, r-in, r-out, half-span, rot: rot, pad: pad) {
            found = (size: size, r: r, rot: rot, w: dims.at(i).width, h: dims.at(i).height)
          }
        }
      }
    }
  }
  found
}

/// Breaks a label wider than `max-w` onto several lines, the lines leaning
/// toward the mark it names (right-aligned on the left of a circle, left-aligned
/// on the right). Without this one long name pushes a whole chart small.
///
/// - body (content): Label
/// - max-w (length): Widest the label may be
/// - angle (float): Degrees clockwise from 3 o'clock of the mark it names
/// -> content
#let wrap-label(body, max-w, angle) = {
  if measure(body).width <= max-w { body } else {
    let c = calc.cos(angle * 1deg)
    let al = if c < -0.3 { right } else if c > 0.3 { left } else { center }
    box(width: max-w, align(al, par(justify: false, leading: 0.4em, body)))
  }
}

/// Places `body` centred on (`x`, `y`), optionally turned by `rot` degrees
/// clockwise (see `fit-wedge-label`).
///
/// - x (length): Centre x
/// - y (length): Centre y
/// - w (length): Label width
/// - h (length): Label height
/// - body (content): Label
/// - rot (float): Rotation, degrees clockwise
/// -> content
#let place-centred(x, y, w, h, body, rot: 0) = {
  let b = box(width: w + 1pt, height: h, align(center + horizon, body))
  place(left + top, dx: x - w / 2 - 0.5pt, dy: y - h / 2,
    if rot == 0 { b } else { rotate(rot * 1deg, b) })  // Typst turns positive angles clockwise, like screen angles
}

// ── Outside a circle ────────────────────────────────────────────────────

// Top-left of a w×h label for a mark at (mx, my): a continuous slide from
// left of the point (angle 0) to centred above/below it (angle ±90°) to
// right of it (angle 180°), then nudged outward until no part of the label
// is nearer the mark than `gap` (a big label at a diagonal would otherwise
// graze the mark it names).
#let _slot(angle, w, h, mx, my, gap) = {
  let (c, s) = (calc.cos(angle * 1deg), calc.sin(angle * 1deg))
  let (x, y) = (mx + gap * c - w * (1 - c) / 2, my + gap * s - h * (1 - s) / 2)
  for _ in range(6) {
    let (ex, ey) = (calc.max(x - mx, 0pt, mx - x - w), calc.max(y - my, 0pt, my - y - h))
    let d = calc.sqrt((ex / 1pt) * (ex / 1pt) + (ey / 1pt) * (ey / 1pt)) * 1pt
    if d >= gap - 0.05pt { break }
    // How fast moving along (c, s) opens the gap, given where the nearest point is
    let (ux, uy) = (if x > mx { 1 } else { -1 }, if y > my { 1 } else { -1 })
    let rate = if d == 0pt { 1.0 } else { calc.max(0.25, (ux * ex / 1pt * c + uy * ey / 1pt * s) / (d / 1pt)) }
    x += (gap - d) / rate * c
    y += (gap - d) / rate * s
  }
  (x, y)
}

// Length of the vector (dx, dy)
#let _dist(dx, dy) = calc.sqrt((dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt)) * 1pt

// Whether two label rectangles come within `margin` of each other
#let _touch(a, b, margin) = (
  a.lx < b.lx + b.w + margin and b.lx < a.lx + a.w + margin
    and a.ly < b.ly + b.h + margin and b.ly < a.ly + a.h + margin
)

// Top-left of mark `m`'s label when the mark is read as sitting at `phi`
// degrees on its circle, though it really sits at `theta`, with the label on
// row `lvl` (0: against the circle; each row beyond stands one label's depth
// further out). A label slid along the circle also stands a little further
// out the further it slid (up to 10pt), so the leader lines of a fan clear
// the labels they pass.
#let _rect(m, phi, theta, lvl, cx, cy, gap) = {
  let (ax, ay) = polar-pt(cx, cy, m.ar, phi)
  let slid = calc.abs(phi - theta) / 57.2958 * m.ar
  let (c, s) = (calc.cos(phi * 1deg), calc.sin(phi * 1deg))
  let lift = lvl * (m.w * calc.abs(c) + m.h * calc.abs(s) + 2pt)
  let (lx, ly) = _slot(phi, m.w, m.h, ax, ay, gap + calc.min(10pt, 0.3 * slid) + lift)
  (lx: lx, ly: ly)
}

// Lays out every label round its circle, keeping the order of the marks.
//
// Labels whose marks are close enough to collide are slid along the circle
// until none comes within `sep` of another, each as near its own mark as it
// can stay: a cluster at 12 or 6 o'clock fans out sideways, one at 3 or 9
// o'clock up and down, one in between both. The room two neighbours need is
// their extent along the circle's tangent (a w×h box seen along direction
// `psi` measures w|sin| + h|cos|) as an angle at their distance from the
// centre; the nearest layout that gives every neighbour that room is a
// pool-adjacent-violators fit. Neighbours still touching afterwards (the
// estimate is a little off at diagonals) are given more room and the fit is
// repeated.
//
// When the crowd is too long for one row (a ring of labels is only so long),
// the labels of each cluster take turns on two or three rows, stepping out
// from the circle, and only labels on the same row need room along it.
// The fewest rows that leave no label touching another, inside `bounds`
// (none: no limit), and slid no further than a radius, win.
//
// Returns the marks, each with its final `lx`, `ly`, angle `phi` and row `lv`.
#let _fan(marks, cx, cy, gap, sep, bounds) = {
  let n = marks.len()
  if n == 0 { return () }
  // By angle, starting after the widest empty arc, so a cluster that
  // straddles 3 o'clock is not cut in two
  let norm = marks.map(m => calc.rem-euclid(m.angle, 360))
  let by-angle = array.range(n).sorted(key: i => (norm.at(i), i))
  let first = 0
  let widest = -1.0
  for k in range(n) {
    let next = if k + 1 < n { norm.at(by-angle.at(k + 1)) } else { norm.at(by-angle.at(0)) + 360 }
    if next - norm.at(by-angle.at(k)) > widest {
      widest = next - norm.at(by-angle.at(k))
      first = calc.rem(k + 1, n)
    }
  }
  let seq = range(n).map(k => by-angle.at(calc.rem(first + k, n)))
  let ms = seq.map(i => marks.at(i))
  let th = ()
  let wrapped = false
  for (k, i) in seq.enumerate() {
    if k > 0 and norm.at(i) < norm.at(seq.at(k - 1)) { wrapped = true }
    let a = norm.at(i)
    th.push(if wrapped { a + 360 } else { a })
  }

  let rects(phi, lv) = range(n).map(k => {
    let at = _rect(ms.at(k), phi.at(k), th.at(k), lv.at(k), cx, cy, gap)
    (: ..ms.at(k), ..at)
  })
  let fitted(phi, lv) = rects(phi, lv).enumerate().map(((k, p)) => {
    let q = (: ..p, phi: phi.at(k), th: th.at(k), lv: lv.at(k))
    if bounds == none { q } else {
      (: ..q, lx: calc.max(bounds.left, calc.min(bounds.right - p.w, p.lx)),
        ly: calc.max(bounds.top, calc.min(bounds.bottom - p.h, p.ly)))
    }
  })

  // Where each label stands in the run of neighbours it touches (0: first or alone)
  let home = rects(th, (0,) * n)
  let pool = (0,) * n
  for k in range(1, n) {
    if _touch(home.at(k - 1), home.at(k), sep) { pool.at(k) = pool.at(k - 1) + 1 }
  }

  let limit = calc.max(..marks.map(m => m.ar))
  let best = none
  for rows in (1, 2, 3) {
    let lv = pool.map(j => calc.rem(j, rows))
    let phi = th
    let grow = (1.0,) * n
    for round in range(16) {
      let rs = rects(phi, lv)
      // Label k is squeezed when it, or a label on the same row after it,
      // touches one before it
      let tight = (false,) * n
      for a in range(n) {
        for b in range(a + 1, n) {
          if lv.at(a) == lv.at(b) and _touch(rs.at(a), rs.at(b), sep) {
            for c in range(a + 1, b + 1) { if lv.at(c) == lv.at(a) { tight.at(c) = true } }
          }
        }
      }
      if not tight.any(t => t) { break }

      for row in range(rows) {
        let idx = range(n).filter(k => lv.at(k) == row)
        if idx.len() < 2 { continue }
        // Degrees each label needs beyond the one before it
        let steps = (0.0,)
        for j in range(1, idx.len()) {
          let (ka, kb) = (idx.at(j - 1), idx.at(j))
          if round > 0 and tight.at(kb) { grow.at(kb) *= 1.25 }
          let (a, b) = (rs.at(ka), rs.at(kb))
          let psi = (phi.at(ka) + phi.at(kb)) / 2 * 1deg
          let along(m) = m.w * calc.abs(calc.sin(psi)) + m.h * calc.abs(calc.cos(psi))
          let reach = calc.max(1pt, (_dist(a.lx + a.w / 2 - cx, a.ly + a.h / 2 - cy) + _dist(b.lx + b.w / 2 - cx, b.ly + b.h / 2 - cy)) / 2)
          let need = ((along(a) + along(b)) / 2 + sep) / (2 * reach)
          steps.push(2 * calc.asin(calc.min(1.0, need)).deg() * grow.at(kb))
        }
        // The nearest layout with that room between neighbours (degrees as points)
        let at = spread-labels(idx.map(k => th.at(k) * 1pt), need: (a, b) => steps.at(b) * 1pt)
        for (j, k) in idx.enumerate() { phi.at(k) = at.at(j) / 1pt }
      }
    }

    let placed = fitted(phi, lv)
    let clashes = 0
    for a in range(n) {
      for b in range(a + 1, n) {
        if _touch(placed.at(a), placed.at(b), 0pt) { clashes += 1 }
      }
    }
    let slide = calc.max(..range(n).map(k => calc.abs(phi.at(k) - th.at(k)) / 57.2958 * ms.at(k).ar))
    if best == none or (clashes, slide) < (best.clashes, best.slide) {
      best = (placed: placed, clashes: clashes, slide: slide)
    }
    if clashes == 0 and slide <= limit { break }
  }
  best.placed
}

// Every label that can be shown without touching another or leaving
// `bounds` (none: no limit), placed. When a crowd cannot be fitted, the label
// of lowest priority among those still touching is dropped and the rest laid
// out again.
#let _layout-outside(marks, cx, cy, gap, bounds: none) = {
  let live = marks
  let out = ()
  for _ in range(marks.len() + 1) {
    let placed = _fan(live, cx, cy, gap, 1.5pt, bounds)
    let weakest = none
    for (a, p) in placed.enumerate() {
      for q in placed.slice(a + 1) {
        if _touch(p, q, 0pt) {
          for c in (p, q) {
            if weakest == none or (c.priority, -c.idx) < (weakest.priority, -weakest.idx) { weakest = c }
          }
        }
      }
    }
    if weakest == none {
      out = placed
      break
    }
    live = live.filter(m => m.idx != weakest.idx)
  }
  out
}

// Measured size (with a hair of slack) of every item's label
#let _sizes(items) = items.map(it => {
  let m = measure(it.body)
  (m.width + 1pt, m.height)
})

#let _marks(items, sizes, r) = items.zip(sizes).enumerate().map(((i, (it, (w, h)))) => (
  idx: i, angle: it.angle, ar: it.at("r", default: r), w: w, h: h, src: it.at("from", default: none),
  priority: it.at("priority", default: 0), body: it.body))

/// The box, centred on the chart, that holds a circle of radius `r` and every
/// outside label around it (see `place-outside-labels`): `x` and `y` are its
/// half-width and half-height; `left`, `right`, `top` and `bottom` how far
/// the labels (or the circle) reach on each side, without `pad`.
///
/// - items (array): Dictionaries with `angle` (degrees) and `body`
/// - r (length): Circle radius
/// - gap (length): Distance between circle and label
/// - pad (length): Clearance beyond the labels
/// -> dictionary
#let polar-label-extent(items, r, gap: 4pt, pad: 1pt) = {
  let (left, right, top, bottom) = (r, r, r, r)
  for p in _layout-outside(_marks(items, _sizes(items), r), 0pt, 0pt, gap) {
    left = calc.max(left, -p.lx)
    right = calc.max(right, p.lx + p.w)
    top = calc.max(top, -p.ly)
    bottom = calc.max(bottom, p.ly + p.h)
  }
  (x: calc.max(left, right) + pad, y: calc.max(top, bottom) + pad, left: left, right: right, top: top, bottom: bottom)
}

/// Biggest circle radius at which every outside label (see
/// `place-outside-labels`) still fits inside a `box-w`×`box-h` box centred
/// on (`cx`, `cy`).
///
/// - items (array): Dictionaries with `angle` (degrees) and `body`
/// - cx (length): Centre x
/// - cy (length): Centre y
/// - box-w (length): Box width
/// - box-h (length): Box height
/// - gap (length): Distance between circle and label
/// - pad (length): Clearance from the box's edges
/// -> length
#let polar-fit-radius(items, cx, cy, box-w, box-h, gap: 4pt, pad: 1pt) = {
  let sizes = _sizes(items)
  // How far the labels poke out of the box when the circle has radius r
  let over(r) = {
    let worst = r - (calc.min(cx, cy, box-w - cx, box-h - cy) - pad)
    for p in _layout-outside(_marks(items, sizes, r), cx, cy, gap) {
      worst = calc.max(worst, p.lx + p.w - (box-w - pad), pad - p.lx, p.ly + p.h - (box-h - pad), pad - p.ly)
    }
    worst
  }
  // Bisection: `over` only grows with r
  let (lo, hi) = (calc.min(cx, cy) * 0.25, calc.min(cx, cy, box-w - cx, box-h - cy) - pad)
  if over(hi) <= 0pt { hi } else {
    for _ in range(12) {
      let mid = (lo + hi) / 2
      if over(mid) <= 0pt { lo = mid } else { hi = mid }
    }
    lo
  }
}

/// Labels around a circle: each label sits just beyond its own mark. Labels
/// that would collide are slid round the circle (sideways at the top and
/// bottom, up and down at the sides) until they clear each other, a label
/// that moved gets a leader line back to its mark, and a label that still
/// cannot be placed without touching another is dropped (lowest `priority`
/// first).
///
/// - items (array): Dictionaries with `angle` (degrees), `body` (content),
///   and optionally `r` (where the mark ends, default `r`), `priority`
///   (default 0; higher survives) and `from` (a radius: the mark lies there,
///   deeper inside the chart than its label, so the label always gets a
///   leader line from that point)
/// - cx (length): Centre x
/// - cy (length): Centre y
/// - r (length): Default radius of the marks
/// - bounds (dictionary): `left`, `right`, `top`, `bottom` the labels must stay inside
/// - gap (length): Distance between mark and label
/// - leader-stroke (stroke): Style of the leader lines
/// - tol (length): How far a label may slide before it earns a leader
/// -> content
#let place-outside-labels(items, cx, cy, r, bounds, gap: 4pt, leader-stroke: 0.5pt + gray, tol: 1.5pt) = {
  let marks = _marks(items, _sizes(items), r)
  for p in _layout-outside(marks, cx, cy, gap, bounds: bounds) {
    let c = calc.cos(p.phi * 1deg)
    let (ax, ay) = polar-pt(cx, cy, if p.src == none { p.ar } else { p.src }, p.angle)
    let home = _rect(p, p.th, p.th, 0, cx, cy, gap)
    let moved = p.src != none or calc.abs(p.ly - home.ly) > tol or calc.abs(p.lx - home.lx) > tol
    let h-align = if c < -0.3 { right } else if c > 0.3 { left } else { center }
    place(left + top, dx: p.lx, dy: p.ly,
      box(width: p.w, height: p.h, align(h-align + horizon, p.body)))
    // Leader from the mark to the nearest point of the label
    let (tx, ty) = (calc.max(p.lx, calc.min(p.lx + p.w, ax)), calc.max(p.ly, calc.min(p.ly + p.h, ay)))
    let (dx, dy) = ((tx - ax) / 1pt, (ty - ay) / 1pt)
    let len = calc.sqrt(dx * dx + dy * dy)
    if moved and len > 3 {
      place(left + top, line(start: (ax, ay), end: (tx - dx / len * 1.5pt, ty - dy / len * 1.5pt), stroke: leader-stroke))
      // A mark inside the chart, away from its edge, gets a dot to say where it starts
      if p.src != none {
        place(left + top, dx: ax - 1pt, dy: ay - 1pt, circle(radius: 1pt, fill: stroke(leader-stroke).paint, stroke: none))
      }
    }
  }
}
