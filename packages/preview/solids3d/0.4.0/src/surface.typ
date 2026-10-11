// surface.typ — Bézier patches and surfaces (three_surface.asy subset):
// planar patches, surfaces of revolution, extrusions and the unit solids.

#import "vec.typ": *
#import "path3.typ": *
#import "geom-transform.typ": geom-transform

#let nslice = 12 // Asymptote's nslice (three_surface.asy)

#let is-surface(s) = type(s) == dictionary and s.at("kind", default: none) == "surface"
#let is-patch(p) = type(p) == dictionary and p.at("kind", default: none) == "patch"
#let is-revolution(r) = type(r) == dictionary and r.at("kind", default: none) == "revolution"

// Newell normal of a closed polygon given by its points.
#let newell-normal(pts) = {
  let n = pts.len()
  let nx = 0.0
  let ny = 0.0
  let nz = 0.0
  for i in range(n) {
    let (x0, y0, z0) = pts.at(i)
    let (x1, y1, z1) = pts.at(calc.rem-euclid(i + 1, n))
    nx += (y0 - y1) * (z0 + z1)
    ny += (z0 - z1) * (x0 + x1)
    nz += (x0 - x1) * (y0 + y1)
  }
  vunit((nx, ny, nz))
}

#let mean-of(pts) = {
  if pts.len() == 0 { return O }
  vmul(1 / pts.len(), pts.fold(O, vadd))
}

// A patch from a closed boundary path3.
#let patch(boundary, normal: auto, center: auto, color: none, holes: ()) = {
  let b = if boundary.cyclic { boundary } else { close3(boundary) }
  let pts = flatten3(b, n: 4)
  let nrm = if normal == auto { newell-normal(pts) } else { vunit(normal) }
  let ctr = if center == auto { mean-of(b.nodes) } else { center }
  let out = (kind: "patch", boundary: b, normal: nrm, center: ctr, color: color)
  if holes.len() > 0 { out.holes = holes.map(h => if h.cyclic { h } else { close3(h) }) }
  out
}

#let surface-from-patches(patches) = (kind: "surface", patches: patches)

// Rotation (3x3, flattened) by ang degrees about the unit axis (ax, ay, az).
#let rot3x3(ang, ax, ay, az) = {
  let s = calc.sin(ang * 1deg)
  let c = calc.cos(ang * 1deg)
  let t = 1 - c
  (
    t * ax * ax + c, t * ax * ay - s * az, t * ax * az + s * ay,
    t * ax * ay + s * az, t * ay * ay + c, t * ay * az - s * ax,
    t * ax * az - s * ay, t * ay * az + s * ax, t * az * az + c,
  )
}

// Tangent of the Bézier segment (a, b, c, d) at its start (t = 0) or end
// (t = 1), with fallbacks for coincident control points.
#let segment-tangent(a, b, c, d, t) = {
  let v = if t < 0.5 { vsub(b, a) } else { vsub(d, c) }
  if vabs2(v) < 1e-24 { v = if t < 0.5 { vsub(c, a) } else { vsub(d, b) } }
  if vabs2(v) < 1e-24 { v = vsub(d, a) }
  v
}

// Unit surface normal of the profile point p (tangent tau) of a surface of
// revolution about the axis (c, u), u unit: tau x (u x rad).
// Written with inline arithmetic (called for every patch corner).
#let rev-normal(px, py, pz, tx, ty, tz, cx, cy, cz, ux, uy, uz) = {
  let (rx, ry, rz) = (px - cx, py - cy, pz - cz)
  let h = rx * ux + ry * uy + rz * uz
  rx -= h * ux
  ry -= h * uy
  rz -= h * uz
  // t = u x rad
  let (wx, wy, wz) = (uy * rz - uz * ry, uz * rx - ux * rz, ux * ry - uy * rx)
  let (nx, ny, nz) = (ty * wz - tz * wy, tz * wx - tx * wz, tx * wy - ty * wx)
  let nn = calc.sqrt(nx * nx + ny * ny + nz * nz)
  if nn > 1e-12 * (calc.sqrt(tx * tx + ty * ty + tz * tz) + 1e-300) { return (nx / nn, ny / nn, nz / nn) }
  // point on the axis: tau x (u x tau) = u (tau.tau) - tau (tau.u)
  let tt = tx * tx + ty * ty + tz * tz
  let tu = tx * ux + ty * uy + tz * uz
  let (mx, my, mz) = (ux * tt - tx * tu, uy * tt - ty * tu, uz * tt - tz * tu)
  let mn = calc.sqrt(mx * mx + my * my + mz * mz)
  if mn > 1e-300 { (mx / mn, my / mn, mz / mn) } else { (ux, uy, uz) }
}

