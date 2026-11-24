// Derivation resolver: order-free (fixpoint), no string aliases, no descriptor language.
// A derivation is a plain Typst function `t => value` over the resolved tokens.
//
// Soundness (concept §4.3):
//  - round 0 is seeded with the RESOLVED DEFAULT tree, so a derivation never sees a
//    zero/empty placeholder (no "cannot divide by zero", no "string is empty");
//  - the round cap is (number of derivations + 1), which every acyclic chain meets;
//  - the fixpoint runs twice, from two different seeds. An acyclic graph reaches the
//    same values from any seed; a cycle keeps a seed-dependent value. Different
//    results (or no settling) = a cycle, reported with the leaves involved.

#import "schema.typ": is-array-of

#let _admits-fn(types) = type(types) == array and function in types
#let _is-deriv(v, types) = type(v) == function and not _admits-fn(types)

#let _eval-leaf(v, types, t) = {
  if _is-deriv(v, types) { v(t) } else if type(v) == array {
    v.map(x => if type(x) == function { x(t) } else { x })
  } else { v }
}

/// Maps f(spec-leaf, types, seed-leaf) over the spec tree (seed may be none).
#let _map(spec, types, seed, f) = {
  if type(spec) != dictionary or type(types) != dictionary {
    return f(spec, types, seed)
  }
  let out = (:)
  for (k, v) in spec {
    out.insert(k, _map(
      v,
      types.at(k, default: ()),
      if type(seed) == dictionary { seed.at(k, default: none) } else { none },
      f,
    ))
  }
  out
}

#let _count(spec, types) = {
  if type(spec) != dictionary or type(types) != dictionary {
    return if _is-deriv(spec, types) { 1 } else if type(spec) == array {
      spec.filter(x => type(x) == function).len()
    } else { 0 }
  }
  spec
    .pairs()
    .map(((k, v)) => _count(v, types.at(k, default: ())))
    .sum(default: 0)
}

#let _placeholder(types) = {
  let t = if type(types) == array { types.at(0, default: none) } else { none }
  if t == color { black } else if t == length { 10pt } else if t == str {
    "x"
  } else if t == array { ("x",) } else if (
    t == bool
  ) { false } else if t == ratio { 50% } else if t == int { 1 } else if (
    type(t) == type
  ) { none } else { t }
}

/// A second, different but equally harmless value (for the two-seed cycle test).
#let _perturb(v) = {
  if type(v) == color { v.negate() } else if type(v) == length {
    v * 1.5 + 0.5pt
  } else if type(v) == str {
    v + "\u{2060}"
  } else if type(v) == array { v + ("\u{2060}",) } else if type(v) == int {
    v + 1
  } else if type(v) == bool {
    not v
  } else if type(v) == ratio { v + 1% } else if type(v) == relative {
    v + 1pt
  } else { v }
}

#let _paths-differing(a, b, path) = {
  if type(a) == dictionary and type(b) == dictionary {
    a
      .keys()
      .map(k => _paths-differing(a.at(k), b.at(k, default: none), path + (k,)))
      .flatten()
  } else if a != b { (path.join("::"),) } else { () }
}

#let _run(spec, types, seed, cap) = {
  let t = _map(spec, types, seed, (v, ty, s) => if _is-deriv(v, ty) {
    s
  } else if type(v) == array {
    v
      .enumerate()
      .map(((i, x)) => if type(x) == function {
        if type(s) == array { s.at(i, default: none) } else { none }
      } else { x })
  } else { v })
  for round in range(cap + 1) {
    let next = _map(spec, types, none, (v, ty, _) => _eval-leaf(v, ty, t))
    if next == t { return (t, true) }
    t = next
  }
  (t, false)
}

/// The resolved schema defaults (the safe seed). Pure, memoised by Typst.
#let resolved-defaults(defaults, types) = {
  let seed = _map(defaults, types, none, (v, ty, _) => if _is-deriv(v, ty) {
    _placeholder(ty)
  } else { v })
  let (t, ok) = _run(defaults, types, seed, _count(defaults, types) + 1)
  // seeds are absolute (1em = 10pt), so seed values mix freely with absolute lengths
  _map(t, types, none, (v, ty, _) => if type(v) == length and v.em != 0 {
    v.abs + v.em * 10pt
  } else { v })
}

