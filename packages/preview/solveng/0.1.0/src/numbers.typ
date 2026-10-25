// Number formatting and reading quantities.
/// ## Writing values
///
/// ```typ
/// #def("R = 4.7 kOhm")                // strings: name = number + unit ("I = 30mA" works without the space too)
/// #def($R_1 = 4.7 "k"Omega$)          // math content
/// #def($I = frac(2, 4) "A"$, "Q0 = 3450/2 mAh", "U = (1+2)*1,5 V", "A = 2^3 m^2")  // arithmetic in the number
/// #def("R2 = 2 R", "Z = [5 V] / I")   // [5 V] is a value inside an equation
/// #def("U2 = R [1 mA]")
/// #solve("Q = @U2 [2 s]")             // @U2 inlines its formula: Q = R [1 mA] [2 s]
/// ```
///
/// - **Units:** SI base units (m kg s A K mol cd) and V A Ω W J C F H S Hz N Pa T Wb, min h Ah Wh As Ws eV l %, ‰, °, rad, °C (as a temperature *difference*), all SI prefixes; your own with the option `units`. Powers as `m^2`, `m²`, `s^-1`; quotients as `m/s^2`; products with spaces `kg m`.
/// - **Typeable spellings:** `Ohm`/`ohm`/`Omega` → Ω, `u` → µ, `degC` → °C, `deg` → °. They are printed with the proper symbols (`"20 uA"` → 20 µA).
/// - **Decimal comma:** `"7,2 V"` works; the output separator follows the document language (option `separator`).
/// - **Names:** `Q0`→Q₀, `R_min`→R_min, `rho`→ρ, `DeltaT`→ΔT, `tol`→tol (upright). In math equations `Q_0` is a different variable than `Q0`.
/// - **Operators:** `+ - * / ^ · ×`, implicit multiplication (`2 pi f C`), `sqrt exp ln log sin cos tan asin acos atan abs`, constants `pi e` (unless you define a variable with that name), your own functions.

#import "units.typ": *