// One patch of a surface of revolution: the profile segment (a, b, cc, d)
// (absolute coordinates, st = straight) swept from angle th0 to th1
// (degrees) about the axis through c with unit direction u. The patch
// carries its four corner normals (for smooth shading) and the generator
// data (`rev`) which lets the renderer refine it along the silhouette.
#let rev-patch(c, u, a, b, cc, d, st, th0, th1, col) = {
  let (cx, cy, cz) = c
  let (ux, uy, uz) = u
  // rotation matrices at th0, th1 and the mid angle (inlined rot3x3)
  let sn = calc.sin(th0 * 1deg)
  let cs = calc.cos(th0 * 1deg)
  let tt = 1 - cs
  let (r00, r01, r02, r10, r11, r12, r20, r21, r22) = (tt * ux * ux + cs, tt * ux * uy - sn * uz, tt * ux * uz + sn * uy, tt * ux * uy + sn * uz, tt * uy * uy + cs, tt * uy * uz - sn * ux, tt * ux * uz - sn * uy, tt * uy * uz + sn * ux, tt * uz * uz + cs)
  sn = calc.sin(th1 * 1deg)
  cs = calc.cos(th1 * 1deg)
  tt = 1 - cs
  let (q00, q01, q02, q10, q11, q12, q20, q21, q22) = (tt * ux * ux + cs, tt * ux * uy - sn * uz, tt * ux * uz + sn * uy, tt * ux * uy + sn * uz, tt * uy * uy + cs, tt * uy * uz - sn * ux, tt * ux * uz - sn * uy, tt * uy * uz + sn * ux, tt * uz * uz + cs)
  sn = calc.sin(0.5 * (th0 + th1) * 1deg)
  cs = calc.cos(0.5 * (th0 + th1) * 1deg)
  tt = 1 - cs
  let (m00, m01, m02, m10, m11, m12, m20, m21, m22) = (tt * ux * ux + cs, tt * ux * uy - sn * uz, tt * ux * uz + sn * uy, tt * ux * uy + sn * uz, tt * uy * uy + cs, tt * uy * uz - sn * ux, tt * ux * uz - sn * uy, tt * uy * uz + sn * ux, tt * uz * uz + cs)
  let kk = 4 / 3 * calc.tan((th1 - th0) / 4 * 1deg)
  // coordinates relative to c
  let (ax0, ay0, az0) = (a.at(0) - cx, a.at(1) - cy, a.at(2) - cz)
  let (bx0, by0, bz0) = (b.at(0) - cx, b.at(1) - cy, b.at(2) - cz)
  let (ccx0, ccy0, ccz0) = (cc.at(0) - cx, cc.at(1) - cy, cc.at(2) - cz)
  let (dx0, dy0, dz0) = (d.at(0) - cx, d.at(1) - cy, d.at(2) - cz)
  let ha = ax0 * ux + ay0 * uy + az0 * uz
  let hd = dx0 * ux + dy0 * uy + dz0 * uz
  let (cax, cay, caz) = (ha * ux, ha * uy, ha * uz)
  let (cdx, cdy, cdz) = (hd * ux, hd * uy, hd * uz)
  // rotated control points (absolute)
  let A0 = (cx + r00 * ax0 + r01 * ay0 + r02 * az0, cy + r10 * ax0 + r11 * ay0 + r12 * az0, cz + r20 * ax0 + r21 * ay0 + r22 * az0)
  let B0 = (cx + r00 * bx0 + r01 * by0 + r02 * bz0, cy + r10 * bx0 + r11 * by0 + r12 * bz0, cz + r20 * bx0 + r21 * by0 + r22 * bz0)
  let C0 = (cx + r00 * ccx0 + r01 * ccy0 + r02 * ccz0, cy + r10 * ccx0 + r11 * ccy0 + r12 * ccz0, cz + r20 * ccx0 + r21 * ccy0 + r22 * ccz0)
  let D0 = (cx + r00 * dx0 + r01 * dy0 + r02 * dz0, cy + r10 * dx0 + r11 * dy0 + r12 * dz0, cz + r20 * dx0 + r21 * dy0 + r22 * dz0)
  let A1 = (cx + q00 * ax0 + q01 * ay0 + q02 * az0, cy + q10 * ax0 + q11 * ay0 + q12 * az0, cz + q20 * ax0 + q21 * ay0 + q22 * az0)
  let B1 = (cx + q00 * bx0 + q01 * by0 + q02 * bz0, cy + q10 * bx0 + q11 * by0 + q12 * bz0, cz + q20 * bx0 + q21 * by0 + q22 * bz0)
  let C1 = (cx + q00 * ccx0 + q01 * ccy0 + q02 * ccz0, cy + q10 * ccx0 + q11 * ccy0 + q12 * ccz0, cz + q20 * ccx0 + q21 * ccy0 + q22 * ccz0)
  let D1 = (cx + q00 * dx0 + q01 * dy0 + q02 * dz0, cy + q10 * dx0 + q11 * dy0 + q12 * dz0, cz + q20 * dx0 + q21 * dy0 + q22 * dz0)
  // arc at d: from D0 to D1; tangent = u x (point - centre)
  let (u0x, u0y, u0z) = (D0.at(0) - cx - cdx, D0.at(1) - cy - cdy, D0.at(2) - cz - cdz)
  let (u3x, u3y, u3z) = (D1.at(0) - cx - cdx, D1.at(1) - cy - cdy, D1.at(2) - cz - cdz)
  let q1 = (D0.at(0) + kk * (uy * u0z - uz * u0y), D0.at(1) + kk * (uz * u0x - ux * u0z), D0.at(2) + kk * (ux * u0y - uy * u0x))
  let q2 = (D1.at(0) - kk * (uy * u3z - uz * u3y), D1.at(1) - kk * (uz * u3x - ux * u3z), D1.at(2) - kk * (ux * u3y - uy * u3x))
  // arc at a: from A0 to A1 (used reversed)
  let (v0x, v0y, v0z) = (A0.at(0) - cx - cax, A0.at(1) - cy - cay, A0.at(2) - cz - caz)
  let (v3x, v3y, v3z) = (A1.at(0) - cx - cax, A1.at(1) - cy - cay, A1.at(2) - cz - caz)
  let s1 = (A0.at(0) + kk * (uy * v0z - uz * v0y), A0.at(1) + kk * (uz * v0x - ux * v0z), A0.at(2) + kk * (ux * v0y - uy * v0x))
  let s2 = (A1.at(0) - kk * (uy * v3z - uz * v3y), A1.at(1) - kk * (uz * v3x - ux * v3z), A1.at(2) - kk * (ux * v3y - uy * v3x))
  let boundary = (
    kind: "path3",
    nodes: (A0, D0, D1, A1),
    pre: (s1, C0, q2, B1),
    post: (B0, q1, C1, s2),
    straight: (st, false, st, false),
    cyclic: true,
  )
  // profile tangents at the ends and the middle of the segment (with fallbacks)
  let (tax, tay, taz) = (bx0 - ax0, by0 - ay0, bz0 - az0)
  if tax * tax + tay * tay + taz * taz < 1e-24 { (tax, tay, taz) = (ccx0 - ax0, ccy0 - ay0, ccz0 - az0) }
  if tax * tax + tay * tay + taz * taz < 1e-24 { (tax, tay, taz) = (dx0 - ax0, dy0 - ay0, dz0 - az0) }
  let (tdx, tdy, tdz) = (dx0 - ccx0, dy0 - ccy0, dz0 - ccz0)
  if tdx * tdx + tdy * tdy + tdz * tdz < 1e-24 { (tdx, tdy, tdz) = (dx0 - bx0, dy0 - by0, dz0 - bz0) }
  if tdx * tdx + tdy * tdy + tdz * tdz < 1e-24 { (tdx, tdy, tdz) = (dx0 - ax0, dy0 - ay0, dz0 - az0) }
  let (pmx, pmy, pmz) = (0.125 * (ax0 + dx0) + 0.375 * (bx0 + ccx0), 0.125 * (ay0 + dy0) + 0.375 * (by0 + ccy0), 0.125 * (az0 + dz0) + 0.375 * (bz0 + ccz0))
  let (dmx, dmy, dmz) = (0.75 * (dx0 - ax0 + ccx0 - bx0), 0.75 * (dy0 - ay0 + ccy0 - by0), 0.75 * (dz0 - az0 + ccz0 - bz0))
  if dmx * dmx + dmy * dmy + dmz * dmz < 1e-24 { (dmx, dmy, dmz) = (dx0 - ax0, dy0 - ay0, dz0 - az0) }
  // unrotated unit normals tau x (u x rad) at a, d and the middle (inlined
  // rev-normal; points on the axis fall back to the axis component
  // orthogonal to tau)
  let nrms = ()
  for (px, py, pz, tx, ty, tz) in ((ax0, ay0, az0, tax, tay, taz), (dx0, dy0, dz0, tdx, tdy, tdz), (pmx, pmy, pmz, dmx, dmy, dmz)) {
    let h = px * ux + py * uy + pz * uz
    let (rx, ry, rz) = (px - h * ux, py - h * uy, pz - h * uz)
    let (wx, wy, wz) = (uy * rz - uz * ry, uz * rx - ux * rz, ux * ry - uy * rx)
    let (nx, ny, nz) = (ty * wz - tz * wy, tz * wx - tx * wz, tx * wy - ty * wx)
    let nn = calc.sqrt(nx * nx + ny * ny + nz * nz)
    let tl = calc.sqrt(tx * tx + ty * ty + tz * tz) + 1e-300
    if nn > 1e-12 * tl { nrms.push((nx / nn, ny / nn, nz / nn)) } else {
      let t2 = tx * tx + ty * ty + tz * tz
      let tu = tx * ux + ty * uy + tz * uz
      let (mx, my, mz) = (ux * t2 - tx * tu, uy * t2 - ty * tu, uz * t2 - tz * tu)
      let mn = calc.sqrt(mx * mx + my * my + mz * mz)
      nrms.push(if mn > 1e-300 { (mx / mn, my / mn, mz / mn) } else { (ux, uy, uz) })
    }
  }
  let ((nax, nay, naz), (ndx, ndy, ndz), (nmx, nmy, nmz)) = nrms
  let nA0 = (r00 * nax + r01 * nay + r02 * naz, r10 * nax + r11 * nay + r12 * naz, r20 * nax + r21 * nay + r22 * naz)
  let nA1 = (q00 * nax + q01 * nay + q02 * naz, q10 * nax + q11 * nay + q12 * naz, q20 * nax + q21 * nay + q22 * naz)
  let nD0 = (r00 * ndx + r01 * ndy + r02 * ndz, r10 * ndx + r11 * ndy + r12 * ndz, r20 * ndx + r21 * ndy + r22 * ndz)
  let nD1 = (q00 * ndx + q01 * ndy + q02 * ndz, q10 * ndx + q11 * ndy + q12 * ndz, q20 * ndx + q21 * ndy + q22 * ndz)
  let nrm = (m00 * nmx + m01 * nmy + m02 * nmz, m10 * nmx + m11 * nmy + m12 * nmz, m20 * nmx + m21 * nmy + m22 * nmz)
  let center = (0.25 * (A0.at(0) + D0.at(0) + D1.at(0) + A1.at(0)), 0.25 * (A0.at(1) + D0.at(1) + D1.at(1) + A1.at(1)), 0.25 * (A0.at(2) + D0.at(2) + D1.at(2) + A1.at(2)))
  (
    kind: "patch", boundary: boundary, normal: nrm, center: center, color: col,
    normals: (nA0, nD0, nD1, nA1),
    rev: (c: c, u: u, seg: (a, b, cc, d), st: st, th0: th0, th1: th1),
  )
}

