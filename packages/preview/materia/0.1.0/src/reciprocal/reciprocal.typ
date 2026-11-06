// Reciprocal lattice vectors from direct lattice vectors or crystal-system
// parameters. Everything downstream (Brillouin zones, k-paths) is built from
// the three reciprocal vectors this module returns.
//
// Pure functions on scenery's linalg — cetz-free.
#import "@preview/scenery:0.1.0": vcross, vdot, vscale

// --- params -> direct vectors -------------------------------------------------
//
// This mirrors materia's params->vectors convention so reciprocal vectors stay
// consistent with a materia structure's `vectors` field. The basis orientation is:
//   a1 = (a, 0, 0)                          (a along x)
//   a2 = (b cosγ, b sinγ, 0)                (b in the xy-plane)
//   a3 = (c cosβ, c (cosα - cosβ cosγ)/sinγ, c z)
// If the real-space convention changes, this block must be updated in lockstep;
// the fixture tests feed the same params to both conventions to catch drift.

#let _deg(x) = if type(x) == angle { x / 1deg } else { float(x) }

// Fill a params dict to the six lattice constants (a, b, c in Å; angles in deg),
// mirroring lattice-params defaults: b and c default to a, angles to 90.
#let _fill-params(p) = {
  let a = _deg(p.at("a"))
  (
    a: a,
    b: if "b" in p { _deg(p.at("b")) } else { a },
    c: if "c" in p { _deg(p.at("c")) } else { a },
    alpha: if "alpha" in p { _deg(p.at("alpha")) } else { 90.0 },
    beta: if "beta" in p { _deg(p.at("beta")) } else { 90.0 },
    gamma: if "gamma" in p { _deg(p.at("gamma")) } else { 90.0 },
  )
}

/// Converts conventional-cell parameters to three direct lattice vectors.
///
/// Missing `b`/`c` lengths default to `a`; missing `alpha`/`beta`/`gamma`
/// angles default to 90 degrees. The orientation matches materia real space.
///
/// - p (dictionary): Lattice parameters in Å and angles or degree values.
/// -> array
#let params-to-vectors(p) = {
  let q = _fill-params(p)
  let (ca, cb, cg) = (calc.cos(q.alpha * 1deg), calc.cos(q.beta * 1deg), calc.cos(q.gamma * 1deg))
  let sg = calc.sin(q.gamma * 1deg)
  let cx = q.c * cb
  let cy = q.c * (ca - cb * cg) / sg
  let cz = calc.sqrt(calc.max(q.c * q.c - cx * cx - cy * cy, 0.0))
  (
    (q.a, 0.0, 0.0),
    (q.b * cg, q.b * sg, 0.0),
    (cx, cy, cz),
  )
}

// Is `direct` an array of three 3-vectors (as opposed to a params dict)?
#let _is-vectors(direct) = {
  type(direct) == array and direct.len() == 3 and direct.all(v => type(v) == array and v.len() == 3)
}

/// Reciprocal lattice vectors (2π convention) from a direct lattice.
///
/// - direct (array, dictionary): either three direct lattice vectors — an array
///   of three 3-vectors in Å — a materia structure with a `vectors` field, or a
///   crystal-system parameter dict with keys
///   `a`, `b`, `c` (Å) and `alpha`, `beta`, `gamma` (angles or degrees). Missing
///   lengths default to `a`; missing angles default to 90°.
/// -> array
/// Returns `(b1, b2, b3)`, the three reciprocal vectors in Å⁻¹, with
/// b_i = 2π (a_j × a_k) / (a_1 · (a_2 × a_3)) (cyclic).
#let reciprocal-vectors(direct) = {
  let (a1, a2, a3) = if _is-vectors(direct) { direct }
    else if type(direct) == dictionary and "vectors" in direct { direct.vectors }
    else { params-to-vectors(direct) }
  let vol = vdot(a1, vcross(a2, a3))
  let f = 2.0 * calc.pi / vol
  (
    vscale(vcross(a2, a3), f),
    vscale(vcross(a3, a1), f),
    vscale(vcross(a1, a2), f),
  )
}
