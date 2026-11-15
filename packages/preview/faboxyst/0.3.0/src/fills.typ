// ===========================================================================
//  faboxyst/fills.typ — extra paint fills.
//
//  `halftone` / `trame` — the dot-screen fill of the programme ribbon's end
//  panel, as a first-class Typst `tiling`: use it anywhere a paint is
//  accepted (`fill:`, `stroke:`, `fabox(fill: …)`, `rect`, `curve`, …).
//
//    #rect(width: 3cm, height: 1cm, fill: halftone(rgb("#45B3BE")))
//    #fabox(fill: trame(rgb("#E8842C"), backdrop: rgb("#FDEBD3")))[Trame]
// ===========================================================================

/// A halftone dot screen: a tiling `tiling` of dots, optionally staggered
/// (diagonal grid) and optionally laid over a `backdrop` paint (a colour or
/// a gradient, e.g. the panel gradient under the dots).
///
/// ```typ
/// #rect(width: 4cm, height: 1.2cm,
///   fill: halftone(rgb("#45B3BE"), backdrop: rgb("#7BC9DF")))
/// ```
#let halftone(
  base,
  dot: auto,          // dot colour; auto = base darkened
  spacing: 6pt,       // tile size; the staggered grid puts 2 dots per tile
  radius: 18%,        // dot radius, as a fraction of `spacing`
  stagger: true,      // true = diagonal screen, false = square grid
  backdrop: none,     // paint laid under the dots (colour, gradient, none)
) = {
  let d = if dot == auto { base.darken(25%) } else { dot }
  let s = spacing
  let r = radius * s
  let tile = (dx, dy) => place(top + left, dx: dx - r, dy: dy - r,
    circle(radius: r, fill: d))
  if stagger {
    tiling(size: (s, s), {
      if backdrop != none {
        place(top + left, rect(width: s, height: s, fill: backdrop))
      }
      tile(s * 0.25, s * 0.25)
      tile(s * 0.75, s * 0.75)
    })
  } else {
    tiling(size: (s, s), {
      if backdrop != none {
        place(top + left, rect(width: s, height: s, fill: backdrop))
      }
      tile(s / 2, s / 2)
    })
  }
}

/// French alias for `halftone`.
#let trame(..a) = halftone(..a)

// ---------------------------------------------------------------------------
//  TikZ-style patterns (patterns + patterns.meta libraries)
// ---------------------------------------------------------------------------

// One family of parallel lines at `angle`, period `distance`, drawn inside
// its seamless lattice tile (Lx = d/|n.x|, Ly = d/|n.y|): translating the
// tile by either edge maps the family onto itself, so any angle tiles
// without a seam.
#let _lines-tile(angle, distance, line-width, color) = {
  let th = if type(angle) == type(1deg) { angle } else { angle * 1deg }
  let nx = -calc.sin(th)
  let ny = calc.cos(th)
  let d = distance
  let Lx = if calc.abs(nx) < 0.0001 { d } else { d / calc.abs(nx) }
  let Ly = if calc.abs(ny) < 0.0001 { d } else { d / calc.abs(ny) }
  // offsets of the lines crossing the tile: p.n over the four corners
  let os = ((0pt, 0pt), (Lx, 0pt), (0pt, Ly), (Lx, Ly))
    .map(c => c.at(0) * nx + c.at(1) * ny)
  let o-min = calc.min(os.at(0), os.at(1), os.at(2), os.at(3))
  let o-max = calc.max(os.at(0), os.at(1), os.at(2), os.at(3))
  let k0 = calc.floor(o-min / d) - 1
  let k1 = calc.ceil(o-max / d) + 1
  let T = Lx + Ly
  let ux = calc.cos(th)
  let uy = calc.sin(th)
  (Lx, Ly, range(k0, k1 + 1).map(k => {
    let o = k * d
    let cx = o * nx
    let cy = o * ny
    line(start: (cx - T * ux, cy - T * uy), end: (cx + T * ux, cy + T * uy),
      stroke: (paint: color, thickness: line-width))
  }))
}