// Surface of revolution of the planar path g about the line c--c+axis,
// from angle1 to angle2 (degrees) sampled n times.
// An optional color(i, j) callback gives the colour of patch (segment i,
// angle j).
#let surface-of-revolution(c, g, axis, n: nslice, angle1: 0, angle2: 360, color: none) = {
  let u = vunit(axis)
  let cc0 = c.map(float)
  let L = length3(g)
  if n <= 0 or L == 0 { return surface-from-patches(()) }
  let w = (angle2 - angle1) / n
  let patches = ()
  let scale = calc.max(vabs(vsub(max3(g), min3(g))), 1e-300)
  let (cx, cy, cz) = cc0
  let (ux, uy, uz) = u
  for i in range(L) {
    let (a, b, cc, d) = segment(g, i)
    let st = straight(g, i)
    // skip segments lying on the axis
    let (ax0, ay0, az0) = (a.at(0) - cx, a.at(1) - cy, a.at(2) - cz)
    let (dx0, dy0, dz0) = (d.at(0) - cx, d.at(1) - cy, d.at(2) - cz)
    let ha = ax0 * ux + ay0 * uy + az0 * uz
    let hd = dx0 * ux + dy0 * uy + dz0 * uz
    let ra = calc.sqrt(calc.max(0, ax0 * ax0 + ay0 * ay0 + az0 * az0 - ha * ha))
    let rd = calc.sqrt(calc.max(0, dx0 * dx0 + dy0 * dy0 + dz0 * dz0 - hd * hd))
    if ra <= 1e-9 * scale and rd <= 1e-9 * scale { continue }
    for k in range(n) {
      let th0 = angle1 + k * w
      let col = if color == none { none } else { color(i, th0) }
      patches.push(rev-patch(cc0, u, a, b, cc, d, st, th0, th0 + w, col))
    }
  }
  surface-from-patches(patches)
}

