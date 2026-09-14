// Mirrors upstream src/xyzrender/selectors.py.
//
// Element-category resolver for atom selection. A mini-language used
// by region_specs (and, upstream, by `--scale`, highlights, etc.).
// Accepts comma-separated tokens where each token is one of:
//
//   * a category ("M", "L", "het", "hal", "pnic", "chal", "noble",
//     "triel", "tetrel", "sbm")
//   * an element symbol ("Fe", "O", "Cl")
//   * a 1-indexed numeric or range ("1", "3-7")
//   * the literal "all" or "*"
//
// IMPORTANT: METALS / SBLOCK_METALS MUST stay in sync with
// `plugin/src/data_loader.rs` (the Rust translation of upstream
// xyzgraph's `data_loader.py`). When upstream adds an element to
// either set, update both files. We duplicate here because the
// plugin's data is compiled into the WASM and not exposed across
// the boundary.

// data_loader.py:110-121 → SBLOCK_METALS in data_loader.rs:23-25.
#let _SBLOCK_METALS = (
  "Li", "Be", "Na", "Mg", "K", "Ca", "Rb", "Sr", "Cs", "Ba",
)

// data_loader.py:124-183 → METALS in data_loader.rs:29-41.
#let _METALS = (
  // s-block
  "Li", "Be", "Na", "Mg", "K", "Ca", "Rb", "Sr", "Cs", "Ba",
  // d-block subset
  "Zn", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Y", "Zr", "Nb",
  "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "Hf", "Ta", "W", "Re", "Os", "Ir",
  "Pt", "Au", "Hg",
  // p-block metals treated as metals
  "Al", "Ga", "In", "Sn", "Pb",
  // f-block (lanthanides)
  "La", "Ce", "Pr", "Nd", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb",
  "Lu",
)

// All known element symbols (subset matching plugin's atom_symbols.json).
// Used to validate user-supplied element tokens. v1 ships a generous
// subset — periods 1-6 main group + common metals. Add elements as
// needed; the renderer falls back gracefully on unknown symbols.
#let _ALL_SYMBOLS = (
  "H", "He",
  "Li", "Be", "B", "C", "N", "O", "F", "Ne",
  "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar",
  "K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn",
  "Ga", "Ge", "As", "Se", "Br", "Kr",
  "Rb", "Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd",
  "In", "Sn", "Sb", "Te", "I", "Xe",
  "Cs", "Ba",
  "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu",
  "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg",
  "Tl", "Pb", "Bi", "Po", "At", "Rn",
)

// selectors.py:25-39 — static element-set categories.
#let _STATIC_CATEGORIES = (
  "M": _METALS,
  "sbm": _SBLOCK_METALS,
  // L = "ligand" / non-metal; het = ligand-heteroatom (not C, H, metal).
  // Static element-set fallback when the molecule has no metals
  // (see chemistry-aware narrowing below).
  "L": _ALL_SYMBOLS.filter(s => _METALS.position(m => m == s) == none),
  "het": _ALL_SYMBOLS.filter(s =>
    _METALS.position(m => m == s) == none and s != "C" and s != "H"
  ),
  "hal":    ("F", "Cl", "Br", "I", "At"),
  "pnic":   ("N", "P", "As", "Sb", "Bi"),
  "chal":   ("O", "S", "Se", "Te", "Po"),
  "noble":  ("He", "Ne", "Ar", "Kr", "Xe", "Rn"),
  "triel":  ("B", "Al", "Ga", "In", "Tl"),
  "tetrel": ("C", "Si", "Ge", "Sn", "Pb"),
)

// Single-character digit test. Typst's expression continuation rules
// across newlines are subtle even inside `{}` (a leading `or` after a
// newline can trip the parser), so the chain is kept on one line.
#let _is-digit(c) = c == "0" or c == "1" or c == "2" or c == "3" or c == "4" or c == "5" or c == "6" or c == "7" or c == "8" or c == "9"

#let _all-digits(s) = s.len() > 0 and range(s.len()).all(i => _is-digit(s.at(i)))

// Match "N" or "N-M" (with optional whitespace around the hyphen, e.g.
// "31 - 38") with N, M = positive integers.
#let _is-numeric-range(s) = {
  let t = s.trim()
  if t.contains("-") {
    let parts = t.split("-")
    parts.len() == 2 and _all-digits(parts.at(0).trim()) and _all-digits(parts.at(1).trim())
  } else {
    _all-digits(t)
  }
}

