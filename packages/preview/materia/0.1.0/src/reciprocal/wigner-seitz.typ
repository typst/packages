// First Brillouin zone = Wigner-Seitz cell of the reciprocal lattice, built at
// runtime by half-space intersection. The shape varies continuously with the
// lattice parameters (docs/design/scenery.md, decision D7), so it cannot be
// precomputed per Bravais class — every call solves the geometry from scratch.
//
// Method (see issue #10):
//   1. Enumerate neighbour lattice points g = n1 b1 + n2 b2 + n3 b3 with each
//      n in [-2, 2] (the "2 shells", 124 points). Each g gives a bisector
//      half-space  x·g <= |g|²/2  (the plane equidistant from 0 and g).
//   2. Every triple of planes meets in a candidate vertex (a 3x3 solve). Keep
//      the candidates that satisfy EVERY half-space (tolerance-deduped).
//   3. Group the surviving vertices by the plane they lie on; a plane with >= 3
//      of them is a face. Order each face's vertices into a ring and orient it
//      outward.
//
// Pure functions on scenery's linalg — cetz-free. The
// output `(vertices, faces)` is index-based, directly consumable as
// `scenery.mesh(vertices, faces)`.
#import "@preview/scenery:0.1.0": vadd, vsub, vscale, vdot, vcross, vlen, vnorm

// How many of the nearest bisector planes to keep before the O(k³) triple loop.
//
// Safety: a 3D lattice has at most 14 Voronoi-relevant vectors (the general
// bound 2(2^d - 1) for d = 3), i.e. the Wigner-Seitz cell has at most 14 faces,
// and every relevant vector is among the SHORTEST lattice vectors. A point lies
// outside the cell iff it violates some relevant half-space, so keeping every
// relevant plane is sufficient both to find all true vertices (each is the
// meet of three relevant planes) and to reject every spurious one. 50 nearest
// planes is >3x the 14-plane bound, so the relevant set is always retained,
// while C(50,3) ~ 2e4 triples keeps the compile well under a second.
#let _max-planes = 50

// Cramer's rule for the three planes n_i·x = d_i (rows n1,n2,n3). Returns `none`
// when the planes are near-parallel (|det| below `eps-det`), i.e. no unique meet.
#let _solve3(n1, n2, n3, d1, d2, d3, eps-det) = {
  let c23 = vcross(n2, n3)
  let det = vdot(n1, c23)
  if calc.abs(det) < eps-det { return none }
  let c31 = vcross(n3, n1)
  let c12 = vcross(n1, n2)
  // x = A⁻¹ d, with A⁻¹ columns (n2×n3, n3×n1, n1×n2)/det.
  vscale(vadd(vadd(vscale(c23, d1), vscale(c31, d2)), vscale(c12, d3)), 1 / det)
}