// ---------------------------------------------------------------------------
// Parametric and indexed mesh surfaces
// ---------------------------------------------------------------------------
// Build a regular tensor-product mesh from f(u, v).  Each cell is a genuine
// surface patch with four corner normals, so it benefits from the same smooth
// shading as revolution patches.  `normal` may be a constant triple or a
// callback normal(u, v); when omitted, vertex normals are averaged from the
// incident cells.
#let surface-grid(f, u0, u1, v0, v1, nu: 16, nv: 12, cyclic-u: false, cyclic-v: false, normal: auto, color: none) = {
  nu = calc.max(1, int(nu))
  nv = calc.max(1, int(nv))
  let us = range(nu + 1).map(i => u0 + (u1 - u0) * i / nu)
  let vs = range(nv + 1).map(j => v0 + (v1 - v0) * j / nv)
  let points = ()
  for u in us {
    let row = ()
    for v in vs { row.push(f(u, v).map(float)) }
    points.push(row)
  }

  // Face order is (u, v): p00 -> p10 -> p11 -> p01.  Consequently the
  // default normal is du x dv, which is also the orientation of the path.
  let face-normals = ()
  for i in range(nu) {
    let row = ()
    for j in range(nv) {
      let p00 = points.at(i).at(j)
      let p10 = points.at(i + 1).at(j)
      let p01 = points.at(i).at(j + 1)
      row.push(vunit(vcross(vsub(p10, p00), vsub(p01, p00))))
    }
    face-normals.push(row)
  }

  // One normal per grid vertex.  Averaging face normals is robust at a grid
  // corner and avoids a visible crease between adjacent cells.
  let vertex-normals = ()
  for i in range(nu + 1) {
    let row = ()
    for j in range(nv + 1) {
      if normal != auto and is-triple(normal) {
        row.push(vunit(normal))
      } else if normal != auto {
        row.push(vunit(normal(us.at(i), vs.at(j))))
      } else {
        let acc = O
        for di in (-1, 0) {
          for dj in (-1, 0) {
            let fi0 = i + di
            let fj0 = j + dj
            let fi = if cyclic-u { calc.rem-euclid(fi0, nu) } else { fi0 }
            let fj = if cyclic-v { calc.rem-euclid(fj0, nv) } else { fj0 }
            if fi >= 0 and fi < nu and fj >= 0 and fj < nv {
              acc = vadd(acc, face-normals.at(fi).at(fj))
            }
          }
        }
        row.push(vunit(acc))
      }
    }
    vertex-normals.push(row)
  }

  let patches = ()
  for i in range(nu) {
    for j in range(nv) {
      let p00 = points.at(i).at(j)
      let p10 = points.at(i + 1).at(j)
      let p11 = points.at(i + 1).at(j + 1)
      let p01 = points.at(i).at(j + 1)
      let boundary = line3(p00, p10, p11, p01, cyclic: true)
      let col = if color == none { none } else if type(color) == function {
        color(0.5 * (us.at(i) + us.at(i + 1)), 0.5 * (vs.at(j) + vs.at(j + 1)))
      } else { color }
      patches.push((
        kind: "patch",
        boundary: boundary,
        normal: face-normals.at(i).at(j),
        center: mean-of((p00, p10, p11, p01)),
        color: col,
        normals: (
          vertex-normals.at(i).at(j),
          vertex-normals.at(i + 1).at(j),
          vertex-normals.at(i + 1).at(j + 1),
          vertex-normals.at(i).at(j + 1),
        ),
      ))
    }
  }
  surface-from-patches(patches)
}

