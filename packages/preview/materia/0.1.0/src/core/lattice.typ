// Lattice parameters, vectors, and fractional-to-cartesian conversion.
// Per-crystal-system validation + completion; cetz-free (imports only linalg).
#import "@preview/scenery:0.1.0": vscale, vadd

#let _free-params = (
  triclinic: ("a", "b", "c", "alpha", "beta", "gamma"),
  monoclinic: ("a", "b", "c", "beta"),
  orthorhombic: ("a", "b", "c"),
  tetragonal: ("a", "c"),
  trigonal: ("a", "c"),
  hexagonal: ("a", "c"),
  cubic: ("a",),
  oblique: ("a", "b", "gamma"),
  rectangular: ("a", "b"),
  square: ("a",),
  hexagonal2d: ("a",),
)

#let _deg(x) = if type(x) == angle { x / 1deg } else { float(x) }

#let check-lattice-args(ltype, given) = {
  if ltype not in _free-params {
    return (ok: false, msg: "unknown lattice type '" + repr(ltype) + "'")
  }
  let free = _free-params.at(ltype)
  for k in given.keys() {
    if k not in free {
      return (ok: false, msg: "lattice parameter '" + k + "' is fixed by the " + ltype + " system; give only " + free.join(", "))
    }
  }
  for k in free {
    if k not in given or given.at(k) == none {
      return (ok: false, msg: "the " + ltype + " system requires lattice parameter '" + k + "'")
    }
  }
  (ok: true, msg: "")
}

#let lattice-params(ltype, given) = {
  let chk = check-lattice-args(ltype, given)
  assert(chk.ok, message: "materia: " + chk.msg)
  let g(k, d) = if k in given { _deg(given.at(k)) } else { d }
  let a = g("a", 1.0)
  let two-d = ltype in ("oblique", "rectangular", "square", "hexagonal2d")
  (
    a: a,
    b: g("b", a),
    c: if two-d { 1.0 } else { g("c", a) },
    alpha: g("alpha", 90.0),
    beta: g("beta", 90.0),
    gamma: g("gamma", if ltype in ("trigonal", "hexagonal", "hexagonal2d") { 120.0 } else { 90.0 }),
  )
}

#let lattice-vectors(p) = {
  let (ca, cb, cg) = (calc.cos(p.alpha * 1deg), calc.cos(p.beta * 1deg), calc.cos(p.gamma * 1deg))
  let sg = calc.sin(p.gamma * 1deg)
  let cx = p.c * cb
  let cy = p.c * (ca - cb * cg) / sg
  let cz = calc.sqrt(calc.max(p.c * p.c - cx * cx - cy * cy, 0.0))
  (
    (p.a, 0.0, 0.0),
    (p.b * cg, p.b * sg, 0.0),
    (cx, cy, cz),
  )
}

#let frac-to-cart(vecs, frac, periodic) = {
  let r = vadd(vscale(vecs.at(0), frac.at(0)), vscale(vecs.at(1), frac.at(1)))
  if periodic.at(2) {
    vadd(r, vscale(vecs.at(2), frac.at(2)))
  } else {
    (r.at(0), r.at(1), r.at(2) + frac.at(2))  // z already in angstrom
  }
}