/// First Brillouin zone (Wigner-Seitz cell of the reciprocal lattice).
///
/// - recip (array): three reciprocal lattice vectors (each a 3-vector), e.g.
///   the output of `reciprocal-vectors`.
/// -> dictionary, none
/// Returns `(vertices: array of 3-vecs, faces: array of vertex-index arrays)`,
/// directly consumable as `scenery.mesh(vertices, faces)`. Faces are polygon
/// rings ordered consistently with outward normals.
///
/// Degenerate input — three coplanar/linearly dependent reciprocal vectors, so
/// no bounded cell exists — returns the sentinel `none` (matching
/// `scenery`'s `hull-faces`; Typst cannot recover from a raised assertion inside
/// a test, so callers check for `none` rather than aborting compilation).
#let bz-cell(recip) = {
  let (b1, b2, b3) = recip
  let bmin = calc.min(vlen(b1), vlen(b2), vlen(b3))
  // Zero or coplanar basis -> no bounded Wigner-Seitz cell.
  if bmin <= 0 { return none }
  if calc.abs(vdot(b1, vcross(b2, b3))) < 1e-9 * bmin * bmin * bmin { return none }

  // Tolerances scaled to the lattice: `x·g` and offsets live on the |b|² scale,
  // positions on the |b| scale, the triple determinant on the |b|³ scale.
  let s2 = bmin * bmin
  let eps-det = 1e-9 * s2 * bmin // truly singular plane triples only
  let eps-in = 1e-7 * s2 // half-space "inside" slack (strict)
  let eps-face = 1e-6 * s2 // on-plane membership (looser, so it never drops an accepted vertex)
  let eps-dedup = 1e-6 * bmin // merge distance for coincident vertices

  // 1. bisector planes for the 2-shell neighbourhood, nearest first.
  let planes = ()
  for n1 in range(-2, 3) {
    for n2 in range(-2, 3) {
      for n3 in range(-2, 3) {
        if n1 == 0 and n2 == 0 and n3 == 0 { continue }
        let g = vadd(vadd(vscale(b1, n1), vscale(b2, n2)), vscale(b3, n3))
        planes.push((normal: g, offset: vdot(g, g) / 2, len: vlen(g)))
      }
    }
  }
  planes = planes.sorted(key: p => p.len)
  let k = calc.min(_max-planes, planes.len())
  planes = planes.slice(0, k)

  // 2. candidate vertices: every plane triple, kept iff inside every half-space.
  let verts = ()
  for i in range(k) {
    let pi = planes.at(i)
    for j in range(i + 1, k) {
      let pj = planes.at(j)
      for l in range(j + 1, k) {
        let pl = planes.at(l)
        let x = _solve3(pi.normal, pj.normal, pl.normal, pi.offset, pj.offset, pl.offset, eps-det)
        if x == none { continue }
        if not planes.all(p => vdot(x, p.normal) - p.offset <= eps-in) { continue }
        // dedup against vertices already accepted
        let dup = false
        for v in verts {
          if vlen(vsub(v, x)) < eps-dedup { dup = true; break }
        }
        if not dup { verts.push(x) }
      }
    }
  }
  if verts.len() < 4 { return none }

  // 3. faces: group vertices by the plane they sit on; keep planes with >= 3.
  let faces = ()
  for p in planes {
    let g = p.normal
    let idxs = range(verts.len()).filter(ix => calc.abs(vdot(verts.at(ix), g) - p.offset) < eps-face)
    if idxs.len() < 3 { continue }
    // Order the ring counter-clockwise about the face centroid, in the plane
    // frame (u, v) with the OUTWARD normal (g points away from the origin, since
    // offset = |g|²/2 > 0), giving all faces a consistent outward orientation.
    let nrm = vnorm(g)
    let c = vscale(idxs.map(ix => verts.at(ix)).fold((0.0, 0.0, 0.0), vadd), 1 / idxs.len())
    let u = vnorm(vsub(verts.at(idxs.first()), c))
    let w = vcross(nrm, u)
    let ordered = idxs.sorted(key: ix => {
      let r = vsub(verts.at(ix), c)
      calc.atan2(vdot(r, u), vdot(r, w)).rad()
    })
    faces.push(ordered)
  }
  if faces.len() < 4 { return none }

  (vertices: verts, faces: faces)
}

/// Volume of a Brillouin-zone cell, by summing origin-based tetrahedra.
///
/// Each face is fanned into triangles from its first vertex; every triangle with
/// the origin forms a tetrahedron whose volume is added. The origin is interior
/// to the cell, so this equals the enclosed volume regardless of face winding.
/// Used as an independent invariant: it must equal |det(b1,b2,b3)|.
///
/// - cell (dictionary): a `bz-cell` result `(vertices, faces)`.
/// -> float
#let bz-volume(cell) = {
  let verts = cell.vertices
  let total = 0.0
  for f in cell.faces {
    let v0 = verts.at(f.first())
    for m in range(1, f.len() - 1) {
      total += calc.abs(vdot(v0, vcross(verts.at(f.at(m)), verts.at(f.at(m + 1))))) / 6.0
    }
  }
  total
}