// Short aliases used by plotting code.
#let parametric-surface = surface-grid
#let parametric = surface-grid

// Convenience wrapper for z = f(x, y).
#let heightfield(f, x0, x1, y0, y1, nx: 16, ny: 16, normal: auto, color: none) = {
  surface-grid((x, y) => (x, y, f(x, y)), x0, x1, y0, y1, nu: nx, nv: ny, normal: if normal == auto { auto } else if is-triple(normal) { normal } else { (x, y) => vunit(normal(x, y)) }, color: color)
}

// Build a surface from vertices and polygonal faces.  Faces use zero-based
// indices by default; pass indices: "one" for OBJ/Asymptote-style indices.
// Vertex normals are averaged across adjacent faces unless `normal` is a
// constant triple or a callback normal(vertex) supplied by the caller.
#let surface-mesh(vertices, faces, indices: "zero", normal: auto, smooth: true, color: none) = {
  let vs = vertices.map(v => v.map(float))
  let fs = faces.map(face => face.map(i => if indices == "one" { int(i) - 1 } else { int(i) }))
  let face-normals = ()
  let face-points = ()
  for ids in fs {
    let pts = ids.map(i => vs.at(i))
    face-points.push(pts)
    face-normals.push(newell-normal(pts))
  }
  let vertex-normals = range(vs.len()).map(_ => O)
  for (k, ids) in fs.enumerate() {
    for i in ids { vertex-normals.at(i) = vadd(vertex-normals.at(i), face-normals.at(k)) }
  }
  for (i, n) in vertex-normals.enumerate() {
    vertex-normals.at(i) = if normal == auto { vunit(n) } else if is-triple(normal) { vunit(normal) } else { vunit(normal(vs.at(i))) }
  }
  let patches = ()
  for (k, ids) in fs.enumerate() {
    let pts = face-points.at(k)
    if pts.len() < 3 { continue }
    let boundary = line3(pts, cyclic: true)
    let nrm = if normal == auto { face-normals.at(k) } else if is-triple(normal) { vunit(normal) } else { vunit(normal(mean-of(pts))) }
    let col = if color == none { none } else if type(color) == function { color(k, mean-of(pts)) } else { color }
    let corners = if smooth { ids.map(i => vertex-normals.at(i)) } else { ids.map(_ => nrm) }
    patches.push((kind: "patch", boundary: boundary, normal: nrm, center: mean-of(pts), color: col, normals: corners))
  }
  surface-from-patches(patches)
}

