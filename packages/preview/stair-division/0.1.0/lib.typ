// =============================================================================
//  ruffini · Synthetic division (Ruffini's rule) tableaux for Typst
//
//  Two public functions:
//    · ruffini(coefficients, root)          — one division P(x) ÷ (x - a),
//        rendered as the classic THREE-row tableau (coefficients · products ·
//        results), remainder boxed, with an optional "quotient / remainder" line.
//    · ruffini-factor(coefficients, roots)  — the stacked tableau that applies
//        several roots in turn (each quotient feeds the next division), with an
//        optional factorization line.
//
//  Unlike a sign/variation table, this actually COMPUTES: you pass the
//  coefficients and the root, and it does the arithmetic AND draws it. All
//  arithmetic is EXACT (rational). Ordinary fractions work as bare numbers
//  (`1/3` is recovered exactly); unusual ones (large denominators) must be passed
//  as strings like "7/99991" — a bare one then errors instead of guessing wrong.
//
//  No dependencies (native `table`). Public API in English; the few rendered
//  words are localizable via `lang` ("en" default, "es"). The polynomial's
//  variable is `x` by default; change it with `variable`.
//
//  Divisor convention: `root` is the number `a` in the divisor `(x - a)`.
//  To divide by (x + 3), pass `root: -3`.
// =============================================================================

#let _blue = rgb("#2e5fa3")

// ---- exact rational numbers: (num, den), den > 0, always reduced ------------

#let _gcd(a, b) = {
  a = calc.abs(a); b = calc.abs(b)
  while b != 0 { let t = calc.rem(a, b); a = b; b = t }
  if a == 0 { 1 } else { a }
}

#let _mkfrac(n, d) = {
  assert(d != 0, message: "ruffini: zero denominator")
  if d < 0 { n = -n; d = -d }
  let g = _gcd(n, d)
  (calc.quo(n, g), calc.quo(d, g))
}

// Recover the simplest fraction behind a float via continued fractions, so a
// value written as a bare number (e.g. `1/3`, which Typst evaluates to a float
// 0.333…) is turned back into the exact fraction. Bounded denominator: if the
// value needs a bigger one (an unusual fraction), it errors and asks for the
// string form — it never silently returns a wrong fraction.
#let _float-to-frac(x) = {
  let maxden = 10000
  let tol = 1e-9
  let neg = x < 0
  let a = calc.abs(x)
  if calc.abs(a - calc.round(a)) < tol { return ((if neg { -1 } else { 1 }) * calc.round(a), 1) }
  let h1 = 1; let h2 = 0 // numerators   h_{i-1}, h_{i-2}
  let k1 = 0; let k2 = 1 // denominators k_{i-1}, k_{i-2}
  let b = a
  let bn = 0; let bd = 1; let ok = false
  let iter = 0
  while iter < 40 {
    iter += 1
    let ai = calc.floor(b)
    let h0 = ai * h1 + h2
    let k0 = ai * k1 + k2
    if k0 > maxden { break }
    bn = h0; bd = k0
    if calc.abs(h0 / k0 - a) < tol { ok = true; break }
    let fr = b - ai
    if fr < 1e-12 { ok = true; break }
    b = 1 / fr
    h2 = h1; h1 = h0
    k2 = k1; k1 = k0
  }
  if not ok and calc.abs(bn / bd - a) >= tol {
    panic("ruffini: cannot represent " + repr(x) + " as a simple fraction — pass it as a string, e.g. \"1/3\".")
  }
  _mkfrac((if neg { -1 } else { 1 }) * bn, bd)
}

// Coerce an input value to a reduced fraction. Accepts:
//   · int              → exact
//   · "a/b" or "a" str → exact (ALWAYS use this for unusual fractions like "3/7")
//   · float            → recovered exactly for simple fractions; errors (asking
//                        for the string form) if it would need a large denominator
#let _tofrac(v) = {
  let t = type(v)
  if t == int { (v, 1) } else if t == float { _float-to-frac(v) } else if t == str {
    let s = v.replace(" ", "")
    if "/" in s { let p = s.split("/"); _mkfrac(int(p.at(0)), int(p.at(1))) } else { (int(s), 1) }
  } else { panic("ruffini: unsupported number " + repr(v)) }
}