/// Resolves the token spec. Any evaluation order works; cycles panic with the leaves.
/// -> dictionary
#let resolve-tokens(spec, types, defaults) = {
  let n = _count(spec, types)
  if n == 0 { return spec }
  let seed-a = resolved-defaults(defaults, types)
  let seed-b = _map(seed-a, types, none, (v, ty, _) => if type(v) == array {
    v.map(_perturb)
  } else { _perturb(v) })
  let (a, ok-a) = _run(spec, types, seed-a, n)
  let (b, ok-b) = _run(spec, types, seed-b, n)
  if not ok-a or not ok-b or a != b {
    let leaves = _paths-differing(a, b, ())
    panic(
      "theme::tokens: derivations form a cycle ("
        + leaves.join(", ")
        + "); every chain of `t => ..` must end in a literal value",
    )
  }
  a
}

/// Resolves option derivations once against the resolved tokens. `options.custom`
/// is an open map and is passed through uninterpreted.
/// `items-table.header-style` is an open set-text map whose VALUES may be derivations.
#let resolve-options(spec, types, t) = {
  let o = _map(spec, types, none, (v, ty, _) => _eval-leaf(v, ty, t))
  let hs = o.at("items-table", default: (:)).at("header-style", default: none)
  if type(hs) == dictionary {
    o.items-table.header-style = hs
      .pairs()
      .map(((k, v)) => (k, if type(v) == function { v(t) } else { v }))
      .to-dict()
  }
  o
}

/// Area fields that accept derivations (schema: area-derivable).
#let resolve-area(r, t, derivable) = {
  if r == none { return none }
  let r = r
  for k in derivable {
    let v = r.at(k, default: none)
    // text, par and rule are records: each value may be a derivation (rule also as a whole)
    let v = if k == "rule" and type(v) == function { v(t) } else { v }
    if k in ("text", "par", "rule") and type(v) == dictionary {
      r.insert(
        k,
        v
          .pairs()
          .map(((a, b)) => (a, if type(b) == function { b(t) } else { b }))
          .to-dict(),
      )
    } else if type(v) == function { r.insert(k, v(t)) }
  }
  r
}

// --- leaf type validation --------------------------------------------------------

#let _show-type(ty) = if is-array-of(ty) {
  (
    "array of "
      + ty
        .at("__array-of__")
        .map(x => if type(x) == type { str(x) } else { repr(x) })
        .join(" | ")
  )
} else if type(ty) == type { str(ty) } else { repr(ty) }

#let _matches(v, types, skip-fns) = {
  for ty in types {
    if is-array-of(ty) {
      if (
        type(v) == array
          and v.all(x => (
            (skip-fns and type(x) == function)
              or _matches(x, ty.at("__array-of__"), false)
          ))
      ) {
        return true
      }
    } else if type(ty) == type {
      if type(v) == ty { return true }
      if ty == ratio and type(v) == relative { return true }
      if ty == relative and type(v) in (ratio, length) { return true }
      if ty == stroke and type(v) in (length, color) { return true }
    } else if v == ty { return true }
  }
  false
}

/// Per-leaf type check with a `::` path (the loom matcher only returns a bool).
/// With `skip-fns`, derivations still pending are skipped (literal leaves first).
#let check-types(value, types, path, skip-fns: false, derivable: true) = {
  if type(types) == dictionary {
    for (k, ty) in types {
      if type(value) == dictionary and k in value {
        check-types(
          value.at(k),
          ty,
          path + (k,),
          skip-fns: skip-fns,
          derivable: derivable,
        )
      }
    }
  } else if types.len() > 0 {
    let v = value
    if skip-fns and _is-deriv(v, types) { return }
    if not _matches(v, types, skip-fns) {
      panic(
        "variable `"
          + path.join("::")
          + "`("
          + repr(v)
          + ") must be of "
          + types.map(_show-type).join(" | ")
          + if derivable and not _admits-fn(types) {
            " (or a derivation `t => ..`)"
          } else { "" },
      )
    }
  }
}
