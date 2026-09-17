// Geometry for rendering: supercell replication, boundary images, and the
// unit-cell wireframe. Pure/cetz-free; consumes a structure value (Task 7).
#import "@preview/scenery:0.1.0": vadd, vscale, vsub, vlen, vcross, vdot, vnorm
#import "../core/lattice.typ": frac-to-cart
#import "../core/data.typ": element-info

#let _cart(structure, frac) = frac-to-cart(structure.vectors, frac, structure.periodic)

/// Atoms to display: supercell replication + boundary images.
/// Returns array of (element, frac, cart, site, image: bool). `frac` is in CELL
/// units and may reach `n` along a periodic axis (boundary copies).
#let display-atoms(structure, supercell: (1, 1, 1), boundary: true, eps: 1e-4) = {
  let n = supercell
  let out = ()
  for a in structure.atoms {
    for i in range(n.at(0)) {
      for j in range(n.at(1)) {
        for k in range(if structure.periodic.at(2) { n.at(2) } else { 1 }) {
          let f = vadd(a.frac, (float(i), float(j), if structure.periodic.at(2) { float(k) } else { 0.0 }))
          out.push((element: a.element, frac: f, site: a.site, image: (i, j, k) != (0, 0, 0)))
        }
      }
    }
  }
  if boundary {
    let images = ()
    for a in out {
      // Per axis: the absolute coordinates this atom should appear at.
      // An atom at ~0 also appears at n; one at ~n also appears at 0.
      // (expand() wraps into [0,1), so within one cell only the ~0 case fires;
      // the ~n case matters for user-provided explicit atoms at exactly 1.0.)
      let targets = range(3).map(i => {
        let f = a.frac.at(i)
        if not structure.periodic.at(i) { (f,) }
        else if calc.abs(f) < eps { (f, float(n.at(i))) }
        else if calc.abs(f - float(n.at(i))) < eps { (f, 0.0) }
        else { (f,) }
      })
      for fx in targets.at(0) {
        for fy in targets.at(1) {
          for fz in targets.at(2) {
            if (fx, fy, fz) != (a.frac.at(0), a.frac.at(1), a.frac.at(2)) {
              images.push((..a, frac: (fx, fy, fz), image: true))
            }
          }
        }
      }
    }
    out += images
  }
  out.map(a => (..a, cart: _cart(structure, a.frac)))
}

/// Unit-cell wireframe edges for every cell in the supercell block, deduplicated.
/// Returns array of (cart-a, cart-b). Layer structures (non-periodic c) draw the
/// 2D parallelogram (4 edges at z = 0).
#let cell-edges(structure, supercell: (1, 1, 1)) = {
  let n = supercell
  let corners-3d = ((0,0,0),(1,0,0),(0,1,0),(0,0,1),(1,1,0),(1,0,1),(0,1,1),(1,1,1))
  let edge-idx-3d = ((0,1),(0,2),(0,3),(1,4),(1,5),(2,4),(2,6),(3,5),(3,6),(4,7),(5,7),(6,7))
  let corners-2d = ((0,0,0),(1,0,0),(0,1,0),(1,1,0))
  let edge-idx-2d = ((0,1),(0,2),(1,3),(2,3))
  let (corners, edge-idx) = if structure.periodic.at(2) { (corners-3d, edge-idx-3d) } else { (corners-2d, edge-idx-2d) }
  let seen = ()
  let out = ()
  for i in range(n.at(0)) {
    for j in range(n.at(1)) {
      for k in range(if structure.periodic.at(2) { n.at(2) } else { 1 }) {
        for (p, q) in edge-idx {
          let fa = vadd(corners.at(p).map(float), (float(i), float(j), float(k)))
          let fb = vadd(corners.at(q).map(float), (float(i), float(j), float(k)))
          let key = repr((fa, fb))
          if key not in seen {
            seen.push(key)
            out.push((_cart(structure, fa), _cart(structure, fb)))
          }
        }
      }
    }
  }
  out
}

/// O(N^2) bond search over displayed atoms. rules: auto | ((elements, max, min?), ..)
#let find-bonds(shown, rules) = {
  let cutoff(a, b) = {
    if rules == auto {
      let r = element-info(a.element).r-cov + element-info(b.element).r-cov
      (min: 0.4, max: 1.15 * r)
    } else {
      let hit = rules.find(r => (
        (r.elements.at(0), r.elements.at(1)) == (a.element, b.element)
          or (r.elements.at(1), r.elements.at(0)) == (a.element, b.element)
      ))
      if hit == none { none } else { (min: hit.at("min", default: 0.4), max: hit.max) }
    }
  }
  let out = ()
  for i in range(shown.len()) {
    for j in range(i + 1, shown.len()) {
      let c = cutoff(shown.at(i), shown.at(j))
      if c != none {
        let d = vlen(vsub(shown.at(i).cart, shown.at(j).cart))
        if d >= c.min and d <= c.max {
          out.push((i: i, j: j))
        }
      }
    }
  }
  out
}

/// Convex hull of <= ~12 points via unique-plane enumeration.
/// Returns faces as polygons (vertices ordered around the outward normal).
#let _hull-faces(pts) = {
  let n = pts.len()
  let faces = ()
  let seen = ()
  for i in range(n) {
    for j in range(i + 1, n) {
      for k in range(j + 1, n) {
        let nrm = vcross(vsub(pts.at(j), pts.at(i)), vsub(pts.at(k), pts.at(i)))
        if vlen(nrm) < 1e-8 { continue }
        let nrm = vnorm(nrm)
        let d = vdot(nrm, pts.at(i))
        let sides = pts.map(p => vdot(nrm, p) - d)
        if sides.any(s => s > 1e-6) and sides.any(s => s < -1e-6) { continue }
        let (nrm, d) = if sides.any(s => s > 1e-6) { (vscale(nrm, -1), -d) } else { (nrm, d) }
        let key = repr(nrm.map(x => calc.round(x, digits: 5)) + (calc.round(d, digits: 5),))
        if key in seen { continue }
        seen.push(key)
        let fpts = pts.filter(p => calc.abs(vdot(nrm, p) - d) < 1e-6)
        // order around centroid
        let c = vscale(fpts.fold((0.0, 0.0, 0.0), vadd), 1 / fpts.len())
        let u = vnorm(vsub(fpts.first(), c))
        let v = vcross(nrm, u)
        faces.push(fpts.sorted(key: p => {
          let r = vsub(p, c)
          calc.atan2(vdot(r, u), vdot(r, v)).rad()
        }))
      }
    }
  }
  faces
}

/// Coordination polyhedra around displayed atoms of the given elements.
#let find-polyhedra(shown, bonds, elements) = {
  let out = ()
  for (ci, c) in shown.enumerate() {
    if c.element not in elements { continue }
    let nbrs = ()
    for b in bonds {
      if b.i == ci { nbrs.push(shown.at(b.j).cart) }
      if b.j == ci { nbrs.push(shown.at(b.i).cart) }
    }
    if nbrs.len() >= 4 {
      out.push((center: ci, faces: _hull-faces(nbrs)))
    }
  }
  out
}