// ---------- numbers ----------
#let _sep(cf) = if cf.separator != auto { cf.separator } else if text.lang in ("de", "fr", "it", "es", "pt", "nl", "ru", "pl", "cs", "sk", "sl", "hr", "hu", "sv", "da", "nb", "fi", "tr", "ro", "uk") { "," } else { "." }
// |v| with d decimals as a plain digit string (no float→str surprises like 1e-05)
#let _fixed(v, d, zeros) = {
  let i = calc.round(calc.abs(v) * calc.pow(10.0, d))
  let s = str(int(i))
  if d > 0 {
    s = "0" * calc.max(0, d + 1 - s.len()) + s
    s = s.slice(0, s.len() - d) + "." + s.slice(s.len() - d)
    if not zeros { s = s.trim("0", at: end).trim(".", at: end) }
  }
  if v < 0 and i != 0 { "-" + s } else { s }
}
// -> (mantissa str, exponent | none), rounded to cf.digits significant digits
#let _fmt(x, cf) = {
  if x == 0 or not _ok(x) { return (if x == 0 { "0" } else { repr(x) }, none) }
  let n = cf.digits
  let e = calc.floor(calc.log(calc.abs(x)))
  if calc.abs(calc.round(x / calc.pow(10.0, e), digits: n - 1)) >= 10 { e += 1 } // 9.9996 → 10.00
  let (lo, hi) = if cf.scientific == none { (-calc.inf, calc.inf) } else { cf.scientific }
  let sci = e < lo or e >= hi or calc.abs(x) >= 1e15 or calc.abs(x) < 1e-15
  let p = if not sci { 0 } else if cf.engineering { calc.floor(e / 3) * 3 } else { e }
  let d = n - 1 - e + p
  let y = x / calc.pow(10.0, p)
  if d < 0 { y = calc.round(y / calc.pow(10.0, -d)) * calc.pow(10.0, -d) } // 123456 → 123500 at 4 digits
  (_fixed(y, calc.max(d, 0), cf.trailing-zeros), if sci { p })
}
#let _grp(s, g) = if g == none or s.len() < 5 { s } else {
  let c = s.clusters().rev()
  range(c.len()).map(i => if i > 0 and calc.rem(i, 3) == 0 { c.at(i) + g } else { c.at(i) }).rev().join()
}
// mantissa string + exponent -> content
#let _nc(m, e, cf) = {
  let neg = m.starts-with("-") or m.starts-with("−")
  let m = m.trim(regex("[-−+]"), at: start)
  let (ip, fp) = if m.contains(".") { m.split(".") } else { (m, none) }
  let m = (if neg { "−" } else { "" }) + _grp(ip, if type(cf.grouping) == symbol { str(cf.grouping) } else { cf.grouping }) + if fp != none { _sep(cf) + fp } else { "" }
  let t = if cf.multiplication == "times" { sym.times } else { sym.dot.op }
  if e == none or e == 0 { m } else if m == "1" { $10^#str(e).replace("-", "−")$ } else { $#m #t 10^#str(e).replace("-", "−")$ }
}
// best fraction p/q (q ≤ cf.max-denominator) that equals x, or none
#let _ratio(x, mx) = {
  if not _ok(x) or calc.abs(x) >= 1e15 { return none }
  if calc.round(x) == x { return (int(x), 1) }
  let (h1, h2, k1, k2) = (1.0, 0.0, 0.0, 1.0)
  let y = calc.abs(x)
  for _ in range(40) {
    let a = calc.floor(y)
    (h1, h2) = (a * h1 + h2, h1)
    (k1, k2) = (a * k1 + k2, k1)
    if k1 > mx or h1 > 1e15 { return none }
    if calc.abs(h1 / k1 - calc.abs(x)) <= 1e-12 * calc.abs(x) { return (int(if x < 0 { -h1 } else { h1 }), int(k1)) }
    let f = y - a
    if f == 0 { break }
    y = 1 / f
  }
  none
}
#let _fc((p, q), cf) = {
  if q == 1 { return _nc(str(p), none, cf) }
  let (a, b) = (_nc(str(calc.abs(p)), none, cf), _nc(str(q), none, cf))
  let f = if cf.fractions == "slash" { $#a\/#b$ } else { math.frac(a, b) }
  if p < 0 { $−#f$ } else { f }
}
// how a number is shown -> (content, exact)
#let _nshow(q, cf) = {
  let src = q.at("src", default: none)
  if cf.form == "input" and src != none {
    let s = src.replace(regex("[*·⋅]"), " dot ").replace(".", _sep(cf))
    return (eval(s, mode: "math"), true)
  }
  if cf.form == "fraction" { let r = _ratio(q.n, cf.max-denominator); if r != none { return (_fc(r, cf), true) } }
  if q.raw != none and cf.form != "decimal" {
    let m = q.raw.match(regex("^([^eE]+)(?:[eE]([-+−]?\d+))?$")).captures
    return (_nc(m.at(0), if m.at(1) != none { int(m.at(1).replace("−", "-").replace("+", "")) }, cf), true)
  }
  let (m, e) = _fmt(q.n, cf)
  (_nc(m, e, cf), not _ok(q.n) or calc.abs(float(m) * calc.pow(10.0, if e == none { 0 } else { e }) - q.n) <= 1e-9 * calc.abs(q.n))
}
// quantity -> content
#let _qc(q, cf) = {
  let n = _nshow(q, cf).at(0)
  let u = _ushow(q.u, U: _UT(cf))
  // a bare unit in an expression: A [A]
  if q.at("bare", default: false) { u } else if q.u == "" { n } else { $#n thin #u$ }
}
#let _q0(x, num, U: _U) = {
  if type(x) in (int, float) { return (v: float(x), d: _Z, raw: str(x), n: float(x), u: "", ex: none) }
  let x = _str(x)
  if _E(x) { return x }
  let x = x.trim()
  let N = "[-+−]?[\\d.,()]+(?:[eE][-+−]?\\d+)?"
  let m = x.match(regex("^(" + N + "(?:\\s*[-+−*/·⋅^]\\s*" + N + ")*)\\s*(.*)$"))
  if m == none { return _err("cannot read the value '" + x + "' (a number with a unit, e.g. 7.2 kOhm)") }
  let (s, u) = m.captures
  let s = s.trim().replace(",", ".")
  if s.match(regex("\\d*\\.\\d*\\.")) != none { return _err("cannot read the number '" + s + "'") }
  let un = _unit(u, U: U)
  if _E(un) { return un }
  let (f, d) = un
  if s.match(regex("^[-+−]?[\\d.]+(?:[eE][-+−]?\\d+)?$")) != none {
    let n = float(s.replace("−", "-"))
    if not _ok(n) { return _err("'" + x + "' is out of range (|x| < 1e300)") }
    return (v: n * f, d: d, raw: s, n: n, u: u, ex: none)
  }
  // arithmetic like "3450/2 mAh": evaluate, show the result
  let n = num(s.replace("−", "-").replace(regex("[·⋅]"), "*"))
  if _E(n) { return n }
  (v: n * f, d: d, raw: none, n: n, src: s, u: u, ex: none)
}