#let _fadd(x, y) = _mkfrac(x.at(0) * y.at(1) + y.at(0) * x.at(1), x.at(1) * y.at(1))
#let _fmul(x, y) = _mkfrac(x.at(0) * y.at(0), x.at(1) * y.at(1))
#let _fzero(f) = f.at(0) == 0
#let _fone(f) = f.at(0) == 1 and f.at(1) == 1

// A fraction's MAGNITUDE as a math string fragment: "3" or "frac(1, 2)".
#let _fabs-str(f) = {
  let n = calc.abs(f.at(0))
  if f.at(1) == 1 { str(n) } else { "frac(" + str(n) + ", " + str(f.at(1)) + ")" }
}

// A signed fraction as math content.
#let _fnum(f) = eval((if f.at(0) < 0 { "-" } else { "" }) + _fabs-str(f), mode: "math")

// A polynomial (fraction coefficients, highest degree first) as math content.
// Powers are always braced (`x^(10)`) so degrees ≥ 10 render correctly.
#let _poly(coeffs, var: "x") = {
  let deg = coeffs.len() - 1
  let terms = ()
  for (i, c) in coeffs.enumerate() {
    if _fzero(c) { continue }
    let p = deg - i
    let mag = (calc.abs(c.at(0)), c.at(1))
    let is-one = mag.at(0) == 1 and mag.at(1) == 1
    let coef = if p == 0 { _fabs-str(mag) } else if is-one { "" } else { _fabs-str(mag) }
    let power = if p == 0 { "" } else if p == 1 { var } else { var + "^(" + str(p) + ")" }
    terms.push((neg: c.at(0) < 0, body: coef + power))
  }
  if terms.len() == 0 { return $0$ }
  let s = ""
  for (j, t) in terms.enumerate() {
    if j == 0 { s = (if t.neg { "-" } else { "" }) + t.body } else {
      s = s + (if t.neg { " - " } else { " + " }) + t.body
    }
  }
  eval(s, mode: "math")
}

// A monic linear factor "(x - r)" as a math string (used to build factorizations).
#let _linfac(r, var: "x") = {
  if _fzero(r) { var } else if r.at(0) < 0 { "(" + var + " + " + _fabs-str(r) + ")" } else { "(" + var + " - " + _fabs-str(r) + ")" }
}

// Pad a row of cells to `width` with empty cells.
#let _pad(row, width) = {
  let r = row
  while r.len() < width { r.push([]) }
  r
}

// A placed arrow from (x1, y1) to (x2, y2) with a small two-stroke head at the
// tip. Coordinates are lengths in the enclosing box's frame (y points down).
// Native only — no CeTZ.
#let _arrow(x1, y1, x2, y2, color) = {
  let ang = calc.atan2((x2 - x1) / 1cm, (y2 - y1) / 1cm)
  let L = 0.17cm
  place(line(start: (x1, y1), end: (x2, y2), stroke: 0.9pt + color))
  place(line(start: (x2, y2), end: (x2 + L * calc.cos(ang + 152deg), y2 + L * calc.sin(ang + 152deg)), stroke: 0.9pt + color))
  place(line(start: (x2, y2), end: (x2 + L * calc.cos(ang - 152deg), y2 + L * calc.sin(ang - 152deg)), stroke: 0.9pt + color))
}

// One synthetic division of fraction `coeffs` by `(x - a)` (a a fraction).
// Returns (products, results): `results` is the quotient's coefficients followed
// by the remainder; `products.at(i)` sits under `coeffs.at(i + 1)`.
#let _divide(coeffs, a) = {
  let results = (coeffs.at(0),)
  let products = ()
  for i in range(1, coeffs.len()) {
    let p = _fmul(a, results.at(i - 1))
    products.push(p)
    results.push(_fadd(coeffs.at(i), p))
  }
  (products, results)
}

// Rendered strings, keyed by `lang`. Add a language by copying a block.
#let _i18n = (
  en: (quotient: "Quotient:", remainder: "Remainder:", factorization: "Factorization:", not-exact: "not an exact division (nonzero remainder)."),
  es: (quotient: "Cociente:", remainder: "Resto:", factorization: "Factorización:", not-exact: "no es una división exacta (resto no nulo)."),
)

