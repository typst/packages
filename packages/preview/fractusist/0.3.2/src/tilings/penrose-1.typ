//==============================================================================
// Penrose pentagon tiling (P1)
//
// Reference to https://en.wikipedia.org/wiki/Penrose_tiling
//
// Public functions:
//     p1-a-pentagon, p1-b-pentagon, p1-c-pentagon
//     p1-diamond, p1-boat, p1-star,
//     penrose-1
//==============================================================================


#import "util.typ": *


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate type A pentagon (apex angle 108 deg)
#let p1-a-pentagon(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 36deg, (calc.sqrt(5)-1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -108deg)
  } else {    // right == none
    right = pt-rot(apex, left, 108deg)
  }
  (0, apex, left, right)
}


// Generate type B pentagon (apex angle 108 deg)
#let p1-b-pentagon(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 36deg, (calc.sqrt(5)-1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -108deg)
  } else {    // right == none
    right = pt-rot(apex, left, 108deg)
  }
  (1, apex, left, right)
}


// Generate type C pentagon (apex angle 108 deg)
#let p1-c-pentagon(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 36deg, (calc.sqrt(5)-1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -108deg)
  } else {    // right == none
    right = pt-rot(apex, left, 108deg)
  }
  (2, apex, left, right)
}


// Generate diamond (a thin rhombus) (apex angle 36 deg)
#let p1-diamond(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 72deg, (calc.sqrt(5)+1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -36deg)
  } else {    // right == none
    right = pt-rot(apex, left, 36deg)
  }
  (3, apex, left, right)
}


// Generate boat (roughly 3/5 of a star) (apex angle 36 deg)
#let p1-boat(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 72deg, (calc.sqrt(5)+1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -36deg)
  } else {    // right == none
    right = pt-rot(apex, left, 36deg)
  }
  (4, apex, left, right)
}


// Generate star (pentagram) (apex angle 36 deg)
#let p1-star(apex, left, right) = {
  if apex == none {
    apex = pt-rot-sc(left, right, 72deg, (calc.sqrt(5)+1)/2)
  } else if left == none {
    left = pt-rot(apex, right, -36deg)
  } else {    // right == none
    right = pt-rot(apex, left, 36deg)
  }
  (5, apex, left, right)
}


// Decompose type A pentagon
#let decompose-a-pentagon(v) = {
  let (p0x, p0y) = v.at(1)
  let (p1x, p1y) = v.at(2)
  let (p2x, p2y) = v.at(3)
  let (p3x, p3y) = pt-rot((p1x, p1y), (p0x, p0y), -108deg)
  let (p4x, p4y) = pt-rot((p2x, p2y), (p0x, p0y), 108deg)

  let c = (3 - calc.sqrt(5)) / 2
  let (p01x, p01y) = pt-lerp((p0x, p0y), (p1x, p1y), c)
  let t-bp0 = p1-b-pentagon((p0x, p0y), (p01x, p01y), none)
  let (p13x, p13y) = pt-lerp((p1x, p1y), (p3x, p3y), c)
  let t-bp1 = p1-b-pentagon((p1x, p1y), (p13x, p13y), none)
  let (p34x, p34y) = pt-lerp((p3x, p3y), (p4x, p4y), c)
  let t-bp3 = p1-b-pentagon((p3x, p3y), (p34x, p34y), none)
  let (p42x, p42y) = pt-lerp((p4x, p4y), (p2x, p2y), c)
  let t-bp4 = p1-b-pentagon((p4x, p4y), (p42x, p42y), none)
  let (p20x, p20y) = pt-lerp((p2x, p2y), (p0x, p0y), c)
  let t-bp2 = p1-b-pentagon((p2x, p2y), (p20x, p20y), none)

  let (q01x, q01y) = pt-rot((p01x, p01y), (p0x, p0y), -108deg)
  let t-d0 = p1-diamond((q01x, q01y), (p01x, p01y), none)
  let (q13x, q13y) = pt-rot((p13x, p13y), (p1x, p1y), -108deg)
  let t-d1 = p1-diamond((q13x, q13y), (p13x, p13y), none)
  let (q34x, q34y) = pt-rot((p34x, p34y), (p3x, p3y), -108deg)
  let t-d3 = p1-diamond((q34x, q34y), (p34x, p34y), none)
  let (q42x, q42y) = pt-rot((p42x, p42y), (p4x, p4y), -108deg)
  let t-d4 = p1-diamond((q42x, q42y), (p42x, p42y), none)
  let (q20x, q20y) = pt-rot((p20x, p20y), (p2x, p2y), -108deg)
  let t-d2 = p1-diamond((q20x, q20y), (p20x, p20y), none)

  let t-ap = p1-a-pentagon((q34x, q34y), (q42x, q42y), none)

  (t-bp0, t-bp1, t-bp3, t-bp4, t-bp2, t-d0, t-d1, t-d3, t-d4, t-d2, t-ap)
}


