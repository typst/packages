// Mirrors upstream src/xyzrender/utils.py.
//
// Geometry helpers used by the renderer pipeline.

// ---- angle conversion ----

#let _to-rad(a) = {
  if type(a) == angle {
    a.rad()
  } else if type(a) == int or type(a) == float {
    float(a)
  } else {
    0.0
  }
}

// ---- rotation matrices ----
//
// Right-handed convention; rotations applied in order X, Y, Z.
// Each returns a 3x3 row-major matrix as a tuple of three rows.

#let _rot-x(theta) = (
  (1.0, 0.0, 0.0),
  (0.0, calc.cos(theta), -calc.sin(theta)),
  (0.0, calc.sin(theta), calc.cos(theta)),
)

#let _rot-y(theta) = (
  (calc.cos(theta), 0.0, calc.sin(theta)),
  (0.0, 1.0, 0.0),
  (-calc.sin(theta), 0.0, calc.cos(theta)),
)

#let _rot-z(theta) = (
  (calc.cos(theta), -calc.sin(theta), 0.0),
  (calc.sin(theta), calc.cos(theta), 0.0),
  (0.0, 0.0, 1.0),
)

#let _matmul-vec(m, v) = (
  m.at(0).at(0) * v.at(0) + m.at(0).at(1) * v.at(1) + m.at(0).at(2) * v.at(2),
  m.at(1).at(0) * v.at(0) + m.at(1).at(1) * v.at(1) + m.at(1).at(2) * v.at(2),
  m.at(2).at(0) * v.at(0) + m.at(2).at(1) * v.at(1) + m.at(2).at(2) * v.at(2),
)

// Apply user-supplied rotations (dict with optional x/y/z angle
// entries) to a list of 3D points. Identity case returns coords
// unchanged.
#let apply-rotation(coords, rotate-dict) = {
  if rotate-dict == none or rotate-dict.len() == 0 {
    return coords
  }
  let rx = _to-rad(rotate-dict.at("x", default: 0deg))
  let ry = _to-rad(rotate-dict.at("y", default: 0deg))
  let rz = _to-rad(rotate-dict.at("z", default: 0deg))
  if rx == 0.0 and ry == 0.0 and rz == 0.0 {
    return coords
  }
  let mx = _rot-x(rx)
  let my = _rot-y(ry)
  let mz = _rot-z(rz)
  coords.map(p => {
    let v = (float(p.at(0)), float(p.at(1)), float(p.at(2)))
    let v = _matmul-vec(mx, v)
    let v = _matmul-vec(my, v)
    let v = _matmul-vec(mz, v)
    v
  })
}

// ---- PCA orientation (upstream utils.py:60-127) ----
//
// Aligns the molecule so that the largest variance lies along x, the
// next along y, and the smallest along z (depth). Mirrors upstream's
// `pca_orient`. We skip the `priority_pairs` (TS bonds) and `fit_mask`
// (NCI centroid exclusion) overloads — both belong to features that
// aren't in scope for v1.
//
// `np.linalg.svd(c, full_matrices=False)` returns Vt whose rows are
// the right singular vectors ordered by decreasing singular value.
// For a centred Nx3 matrix c, the right singular vectors equal the
// eigenvectors of the 3x3 covariance C = c^T c, ordered by decreasing
// eigenvalue.  We compute that 3x3 eigendecomposition with cyclic
// Jacobi rotations — small, exact for 3x3, no external dependencies.

#let _identity-3() = (
  (1.0, 0.0, 0.0),
  (0.0, 1.0, 0.0),
  (0.0, 0.0, 1.0),
)

