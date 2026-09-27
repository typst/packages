// Public structure() constructor: builds the structure value consumed by
// everything downstream. Validation lives in the pure check-site() helper.
#import "data.typ": group-data, element-info
#import "lattice.typ": lattice-params, lattice-vectors, frac-to-cart
#import "symmetry.typ": expand

/// Pure validator for a Wyckoff-input site against a group's data.
/// Returns (ok: bool, msg: str); never panics, so failure cases are testable.
#let check-site(group, site) = {
  if "element" not in site or "wyckoff" not in site {
    return (ok: false, msg: "each site needs (element: .., wyckoff: ..)")
  }
  if site.wyckoff not in group.wyckoff {
    return (ok: false, msg: "group " + group.symbol + " has no Wyckoff position '" + site.wyckoff
      + "' (available: " + group.wyckoff.keys().join(", ") + ")")
  }
  let w = group.wyckoff.at(site.wyckoff)
  let extra = site.keys().filter(k => k not in ("element", "wyckoff") and k not in w.vars)
  if extra.len() > 0 {
    return (ok: false, msg: "Wyckoff " + str(w.mult) + site.wyckoff + " of " + group.symbol
      + " does not have free coordinate(s) " + extra.join(", ")
      + if w.vars.len() > 0 { " (free: " + w.vars.join(", ") + ")" } else { " (no free coordinates)" })
  }
  let missing = w.vars.filter(v => v not in site)
  if missing.len() > 0 {
    return (ok: false, msg: "Wyckoff " + str(w.mult) + site.wyckoff + " of " + group.symbol
      + " requires free coordinate(s) " + missing.join(", "))
  }
  (ok: true, msg: "")
}

/// Build a structure value. Exactly one of spacegroup:, layergroup:, or an
/// explicit lattice: array (with atoms:) must be supplied.
#let structure(spacegroup: none, layergroup: none, lattice: (:), sites: (), atoms: (), bonds: none) = {
  let explicit = type(lattice) == array
  let molecule = (not explicit) and spacegroup == none and layergroup == none and atoms.len() > 0
  let n-modes = (int(spacegroup != none) + int(layergroup != none) + int(explicit) + int(molecule))
  assert(n-modes == 1, message: "materia: give exactly one of spacegroup:, layergroup:, an explicit lattice: array with atoms:, or atoms: alone (molecule mode)")

  // Precomputed bonds are a molecule-only optimization (the supercell caveat:
  // periodic bond indices would reference boundary/supercell images). They must
  // index the molecule's own atoms, as (i, j) int pairs with i < j.
  assert(bonds == none or molecule,
    message: "materia: bonds: is only accepted in molecule mode (atoms: alone)")

  if molecule {
    let ident = ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0))
    let alist = atoms.enumerate().map(((i, (el, cart))) => {
      let _ = element-info(el)  // validates the symbol
      assert(cart.len() == 3, message: "materia: molecule atom " + str(i) + " needs a Cartesian (x, y, z)")
      let c = cart.map(float)
      (element: el, frac: c, cart: c, site: i)
    })
    if bonds != none {
      for b in bonds {
        assert(b.len() == 2 and type(b.at(0)) == int and type(b.at(1)) == int,
          message: "materia: each bond must be an (i, j) integer pair")
        assert(0 <= b.at(0) and b.at(0) < b.at(1) and b.at(1) < alist.len(),
          message: "materia: bond index out of range or not i < j: " + repr(b))
      }
    }
    return (kind: "molecule", group: none, vectors: ident, periodic: (false, false, false), atoms: alist, bonds: bonds)
  }

  if explicit {
    assert(lattice.len() == 3 and atoms.len() > 0,
      message: "materia: explicit form needs lattice: (v1, v2, v3) and a non-empty atoms: list")
    for v in lattice {
      assert(v.len() == 3, message: "materia: each explicit lattice vector must have 3 components")
    }
    let vecs = lattice.map(v => v.map(float))
    let periodic = (true, true, true)
    let alist = atoms.enumerate().map(((i, (el, frac))) => {
      let _ = element-info(el)  // validates the symbol
      assert(frac.len() == 3, message: "materia: atom " + str(i) + " needs a fractional coordinate with 3 components")
      (element: el, frac: frac.map(float), cart: frac-to-cart(vecs, frac.map(float), periodic), site: i)
    })
    return (kind: "3d", group: none, vectors: vecs, periodic: periodic, atoms: alist)
  }

  let (kind, number) = if spacegroup != none { ("3d", spacegroup) } else { ("layer", layergroup) }
  let group = group-data(kind, number)
  let periodic = (true, true, kind == "3d")
  assert(sites.len() > 0, message: "materia: sites: must contain at least one site")
  for site in sites {
    let chk = check-site(group, site)
    assert(chk.ok, message: "materia: " + chk.msg)
  }
  let esites = sites.map(s => (
    element: s.element,
    wyckoff: s.wyckoff,
    p: ("x", "y", "z").map(v => if v in s { float(s.at(v)) } else { 0.0 }),
  ))
  for s in sites { let _ = element-info(s.element) }
  let params = lattice-params(group.ltype, lattice)
  let vecs = lattice-vectors(params)
  let alist = expand(group, esites, periodic).map(a =>
    (..a, cart: frac-to-cart(vecs, a.frac, periodic)))
  (kind: kind, group: (number: number, symbol: group.symbol), vectors: vecs, periodic: periodic, atoms: alist)
}
