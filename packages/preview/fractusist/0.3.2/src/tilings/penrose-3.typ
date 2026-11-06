//==============================================================================
// Penrose rhombus tiling (P3)
//
// Reference to https://en.wikipedia.org/wiki/Penrose_tiling
//
// Public functions:
//     p3-a-triangle, p3-ap-triangle
//     p3-b-triangle, p3-bp-triangle
//     penrose-3
//==============================================================================


#import "util.typ": *


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------


// Generate type A triangle (isosceles triangle with apex angle 36 deg)
#let p3-a-triangle(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 72deg, (calc.sqrt(5)+1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -36deg)
  } else {    // right == none
    right = pt-rot(apex, left, 36deg)
  }
  (0, apex, left, right)
}


// Generate type A-prime triangle (isosceles triangle with apex angle 36 deg)
#let p3-ap-triangle(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 72deg, (calc.sqrt(5)+1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -36deg)
  } else {    // right == none
    right = pt-rot(apex, left, 36deg)
  }
  (1, apex, left, right)
}


// Generate type B triangle (isosceles triangle with apex angle 108 deg)
#let p3-b-triangle(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 36deg, (calc.sqrt(5)-1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -108deg)
  } else {    // right == none
    right = pt-rot(apex, left, 108deg)
  }
  (2, apex, left, right)
}


// Generate type B-prime triangle (isosceles triangle with apex angle 108 deg)
#let p3-bp-triangle(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 36deg, (calc.sqrt(5)-1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -108deg)
  } else {    // right == none
    right = pt-rot(apex, left, 108deg)
  }
  (3, apex, left, right)
}


// Decompose type A triangle
#let decompose-a-triangle(v) = {
  (p3-a-triangle(v.at(2), v.at(3), none), p3-bp-triangle(none, v.at(1), v.at(2)))
}


// Decompose type A-prime triangle
#let decompose-ap-triangle(v) = {
  (p3-ap-triangle(v.at(3), none, v.at(2)), p3-b-triangle(none, v.at(3), v.at(1)))
}


// Decompose type B triangle
#let decompose-b-triangle(v) = {
  let t-b = p3-b-triangle(none, v.at(3), v.at(1))
  let t-a = p3-a-triangle(t-b.at(1), v.at(1), none)
  let t-bp = p3-bp-triangle(t-a.at(3), v.at(2), t-a.at(1))
  (t-b, t-a, t-bp)
}


// Decompose type B-prime triangle
#let decompose-bp-triangle(v) = {
  let t-bp = p3-bp-triangle(none, v.at(1), v.at(2))
  let t-ap = p3-ap-triangle(t-bp.at(1), none, v.at(1))
  let t-b = p3-b-triangle(t-ap.at(2), t-ap.at(1), v.at(3))
  (t-bp, t-ap, t-b)
}


// Decompose each triangle in the input vector
#let decompose-triangles(v) = {
  let vo = ()
  for vi in v {
    let tt = vi.at(0)
    if tt == 0 {    // type A
      vo.push(decompose-a-triangle(vi))
    } else if tt == 1 {    // type A-prime
      vo.push(decompose-ap-triangle(vi))
    } else if tt == 2 {    // type B
      vo.push(decompose-b-triangle(vi))
    } else {    // type B-prime
      vo.push(decompose-bp-triangle(vi))
    }
  }
  vo.join()
}