#let mesh-surface = surface-mesh

// Return one straight path per unique edge of an indexed mesh. This is the
// meshlib/matplotlib-style wireframe layer: use `draw(mesh-edges(...), pen)`
// above or below the filled `surface-mesh`. Set `boundary: true` to retain
// only edges incident to one face.
#let mesh-edges(vertices, faces, indices: "zero", boundary: false) = {
  let vs = vertices.map(v => v.map(float))
  let fs = faces.map(face => face.map(i => if indices == "one" { int(i) - 1 } else { int(i) }))
  let counts = (:)
  let pairs = ()
  for ids in fs {
    let n = ids.len()
    if n >= 2 {
      for i in range(n) {
        let a = ids.at(i)
        let b = ids.at(calc.rem-euclid(i + 1, n))
        let lo = calc.min(a, b)
        let hi = calc.max(a, b)
        let key = str(lo) + ":" + str(hi)
        counts.insert(key, counts.at(key, default: 0) + 1)
        pairs.push((key: key, a: a, b: b))
      }
    }
  }
  let seen = (:)
  let out = ()
  for edge in pairs {
    if not seen.at(edge.key, default: false) and (not boundary or counts.at(edge.key) == 1) {
      seen.insert(edge.key, true)
      out.push(line3(vs.at(edge.a), vs.at(edge.b)))
    }
  }
  out
}

// Split every curved segment of p into n pieces (for smoother flat shading).
#let refine3(p, n) = {
  if n <= 1 { return p }
  let L = length3(p)
  let nodes = ()
  let pre = ()
  let post = ()
  let strs = ()
  for i in range(L) {
    let (a, b, c, d) = segment(p, i)
    let st = straight(p, i)
    let k = if st { 1 } else { n }
    let rest = (a, b, c, d)
    for j in range(k) {
      let (A, B, C, D) = if j == k - 1 { rest } else {
        let (l, r) = bez-split(rest.at(0), rest.at(1), rest.at(2), rest.at(3), 1 / (k - j))
        rest = r
        l
      }
      if nodes.len() == 0 { nodes.push(A); pre.push(A) }
      post.push(B)
      pre.push(C)
      nodes.push(D)
      strs.push(st)
    }
  }
  post.push(nodes.last())
  if p.cyclic {
    let m = nodes.len() - 1
    mkpath3(nodes.slice(0, m), (pre.at(m),) + pre.slice(1, m), post.slice(0, m), strs, true)
  } else {
    mkpath3(nodes, pre, post, strs, false)
  }
}

#let extrude(p, ..args, v: Z, n: 8) = {
  let a = args.pos()
  if a.len() > 0 { v = a.at(0) }
  p = refine3(p, n)
  let L = length3(p)
  let patches = ()
  for i in range(L) {
    let (a, b, c, d) = segment(p, i)
    let st = straight(p, i)
    let a2 = vadd(a, v)
    let b2 = vadd(b, v)
    let c2 = vadd(c, v)
    let d2 = vadd(d, v)
    let nodes = (a, d, d2, a2)
    let post = (b, interp(d, d2, 1 / 3), c2, interp(a2, a, 1 / 3))
    let pre = (interp(a2, a, 2 / 3), c, interp(d, d2, 2 / 3), b2)
    let boundary = mkpath3(nodes, pre, post, (st, true, st, true), true)
    let pts = flatten3(boundary, n: 4)
    // corner normals: tangent x v at both ends of the segment
    let ta = segment-tangent(a, b, c, d, 0.0)
    let td = segment-tangent(a, b, c, d, 1.0)
    let na = vunit(vcross(ta, v))
    let nd = vunit(vcross(td, v))
    patches.push((kind: "patch", boundary: boundary, normal: newell-normal(pts), center: mean-of(nodes), color: none, normals: (na, nd, nd, na)))
  }
  surface-from-patches(patches)
}