// Decompose type B pentagon
#let decompose-b-pentagon(v) = {
  let (p0x, p0y) = v.at(1)
  let (p1x, p1y) = v.at(2)
  let (p2x, p2y) = v.at(3)
  let (p3x, p3y) = pt-rot((p1x, p1y), (p0x, p0y), -108deg)
  let (p4x, p4y) = pt-rot((p2x, p2y), (p0x, p0y), 108deg)

  let c = (3 - calc.sqrt(5)) / 2
  let (p01x, p01y) = pt-lerp((p0x, p0y), (p1x, p1y), c)
  let t-bp0 = p1-b-pentagon((p0x, p0y), (p01x, p01y), none)
  let (p13x, p13y) = pt-lerp((p1x, p1y), (p3x, p3y), c)
  let t-bp1 = p1-b-pentagon((p1x, p1y), (p13x, p13y), none)
  let (p34x, p34y) = pt-lerp((p3x, p3y), (p4x, p4y), c)
  let (p31x, p31y) = pt-lerp((p3x, p3y), (p1x, p1y), c)
  let t-cp3 = p1-c-pentagon((p31x, p31y), (p3x, p3y), none)
  let (p42x, p42y) = pt-lerp((p4x, p4y), (p2x, p2y), c)
  let t-cp4 = p1-c-pentagon((p42x, p42y), none, (p4x, p4y))
  let (p20x, p20y) = pt-lerp((p2x, p2y), (p0x, p0y), c)
  let t-bp2 = p1-b-pentagon((p2x, p2y), (p20x, p20y), none)

  let (q01x, q01y) = pt-rot((p01x, p01y), (p0x, p0y), -108deg)
  let t-d0 = p1-diamond((q01x, q01y), (p01x, p01y), none)
  let (q20x, q20y) = pt-rot((p20x, p20y), (p2x, p2y), -108deg)
  let t-d2 = p1-diamond((q20x, q20y), (p20x, p20y), none)

  let (q34x, q34y) = pt-rot((p34x, p34y), (p3x, p3y), -108deg)
  let (q42x, q42y) = pt-rot((p42x, p42y), (p4x, p4y), -108deg)
  let t-ap = p1-a-pentagon((q34x, q34y), (q42x, q42y), none)

  (t-bp0, t-bp1, t-cp3, t-cp4, t-bp2, t-d0, t-d2, t-ap)
}


// Decompose type C pentagon
#let decompose-c-pentagon(v) = {
  let (p0x, p0y) = v.at(1)
  let (p1x, p1y) = v.at(2)
  let (p2x, p2y) = v.at(3)
  let (p3x, p3y) = pt-rot((p1x, p1y), (p0x, p0y), -108deg)
  let (p4x, p4y) = pt-rot((p2x, p2y), (p0x, p0y), 108deg)

  let c = (3 - calc.sqrt(5)) / 2
  let (p01x, p01y) = pt-lerp((p0x, p0y), (p1x, p1y), c)
  let t-bp = p1-b-pentagon((p0x, p0y), (p01x, p01y), none)
  let (p10x, p10y) = pt-lerp((p1x, p1y), (p0x, p0y), c)
  let t-cp1 = p1-c-pentagon((p10x, p10y), (p1x, p1y), none)
  let (p34x, p34y) = pt-lerp((p3x, p3y), (p4x, p4y), c)
  let t-cp3 = p1-c-pentagon((p34x, p34y), none, (p3x, p3y))
  let (p42x, p42y) = pt-lerp((p4x, p4y), (p2x, p2y), c)
  let (p43x, p43y) = pt-lerp((p4x, p4y), (p3x, p3y), c)
  let t-cp4 = p1-c-pentagon((p43x, p43y), (p4x, p4y), none)
  let (p20x, p20y) = pt-lerp((p2x, p2y), (p0x, p0y), c)
  let t-cp2 = p1-c-pentagon((p20x, p20y), none, (p2x, p2y))

  let (q34x, q34y) = pt-rot((p34x, p34y), (p3x, p3y), -108deg)
  let (q42x, q42y) = pt-rot((p42x, p42y), (p4x, p4y), -108deg)
  let t-ap = p1-a-pentagon((q34x, q34y), (q42x, q42y), none)

  (t-bp, t-cp1, t-cp3, t-cp4, t-cp2, t-ap)
}


