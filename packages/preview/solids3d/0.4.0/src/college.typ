// college.typ — independent collège-oriented 3D helpers.
//
// The constructions use the same vector, path and surface primitives as the
// rest of the package. They are inspired by common school geometry figures,
// not copied from any external implementation.

#import "vec.typ": *
#import "path3.typ": *
#import "surface.typ": *
#import "solids.typ": *
#import "education.typ": *
#import "pens.typ": *
#import "picture.typ": draw

// Draw a geometric diagonal. Unlike callout3, this helper really draws the
// segment; a separate callout can be added when a label is wanted.
#let diagonal3(a, b, pen: dashed) = draw(line3(a, b), pen)

// Draw a construction/height segment and optionally mark its foot.
#let height3(top, foot, pen: dashed, mark: false, mark-size: 0.12) = {
  let out = (draw(line3(top, foot), pen),)
  if mark {
    let x = vadd(foot, vmul(mark-size, vunit(vsub(top, foot))))
    out += draw(line3(foot, x), pen)
  }
  out
}

// A regular tetrahedron centered at `center`. `radius` is its circumradius.
#let regular-tetrahedron(center: O, radius: 1) = {
  let r = radius / calc.sqrt(3)
  let a = vadd(center, vmul(r, (1, 1, 1)))
  let b = vadd(center, vmul(r, (1, -1, -1)))
  let c = vadd(center, vmul(r, (-1, 1, -1)))
  let d = vadd(center, vmul(r, (-1, -1, 1)))
  let faces = (
    line3(a, b, c, cyclic: true),
    line3(a, d, b, cyclic: true),
    line3(a, c, d, cyclic: true),
    line3(b, d, c, cyclic: true),
  )
  surface(faces)
}

// A regular octahedron centered at `center`. `radius` is the distance from
// the centre to each vertex.
#let regular-octahedron(center: O, radius: 1) = {
  let p = vadd(center, vmul(radius, X))
  let m = vadd(center, vmul(-radius, X))
  let q = vadd(center, vmul(radius, Y))
  let n = vadd(center, vmul(-radius, Y))
  let u = vadd(center, vmul(radius, Z))
  let d = vadd(center, vmul(-radius, Z))
  let faces = (
    line3(u, p, q, cyclic: true), line3(u, q, m, cyclic: true),
    line3(u, m, n, cyclic: true), line3(u, n, p, cyclic: true),
    line3(d, q, p, cyclic: true), line3(d, m, q, cyclic: true),
    line3(d, n, m, cyclic: true), line3(d, p, n, cyclic: true),
  )
  surface(faces)
}

// A frustum of revolution with two circular bases. The side profile is
// independent of the educational annotations and can be drawn as a skeleton.
#let frustum3(center: O, bottom-radius: 1, top-radius: 0.6, height: 1.5, n: 24) = {
  let side = revolution(
    line3(
      vadd(center, (bottom-radius, 0, 0)),
      vadd(center, (top-radius, 0, height)),
    ),
    Z,
  )
  let bottom = apply(shift(center), Circle3(O, bottom-radius, normal: Z, n: n))
  let top = apply(shift(vadd(center, (0, 0, height))), Circle3(O, top-radius, normal: Z, n: n))
  surface(side, surface(bottom), surface(top))
}

// Build a labelled vertex set for a cuboid. The result is a dictionary with
// the conventional A--H names and the lower/upper boxes.
#let cuboid-vertices(origin: O, length: 3, width: 2, height: 1.5) = {
  let (x, y, z) = origin
  let A = (x, y, z)
  let B = (x + length, y, z)
  let C = (x + length, y + width, z)
  let D = (x, y + width, z)
  let E = (x, y, z + height)
  let F = (x + length, y, z + height)
  let G = (x + length, y + width, z + height)
  let H = (x, y + width, z + height)
  (A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H)
}

// Draw all twelve cuboid edges, optionally including the four hidden edges.
#let cuboid-edges(v, visible: black, hidden: dashed) = {
  let front = (
    draw(line3(v.A, v.B), visible), draw(line3(v.B, v.C), visible),
    draw(line3(v.C, v.D), visible), draw(line3(v.D, v.A), visible),
    draw(line3(v.E, v.F), visible), draw(line3(v.F, v.G), visible),
    draw(line3(v.G, v.H), visible), draw(line3(v.H, v.E), visible),
    draw(line3(v.B, v.F), visible), draw(line3(v.C, v.G), visible),
  )
  front + (
    draw(line3(v.A, v.E), hidden), draw(line3(v.D, v.H), hidden),
  )
}

// A standard right triangular prism with a right triangle in the xy-plane.
#let right-prism3(origin: O, base: 2, width: 1.2, height: 2) = {
  let a = origin
  let b = vadd(origin, (base, 0, 0))
  let c = vadd(origin, (0, width, 0))
  let top = vmul(height, Z)
  let faces = (
    line3(a, b, c, cyclic: true),
    line3(vadd(a, top), vadd(c, top), vadd(b, top), cyclic: true),
    line3(a, vadd(a, top), vadd(b, top), b, cyclic: true),
    line3(b, vadd(b, top), vadd(c, top), c, cyclic: true),
    line3(c, vadd(c, top), vadd(a, top), a, cyclic: true),
  )
  surface(faces)
}
