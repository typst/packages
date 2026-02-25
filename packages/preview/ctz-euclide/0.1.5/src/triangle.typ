// ctz-euclide/src/triangle.typ
// Triangle center calculations

#import "util.typ"
#import "intersection.typ": line-line-raw

/// Calculate the centroid (center of gravity) of triangle ABC
#let centroid-raw(a, b, c) = {
  (
    (a.at(0) + b.at(0) + c.at(0)) / 3,
    (a.at(1) + b.at(1) + c.at(1)) / 3,
    a.at(2, default: 0),
  )
}

/// Calculate the circumcenter of triangle ABC
#let circumcenter-raw(a, b, c) = {
  util.assert-not-collinear(a, b, c)
  let (pb1-p1, pb1-p2, _) = util.perpendicular-bisector(a, b)
  let (pb2-p1, pb2-p2, _) = util.perpendicular-bisector(a, c)

  let center = line-line-raw(pb1-p1, pb1-p2, pb2-p1, pb2-p2, ray: true)
  if center == none {
    return util.midpoint(a, b)
  }
  center
}

/// Calculate the incenter of triangle ABC
#let incenter-raw(a, b, c) = {
  util.assert-not-collinear(a, b, c)
  let la = util.dist(b, c)
  let lb = util.dist(a, c)
  let lc = util.dist(a, b)
  let total = la + lb + lc

  if util.approx-zero(total) {
    return a
  }

  (
    (la * a.at(0) + lb * b.at(0) + lc * c.at(0)) / total,
    (la * a.at(1) + lb * b.at(1) + lc * c.at(1)) / total,
    a.at(2, default: 0),
  )
}

/// Calculate the orthocenter of triangle ABC
#let orthocenter-raw(a, b, c) = {
  let foot-a = util.project-point-on-line(a, b, c)
  let foot-b = util.project-point-on-line(b, a, c)

  let center = line-line-raw(a, foot-a, b, foot-b, ray: true)
  if center == none {
    // Right angle case - check which vertex
    let ab = (b.at(0) - a.at(0), b.at(1) - a.at(1))
    let ac = (c.at(0) - a.at(0), c.at(1) - a.at(1))
    if util.approx-zero(ab.at(0) * ac.at(0) + ab.at(1) * ac.at(1)) { return a }

    let ba = (a.at(0) - b.at(0), a.at(1) - b.at(1))
    let bc = (c.at(0) - b.at(0), c.at(1) - b.at(1))
    if util.approx-zero(ba.at(0) * bc.at(0) + ba.at(1) * bc.at(1)) { return b }

    return c
  }
  center
}

/// Calculate the inradius of triangle ABC
#let inradius-raw(a, b, c) = {
  let abx = b.at(0) - a.at(0)
  let aby = b.at(1) - a.at(1)
  let acx = c.at(0) - a.at(0)
  let acy = c.at(1) - a.at(1)
  let area = calc.abs(abx * acy - aby * acx) / 2

  let s = (util.dist(a, b) + util.dist(b, c) + util.dist(a, c)) / 2
  if util.approx-zero(s) { return 0 }
  area / s
}

/// Calculate the circumradius of triangle ABC
#let circumradius-raw(a, b, c) = {
  let la = util.dist(b, c)
  let lb = util.dist(a, c)
  let lc = util.dist(a, b)

  let abx = b.at(0) - a.at(0)
  let aby = b.at(1) - a.at(1)
  let acx = c.at(0) - a.at(0)
  let acy = c.at(1) - a.at(1)
  let area = calc.abs(abx * acy - aby * acx) / 2

  if util.approx-zero(area) { return 0 }
  (la * lb * lc) / (4 * area)
}

// =============================================================================
// ADDITIONAL TRIANGLE CENTERS
// =============================================================================

/// Calculate the nine-point (Euler) circle center
#let euler-center-raw(a, b, c) = {
  let O = circumcenter-raw(a, b, c)
  let H = orthocenter-raw(a, b, c)
  util.midpoint(O, H)
}

/// Calculate the nine-point circle radius (half circumradius)
#let euler-radius-raw(a, b, c) = {
  circumradius-raw(a, b, c) / 2
}