// Eigendecompose a 3x3 symmetric matrix `A` via cyclic Jacobi.
// Returns `(eigvals, eigvecs)` where eigvecs columns are the
// eigenvectors. Cyclic order, max 50 sweeps — 3x3 converges in <10.
#let _jacobi-eig-3(A) = {
  let a = A.map(row => row.map(v => float(v)))
  let v = _identity-3()
  let n = 3
  let mut-set(m, i, j, val) = {
    let row = m.at(i)
    let new-row = range(row.len()).map(k => if k == j { val } else { row.at(k) })
    range(m.len()).map(r => if r == i { new-row } else { m.at(r) })
  }
  let read(m, i, j) = m.at(i).at(j)
  let max-sweeps = 50
  let eps = 0.00000000000001
  for _ in range(max-sweeps) {
    // off-diagonal magnitude
    let off = calc.abs(read(a, 0, 1)) + calc.abs(read(a, 0, 2)) + calc.abs(read(a, 1, 2))
    if off < eps { break }
    // (p, q) sweep — only upper triangle for symmetric matrices
    let pairs = ((0, 1), (0, 2), (1, 2))
    for (p, q) in pairs {
      let apq = read(a, p, q)
      if calc.abs(apq) < eps { continue }
      let app = read(a, p, p)
      let aqq = read(a, q, q)
      let theta = (aqq - app) / (2.0 * apq)
      let t = if theta >= 0.0 {
        1.0 / (theta + calc.sqrt(1.0 + theta * theta))
      } else {
        1.0 / (theta - calc.sqrt(1.0 + theta * theta))
      }
      let c = 1.0 / calc.sqrt(1.0 + t * t)
      let s = t * c
      // Update A: rotate rows/columns p and q.
      let new-app = app - t * apq
      let new-aqq = aqq + t * apq
      a = mut-set(a, p, p, new-app)
      a = mut-set(a, q, q, new-aqq)
      a = mut-set(a, p, q, 0.0)
      a = mut-set(a, q, p, 0.0)
      for r in range(n) {
        if r != p and r != q {
          let arp = read(a, r, p)
          let arq = read(a, r, q)
          let new-arp = c * arp - s * arq
          let new-arq = s * arp + c * arq
          a = mut-set(a, r, p, new-arp)
          a = mut-set(a, p, r, new-arp)
          a = mut-set(a, r, q, new-arq)
          a = mut-set(a, q, r, new-arq)
        }
      }
      // Accumulate V (eigenvectors as columns).
      for r in range(n) {
        let vrp = read(v, r, p)
        let vrq = read(v, r, q)
        v = mut-set(v, r, p, c * vrp - s * vrq)
        v = mut-set(v, r, q, s * vrp + c * vrq)
      }
    }
  }
  let eigvals = (read(a, 0, 0), read(a, 1, 1), read(a, 2, 2))
  (eigvals, v)
}

// Plugin-backed `pca_orient`. The Rust port in plugin/src/renderer.rs
// uses the same Jacobi eigendecomposition algorithm as the Typst
// reference port below, plus a deterministic sign convention
// (largest-magnitude component of each principal axis non-negative)
// so output matches across Typst and Rust paths bit-exactly. One
// WASM round-trip per render — much cheaper than running the
// eigendecomp through Typst's interpreter on big molecules.
#let pca-orient(coords) = {
  let n = coords.len()
  if n < 2 { return coords }
  let positions = coords.map(p => (
    float(p.at(0)), float(p.at(1)), float(p.at(2)),
  ))
  let p = plugin("assets/xyzrender.wasm")
  let raw = p.pca_orient(cbor.encode((positions: positions)))
  cbor(raw)
}