// Decompose diamond
#let decompose-diamond(v) = {
  let (p0x, p0y) = v.at(1)
  let (p1x, p1y) = v.at(2)
  let (p2x, p2y) = v.at(3)
  let (p3x, p3y) = (p1x + p2x - p0x, p1y + p2y - p0y)

  let t-cp = p1-c-pentagon(none, (p2x, p2y), (p1x, p1y))

  let c = (3 - calc.sqrt(5)) / 2
  let (p01x, p01y) = pt-lerp((p0x, p0y), (p1x, p1y), c)
  let t-b = p1-boat((p0x, p0y), (p01x, p01y), none)
  let (p32x, p32y) = pt-lerp((p3x, p3y), (p2x, p2y), c)
  let t-s = p1-star((p3x, p3y), (p32x, p32y), none)

  (t-cp, t-b, t-s)
}


// Decompose boat
#let decompose-boat(v) = {
  let (p0x, p0y) = v.at(1)
  let (p1x, p1y) = v.at(2)
  let (p2x, p2y) = v.at(3)
  let (p3x, p3y) = pt-rot((p1x, p1y), (p0x, p0y), 108deg)
  let (p4x, p4y) = pt-rot((p2x, p2y), (p0x, p0y), -108deg)
  let (p5x, p5y) = pt-rot((p3x, p3y), (p1x, p1y), -36deg)
  let (p6x, p6y) = pt-rot((p4x, p4y), (p2x, p2y), 36deg)

  let c = (3 - calc.sqrt(5)) / 2
  let (p01x, p01y) = pt-lerp((p0x, p0y), (p1x, p1y), c)
  let t-b0 = p1-boat((p0x, p0y), (p01x, p01y), none)
  let (p35x, p35y) = pt-lerp((p3x, p3y), (p5x, p5y), c)
  let t-b1 = p1-boat((p3x, p3y), (p35x, p35y), none)
  let (p42x, p42y) = pt-lerp((p4x, p4y), (p2x, p2y), c)
  let t-b2 = p1-boat((p4x, p4y), (p42x, p42y), none)
  let (p56x, p56y) = pt-lerp((p5x, p5y), (p6x, p6y), c)
  let (p65x, p65y) = pt-lerp((p6x, p6y), (p5x, p5y), c)
  let t-s = p1-star(none, (p65x, p65y), (p56x, p56y))

  let t-cp0 = p1-c-pentagon(none, (p2x, p2y), (p1x, p1y))
  let t-cp1 = p1-c-pentagon(none, (p1x, p1y), (p5x, p5y))
  let t-cp2 = p1-c-pentagon(none, (p6x, p6y), (p2x, p2y))

  (t-b0, t-b1, t-b2, t-s, t-cp0, t-cp1, t-cp2)
}