// Get the path of arc for the triangle
#let triangle-arc(pa, pl, pr, len-side, len-base, r, c, lr) = {
  if lr == 0 {    // left corner
    let vx = (pr.at(0) - pl.at(0)) / len-base
    let vy = (pr.at(1) - pl.at(1)) / len-base
    let p0x = pl.at(0) + vx * r
    let p0y = pl.at(1) + vy * r
    let p1x = p0x + (-vy) * c * r
    let p1y = p0y + vx * c * r
    vx = (pa.at(0) - pl.at(0)) / len-side
    vy = (pa.at(1) - pl.at(1)) / len-side
    let p3x = pl.at(0) + vx * r
    let p3y = pl.at(1) + vy * r
    let p2x = p3x + vy * c * r
    let p2y = p3y + (-vx) * c * r
    ((p0x, p0y), (p1x, p1y), (p2x, p2y), (p3x, p3y))
  } else {    // right corner
    let vx = (pl.at(0) - pr.at(0)) / len-base
    let vy = (pl.at(1) - pr.at(1)) / len-base
    let p0x = pr.at(0) + vx * r
    let p0y = pr.at(1) + vy * r
    let p1x = p0x + vy * c * r
    let p1y = p0y + (-vx) * c * r
    vx = (pa.at(0) - pr.at(0)) / len-side
    vy = (pa.at(1) - pr.at(1)) / len-side
    let p3x = pr.at(0) + vx * r
    let p3y = pr.at(1) + vy * r
    let p2x = p3x + (-vy) * c * r
    let p2y = p3y + vx * c * r
    ((p0x, p0y), (p1x, p1y), (p2x, p2y), (p3x, p3y))
  }
}


// Generate each component path of tiling
#let gen-paths(v-ini, n, padding) = {
  // Generates all triangle vertices
  let v = v-ini
  for _ in range(n) {
    v = decompose-triangles(v)
  }


  // Get bounding box for the graph
  let (x-min, x-max, y-min, y-max) = (1e16, -1e16, 1e16, -1e16)
  for vi in v {
    x-min = calc.min(x-min, vi.at(1).at(0), vi.at(2).at(0), vi.at(3).at(0))
    x-max = calc.max(x-max, vi.at(1).at(0), vi.at(2).at(0), vi.at(3).at(0))
    y-min = calc.min(y-min, vi.at(1).at(1), vi.at(2).at(1), vi.at(3).at(1))
    y-max = calc.max(y-max, vi.at(1).at(1), vi.at(2).at(1), vi.at(3).at(1))
  }
  x-min -= padding
  x-max += padding
  y-min -= padding
  y-max += padding
  let width = (x-max - x-min) * 1pt
  let height = (y-max - y-min) * 1pt


  // Generate drawing commands
  let cmd-triangle-a = ()
  let cmd-triangle-b = ()
  let cmd-edge = ()
  for vi in v {
    let pl = ((vi.at(2).at(0) - x-min) * 1pt, (y-max - vi.at(2).at(1)) * 1pt)
    let pa = ((vi.at(1).at(0) - x-min) * 1pt, (y-max - vi.at(1).at(1)) * 1pt)
    let pr = ((vi.at(3).at(0) - x-min) * 1pt, (y-max - vi.at(3).at(1)) * 1pt)

    if vi.at(0) == 0 or vi.at(0) == 1 {    // type A or A-prime
      cmd-triangle-a.push(std.curve.move(pl))
      cmd-triangle-a.push(std.curve.line(pa))
      cmd-triangle-a.push(std.curve.line(pr))
      cmd-triangle-a.push(std.curve.close(mode: "straight"))
    } else {    // type B or B-prime
      cmd-triangle-b.push(std.curve.move(pl))
      cmd-triangle-b.push(std.curve.line(pa))
      cmd-triangle-b.push(std.curve.line(pr))
      cmd-triangle-b.push(std.curve.close(mode: "straight"))
    }
    cmd-edge.push(std.curve.move(pl))
    cmd-edge.push(std.curve.line(pa))
    cmd-edge.push(std.curve.line(pr))
  }

  let cmd-arc1 = ()
  let cmd-arc2 = ()
  let v0 = v.at(0)
  let len-side = calc.norm(v0.at(1).at(0) - v0.at(2).at(0), v0.at(1).at(1) - v0.at(2).at(1))
  let len-base-a = len-side * (calc.sqrt(5) - 1) / 2
  let len-base-b = len-side * (calc.sqrt(5) + 1) / 2
  let c-a = 4/3 * calc.tan(calc.pi/10)
  let c-b = 4/3 * calc.tan(calc.pi/20)
  for vi in v {
    let ((p0x, p0y), (p1x, p1y), (p2x, p2y), (p3x, p3y)) = if vi.at(0) == 0 {    // type A
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-a, len-side/4, c-a, 0)
    } else if vi.at(0) == 1 {    // type A-prime
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-a, len-side/4, c-a, 1)
    } else if vi.at(0) == 2 {    // type B
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-b, len-side/4, c-b, 1)
    } else {    // type B-prime
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-b, len-side/4, c-b, 0)
    }
    cmd-arc1.push(std.curve.move(((p0x - x-min) * 1pt, (y-max - p0y) * 1pt)))
    cmd-arc1.push(std.curve.cubic(
      ((p1x - x-min) * 1pt, (y-max - p1y) * 1pt),
      ((p2x - x-min) * 1pt, (y-max - p2y) * 1pt),
      ((p3x - x-min) * 1pt, (y-max - p3y) * 1pt)
    ))

    let ((p0x, p0y), (p1x, p1y), (p2x, p2y), (p3x, p3y)) = if vi.at(0) == 0 {    // type A
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-a, len-side/4, c-a, 1)
    } else if vi.at(0) == 1 {    // type A-prime
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-a, len-side/4, c-a, 0)
    } else if vi.at(0) == 2 {    // type B
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-b, len-side*3/4, c-b, 0)
    } else {    // type B-prime
      triangle-arc(vi.at(1), vi.at(2), vi.at(3), len-side, len-base-b, len-side*3/4, c-b, 1)
    }
    cmd-arc2.push(std.curve.move(((p0x - x-min) * 1pt, (y-max - p0y) * 1pt)))
    cmd-arc2.push(std.curve.cubic(
      ((p1x - x-min) * 1pt, (y-max - p1y) * 1pt),
      ((p2x - x-min) * 1pt, (y-max - p2y) * 1pt),
      ((p3x - x-min) * 1pt, (y-max - p3y) * 1pt)
    ))
  }

  ((width, height), cmd-triangle-a, cmd-triangle-b, cmd-edge, cmd-arc1, cmd-arc2)
}