/// Calculate the Lemoine point (symmedian point)
#let lemoine-raw(a, b, c) = {
  let la-sq = util.dist-sq(b, c)
  let lb-sq = util.dist-sq(a, c)
  let lc-sq = util.dist-sq(a, b)
  let total = la-sq + lb-sq + lc-sq

  if util.approx-zero(total) { return a }

  (
    (la-sq * a.at(0) + lb-sq * b.at(0) + lc-sq * c.at(0)) / total,
    (la-sq * a.at(1) + lb-sq * b.at(1) + lc-sq * c.at(1)) / total,
    a.at(2, default: 0),
  )
}

/// Calculate the Nagel point
#let nagel-raw(a, b, c) = {
  let la = util.dist(b, c)
  let lb = util.dist(a, c)
  let lc = util.dist(a, b)
  let s = (la + lb + lc) / 2

  let wa = s - la
  let wb = s - lb
  let wc = s - lc
  let total = wa + wb + wc

  if util.approx-zero(total) { return centroid-raw(a, b, c) }

  (
    (wa * a.at(0) + wb * b.at(0) + wc * c.at(0)) / total,
    (wa * a.at(1) + wb * b.at(1) + wc * c.at(1)) / total,
    a.at(2, default: 0),
  )
}

/// Calculate the Gergonne point
#let gergonne-raw(a, b, c) = {
  let la = util.dist(b, c)
  let lb = util.dist(a, c)
  let lc = util.dist(a, b)
  let s = (la + lb + lc) / 2

  let sa = s - la
  let sb = s - lb
  let sc = s - lc

  if util.approx-zero(sa) or util.approx-zero(sb) or util.approx-zero(sc) {
    return centroid-raw(a, b, c)
  }

  let wa = sb * sc
  let wb = sa * sc
  let wc = sa * sb
  let total = wa + wb + wc

  if util.approx-zero(total) { return centroid-raw(a, b, c) }

  (
    (wa * a.at(0) + wb * b.at(0) + wc * c.at(0)) / total,
    (wa * a.at(1) + wb * b.at(1) + wc * c.at(1)) / total,
    a.at(2, default: 0),
  )
}

/// Calculate the Spieker center (incenter of medial triangle)
#let spieker-raw(a, b, c) = {
  let ma = util.midpoint(b, c)
  let mb = util.midpoint(a, c)
  let mc = util.midpoint(a, b)
  incenter-raw(ma, mb, mc)
}

/// Calculate the Feuerbach point (tangent point of nine-point and incircle)
#let feuerbach-raw(a, b, c) = {
  let I = incenter-raw(a, b, c)
  let N = euler-center-raw(a, b, c)
  let r = inradius-raw(a, b, c)
  let R9 = euler-radius-raw(a, b, c)

  let d = util.dist(I, N)
  if util.approx-zero(d) { return I }

  let dx = (I.at(0) - N.at(0)) / d
  let dy = (I.at(1) - N.at(1)) / d
  let dist-from-N = R9 - r

  (N.at(0) + dist-from-N * dx, N.at(1) + dist-from-N * dy, a.at(2, default: 0))
}

/// Calculate the Mittenpunkt
#let mittenpunkt-raw(a, b, c) = {
  let la = util.dist(b, c)
  let lb = util.dist(a, c)
  let lc = util.dist(a, b)

  let wa = la * (lb + lc - la)
  let wb = lb * (lc + la - lb)
  let wc = lc * (la + lb - lc)
  let total = wa + wb + wc

  if util.approx-zero(total) { return centroid-raw(a, b, c) }

  (
    (wa * a.at(0) + wb * b.at(0) + wc * c.at(0)) / total,
    (wa * a.at(1) + wb * b.at(1) + wc * c.at(1)) / total,
    a.at(2, default: 0),
  )
}