// Decompose star
#let decompose-star(v) = {
  let (p0x, p0y) = v.at(1)
  let (p1x, p1y) = v.at(2)
  let (p2x, p2y) = v.at(3)
  let (p3x, p3y) = pt-rot((p1x, p1y), (p0x, p0y), 108deg)
  let (p4x, p4y) = pt-rot((p2x, p2y), (p0x, p0y), -108deg)
  let (p5x, p5y) = pt-rot((p3x, p3y), (p1x, p1y), -36deg)
  let (p6x, p6y) = pt-rot((p4x, p4y), (p2x, p2y), 36deg)
  let (p7x, p7y) = pt-rot((p5x, p5y), (p3x, p3y), 108deg)
  let (p8x, p8y) = pt-rot((p6x, p6y), (p4x, p4y), -108deg)
  let (p9x, p9y) = pt-rot((p7x, p7y), (p5x, p5y), -36deg)

  let t-cp0 = p1-c-pentagon(none, (p2x, p2y), (p1x, p1y))

  let c = (3 - calc.sqrt(5)) / 2
  let (p01x, p01y) = pt-lerp((p0x, p0y), (p1x, p1y), c)
  let t-b0 = p1-boat((p0x, p0y), (p01x, p01y), none)
  let (p35x, p35y) = pt-lerp((p3x, p3y), (p5x, p5y), c)
  let t-b1 = p1-boat((p3x, p3y), (p35x, p35y), none)
  let (p42x, p42y) = pt-lerp((p4x, p4y), (p2x, p2y), c)
  let t-b2 = p1-boat((p4x, p4y), (p42x, p42y), none)
  let (p79x, p79y) = pt-lerp((p7x, p7y), (p9x, p9y), c)
  let t-b3 = p1-boat((p7x, p7y), (p79x, p79y), none)
  let (p86x, p86y) = pt-lerp((p8x, p8y), (p6x, p6y), c)
  let t-b4 = p1-boat((p8x, p8y), (p86x, p86y), none)
  let (p56x, p56y) = pt-lerp((p5x, p5y), (p6x, p6y), c)
  let (p65x, p65y) = pt-lerp((p6x, p6y), (p5x, p5y), c)
  let t-s = p1-star(none, (p65x, p65y), (p56x, p56y))

  let t-cp0 = p1-c-pentagon(none, (p2x, p2y), (p1x, p1y))
  let t-cp1 = p1-c-pentagon(none, (p1x, p1y), (p5x, p5y))
  let t-cp2 = p1-c-pentagon(none, (p6x, p6y), (p2x, p2y))
  let t-cp3 = p1-c-pentagon(none, (p5x, p5y), (p9x, p9y))
  let t-cp4 = p1-c-pentagon(none, (p9x, p9y), (p6x, p6y))

  (t-b0, t-b1, t-b2, t-b3, t-b4, t-s, t-cp0, t-cp1, t-cp2, t-cp3, t-cp4)
}


// Decompose each shape in the input vector
#let decompose-shapes(v) = {
  let vo = ()
  for vi in v {
    let tt = vi.at(0)
    if tt == 0 {    // type A pentagon
      vo.push(decompose-a-pentagon(vi))
    } else if tt == 1 {    // type B pentagon
      vo.push(decompose-b-pentagon(vi))
    } else if tt == 2 {    // type C pentagon
      vo.push(decompose-c-pentagon(vi))
    } else if tt == 3 {    // diamond
      vo.push(decompose-diamond(vi))
    } else if tt == 4 {    // boad
      vo.push(decompose-boat(vi))
    } else {    // star
      vo.push(decompose-star(vi))
    }
  }
  vo.join()
}


// Get all vertices of pentagon (anticlockwise)
#let vert-pentagon(p0, p1, p2) = {
  let (p0x, p0y) = p0
  let (p1x, p1y) = p1
  let (p2x, p2y) = p2
  let p3 = pt-rot((p1x, p1y), (p0x, p0y), -108deg)
  let p4 = pt-rot((p2x, p2y), (p0x, p0y), 108deg)
  (p0, p1, p3, p4, p2)
}


// Get all vertices of diamond (anticlockwise)
#let vert-diamond(p0, p1, p2) = {
  let (p0x, p0y) = p0
  let (p1x, p1y) = p1
  let (p2x, p2y) = p2
  let p3 = (p1x + p2x - p0x, p1y + p2y - p0y)
  (p0, p1, p3, p2)
}


