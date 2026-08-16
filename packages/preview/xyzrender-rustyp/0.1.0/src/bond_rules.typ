// Mirrors upstream src/xyzrender/bond_rules.py.
//
// Upstream `apply_bond_rules` parses `cfg.unbond` / `cfg.bond` specs
// against a NetworkX graph and drops/adds edges on a render-time copy.
// The v1 Typst port supports the **index-pair subset only**:
//
//   cfg.unbond: ("1-3", "4-5")  — remove these covalent bonds
//   cfg.bond:   ("1-3",)        — add these covalent bonds
//
// Pair specs are subject to `index_base` (default 1, see types.typ) —
// a Typst-port-only knob with no upstream parallel, added so
// `bond`/`unbond`/`ts_bonds`/`nci_bonds`/`vdw_indices`/`hy` all read the
// same numbering, switchable document-wide via
// `xyzrender.with(index_base: 0)`.
//
// Selector grammar (`"M-L"`, `"hal"`, `"pi"`, standalone atom indices),
// the `all` / `*` sentinels, and pi / haptic centroid replacement are
// out of scope (PLAN.md:23-29) — they need the upstream selector
// resolver and aromatic-ring topology in a graph form the plugin
// doesn't expose. TS / NCI overlay edges aren't present in the bond
// list either, so the upstream "skip NCI/TS overlay edges" guard is a
// no-op here.
//
// Visual bond-order styling (single / double / triple parallel lines,
// width and gap) lives inline in renderer.typ where it mirrors
// renderer.py:1377-1390 verbatim.
//
// File kept for 1:1 parity with upstream src/xyzrender/.

#import "types.typ": defaults

// Parse a pair-spec string like "1-3" -> (0, 2). Returns `none` for
// anything that doesn't match upstream's `_INDEX_PAIR_RE`
// (`^([1-9]\d*)-([1-9]\d*)$`) generalized to also accept a bare "0" as
// a single-digit number — non-numeric specs (`M-L`, `hal`) and
// multi-digit leading zeros (`01-3`) are rejected either way. Self-loops
// (`3-3`) pass the parse and are caught by the caller.
//
// `index-base` is this project's document-wide indexing knob (default
// `1`, see types.typ), threaded through so `bond`/`unbond` read the
// same numbering as `vdw_indices`/`hy`/`ts_bonds`/`nci_bonds`: with the
// default `index-base: 1`, "1-3" means the first and third atoms;
// with `index-base: 0` bound via `xyzrender.with(index_base: 0)`, "0-2"
// means the same pair.
#let _parse-index-pair(spec, index-base: 1) = {
  let s = spec.trim()
  let parts = s.split("-")
  if parts.len() != 2 { return none }
  let lhs = parts.at(0)
  let rhs = parts.at(1)
  if lhs.len() == 0 or rhs.len() == 0 { return none }
  // Reject multi-digit leading zeros ("01"), but allow a bare "0" —
  // needed as a legitimate first-atom number once `index-base: 0`.
  if (lhs.len() > 1 and lhs.first() == "0") or (rhs.len() > 1 and rhs.first() == "0") { return none }
  for c in lhs.codepoints() {
    if not ("0" <= c and c <= "9") { return none }
  }
  for c in rhs.codepoints() {
    if not ("0" <= c and c <= "9") { return none }
  }
  (int(lhs) - index-base, int(rhs) - index-base)
}

#let _canonical(i, j) = if i < j { (i, j) } else { (j, i) }

// `bond:`/`unbond:` are typed as arrays of pair-spec strings
// (`array<str>`), so a single spec still has to be written as a
// one-element array in Typst — `("1-3",)`, not `("1-3")` (parens alone
// don't make an array; the trailing comma does). As a convenience
// (matching this project's own `vdw_indices` string-or-array
// convention, see renderer.typ), also accept a bare string directly:
// `unbond: "1-3"` is treated as `unbond: ("1-3",)`. Without this
// normalization a bare string would silently iterate character-by-
// character (`for spec in "1-3"` walks "1", "-", "3") instead of being
// treated as one pair spec.
#let _as-spec-list(x) = if type(x) == str { (x,) } else { x }

