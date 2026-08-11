#import "@preview/scenery:0.1.0": mvec, vadd

#let _wrap(x) = calc.rem(calc.rem(x, 1.0) + 1.0, 1.0)

#let _close(p, q, periodic, eps) = {
  range(3).all(i => {
    let d = calc.abs(p.at(i) - q.at(i))
    let d = if periodic.at(i) { calc.min(d, 1.0 - d) } else { d }
    d < eps
  })
}

/// Expand Wyckoff sites into the full cell.
/// group: dict from data.group-data; sites: ((element, wyckoff, p), ..);
/// periodic: (bool, bool, bool). Returns ((element, frac, site), ..).
#let expand(group, sites, periodic, eps: 1e-4) = {
  let atoms = ()
  for (si, site) in sites.enumerate() {
    assert(
      site.wyckoff in group.wyckoff,
      message: "materia: group " + group.symbol + " has no Wyckoff position '" + site.wyckoff
        + "' (available: " + group.wyckoff.keys().join(", ") + ")",
    )
    let w = group.wyckoff.at(site.wyckoff)
    let rep = vadd(mvec(w.m, site.p), w.t)
    let orbit = ()
    for op in group.ops {
      let q = vadd(mvec(op.at(0), rep), op.at(1))
      let q = range(3).map(i => if periodic.at(i) { _wrap(q.at(i)) } else { q.at(i) })
      if not orbit.any(o => _close(o, q, periodic, eps)) {
        orbit.push(q)
      }
    }
    assert(
      orbit.len() == w.mult,
      message: "materia: site " + str(si) + " (" + site.element + " at " + site.wyckoff + " of "
        + group.symbol + ") expanded to " + str(orbit.len()) + " atoms, expected " + str(w.mult)
        + ". A free coordinate may coincide with a more special position.",
    )
    for q in orbit {
      atoms.push((element: site.element, frac: q, site: si))
    }
  }
  atoms
}

/// Expand explicit asymmetric-unit atoms through a group's operations,
/// treating each as a general position: q = op.0 · frac + op.1 per op,
/// wrapped on periodic dims and deduplicated per-atom-orbit. Used by the CIF
/// spacegroup-identifier import path, where atoms arrive as raw fractional
/// coordinates rather than Wyckoff letters. Unlike expand(), there is no
/// multiplicity assertion: an atom on a special position yields a smaller
/// orbit, which is correct here.
/// asym: ((element, (fx, fy, fz)), ..). Returns ((element, frac, site), ..).
#let expand-general(group, asym, periodic, eps: 1e-4) = {
  let atoms = ()
  for (si, (el, p)) in asym.enumerate() {
    let orbit = ()
    for op in group.ops {
      let q = vadd(mvec(op.at(0), p), op.at(1))
      let q = range(3).map(i => if periodic.at(i) { _wrap(q.at(i)) } else { q.at(i) })
      if not orbit.any(o => _close(o, q, periodic, eps)) {
        orbit.push(q)
      }
    }
    for q in orbit {
      atoms.push((element: el, frac: q, site: si))
    }
  }
  atoms
}