// utils.py:60-127 — pure-Typst reference port (priority_pairs /
// fit_mask paths dropped). Kept as the 1:1 mirror of upstream
// `xyzrender/utils.py` (per the file-tree convention) and as a
// fallback in case the plugin path needs to be bypassed for
// debugging. Production callers should use `pca-orient` above.
#let pca-orient-typst(coords) = {
  let n = coords.len()
  if n < 2 { return coords }
  // Centroid.
  let cx = coords.map(p => float(p.at(0))).sum() / n
  let cy = coords.map(p => float(p.at(1))).sum() / n
  let cz = coords.map(p => float(p.at(2))).sum() / n
  let centred = coords.map(p => (
    float(p.at(0)) - cx,
    float(p.at(1)) - cy,
    float(p.at(2)) - cz,
  ))
  // Degenerate: all coincident.
  let max-norm = calc.max(..centred.map(p =>
    calc.max(calc.abs(p.at(0)), calc.abs(p.at(1)), calc.abs(p.at(2)))
  ))
  if max-norm < 0.000000000001 { return centred }
  // Diatomic special case (utils.py:86-95): align bond along x.
  if n == 2 {
    let ax-raw = (
      centred.at(1).at(0) - centred.at(0).at(0),
      centred.at(1).at(1) - centred.at(0).at(1),
      centred.at(1).at(2) - centred.at(0).at(2),
    )
    let mag = calc.sqrt(
      ax-raw.at(0) * ax-raw.at(0)
      + ax-raw.at(1) * ax-raw.at(1)
      + ax-raw.at(2) * ax-raw.at(2)
    )
    let ax = (ax-raw.at(0) / mag, ax-raw.at(1) / mag, ax-raw.at(2) / mag)
    // ref = standard basis vector along the smallest |ax| component
    // (np.eye(3)[argmin(|ax|)]).
    let abs-ax = (calc.abs(ax.at(0)), calc.abs(ax.at(1)), calc.abs(ax.at(2)))
    let i-min = if abs-ax.at(0) <= abs-ax.at(1) and abs-ax.at(0) <= abs-ax.at(2) { 0 }
                else if abs-ax.at(1) <= abs-ax.at(2) { 1 } else { 2 }
    let ref-vec = if i-min == 0 { (1.0, 0.0, 0.0) }
                  else if i-min == 1 { (0.0, 1.0, 0.0) }
                  else { (0.0, 0.0, 1.0) }
    // z = cross(ax, ref); normalize. y = cross(z, ax).
    let cross(a, b) = (
      a.at(1) * b.at(2) - a.at(2) * b.at(1),
      a.at(2) * b.at(0) - a.at(0) * b.at(2),
      a.at(0) * b.at(1) - a.at(1) * b.at(0),
    )
    let z-raw = cross(ax, ref-vec)
    let z-mag = calc.sqrt(
      z-raw.at(0) * z-raw.at(0)
      + z-raw.at(1) * z-raw.at(1)
      + z-raw.at(2) * z-raw.at(2)
    )
    let z = (z-raw.at(0) / z-mag, z-raw.at(1) / z-mag, z-raw.at(2) / z-mag)
    let y = cross(z, ax)
    // rot = [[ax], [y], [z]] (rows). oriented = centred @ rot.T.
    let rot = (ax, y, z)
    return centred.map(p => (
      rot.at(0).at(0) * p.at(0) + rot.at(0).at(1) * p.at(1) + rot.at(0).at(2) * p.at(2),
      rot.at(1).at(0) * p.at(0) + rot.at(1).at(1) * p.at(1) + rot.at(1).at(2) * p.at(2),
      rot.at(2).at(0) * p.at(0) + rot.at(2).at(1) * p.at(1) + rot.at(2).at(2) * p.at(2),
    ))
  }
  // General path (utils.py:106-111): SVD of centred coords. Equivalent
  // to eigendecomposing the 3x3 covariance C = c^T c. Eigenvectors of
  // C are the right singular vectors of c; eigenvalues are the
  // squared singular values, so the ordering matches.
  let c = (
    (0.0, 0.0, 0.0),
    (0.0, 0.0, 0.0),
    (0.0, 0.0, 0.0),
  )
  // accumulate outer-products
  let c00 = centred.map(p => p.at(0) * p.at(0)).sum()
  let c01 = centred.map(p => p.at(0) * p.at(1)).sum()
  let c02 = centred.map(p => p.at(0) * p.at(2)).sum()
  let c11 = centred.map(p => p.at(1) * p.at(1)).sum()
  let c12 = centred.map(p => p.at(1) * p.at(2)).sum()
  let c22 = centred.map(p => p.at(2) * p.at(2)).sum()
  let cov = (
    (c00, c01, c02),
    (c01, c11, c12),
    (c02, c12, c22),
  )
  let (eigvals, eigvecs) = _jacobi-eig-3(cov)
  // Sort eigvecs columns by descending eigenvalue.
  let order = (0, 1, 2).sorted(key: i => -eigvals.at(i))
  let col(m, j) = (m.at(0).at(j), m.at(1).at(j), m.at(2).at(j))
  let v-max = col(eigvecs, order.at(0))
  let v-mid = col(eigvecs, order.at(1))
  let v-min = col(eigvecs, order.at(2))
  // upstream uses Vt (rows = right singular vectors). Same layout: rot[0]=v-max, etc.
  let rot = (v-max, v-mid, v-min)
  // Ensure det(rot) = +1 (utils.py:108-109): if reflection, flip last row.
  let det = (
    rot.at(0).at(0) * (rot.at(1).at(1) * rot.at(2).at(2) - rot.at(1).at(2) * rot.at(2).at(1))
    - rot.at(0).at(1) * (rot.at(1).at(0) * rot.at(2).at(2) - rot.at(1).at(2) * rot.at(2).at(0))
    + rot.at(0).at(2) * (rot.at(1).at(0) * rot.at(2).at(1) - rot.at(1).at(1) * rot.at(2).at(0))
  )
  let rot = if det < 0.0 {
    (rot.at(0), rot.at(1), (-rot.at(2).at(0), -rot.at(2).at(1), -rot.at(2).at(2)))
  } else { rot }
  // oriented[i] = rot @ centred[i] (rows of rot project onto principal axes).
  centred.map(p => (
    rot.at(0).at(0) * p.at(0) + rot.at(0).at(1) * p.at(1) + rot.at(0).at(2) * p.at(2),
    rot.at(1).at(0) * p.at(0) + rot.at(1).at(1) * p.at(1) + rot.at(1).at(2) * p.at(2),
    rot.at(2).at(0) * p.at(0) + rot.at(2).at(1) * p.at(1) + rot.at(2).at(2) * p.at(2),
  ))
}