/// Calculate an excenter of triangle ABC
/// vertex: "a", "b", or "c" to specify which excircle
#let excenter-raw(a, b, c, vertex: "a") = {
  let la = util.dist(b, c)
  let lb = util.dist(a, c)
  let lc = util.dist(a, b)

  if vertex == "a" {
    let total = -la + lb + lc
    if util.approx-zero(total) { return a }
    ((-la * a.at(0) + lb * b.at(0) + lc * c.at(0)) / total,
     (-la * a.at(1) + lb * b.at(1) + lc * c.at(1)) / total,
     a.at(2, default: 0))
  } else if vertex == "b" {
    let total = la - lb + lc
    if util.approx-zero(total) { return b }
    ((la * a.at(0) - lb * b.at(0) + lc * c.at(0)) / total,
     (la * a.at(1) - lb * b.at(1) + lc * c.at(1)) / total,
     a.at(2, default: 0))
  } else {
    let total = la + lb - lc
    if util.approx-zero(total) { return c }
    ((la * a.at(0) + lb * b.at(0) - lc * c.at(0)) / total,
     (la * a.at(1) + lb * b.at(1) - lc * c.at(1)) / total,
     a.at(2, default: 0))
  }
}

/// Calculate the exradius opposite to vertex
#let exradius-raw(a, b, c, vertex: "a") = {
  let la = util.dist(b, c)
  let lb = util.dist(a, c)
  let lc = util.dist(a, b)
  let s = (la + lb + lc) / 2

  let abx = b.at(0) - a.at(0)
  let aby = b.at(1) - a.at(1)
  let acx = c.at(0) - a.at(0)
  let acy = c.at(1) - a.at(1)
  let area = calc.abs(abx * acy - aby * acx) / 2

  if vertex == "a" {
    if util.approx-zero(s - la) { return 0 }
    area / (s - la)
  } else if vertex == "b" {
    if util.approx-zero(s - lb) { return 0 }
    area / (s - lb)
  } else {
    if util.approx-zero(s - lc) { return 0 }
    area / (s - lc)
  }
}

// =============================================================================
// SPECIAL TRIANGLES
// =============================================================================

/// Calculate the medial triangle vertices
#let medial-triangle-raw(a, b, c) = {
  (util.midpoint(b, c), util.midpoint(a, c), util.midpoint(a, b))
}

/// Calculate the orthic triangle vertices (feet of altitudes)
#let orthic-triangle-raw(a, b, c) = {
  (util.project-point-on-line(a, b, c),
   util.project-point-on-line(b, a, c),
   util.project-point-on-line(c, a, b))
}

/// Calculate the contact triangle (intouch triangle) vertices
#let intouch-triangle-raw(a, b, c) = {
  let I = incenter-raw(a, b, c)
  (util.project-point-on-line(I, b, c),
   util.project-point-on-line(I, a, c),
   util.project-point-on-line(I, a, b))
}

/// Calculate the excentral triangle vertices
#let excentral-triangle-raw(a, b, c) = {
  (excenter-raw(a, b, c, vertex: "a"),
   excenter-raw(a, b, c, vertex: "b"),
   excenter-raw(a, b, c, vertex: "c"))
}

/// Calculate the tangential triangle vertices
#let tangential-triangle-raw(a, b, c) = {
  let O = circumcenter-raw(a, b, c)

  let ob-x = b.at(0) - O.at(0)
  let ob-y = b.at(1) - O.at(1)
  let tan-b1 = (b.at(0) - ob-y, b.at(1) + ob-x)

  let oc-x = c.at(0) - O.at(0)
  let oc-y = c.at(1) - O.at(1)
  let tan-c1 = (c.at(0) - oc-y, c.at(1) + oc-x)

  let oa-x = a.at(0) - O.at(0)
  let oa-y = a.at(1) - O.at(1)
  let tan-a1 = (a.at(0) - oa-y, a.at(1) + oa-x)

  let Ta = line-line-raw(b, tan-b1, c, tan-c1, ray: true)
  let Tb = line-line-raw(a, tan-a1, c, tan-c1, ray: true)
  let Tc = line-line-raw(a, tan-a1, b, tan-b1, ray: true)

  (if Ta == none { a } else { Ta },
   if Tb == none { b } else { Tb },
   if Tc == none { c } else { Tc })
}