// Get all vertices of boat (anticlockwise)
#let vert-boat(p0, p1, p2) = {
  let (p0x, p0y) = p0
  let (p1x, p1y) = p1
  let (p2x, p2y) = p2
  let (p3x, p3y) = pt-rot((p1x, p1y), (p0x, p0y), 108deg)
  let (p4x, p4y) = pt-rot((p2x, p2y), (p0x, p0y), -108deg)
  let (p5x, p5y) = pt-rot((p3x, p3y), (p1x, p1y), -36deg)
  let (p6x, p6y) = pt-rot((p4x, p4y), (p2x, p2y), 36deg)
  (p0, p1, (p3x, p3y), (p5x, p5y), (p6x, p6y), (p4x, p4y), p2)
}


// Get all vertices of star (anticlockwise)
#let vert-star(p0, p1, p2) = {
  let (p0x, p0y) = p0
  let (p1x, p1y) = p1
  let (p2x, p2y) = p2
  let (p3x, p3y) = pt-rot((p1x, p1y), (p0x, p0y), 108deg)
  let (p4x, p4y) = pt-rot((p2x, p2y), (p0x, p0y), -108deg)
  let (p5x, p5y) = pt-rot((p3x, p3y), (p1x, p1y), -36deg)
  let (p6x, p6y) = pt-rot((p4x, p4y), (p2x, p2y), 36deg)
  let (p7x, p7y) = pt-rot((p5x, p5y), (p3x, p3y), 108deg)
  let (p8x, p8y) = pt-rot((p6x, p6y), (p4x, p4y), -108deg)
  let (p9x, p9y) = pt-rot((p7x, p7y), (p5x, p5y), -36deg)
  (p0, p1, (p3x, p3y), (p5x, p5y), (p7x, p7y), (p9x, p9y), (p8x, p8y), (p6x, p6y), (p4x, p4y), p2)
}


// Generate each component path of tiling
#let gen-paths(v-ini, n, padding) = {
  // Generates all shape vertices
  let v = v-ini
  for _ in range(n) {
    v = decompose-shapes(v)
  }


  // Get bounding box for the graph
  let (x-min, x-max, y-min, y-max) = (1e16, -1e16, 1e16, -1e16)
  for vi in v {
    let tt = vi.at(0)
    let vp
    if tt == 0 or tt == 1 or tt == 2 {    // pentagon
      vp = vert-pentagon(vi.at(1), vi.at(2), vi.at(3))
    } else if tt == 3 {    // diamond
      vp = vert-diamond(vi.at(1), vi.at(2), vi.at(3))
    } else if tt == 4 {    // boat
      vp = vert-boat(vi.at(1), vi.at(2), vi.at(3))
    } else {    // star
      vp = vert-star(vi.at(1), vi.at(2), vi.at(3))
    }
    let vx = range(vp.len()).map(it => vp.at(it).at(0))
    let vy = range(vp.len()).map(it => vp.at(it).at(1))
    x-min = calc.min(x-min, ..vx)
    x-max = calc.max(x-max, ..vx)
    y-min = calc.min(y-min, ..vy)
    y-max = calc.max(y-max, ..vy)
  }
  x-min -= padding
  x-max += padding
  y-min -= padding
  y-max += padding
  let width = (x-max - x-min) * 1pt
  let height = (y-max - y-min) * 1pt


  // Generate drawing commands
  let cmd-a-pentagon = ()
  let cmd-b-pentagon = ()
  let cmd-c-pentagon = ()
  let cmd-diamond = ()
  let cmd-boat = ()
  let cmd-star = ()
  let cmd-edge = ()
  for vi in v {
    let tt = vi.at(0)
    let vp
    if tt == 0 or tt == 1 or tt == 2 {    // pentagon
      vp = vert-pentagon(vi.at(1), vi.at(2), vi.at(3))
    } else if tt == 3 {    // diamond
      vp = vert-diamond(vi.at(1), vi.at(2), vi.at(3))
    } else if tt == 4 {    // boat
      vp = vert-boat(vi.at(1), vi.at(2), vi.at(3))
    } else {    // star
      vp = vert-star(vi.at(1), vi.at(2), vi.at(3))
    }
    let pn = range(vp.len()).map(it => ((vp.at(it).at(0) - x-min) * 1pt, (y-max - vp.at(it).at(1)) * 1pt))

    if tt == 0 {    // type A pentagon
      for i in range(vp.len()) {
        cmd-a-pentagon.push(if i == 0 {std.curve.move(pn.at(i))} else {std.curve.line(pn.at(i))})
      }
      cmd-a-pentagon.push(std.curve.close(mode: "straight"))
    } else if tt == 1 {    // type B pentagon
      for i in range(vp.len()) {
        cmd-b-pentagon.push(if i == 0 {std.curve.move(pn.at(i))} else {std.curve.line(pn.at(i))})
      }
      cmd-b-pentagon.push(std.curve.close(mode: "straight"))
    } else if tt == 2 {    // type C pentagon
      for i in range(vp.len()) {
        cmd-c-pentagon.push(if i == 0 {std.curve.move(pn.at(i))} else {std.curve.line(pn.at(i))})
      }
      cmd-c-pentagon.push(std.curve.close(mode: "straight"))
    } else if tt == 3 {    // diamond
      for i in range(vp.len()) {
        cmd-diamond.push(if i == 0 {std.curve.move(pn.at(i))} else {std.curve.line(pn.at(i))})
      }
      cmd-diamond.push(std.curve.close(mode: "straight"))
    } else if tt == 4 {    // boad
      for i in range(vp.len()) {
        cmd-boat.push(if i == 0 {std.curve.move(pn.at(i))} else {std.curve.line(pn.at(i))})
      }
    } else {    // star
      for i in range(vp.len()) {
        cmd-star.push(if i == 0 {std.curve.move(pn.at(i))} else {std.curve.line(pn.at(i))})
      }
      cmd-star.push(std.curve.close(mode: "straight"))
    }

    for i in range(vp.len()) {
      cmd-edge.push(if i == 0 {std.curve.move(pn.at(i))} else {std.curve.line(pn.at(i))})
    }
    cmd-edge.push(std.curve.close(mode: "straight"))
  }

  ((width, height), cmd-a-pentagon, cmd-b-pentagon, cmd-c-pentagon, cmd-diamond, cmd-boat, cmd-star, cmd-edge)
}