// ---- projection ----

// Orthographic 3D -> 2D in SVG pixel space (Y is flipped for SVG).
#let project(point, scale, center, canvas-w, canvas-h) = {
  let cx = canvas-w / 2.0 + scale * (point.at(0) - center.at(0))
  let cy = canvas-h / 2.0 - scale * (point.at(1) - center.at(1))
  (cx, cy)
}

// ---- reference scale constants (upstream renderer.py:54-56) ----
//
// `_REF_CANVAS` and `_REF_SPAN` define the reference geometry at
// which bond_width, atom_stroke_width, label_font_size are specified.
// `scale_ratio = current_scale / ref_scale` is used everywhere to
// keep bonds proportional across canvas sizes.
#let _REF_CANVAS = 800.0
#let _REF_SPAN = 6.0

#let ref-scale(config) = {
  let padding-px = float(config.at("padding", default: 10.0))
  (_REF_CANVAS - 2.0 * padding-px) / _REF_SPAN
}

// ---- canvas fitting ----
//
// Ported from upstream renderer.py `_fit_canvas` (verbatim when
// `tight_fit: false`; the default tight fit is a port-only divergence
// documented at `tight_fit` in types.typ):
//   ref_scale  = (_REF_CANVAS - 2*padding) / _REF_SPAN
//   fit_radii  = radii + atom_stroke_width / (2 * ref_scale)
//   _min_bond_r = (bond_width + 2*bond_outline_width) / (2 * ref_scale)
//   fit_radii  = max(fit_radii, _min_bond_r)
//   pad        = max(fit_radii)
//   lo         = pos[:, :2].min(axis=0) - pad
//   hi         = pos[:, :2].max(axis=0) + pad
//   max_span   = max((hi - lo).max(), 1e-6)
//   scale      = (canvas_size - 2*padding) / max_span