// Generic surface constructor:
//   surface(path3)               planar patch bounded by a cyclic path
//   surface(path3-array)         one patch per path
//   surface(revolution, n: ..)   surface of revolution
//   surface(patch)               surface with one patch
//   surface(s1, s2, ...)         union of surfaces
#let surface(..args, n: nslice, color: none, normal: auto, planar: false) = {
  let a = args.pos()
  if a.len() == 0 { return surface-from-patches(()) }
  // surface(revolution, n)
  if a.len() == 2 and is-revolution(a.at(0)) and type(a.at(1)) == int { n = a.at(1); a = (a.at(0),) }
  // surface(path3[], planar: true): one planar patch whose first path is the
  // outer boundary and the others are holes
  if a.len() == 1 and planar and type(a.at(0)) == array and a.at(0).len() > 1 and a.at(0).all(is-path3) {
    let ps = a.at(0)
    return surface-from-patches((patch(ps.at(0), normal: normal, color: color, holes: ps.slice(1)),))
  }
  if a.len() > 1 {
    let patches = ()
    for x in a {
      let s = surface(x, n: n, color: color)
      patches += s.patches
    }
    return surface-from-patches(patches)
  }
  let x = a.at(0)
  if is-surface(x) { x } else if is-patch(x) { surface-from-patches((x,)) } else if is-path3(x) {
    surface-from-patches((patch(x, normal: normal, color: color),))
  } else if is-revolution(x) {
    let out = surface-of-revolution(x.c, x.g, x.axis, n: n, angle1: x.angle1, angle2: x.angle2, color: color)
    if "geom" in x { out.geom = x.geom }
    out
  } else if type(x) == array {
    let patches = ()
    for y in x { patches += surface(y, n: n, color: color).patches }
    surface-from-patches(patches)
  } else { panic("cannot build a surface from " + repr(x)) }
}

// Is the linear part of T a similarity (rotation/reflection times a
// scalar)? Returns (true, det-sign) or (false, 0).
#let similarity-of(T) = {
  let (r0, r1, r2, r3) = T
  let m = ((r0.at(0), r0.at(1), r0.at(2)), (r1.at(0), r1.at(1), r1.at(2)), (r2.at(0), r2.at(1), r2.at(2)))
  // columns
  let c0 = (m.at(0).at(0), m.at(1).at(0), m.at(2).at(0))
  let c1 = (m.at(0).at(1), m.at(1).at(1), m.at(2).at(1))
  let c2 = (m.at(0).at(2), m.at(1).at(2), m.at(2).at(2))
  let l0 = vabs2(c0)
  let l1 = vabs2(c1)
  let l2 = vabs2(c2)
  let l = (l0 + l1 + l2) / 3
  if l <= 0 { return (false, 0) }
  let eps = 1e-9 * l
  let ok = calc.abs(l0 - l) < eps and calc.abs(l1 - l) < eps and calc.abs(l2 - l) < eps and calc.abs(vdot(c0, c1)) < eps and calc.abs(vdot(c0, c2)) < eps and calc.abs(vdot(c1, c2)) < eps
  if not ok { return (false, 0) }
  let det = vdot(c0, vcross(c1, c2))
  (true, if det < 0 { -1 } else { 1 })
}