// Generate Penrose pentagon tiling (P1)
//
// iterations: [0, 6]
//
// Arguments:
//     v-ini: initial shape, optional
//     n: the number of iterations, optional
//     fill-a-pentagon: type A pentagon color, optional
//     fill-b-pentagon: type B pentagon color, optional
//     fill-c-pentagon: type C pentagon color, optional
//     fill-diamond: diamond color, optional
//     fill-boat: boat color, optional
//     fill-star: star color, optional
//     stroke-edge: edge color, optional
//     padding: spacing around the content (in pt), optional
//
// Returns:
//     content: generated vector graphic
#let penrose-1(
  v-ini: (p1-a-pentagon(none, (-200, 0), (200, 0)),),
  n: 3,
  fill-a-pentagon: red,
  fill-b-pentagon: red.darken(20%),
  fill-c-pentagon: red.darken(40%),
  fill-diamond: blue,
  fill-boat: green,
  fill-star: yellow,
  stroke-edge: stroke(paint: gray, thickness: 1pt, cap: "round", join: "round"),
  padding: 0
) = {
  assert(type(v-ini) == array and v-ini.len() > 0, message: "`v-ini` should be arrry type and is non-empty")
  assert(type(n) == int and n >= 0 and n <= 6, message: "`n` should be in range [0, 6]")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  let (sz, cmd-a-pentagon, cmd-b-pentagon, cmd-c-pentagon, cmd-diamond, cmd-boat, cmd-star, cmd-edge) = gen-paths(v-ini, n, padding)
  box(width: sz.at(0), height: sz.at(1), {
    place(std.curve(fill: fill-a-pentagon, stroke: none, ..cmd-a-pentagon))
    place(std.curve(fill: fill-b-pentagon, stroke: none, ..cmd-b-pentagon))
    place(std.curve(fill: fill-c-pentagon, stroke: none, ..cmd-c-pentagon))
    place(std.curve(fill: fill-diamond, stroke: none, ..cmd-diamond))
    place(std.curve(fill: fill-boat, stroke: none, ..cmd-boat))
    place(std.curve(fill: fill-star, stroke: none, ..cmd-star))
    place(std.curve(stroke: stroke-edge, ..cmd-edge))
  })
}
