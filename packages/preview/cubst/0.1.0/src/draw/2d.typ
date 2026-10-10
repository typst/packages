// Straight-on renderer: one face seen head-on, optionally with the stickers
// of the neighbouring faces that touch it drawn as thin strips around it.
// With `face: "U"` on a cube this is the usual OLL/PLL diagram. Pure Typst,
// and generic: the face's stickers come from the puzzle model.

#import "../geom.typ" as g
#import "../state.typ": assert-puzzle, assert-face, index-of
#import "../puzzles/registry.typ" as registry
#import "common.typ": default-palette, fill-of, abs-pt, shape, arrow, name-label

/// Draw one face of a puzzle head-on.
///
/// - `face`: which face to look at (`auto` = the puzzle's first face, `U` on
///   every puzzle but the pyraminx, where it is `F`).
/// - `sides`: whether to draw the neighbouring stickers that touch the face
///   as strips around it.
/// - `sticker`: length of one unit (one cube sticker edge; absolute length).
/// - `gap`: space between stickers (shows `body` through it).
/// - `side-length`: thickness of the side strips as a fraction of a unit.
/// - `margin`: distance between the face and the side strips (`auto` = small).
/// - `arrows`: array of arrows on the face. Each is `(from, to)` or
///   `(from:, to:, double: bool, color:, thickness:, head:)`, where a position
///   is a sticker index, or `(row, col)` on a cube; `color`, `thickness` and
///   `head` override `arrow-color`, `arrow-thickness` and `arrow-head` for
///   that arrow.
/// - `labels`: `true` writes each sticker's index on it (for finding
///   positions); `"faces"` writes the face's name at its centre.
/// - `slices`: draw the puzzle's slice planes (Square-1) as thin lines
///   through the face, reaching a little beyond the drawing; `"through"`
///   makes them span the whole picture box, which is also made symmetric
///   about the face centre, so that the net can continue the line.
/// - `turn`: rotate the picture by an angle; `auto` turns it so that the
///   first slice line is vertical (nothing when the puzzle has no slices).
///
/// A puzzle with `strips: "radial"` (Square-1) gets its side strips as
/// trapezoids whose ends run along the lines from the face centre through
/// the piece boundaries, flush with the face, so that neighbouring strips
/// meet in a mitre and the ends at the slice are parallel to it.
#let draw-face(
  c,
  face: auto,
  sides: true,
  sticker: 6mm,
  gap: 0pt,
  side-length: 0.35,
  margin: auto,
  stroke: 0.5pt + black,
  radius: 0pt,
  palette: default-palette,
  hidden: auto,
  body: none,
  arrows: (),
  arrow-color: black,
  arrow-thickness: 1.6pt,
  arrow-head: 0.3,
  labels: false,
  slices: false,
  turn: 0deg,
) = {
  assert-puzzle(c, who: "draw-face")
  let p = registry.of(c)
  let face = if face == auto { (p.faces)(c.params).first() } else { face }
  assert-face(c, face, who: "draw-face")
  let model = registry.model(c)
  assert(
    face in model.faces,
    message: "cubst: face " + face + " of a " + c.event + " is not flat and cannot be drawn straight on; try " + model.faces.keys().join(", "),
  )
  let fr = model.faces.at(face).frame
  let s = abs-pt(sticker, "sticker")
  let gp = abs-pt(gap, "gap") / s
  let radial = p.at("strips", default: "straight") == "radial"

  // (polygon in face units, color name)
  let shapes = ()
  let own = (:)
  for st in model.stickers.filter(st => st.face == face) {
    let poly = st.poly.map(p => g.to-local(fr, p))
    own.insert(str(st.index), poly)
    shapes.push((poly: g.inset(poly, gp), name: c.faces.at(face).at(st.index)))
  }

  if sides {
    let m = if margin == auto { if radial { 0 } else { calc.max(gp, 0.12) } } else { abs-pt(margin, "margin") / s }
    let n = fr.normal
    let plane = g.dot(model.faces.at(face).verts.first(), n)
    for st in model.stickers.filter(st => st.face != face) {
      // stickers with an edge on this face's plane touch the face
      let on-plane = st.poly.filter(p => calc.abs(g.dot(p, n) - plane) < 1e-6).map(p => g.to-local(fr, p))
      if on-plane.len() < 2 { continue }
      let dir = g.unit2(g.sub2(on-plane.last(), on-plane.first()))
      let along = on-plane.sorted(key: p => g.dot2(p, dir))
      let (a, b) = (along.first(), along.last())
      let out = (-dir.at(1), dir.at(0))
      if g.dot2(out, g.centroid2((a, b))) < 0 { out = g.scale2(out, -1) }
      // the strip's end at `q`: straight out, or along the ray from the centre through `q`
      let end(q, dist) = if radial {
        let ray = g.unit2(q)
        g.add2(q, g.scale2(ray, dist / g.dot2(ray, out)))
      } else { g.add2(q, g.scale2(out, dist)) }
      let poly = (end(a, m), end(b, m), end(b, m + side-length), end(a, m + side-length))
      shapes.push((poly: g.inset(poly, gp), name: c.faces.at(st.face).at(st.index)))
    }
  }

  // the slice planes, as lines through the face centre that reach a little
  // beyond the drawing (the strips, or the face itself) at both ends
  let overhang = 0.4
  let slice-dirs = if slices != false and "slices" in p {
    (p.slices)(c.params).map(normal => g.unit2(g.to-local(fr, g.add(fr.center, g.cross(fr.normal, normal)))))
  } else { () }

  // turn the whole picture: by `turn`, or so that the first slice is vertical
  let angle = if turn != auto { turn } else if slice-dirs.len() == 0 { 0deg } else {
    let d = slice-dirs.first()
    let a = calc.atan2(d.at(1), d.at(0))
    if a > 90deg { a - 180deg } else if a <= -90deg { a + 180deg } else { a }
  }
  let spin(q) = g.rot2(q, angle)
  let shapes = shapes.map(sh => (..sh, poly: sh.poly.map(spin)))
  let own = own.pairs().map(((k, poly)) => (k, poly.map(spin))).to-dict()
  let slice-dirs = slice-dirs.map(spin)

  let slice-lines = slice-dirs.map(d => {
    // where the line through the centre along `d` crosses the drawn edges
    let (lo, hi) = (0, 0)
    for sh in shapes {
      let n = sh.poly.len()
      for i in range(n) {
        let a = sh.poly.at(i)
        let e = g.sub2(sh.poly.at(calc.rem(i + 1, n)), a)
        let denom = d.at(0) * e.at(1) - d.at(1) * e.at(0)
        if calc.abs(denom) < 1e-9 { continue }
        let t = (a.at(0) * e.at(1) - a.at(1) * e.at(0)) / denom
        let u = (a.at(0) * d.at(1) - a.at(1) * d.at(0)) / denom
        if u >= -1e-9 and u <= 1 + 1e-9 {
          lo = calc.min(lo, t)
          hi = calc.max(hi, t)
        }
      }
    }
    (g.scale2(d, lo - overhang), g.scale2(d, hi + overhang))
  })

  let (min, max) = g.bbox(shapes.map(sh => sh.poly).flatten().chunks(2) + slice-lines.flatten().chunks(2))
  if slices == "through" {
    // a box symmetric about the centre, with the lines spanning it entirely
    let m = calc.max(-min.at(0), max.at(0))
    (min, max) = ((-m, min.at(1)), (m, max.at(1)))
    slice-lines = slice-dirs.map(d => {
      let (lo, hi) = (-1e9, 1e9)
      for i in (0, 1) {
        if calc.abs(d.at(i)) > 1e-9 {
          let (t1, t2) = (min.at(i) / d.at(i), max.at(i) / d.at(i))
          lo = calc.max(lo, calc.min(t1, t2))
          hi = calc.min(hi, calc.max(t1, t2))
        }
      }
      (g.scale2(d, lo), g.scale2(d, hi))
    })
  }
  let to-pt(p) = ((p.at(0) - min.at(0)) * s, (p.at(1) - min.at(1)) * s)
  let center(pos) = to-pt(g.centroid2(own.at(str(index-of(c, face, pos)))))
  let slice-lines = slice-lines.map(((from, to)) => (to-pt(from), to-pt(to)))

  box(width: (max.at(0) - min.at(0)) * s * 1pt, height: (max.at(1) - min.at(1)) * s * 1pt, fill: body, radius: radius, {
    for sh in shapes { shape(sh.poly.map(to-pt), fill-of(sh.name, palette, hidden), stroke, radius) }
    for (from, to) in slice-lines {
      place(top + left, line(start: (from.at(0) * 1pt, from.at(1) * 1pt), end: (to.at(0) * 1pt, to.at(1) * 1pt), stroke: 0.6pt + luma(120)))
    }
    for a in arrows {
      let a = if type(a) == array { (from: a.at(0), to: a.at(1)) } else { a }
      arrow(
        center(a.from),
        center(a.to),
        a.at("head", default: arrow-head) * s,
        a.at("color", default: arrow-color),
        a.at("thickness", default: arrow-thickness),
        double: a.at("double", default: false),
      )
    }
    if labels == "faces" {
      // the face's name at its centre, on a white pill since outlines meet there
      let (x, y) = to-pt(spin(g.centroid2(model.faces.at(face).verts.map(p => g.to-local(fr, p)))))
      place(
        top + left,
        dx: (x - 1.5 * s) * 1pt,
        dy: (y - s / 2) * 1pt,
        box(width: 3 * s * 1pt, height: s * 1pt, align(std.center + horizon, name-label(face, s))),
      )
    } else if labels == true {
      for (i, poly) in own {
        let (x, y) = to-pt(g.centroid2(poly))
        place(
          top + left,
          dx: (x - s / 2) * 1pt,
          dy: (y - s / 2) * 1pt,
          box(width: s * 1pt, height: s * 1pt, align(std.center + horizon, text(size: 0.38 * s * 1pt, i))),
        )
      }
    }
  })
}