// Generate Penrose rhombus tiling (P3)
//
// iterations: [0, 10]
//
// Arguments:
//     v-ini: initial shape, optional
//     n: the number of iterations, optional
//     fill-a: type A triangle color, optional
//     fill-b: type B triangle color, optional
//     stroke-edge: edge color, optional
//     stroke-arc1: decorated arcs set 1 color, optional
//     stroke-arc2: decorated arcs set 2 color, optional
//     padding: spacing around the content (in pt), optional
//
// Returns:
//     content: generated vector graphic
#let penrose-3(
  v-ini: (p3-b-triangle(none, (-200, 0), (200, 0)), p3-bp-triangle(none, (200, 0), (-200, 0))),
  n: 3,
  fill-a: blue,
  fill-b: orange,
  stroke-edge: stroke(paint: gray, thickness: 1pt, cap: "round", join: "round"),
  stroke-arc1: stroke(paint: yellow, thickness: 1pt, cap: "round", join: "round"),
  stroke-arc2: stroke(paint: yellow, thickness: 1pt, cap: "round", join: "round"),
  padding: 0
) = {
  assert(type(v-ini) == array and v-ini.len() > 0, message: "`v-ini` should be arrry type and is non-empty")
  assert(type(n) == int and n >= 0 and n <= 10, message: "`n` should be in range [0, 10]")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  let (sz, cmd-triangle-a, cmd-triangle-b, cmd-edge, cmd-arc1, cmd-arc2) = gen-paths(v-ini, n, padding)
  box(width: sz.at(0), height: sz.at(1), {
    place(std.curve(fill: fill-a, stroke: none, ..cmd-triangle-a))
    place(std.curve(fill: fill-b, stroke: none, ..cmd-triangle-b))
    place(std.curve(stroke: stroke-edge, ..cmd-edge))
    place(std.curve(stroke: stroke-arc1, ..cmd-arc1))
    place(std.curve(stroke: stroke-arc2, ..cmd-arc2))
  })
}