#let transform-surface(T, s) = {
  let N = normal-transform(T)
  let (n0, n1, n2) = (N.at(0), N.at(1), N.at(2))
  let (r0, r1, r2, r3) = T
  let (sim, dsign) = similarity-of(T)
  let out = ()
  for p in s.patches {
    let b = transform-path3(T, p.boundary)
    let (x, y, z) = p.normal
    let nrm = vunit((n0.at(0) * x + n0.at(1) * y + n0.at(2) * z, n1.at(0) * x + n1.at(1) * y + n1.at(2) * z, n2.at(0) * x + n2.at(1) * y + n2.at(2) * z))
    let (px, py, pz) = p.center
    let w = r3.at(0) * px + r3.at(1) * py + r3.at(2) * pz + r3.at(3)
    if w == 0 { w = 1e-300 }
    let ctr = ((r0.at(0) * px + r0.at(1) * py + r0.at(2) * pz + r0.at(3)) / w, (r1.at(0) * px + r1.at(1) * py + r1.at(2) * pz + r1.at(3)) / w, (r2.at(0) * px + r2.at(1) * py + r2.at(2) * pz + r2.at(3)) / w)
    let q = (kind: "patch", boundary: b, normal: nrm, center: ctr, color: p.color)
    if "holes" in p { q.holes = p.holes.map(h => transform-path3(T, h)) }
    if "normals" in p {
      q.normals = p.normals.map(v => {
        let (x, y, z) = v
        vunit((n0.at(0) * x + n0.at(1) * y + n0.at(2) * z, n1.at(0) * x + n1.at(1) * y + n1.at(2) * z, n2.at(0) * x + n2.at(1) * y + n2.at(2) * z))
      })
    }
    if "rev" in p and sim {
      let rv = p.rev
      let u2 = vunit(tvector(T, rv.u))
      q.rev = (c: tpoint(T, rv.c), u: u2, seg: rv.seg.map(v => tpoint(T, v)), st: rv.st,
        th0: if dsign < 0 { -rv.th0 } else { rv.th0 }, th1: if dsign < 0 { -rv.th1 } else { rv.th1 })
    }
    out.push(q)
  }
  let result = surface-from-patches(out)
  if "geom" in s {
    let shape = geom-transform(T, s.geom)
    if shape != none { result.geom = shape }
  }
  result
}

#let transform-patch(T, p) = transform-surface(T, surface-from-patches((p,))).patches.at(0)

// Bounding box of a surface (control points).
#let surface-bounds(s) = {
  let m = (float.inf, float.inf, float.inf)
  let M = (-float.inf, -float.inf, -float.inf)
  for p in s.patches {
    m = vmin(m, min3(p.boundary))
    M = vmax(M, max3(p.boundary))
  }
  (m, M)
}

// ---------------------------------------------------------------------------
// Unit solids (three_surface.asy). The revolution-based ones are tessellated
// finely because we render with flat shading.
// ---------------------------------------------------------------------------
#let unit-slices = 32

#let unitplane = surface(unitsquare3)
#let unitdisk = surface(unitcircle3)

#let unitcube = surface((
  line3(O, Y, vadd(X, Y), X, cyclic: true), // bottom (z = 0), outward normal -Z
  line3(O, X, vadd(X, Z), Z, cyclic: true), // y = 0
  line3(O, Z, vadd(Y, Z), Y, cyclic: true), // x = 0
  line3(Z, vadd(X, Z), (1, 1, 1), vadd(Y, Z), cyclic: true), // top
  line3(X, vadd(X, Y), (1, 1, 1), vadd(X, Z), cyclic: true), // x = 1
  line3(Y, vadd(Y, Z), (1, 1, 1), vadd(X, Y), cyclic: true), // y = 1
))

// Half circle in the xz-plane from -Z through X to Z (n segments).
#let half-circle-xz(n) = transform-path3(rotate3(90, X), planar-arc(1.0, -calc.pi / 2, calc.pi / 2, n))
#let quarter-circle-xz(n) = transform-path3(rotate3(90, X), planar-arc(1.0, 0.0, calc.pi / 2, n))

#let unitsphere = surface-of-revolution(O, half-circle-xz(16), Z, n: unit-slices)
#let unithemisphere = surface-of-revolution(O, quarter-circle-xz(8), Z, n: unit-slices)
#let unitcylinder = surface-of-revolution(O, line3(X, vadd(X, Z)), Z, n: unit-slices)
#let unitfrustum(ta, tb) = surface-of-revolution(O, line3((ta, 0, 1 - ta), (tb, 0, 1 - tb)), Z, n: unit-slices)
#let unitcone = unitfrustum(0, 1)
#let unitsolidcone = surface(unitdisk, unitcone)

// Cone over an arbitrary base path with the given vertex.
#let cone-over(base, vertex, n: 4) = {
  base = refine3(base, n)
  let L = length3(base)
  let patches = ()
  for i in range(L) {
    let (a, b, c, d) = segment(base, i)
    let st = straight(base, i)
    let nodes = (a, d, vertex)
    let post = (b, interp(d, vertex, 1 / 3), interp(vertex, a, 1 / 3))
    let pre = (interp(vertex, a, 2 / 3), c, interp(d, vertex, 2 / 3))
    let boundary = mkpath3(nodes, pre, post, (st, true, true), true)
    let na = vunit(vcross(segment-tangent(a, b, c, d, 0.0), vsub(vertex, a)))
    let nd = vunit(vcross(segment-tangent(a, b, c, d, 1.0), vsub(vertex, d)))
    patches.push((kind: "patch", boundary: boundary, normal: newell-normal(flatten3(boundary, n: 4)), center: mean-of(nodes), color: none,
      normals: (na, nd, vunit(vadd(na, nd)))))
  }
  surface-from-patches(patches)
}
