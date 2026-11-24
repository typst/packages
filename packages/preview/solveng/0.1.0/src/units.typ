// Units: names, prefixes, parsing and picking a readable unit.
#import "config.typ": *

// ---------- units: dims = (m, kg, s, A, K, mol, cd) ----------
#let _Z = (0, 0, 0, 0, 0, 0, 0)
#let _BASE = ("m", "kg", "s", "A", "K", "mol", "cd")
// errors are values (typst can't catch panics): (err: "message"), passed up and shown in the document
#let _err(m) = (err: m)
#let _E(x) = type(x) == dictionary and "err" in x
#let _first-err(xs) = xs.find(_E)
// state keys that are not variables: last outputs, outer scope, definition order, functions
#let _SP = ("..", "^", "^0", "!", "#fn")
#let _vars-of(d) = d.pairs().filter(p => p.at(0) not in _SP).to-dict()
#let _ok(v) = not float.is-nan(float(v)) and calc.abs(v) < 1e300
#let _add(a, b, k: 1) = a.zip(b).map(((x, y)) => calc.round(x + k * y, digits: 6))
// the built-in units: name -> (factor to SI, dims)
#let _U = {
  let D(m, kg, s, A, K, mol: 0, cd: 0) = (m, kg, s, A, K, mol, cd)
  let (V, C, J, O) = (D(2, 1, -3, -1, 0), D(0, 0, 1, 1, 0), D(2, 1, -2, 0, 0), D(2, 1, -3, -2, 0))
  (
    m: (1, D(1, 0, 0, 0, 0)), g: (1e-3, D(0, 1, 0, 0, 0)), s: (1, D(0, 0, 1, 0, 0)),
    A: (1, D(0, 0, 0, 1, 0)), K: (1, D(0, 0, 0, 0, 1)), mol: (1, D(0, 0, 0, 0, 0, mol: 1)), cd: (1, D(0, 0, 0, 0, 0, cd: 1)),
    V: (1, V), C: (1, C), J: (1, J),
    "Ω": (1, O), "\u{2126}": (1, O), Ohm: (1, O), ohm: (1, O), Omega: (1, O), W: (1, D(2, 1, -3, 0, 0)),
    S: (1, O.map(x => -x)), F: (1, D(-2, -1, 4, 2, 0)), H: (1, D(2, 1, -2, -2, 0)),
    Hz: (1, D(0, 0, -1, 0, 0)), N: (1, D(1, 1, -2, 0, 0)), Pa: (1, D(-1, 1, -2, 0, 0)),
    T: (1, D(0, 1, -2, -1, 0)), Wb: (1, D(2, 1, -2, -1, 0)), min: (60, D(0, 0, 1, 0, 0)),
    h: (3600, D(0, 0, 1, 0, 0)), Ah: (3600, C), As: (1, C), Wh: (3600, J), Ws: (1, J),
    eV: (1.602176634e-19, J), l: (1e-3, D(3, 0, 0, 0, 0)), L: (1e-3, D(3, 0, 0, 0, 0)),
    "%": (0.01, _Z), "‰": (1e-3, _Z), "°C": (1, D(0, 0, 0, 0, 1)), degC: (1, D(0, 0, 0, 0, 1)), "°": (calc.pi / 180, _Z), deg: (calc.pi / 180, _Z), rad: (1, _Z),
  )
}
// the unit table in effect: the built-in units changed by the option units
#let _UT(cf) = cf.at("#U", default: _U)
#let _P = (a: 1e-18, f: 1e-15, p: 1e-12, n: 1e-9, "µ": 1e-6, "μ": 1e-6, u: 1e-6, m: 1e-3, c: 1e-2, d: 0.1, k: 1e3, M: 1e6, G: 1e9, T: 1e12)
// a unit name: a known unit, or a prefix followed by one (kΩ, mAh)
#let _known(n, U) = n in U or { let c = n.clusters(); c.len() > 1 and c.first() in _P and c.slice(1).join() in U }
// math content -> plain string: $"1k"Omega$ → "1kΩ", $frac(1, 2)"A"$ → "(1)/(2)A"
// q: true for math: quoted text keeps its quotes ($5 "V"$ → 5 "V"), so units written upright can be told from variables
#let _str(c, q: false) = {
  if type(c) == str { return c }
  if type(c) in (int, float, symbol) { return str(c) }
  if type(c) != content { return _err("expected a string or math content, got " + repr(c)) }
  let f = c.func()
  let parts(..xs) = { let xs = xs.pos(); let b = _first-err(xs); if b != none { b } else { xs.join() } }
  if f == text and q and c.text.match(regex("\p{L}|[°%‰]")) != none { "\"" + c.text + "\"" }
  else if f == text or (c.has("text") and type(c.text) == str) { c.text }
  else if f == [ ].func() or f == h { " " }
  else if c.has("children") { parts(..c.children.map(x => _str(x, q: q))) }
  else if f == math.frac { parts("(", _str(c.num, q: q), ")/(", _str(c.denom, q: q), ")") }
  else if f == math.attach {
    // subscripts are part of a name (R_"load"), never units
    parts(_str(c.base, q: q), if c.has("b") { parts("_", _str(c.b)) } else { "" }, if c.has("t") { parts("^(", _str(c.t), ")") } else { "" })
  }
  else if f == math.op { _str(c.text) }
  else if f == math.root {
    if c.has("index") and c.index != none { parts("(", _str(c.radicand, q: q), ")^(1/(", _str(c.index), "))") } else { parts("sqrt(", _str(c.radicand, q: q), ")") }
  }
  else if c.has("body") { _str(c.body, q: q) }
  else { _err("can't read " + repr(c)) }
}
// "k Ω" (prefix written apart, as in $1 "k" Omega$) -> "kΩ"
#let _join-prefix(ts, U: _U) = {
  let out = ()
  for t in ts {
    if out.len() > 0 and out.last() in _P and out.last() not in U and (t in U or t.clusters().len() > 1) { out.last() += t } else { out.push(t) }
  }
  out
}
#let _tok(u, U: _U) = u.replace(regex("[()]"), "").split("/").map(p => _join-prefix(p.split(regex("[\s*·⋅]+")).filter(t => t != ""), U: U).map(t => {
  let m = t.match(regex("^(.+?)(?:\^?([-−]?\d+)|([²³]))?$")).captures
  (m.at(0), if m.at(2) != none { int(m.at(2).replace("²", "2").replace("³", "3")) } else if m.at(1) != none { int(m.at(1).replace("−", "-")) } else { 1 })
}))
// the unit names in a unit string: "kg m/s^2" -> ("kg", "m", "s")
#let _unames(u, U: _U) = _tok(u, U: U).flatten().chunks(2).map(p => p.first()).filter(n => n != "1")
// unit string -> (factor, dims)
#let _unit(u, U: _U) = {
  let (f, d) = (1.0, _Z)
  for (i, p) in _tok(u, U: U).enumerate() {
    for (n, e) in p.filter(t => t.at(0) != "1") {
      let c = n.clusters()
      let (uf, ud) = if n in U { U.at(n) } else if c.len() > 1 and c.first() in _P and c.slice(1).join() in U {
        let (g, dd) = U.at(c.slice(1).join()); (g * _P.at(c.first()), dd)
      } else { return _err("unknown unit '" + n + "'" + if _known(n, _U) { " (it was removed with the option units)" } else { "" }) }
      if i > 0 { e = -e }
      f *= calc.pow(float(uf), e); d = _add(d, ud, k: e)
    }
  }
  (f, d)
}
// typeable spellings shown with their symbols: kOhm → kΩ, uA → µA, degC → °C
#let _ASCII = (Ohm: "Ω", ohm: "Ω", Omega: "Ω", degC: "°C", deg: "°")
#let _uname(n, U: _U) = if n in U { _ASCII.at(n, default: n) } else {
  let c = n.clusters()
  let r = c.slice(1).join()
  if c.len() > 1 and c.first() in _P and r in U { (if c.first() == "u" { "µ" } else { c.first() }) + _ASCII.at(r, default: r) } else { n }
}
#let _ushow(u, U: _U) = _tok(u, U: U).map(p => p.map(((n, e)) => { let n = math.upright(_uname(n, U: U)); if e == 1 { n } else { math.attach(n, tr: str(e)) } }).join(h(0.17em))).join("/")
// pick a readable unit for dims d (only built-in units that are still in the table U)
#let _AU = ("V", "A", "Ω", "W", "J", "C", "F", "H", "S", "N", "Pa", "T", "Wb", "s", "m", "g", "K", "Hz", "mol", "cd")
#let _auto(d, U: _U) = {
  if d == _Z { return "" }
  let au = _AU.filter(u => U.at(u, default: none) == _U.at(u))
  let has(b) = U.at(b, default: none) == _U.at(b)
  for u in au { if _U.at(u).at(1) == d { return u } }
  // m^2 before "m m"
  for b in ("m", "s").filter(has) { for k in (2, 3, -1, -2, -3) { if _U.at(b).at(1).map(x => x * k) == d { return b + "^" + str(k) } } }
  for u in au { for b in ("m", "s", "A", "K").filter(has) { for (k, j) in ((1, " "), (-1, "/"), (-2, "/")) {
    // A·A is A², found below
    if u == b and k == 1 { continue }
    if _add(_U.at(u).at(1), _U.at(b).at(1), k: k) == d { return u + j + b + if k == -2 { "^2" } else { "" } }
  } } }
  // V², Ω⁻¹ before base units
  for u in au { for k in (2, 3, -1, -2) { if _U.at(u).at(1).map(x => x * k) == d { return u + "^" + str(k) } } }
  _BASE.zip(d).filter(p => p.at(1) != 0).map(((n, e)) => if e == 1 { n } else { n + "^" + str(e) }).join(" ")
}
#let _PX = (a: -18, f: -15, p: -12, n: -9, "µ": -6, m: -3, c: -2, d: -1, "": 0, k: 3, M: 6, G: 9, T: 12)
// unit u with the largest allowed prefix that keeps the number ≥ 1
#let _pre(v, u, cf) = {
  let U = _UT(cf)
  let f = u.split(regex("[ /]")).first()
  // areas and volumes: mm², m², km²
  let pw = f.match(regex("^(\p{L}+)\^(\d+)$"))
  if pw != none and v != 0 and cf.prefixes != none and _ok(v) {
    let n = int(pw.captures.at(1))
    let ps = ("m", "", "k").filter(p => p == "" or cf.prefixes == "all" or p in cf.prefixes)
    return ps.filter(p => _PX.at(p) * n <= calc.log(calc.abs(v)) + 1).at(-1, default: ps.first()) + u
  }
  if u == "" or f.contains("^") or v == 0 or cf.prefixes == none or not _ok(v) { return u }
  // times of a minute and more in min / h, not ks (unless those units were removed)
  if u == "s" and cf.prefixes == "all" and calc.abs(v) >= 60 {
    let t = if calc.abs(v) < 3600 { "min" } else { "h" }
    if U.at(t, default: none) == _U.at(t) { return t }
  }
  let ps = if cf.prefixes == "all" { ("a", "f", "p", "n", "µ", "m", "k", "M", "G", "T") } else { cf.prefixes }
  let ps = (ps.map(p => if p == "u" { "µ" } else { p }) + ("",)).filter(p => p in _PX).dedup().sorted(key: p => _PX.at(p))
  let e = calc.log(calc.abs(v))
  ps.filter(p => _PX.at(p) <= e + 1e-9).at(-1, default: ps.first()) + u
}