/// A TikZ-like pattern as a first-class `tiling` paint, with the options of
/// the `patterns` / `patterns.meta` libraries: `kind` (the pattern name),
/// `distance` (period), `angle`, `line-width`, `radius` (dots and stars) and
/// the pattern `color`; `backdrop` lays a paint under the motif.
///
/// Kinds: "horizontal lines", "vertical lines", "north east lines",
/// "north west lines", "hatch", "lines", "grid", "crosshatch", "dots",
/// "crosshatch dots", "checkerboard", "bricks", "fivepointed stars",
/// "sixpointed stars".
///
/// ```typ
/// #rect(width: 4cm, height: 1.2cm,
///   fill: tikzpattern("north east lines", color: rgb("#B03030")))
/// #rect(width: 4cm, height: 1.2cm,
///   fill: tikzpattern("dots", distance: 5pt, radius: 0.8pt))
/// ```
#let tikzpattern(
  kind: "north east lines",
  color: luma(70),
  distance: 4pt,
  angle: auto,
  line-width: 0.4pt,
  radius: auto,        // dots: 0.7pt, stars: 42% of `distance`
  backdrop: none,
) = {
  let d = distance
  let lw = line-width
  let is-star = kind == "fivepointed stars" or kind == "sixpointed stars"
  let rad = if radius != auto { radius }
    else if is-star { d * 0.42 } else { 0.7pt }
  // default orientation per family, overridable through `angle`
  let a = if angle != auto {
    if type(angle) == type(1deg) { angle } else { angle * 1deg }
  } else {
    if kind == "horizontal lines" or kind == "grid" or kind == "lines" { 0deg }
    else if kind == "vertical lines" { 90deg }
    else if kind == "north west lines" { 135deg }
    else if kind == "crosshatch" { 45deg }
    else { 45deg }
  }
  let bg = (Lx, Ly) => if backdrop != none {
    place(top + left, rect(width: Lx, height: Ly, fill: backdrop))
  }
  if kind == "dots" or kind == "crosshatch dots" {
    let cross = kind == "crosshatch dots"
    tiling(size: (d, d), {
      bg(d, d)
      place(top + left, dx: d / 2 - rad, dy: d / 2 - rad,
        circle(radius: rad, fill: color))
      if cross {
        for c in ((0pt, 0pt), (d, 0pt), (0pt, d), (d, d)) {
          place(top + left, dx: c.at(0) - rad, dy: c.at(1) - rad,
            circle(radius: rad, fill: color))
        }
      }
    })
  } else if kind == "checkerboard" {
    tiling(size: (2 * d, 2 * d), {
      bg(2 * d, 2 * d)
      place(top + left, rect(width: d, height: d, fill: color))
      place(top + left, dx: d, dy: d, rect(width: d, height: d, fill: color))
    })
  } else if kind == "bricks" {
    // Drawn bricks separated by mortar joints (the joint width follows
    // `line-width`): course height = `distance`, brick length 2.2 courses,
    // alternate courses offset by half a brick, slightly rounded arrises.
    let g = calc.max(2 * lw, 0.6pt)
    let bh = d
    let bl = 2.2 * d
    let W = bl + g
    let H = 2 * (bh + g)
    let br = calc.min(bh * 0.14, 0.8pt)
    tiling(size: (W, H), {
      bg(W, H)
      place(top + left, rect(width: bl, height: bh, fill: color, radius: br))
      place(top + left, dx: W / 2, dy: bh + g,
        rect(width: bl, height: bh, fill: color, radius: br))
      place(top + left, dx: -W / 2, dy: bh + g,
        rect(width: bl, height: bh, fill: color, radius: br))
    })
  } else if kind == "fivepointed stars" or kind == "sixpointed stars" {
    let five = kind == "fivepointed stars"
    let star = (cx, cy) => {
      let pts = if five {
        range(10).map(i => {
          let r = if calc.rem(i, 2) == 0 { rad } else { rad * 0.42 }
          let ang = (i * 36 - 90) * 1deg
          (cx + r * calc.cos(ang), cy + r * calc.sin(ang))
        })
      } else {
        range(6).map(i => {
          let ang = (i * 60 - 90) * 1deg
          (cx + rad * calc.cos(ang), cy + rad * calc.sin(ang))
        })
      }
      place(top + left, polygon(fill: color, ..pts))
      if not five {
        let pts2 = range(6).map(i => {
          let ang = (i * 60 - 60) * 1deg
          (cx + rad * calc.cos(ang), cy + rad * calc.sin(ang))
        })
        place(top + left, polygon(fill: color, ..pts2))
      }
    }
    tiling(size: (d, d), {
      bg(d, d)
      star(d / 2, d / 2)
      star(0pt, 0pt)
      star(d, 0pt)
      star(0pt, d)
      star(d, d)
    })
  } else {
    // line families: hatch / lines / grid / crosshatch / the four legends
    let fams = if kind == "grid" { (a, a + 90deg) }
      else if kind == "crosshatch" { (a, a + 90deg) }
      else { (a,) }
    // grid at angle 0 must stay horizontal+vertical; crosshatch keeps ±45
    let t1 = _lines-tile(fams.at(0), d, lw, color)
    let Lx = t1.at(0)
    let Ly = t1.at(1)
    if fams.len() == 1 {
      tiling(size: (Lx, Ly), {
        bg(Lx, Ly)
        for ln in t1.at(2) { place(top + left, ln) }
      })
    } else {
      // two families share one tile: the union lattice
      let t2 = _lines-tile(fams.at(1), d, lw, color)
      let W = calc.max(Lx, t2.at(0))
      let H = calc.max(Ly, t2.at(1))
      let mx = calc.round(W / Lx)
      let my = calc.round(H / Ly)
      let m2x = calc.round(W / t2.at(0))
      let m2y = calc.round(H / t2.at(1))
      let W2 = Lx * mx
      let H2 = Ly * my
      let W3 = t2.at(0) * m2x
      let H3 = t2.at(1) * m2y
      let WW = calc.max(W2, W3)
      let HH = calc.max(H2, H3)
      tiling(size: (WW, HH), {
        bg(WW, HH)
        for ln in t1.at(2) { place(top + left, ln) }
        for ln in t2.at(2) { place(top + left, ln) }
      })
    }
  }
}

/// French alias for `tikzpattern`.
#let motif-tikz(..a) = tikzpattern(..a)