/// Ruffini's rule: divide `P(x)` (given by its `coefficients`, highest degree
/// first, INCLUDING zeros for missing terms) by the binomial `(x - root)`.
///
/// Renders the classic three-row tableau and, by default, a line with the
/// quotient and remainder. Arithmetic is exact — pass rationals as strings.
///
/// - coefficients (array): P(x)'s coefficients, highest degree first. Include
///   zeros for missing terms, e.g. `x^3 - 2x^2 + 1` → `(1, -2, 0, 1)`. Each entry
///   is a number (ordinary fractions like `1/2` are recovered exactly) or, for an
///   unusual fraction, a string like `"7/99991"`.
/// - root (int, str): the `a` in the divisor `(x - a)`. For `(x + 3)`, pass `-3`;
///   for a rational root, `1/3` works, or `"7/99991"` for an unusual one.
/// - lang (str): language of the rendered words, `"en"` (default) or `"es"`.
/// - variable (str): the polynomial's variable in the rendered labels (default `"x"`).
/// - color (color): accent color for the rule and the remainder box.
/// - show-result (bool): append the "quotient / remainder" line (default `true`).
/// - highlight-remainder (bool): box the remainder cell (default `true`).
/// - trail (bool): overlay teaching arrows — bring-down, `×root` diagonals and
///   column `+` sums — that show HOW the algorithm works (default `false`). Meant
///   for explaining the method; best with integer coefficients.
#let ruffini(
  coefficients,
  root,
  lang: "en",
  variable: "x",
  color: _blue,
  show-result: true,
  highlight-remainder: true,
  trail: false,
) = {
  assert(type(coefficients) == array and coefficients.len() >= 2,
    message: "ruffini: `coefficients` must be an array of at least two numbers (highest degree first).")
  let S = _i18n.at(lang, default: _i18n.en)
  let V = eval(variable, mode: "math")
  let width = coefficients.len() + 1

  let cf = coefficients.map(_tofrac)
  let a = _tofrac(root)
  let (products, results) = _divide(cf, a)
  let quotient = results.slice(0, -1)
  let remainder = results.at(-1)

  // three rows -------------------------------------------------------------
  let row-coeffs = _pad(([],) + cf.map(_fnum), width)
  let row-prod = _pad((_fnum(a), []) + products.map(_fnum), width)
  let row-res = ([],) + results.enumerate().map(((i, b)) => {
    let m = _fnum(b)
    if highlight-remainder and i == results.len() - 1 {
      table.cell(stroke: 0.7pt + color, m) // remainder cell, boxed by the table itself
    } else { m }
  })
  row-res = _pad(row-res, width)

  if trail {
    // fixed-size table + an overlay of arrows showing the "bring down · multiply
    // by the root · add the column" flow.
    let cw = 1.6cm
    let ch = 1.15cm
    let xc(c) = (c + 0.5) * cw
    let yc(r) = (r + 0.5) * ch
    let tbl = table(
      columns: (cw,) * width,
      rows: ch,
      align: center + horizon,
      inset: 4pt,
      stroke: none,
      ..row-coeffs,
      ..row-prod,
      ..row-res,
      table.vline(x: 1, stroke: 0.7pt + color),
      table.hline(y: 2, start: 0, stroke: 0.7pt + color),
    )
    align(center, box(width: width * cw, height: 3 * ch, {
      place(top + left, tbl)
      // bring-down: c0 → b0 (straight down the first coefficient column)
      _arrow(xc(1), yc(0) + 0.34 * ch, xc(1), yc(2) - 0.34 * ch, color.lighten(25%))
      // multiply: each result b_j → its product a·b_j one column up-right, "×a"
      for j in range(products.len()) {
        let sx = xc(j + 1); let sy = yc(2)
        let ex = xc(j + 2); let ey = yc(1)
        let ux = ex - sx; let uy = ey - sy
        _arrow(sx + 0.30 * ux, sy + 0.30 * uy, ex - 0.30 * ux, ey - 0.30 * uy, color)
        place(dx: (sx + ex) / 2 + 0.02cm, dy: (sy + ey) / 2 - 0.66cm, text(0.68em, fill: color, weight: "bold")[×#_fnum(a)])
      }
      // add: each column below the rule sums into the result ("+")
      for c in range(2, width) {
        place(dx: xc(c) - 0.13cm, dy: 2 * ch - 0.01cm, text(0.8em, fill: color.lighten(10%))[$+$])
      }
    }))
  } else {
    align(center, table(
      columns: width,
      align: center + horizon,
      inset: 6pt,
      stroke: none,
      ..row-coeffs,
      ..row-prod,
      ..row-res,
      table.vline(x: 1, stroke: 0.7pt + color),
      table.hline(y: 2, start: 0, stroke: 0.7pt + color), // runs under the root too
    ))
  }

  if show-result {
    align(center, block(above: 8pt, [
      #S.quotient $C(#V) = #_poly(quotient, var: variable)$ \
      #S.remainder $R = #_fnum(remainder)$
    ]))
  }
}

/// Extended Ruffini: apply several `roots` in turn, each division acting on the
/// previous quotient. Renders the stacked staircase tableau and, if every
/// division is exact, a factorization line.
///
/// - coefficients (array): P(x)'s coefficients, highest degree first (with zeros).
///   Integers or string fractions like `"1/2"`.
/// - roots (array): the successive values `a` to divide by, in order (ints or
///   string fractions).
/// - lang (str): `"en"` (default) or `"es"`.
/// - variable (str): the polynomial's variable (default `"x"`).
/// - color (color): accent color for the rules.
/// - show-result (bool): append the factorization line (default `true`).
/// - highlight-remainder (bool): box each division's remainder cell (default `true`).
#let ruffini-factor(
  coefficients,
  roots,
  lang: "en",
  variable: "x",
  color: _blue,
  show-result: true,
  highlight-remainder: true,
) = {
  assert(type(coefficients) == array and coefficients.len() >= 2,
    message: "ruffini-factor: `coefficients` must be an array of at least two numbers.")
  assert(type(roots) == array and roots.len() >= 1,
    message: "ruffini-factor: `roots` must be a non-empty array.")
  let S = _i18n.at(lang, default: _i18n.en)
  let V = eval(variable, mode: "math")
  let width = coefficients.len() + 1
  let rts = roots.map(_tofrac)

  let cells = _pad(([],) + coefficients.map(_tofrac).map(_fnum), width)
  let hlines = ()
  let row = 1 // next row index to be written

  let current = coefficients.map(_tofrac)
  let remainders = ()
  for r in rts {
    let L = current.len()
    let (products, results) = _divide(current, r)
    cells += _pad((_fnum(r), []) + products.map(_fnum), width) // product row
    row += 1
    let res-row = ([],) + results.enumerate().map(((i, b)) => {
      let m = _fnum(b)
      if highlight-remainder and i == results.len() - 1 {
        table.cell(stroke: 0.7pt + color, m) // this division's remainder, boxed
      } else { m }
    })
    cells += _pad(res-row, width) // result row
    hlines.push(table.hline(y: row, start: 0, end: L + 1, stroke: 0.7pt + color)) // under the root too
    row += 1
    remainders.push(results.at(-1))
    current = results.slice(0, -1)
    if current.len() == 0 { break }
  }

  align(center, table(
    columns: width,
    align: center + horizon,
    inset: 6pt,
    stroke: none,
    ..cells,
    table.vline(x: 1, stroke: 0.7pt + color),
    ..hlines,
  ))

  if show-result {
    let exact = remainders.all(_fzero)
    let line = if not exact {
      [#S.factorization #S.not-exact]
    } else {
      // Monic factors (x - r) for each root applied; the final quotient `current`
      // carries P's leading coefficient (division by monic binomials preserves it).
      let factors = rts.slice(0, remainders.len()).map(r => _linfac(r, var: variable)).join("")
      if current.len() == 1 {
        // fully factored into linear factors; `current` is the leading constant
        let lead = current.at(0)
        let head = if _fone(lead) { "" } else { (if lead.at(0) < 0 { "-" } else { "" }) + _fabs-str(lead) + " " }
        [#S.factorization $P(#V) = #eval(head + factors, mode: "math")$]
      } else {
        // an irreducible-here quotient remains
        [#S.factorization $P(#V) = #eval(factors, mode: "math") (#_poly(current, var: variable))$]
      }
    }
    align(center, block(above: 8pt, line))
  }
}