// Apply `cfg.bond` / `cfg.unbond` to a parsed-data dict.
//
// `data` is the dict returned by `process-xyz` (parsers.typ): three
// parallel arrays `bonds`, `bond_orders`, `aromatic_flags` plus
// `elements`, `coords`, `aromatic_rings`. We rebuild the parallel
// arrays so all three stay aligned (upstream mutates a single graph;
// here we filter & extend).
//
// Mirrors upstream apply_bond_rules (bond_rules.py:33-178), index-pair
// branches only. Returns the updated `data` dict.
#let apply-bond-rules(data, cfg) = {
  let unbond-specs = _as-spec-list(cfg.at("unbond", default: defaults.unbond))
  let bond-specs = _as-spec-list(cfg.at("bond", default: defaults.bond))
  if unbond-specs.len() == 0 and bond-specs.len() == 0 {
    return data
  }

  let index-base = int(cfg.at("index_base", default: defaults.index_base))
  let n = data.elements.len()
  let bonds = data.at("bonds", default: ())
  let orders = data.at("bond_orders", default: ())
  let aromatic = data.at("aromatic_flags", default: ())

  // -- Parse and validate `bond` additions upfront -----------------------
  // Upstream bond_rules.py:151-162 raises before any mutation.
  let add-canonical = (:)  // canonical "i,j" -> (i, j)
  for spec in bond-specs {
    let pair = _parse-index-pair(spec, index-base: index-base)
    if pair == none {
      panic("xyzrender: --bond only accepts pairs like \"1-3\" (index_base: " + str(index-base) + "), got " + spec)
    }
    let (i, j) = pair
    if i == j {
      panic("xyzrender: --bond " + str(i + index-base) + "-" + str(j + index-base) + ": cannot bond an atom to itself")
    }
    if i < 0 or i >= n or j < 0 or j >= n {
      panic("xyzrender: --bond " + str(i + index-base) + "-" + str(j + index-base)
        + ": atom index out of range (molecule has " + str(n) + " atoms)")
    }
    let (ci, cj) = _canonical(i, j)
    add-canonical.insert(str(ci) + "," + str(cj), (ci, cj))
  }

  // -- Collect `unbond` removals -----------------------------------------
  let remove-canonical = (:)
  for spec in unbond-specs {
    let pair = _parse-index-pair(spec, index-base: index-base)
    if pair == none {
      panic("xyzrender: v1 --unbond only accepts pairs like \"1-3\" (index_base: " + str(index-base) + "; selector grammar like \"M-L\" / \"hal\" / \"all\" is not yet ported), got " + spec)
    }
    let (i, j) = pair
    if i == j {
      // Upstream warns and skips; we panic since v1 has no logger.
      continue
    }
    if i < 0 or i >= n or j < 0 or j >= n {
      continue
    }
    let (ci, cj) = _canonical(i, j)
    remove-canonical.insert(str(ci) + "," + str(cj), (ci, cj))
  }

  // -- Subtract overrides (upstream bond_rules.py:165-167) ---------------
  // `bond` pairs override `unbond`: keep them in the graph.
  for key in add-canonical.keys() {
    if key in remove-canonical {
      let _ = remove-canonical.remove(key)
    }
  }

  // -- Apply removals: filter the three parallel arrays in lockstep -----
  let kept-bonds = ()
  let kept-orders = ()
  let kept-aromatic = ()
  let present = (:)  // canonical "i,j" -> true, for "already exists" checks
  for k in range(bonds.len()) {
    let pair = bonds.at(k)
    let i = int(pair.at(0))
    let j = int(pair.at(1))
    let (ci, cj) = _canonical(i, j)
    let key = str(ci) + "," + str(cj)
    if key in remove-canonical { continue }
    kept-bonds.push(pair)
    if k < orders.len() { kept-orders.push(orders.at(k)) } else { kept-orders.push(1) }
    if k < aromatic.len() { kept-aromatic.push(aromatic.at(k)) } else { kept-aromatic.push(false) }
    present.insert(key, true)
  }

  // -- Apply additions: append (only if not already present) ------------
  for (key, pair) in add-canonical {
    if key in present { continue }
    kept-bonds.push((pair.at(0), pair.at(1)))
    kept-orders.push(1)
    kept-aromatic.push(false)
    present.insert(key, true)
  }

  data + (
    bonds: kept-bonds,
    bond_orders: kept-orders,
    aromatic_flags: kept-aromatic,
  )
}