// selectors.py:47-68 — normalize a token (lowercase category match,
// title-case element match). Returns `none` for unknown tokens
// instead of raising — the caller decides whether to ignore or
// surface the error.
#let normalize-token(token) = {
  let low = lower(token)
  // Category match (case-insensitive)
  for cat-key in _STATIC_CATEGORIES.keys() {
    if low == lower(cat-key) { return cat-key }
  }
  // Element symbol (title-case the token)
  let title = if token.len() == 0 {
    ""
  } else if token.len() == 1 {
    upper(token)
  } else {
    upper(token.at(0)) + lower(token.slice(1))
  }
  if _ALL_SYMBOLS.position(s => s == title) != none {
    return title
  }
  none
}

// selectors.py:71-111 — resolve a normalised token to an element set.
// Returns an array of element symbols, or `none` for invalid tokens.
#let resolve-element-set(token) = {
  if token in _STATIC_CATEGORIES {
    _STATIC_CATEGORIES.at(token)
  } else if _ALL_SYMBOLS.position(s => s == token) != none {
    (token,)
  } else {
    none
  }
}

// selectors.py:114-181 — resolve a spec string to a set of 0-indexed
// atom indices. `elements` is the per-atom symbol array; `bonds` is
// the bond pair list (used by the L/het chemistry-aware narrowing
// to find ligand atoms bonded to a metal). Returns a sorted list of
// distinct indices.
//
// `index-base` controls the numeric-range path: upstream is 1-indexed
// (subtract 1 to convert), so `index-base: 1` is the default and
// matches selectors.py:164. `index-base: 0` means the user wrote raw
// 0-indexed numbers and no shift is applied.
#let resolve-atom-indices(spec, elements, bonds: (), index-base: 1) = {
  // Comma-separated multi-spec: split, resolve each, union (selectors.py:146-152).
  if spec.contains(",") {
    let result = ()
    for part in spec.split(",") {
      let stripped = part.trim()
      if stripped.len() > 0 {
        for i in resolve-atom-indices(stripped, elements, bonds: bonds, index-base: index-base) {
          if result.position(j => j == i) == none {
            result.push(i)
          }
        }
      }
    }
    return result.sorted()
  }
  let stripped = spec.trim()
  // "all" / "*" — every atom (selectors.py:155-156). NCI centroid
  // dummy atoms ("*" symbol) are excluded.
  if stripped == "all" or stripped == "*" {
    return range(elements.len()).filter(i => elements.at(i) != "*")
  }
  // Numeric range (selectors.py:160-169). With index-base=1 (upstream
  // default) "1-5" → atoms 0..4. With index-base=0, "1-5" → atoms 1..5
  // (no shift). Whitespace around the hyphen is tolerated so users can
  // write "31 - 38".
  if _is-numeric-range(stripped) {
    if stripped.contains("-") {
      let parts = stripped.split("-")
      let a = int(parts.at(0).trim())
      let b = int(parts.at(1).trim())
      return range(a - index-base, b - index-base + 1).filter(i => 0 <= i and i < elements.len())
    } else {
      let i = int(stripped) - index-base
      if 0 <= i and i < elements.len() { return (i,) }
      return ()
    }
  }
  // Category / element (selectors.py:170-181).
  let norm = normalize-token(stripped)
  if norm == none { return () }
  let symbols = resolve-element-set(norm)
  if symbols == none { return () }
  let matched = range(elements.len()).filter(i => {
    symbols.position(s => s == elements.at(i)) != none
  })
  // Chemistry-aware narrowing for L / het (selectors.py:177-181):
  // when the graph has metals, narrow to atoms bonded to a metal
  // (the chemistry meaning of "ligand" / "ligand-heteroatom").
  if norm == "L" or norm == "het" {
    let metal-indices = range(elements.len()).filter(i => {
      _METALS.position(m => m == elements.at(i)) != none
    })
    if metal-indices.len() > 0 {
      // adj[ai] = array of bonded atom indices
      let adj = range(elements.len()).map(_ => ())
      for pair in bonds {
        let p = int(pair.at(0))
        let q = int(pair.at(1))
        adj.at(p).push(q)
        adj.at(q).push(p)
      }
      let metal-set = range(elements.len()).map(_ => false)
      for i in metal-indices { metal-set.at(i) = true }
      matched = matched.filter(ai => {
        adj.at(ai).position(nb => metal-set.at(nb)) != none
      })
    }
  }
  matched
}