#let fit-canvas(coords, radii-ang, config) = {
  let canvas = float(config.at("canvas_size", default: 800))
  let padding-px = float(config.at("padding", default: 10.0))
  let stroke-w = float(config.at("atom_stroke_width", default: 1.5))
  let bond-w = float(config.at("bond_width", default: 5.0))
  let bond-ow = float(config.at("bond_outline_width", default: 0.0))

  if coords.len() == 0 {
    return (canvas, canvas, 1.0, (0.0, 0.0, 0.0))
  }

  let rs = ref-scale(config)
  let stroke-pad = stroke-w / (2.0 * rs)
  let min-bond-r = (bond-w + 2.0 * bond-ow) / (2.0 * rs)

  let fit-radii = radii-ang.map(r => calc.max(r + stroke-pad, min-bond-r))

  let xs = coords.map(p => float(p.at(0)))
  let ys = coords.map(p => float(p.at(1)))
  let zs = coords.map(p => float(p.at(2)))
  // Port-only `tight_fit` (see types.typ): per-atom extents give a box
  // tight to the ink. Upstream instead pads the center bbox by the
  // single largest radius on all four sides; keep that branch for
  // upstream-faithful fixture comparisons (`tight_fit: false`).
  let tight = config.at("tight_fit", default: true) == true
  let (xmin, xmax, ymin, ymax) = if tight {
    (
      calc.min(..range(coords.len()).map(i => xs.at(i) - fit-radii.at(i))),
      calc.max(..range(coords.len()).map(i => xs.at(i) + fit-radii.at(i))),
      calc.min(..range(coords.len()).map(i => ys.at(i) - fit-radii.at(i))),
      calc.max(..range(coords.len()).map(i => ys.at(i) + fit-radii.at(i))),
    )
  } else {
    let pad-ang = if fit-radii.len() == 0 { 0.0 } else { calc.max(..fit-radii) }
    (
      calc.min(..xs) - pad-ang,
      calc.max(..xs) + pad-ang,
      calc.min(..ys) - pad-ang,
      calc.max(..ys) + pad-ang,
    )
  }

  let cx = (xmin + xmax) / 2.0
  let cy = (ymin + ymax) / 2.0
  let cz = (calc.min(..zs) + calc.max(..zs)) / 2.0

  let x-span = xmax - xmin
  let y-span = ymax - ymin
  // Upstream `_fit_canvas` (renderer.py:1991-2002): when `fixed_span`
  // is set the molecule's own bounding box no longer drives the scale
  // — `max_span = fixed_span` is used instead, and the canvas locks to
  // square `canvas_size × canvas_size`. This is the knob users reach
  // for to get identical per-Å scale (and thus identical atom pixel
  // sizes) across different molecules. Without this branch every
  // render auto-fits to its own bounds and `fixed_span` is silently
  // ignored.
  let fixed-span-raw = config.at("fixed_span", default: none)
  let fixed-span = if fixed-span-raw == none or fixed-span-raw == auto {
    none
  } else {
    float(fixed-span-raw)
  }
  // Port-only absolute-scale mode (see types.typ `consistent_scale`):
  // instead of fitting the molecule's own span to the canvas, lock the
  // per-Å scale to the reference density so atoms/bonds are the same
  // physical size across molecules, and let the canvas grow with the
  // molecule. `fixed_span` (square GIF canvas) still takes precedence.
  let use-absolute = fixed-span == none and config.at("_use_absolute_scale", default: false)

  let scale = if fixed-span != none {
    (canvas - 2.0 * padding-px) / fixed-span
  } else if use-absolute {
    // Fixed per-Å scale anchored to `canvas_size` over a constant
    // reference span (`_REF_SPAN`), NOT to the molecule's own span. A
    // molecule ≈ `_REF_SPAN` Å wide fills `canvas_size` on its long
    // axis, exactly as auto-fit does for that size; every other molecule
    // shares the same scale (→ consistent atom sizes). Crucially this
    // keeps `canvas_size` as the zoom control: bigger `canvas_size` →
    // bigger scale → bigger atoms/canvas, same as the fill path.
    (canvas - 2.0 * padding-px) / _REF_SPAN
  } else {
    (canvas - 2.0 * padding-px) / calc.max(x-span, y-span, 0.000001)
  }

  // Upstream `_fit_canvas`:
  //   if cfg.fixed_span is not None:
  //       w = h = cfg.canvas_size            # GIF mode: square canvas
  //   else:
  //       w = int(x_span * scale + 2 * padding)
  //       h = int(y_span * scale + 2 * padding)
  // In absolute mode the same span-based canvas formula applies — the
  // only change is that `scale` no longer depends on the molecule, so a
  // bigger molecule yields a proportionally bigger canvas.
  let (w, h) = if fixed-span != none {
    (canvas, canvas)
  } else {
    (
      calc.round(x-span * scale + 2.0 * padding-px),
      calc.round(y-span * scale + 2.0 * padding-px),
    )
  }

  (w, h, scale, (cx, cy, cz))
}

// ---- string assembly ----

// Collect SVG fragments in an array and `join` once; Typst strings
// are immutable so `+=` in a loop is O(N^2).
#let join-svg(parts) = parts.join("")

// Format a float for SVG output to one decimal place — matches
// upstream's `f"{x:.1f}"` formatting (renderer.py:1007 etc.).
#let fnum(x) = {
  let r = calc.round(float(x) * 10.0) / 10.0
  str(r)
}
