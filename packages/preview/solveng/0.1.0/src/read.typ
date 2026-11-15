// Reading math as typed: which letters are units and which are variables.
/// ## Units and variables
///
/// Many engineering symbols are also units: `A` (area, ampere), `V` (volume, volt), `T` (period, tesla), `h` (height, hour), `C`, `F`, `W`, `m`, `s`, `l`, `L`, … solveng keeps them apart by *how* they are written, never by guessing:
///
/// - **Strings:** a unit is read only where a value is written – right after a number (`"I = 30 mA"`) or in brackets (`[5 V]`, `[A]` for one ampere). Every other name in an equation is a variable.
/// - **Math:** quoted text is a unit (`$30 "mA"$`, `$3 "h"$` – set upright, as units should be); a bare letter is a variable if one with that name is defined (`$3 h$` with `h` defined is 3 times h, in italics), else a unit after a number (`$5 V$`).
/// - **Unclear is an error:** a value whose unit is also a defined variable (`"t = 3 h"` with `h` defined, `"f = 1/T"` with `T` defined) is refused, with a hint how to write either meaning: `[3 h]` for hours, `3*h` or `1/(T)` for the variable.
///
/// ```typ
/// #def("A = 12")
/// #solve("x = A [A]")                  // x = A · A = 12 · A = 12 A
/// #solve("y = A A", unit: "A")         // error: the result has unit 1, not A – 'A' is read as a variable here; …
/// #def("T = 2 s")
/// #def("f = 1/T")                      // error: 'T' in '1/T' is both a defined variable and a unit – …
/// #solve("f = 1/(T)")                  // f = 1/T = 1/(2 s) = 500 mHz
/// ```
///
/// For documents where nothing may be read two ways, `#solve-config(strict: true)` also refuses unit names as variable names (`A = 3 m^2` → pick `A_1`, or remove the unit) and bare units in math (`$5 V$` → `$5 "V"$`).
///
/// The available units can be changed with the option `units`: new units are defined by a value, `none` removes one (which frees its name, e.g. `T` for a period that is then never read as tesla):
///
/// ```typ
/// #solve-config(units: (bar: "100 kPa", rpm: "1/min", t: "1000 kg", T: none))
/// #def("p = 3 bar", "n = 3000 rpm")              // prefixes work too: mbar, kbar
/// #solve-config(preferred-units: ("bar", "kWh"))  // results with these dimensions are shown in these units
/// ```

#import "display.typ": *

// tokens like _tk, plus quoted text ("mA") as one token
#let _tkq(s) = s.matches(regex("\"[^\"]*\"|\\[[^\\]]*\\]|\\d+\\.?\\d*(?:[eE][-+]?\\d+)?|\\.\\d+|@?\\p{L}[\\p{L}\\p{N}_]*|\\S")).map(m => m.text)
#let _quoted(k) = k != none and k.len() >= 2 and k.starts-with("\"") and k.ends-with("\"")
#let _unq(k) = if _quoted(k) { k.slice(1, -1) } else { k }
// strict: a unit typed bare in math is set in italics like a variable, so it has to be quoted
#let _strict-unit(k) = _err("write " + k + " in quotes, \"" + k + "\": with the option strict, units in math are quoted (set upright), bare letters are variables")

// one side of a math equation as typed: decimal commas (0,95) and quantities written without brackets
// (frac(3450/2 "mAh", 30 "mA") → [(3450)/(2) mAh]/[30 mA]). Quoted text ("V") is a unit; a bare letter is a
// unit only after a number and if it isn't a defined variable ($3 h$ with a variable h is 3 times h).
// bare: units may also follow a call or a name (f(20) Ω is f(20) times 1 Ω); only for values, not equations, where an undefined A is a variable
// -> a string _parse reads, or an error
#let _math-src(s, vars, cf, bare: false) = {
  let U = _UT(cf)
  let s = s.replace(regex("(\d),(\d)"), m => m.captures.at(0) + "." + m.captures.at(1))
  // "k"Omega, "k" "A": a quoted prefix belongs to the unit after it ("m" Omega is metre times ohm, "m"Omega milliohm)
  let join(m) = {
    let (p, sp, u) = m.captures
    if sp == "" or (p in _P and not _known(p, U)) { "\"" + p + u.trim("\"") + "\"" } else { m.text }
  }
  let s = s.replace(regex("\"([^\"]*)\"(\\s*)(\"[^\"]*\"|Ω|\u{2126})"), join)
  let t = _tkq(s)
  let num(k) = k.match(regex("^[\d.]")) != none
  let name(k) = k != none and k.match(regex("^\p{L}")) != none
  let unit(k) = if _quoted(k) { _isu(_unq(k), U: U) } else { name(k) and k not in vars and _isu(k, U: U) }
  // a unit typed bare, which strict refuses (Ω is upright anyway)
  let loose(k) = cf.strict and not _quoted(k) and k not in ("Ω", "\u{2126}")
  // a plain value: R = 7.2 kΩ
  let plain = t.map(_unq).join(" ")
  if _isq(plain, U: U) and t.all(k => _quoted(k) or k not in vars) {
    let b = t.find(k => name(k) and loose(k))
    // quoted: the unit is meant even if there is a variable with its name
    return if b != none { _strict-unit(b) } else if t.any(_quoted) { "[" + plain + "]" } else { plain }
  }
  // a parenthesized unit as math writes it: ( mm ^ ( 2 ) ) -> ("mm^2", index after it), or none
  let group(j) = {
    if t.at(j, default: none) != "(" { return none }
    let (dp, e) = (0, j)
    while e < t.len() {
      if t.at(e) == "(" { dp += 1 } else if t.at(e) == ")" { dp -= 1; if dp == 0 { break } }
      e += 1
    }
    let inner = t.slice(j + 1, calc.min(e, t.len()))
    if e >= t.len() or not inner.any(unit) or not inner.all(k => unit(k) or k in ("^", "(", ")", "-", "−", "*", "·", "⋅") or k.match(regex("^\d+$")) != none) { return none }
    let u = inner.map(_unq).join(" ").replace(regex("\^\s*\(\s*([-−]?)\s*(\d+)\s*\)"), m => "^" + m.captures.at(0).replace("−", "-") + m.captures.at(1))
    (u.replace(regex("[()]"), "").replace(regex("\s*\^\s*"), "^").trim(), e + 1, inner.find(k => unit(k) and loose(k)))
  }
  // start of the numeric factor at the end of out ((3450)/(2), 2^3), or none
  let start(out) = {
    let (d, best) = (0, none)
    for i in range(out.len() - 1, -1, step: -1) {
      let k = out.at(i)
      if k == ")" { d += 1 }
      else if k == "(" {
        d -= 1
        if d < 0 or (d == 0 and i > 0 and name(out.at(i - 1))) { break } // f(2) is a call
      }
      else if not (num(k) or k in ("*", "/", "·", "⋅", "×", "^") or (d > 0 and k in ("+", "-", "−"))) { break }
      if d == 0 and (num(k) or k == "(") { best = i }
    }
    best
  }
  let out = ()
  let i = 0
  while i < t.len() {
    let k = t.at(i)
    let b = if (unit(k) or group(i) != none) and out.len() > 0 and (num(out.last()) or out.last() == ")") { start(out) }
    if b == none and bare and (unit(k) or group(i) != none) and out.len() > 0 and (out.last() == ")" or name(out.last())) { b = out.len() }
    // a quoted unit on its own: "A" alone is one ampere
    if b == none and _quoted(k) and unit(k) { b = out.len() }
    if b == none {
      // 3 h with a variable h: a number times the variable, not 3 hours
      out.push(if num(k) and name(t.at(i + 1, default: none)) and t.at(i + 1) in vars { "[" + k + "]" } else { _unq(k) })
      i += 1
      continue
    }
    let (u, j) = ((), i)
    let go = true
    while go and j < t.len() {
      let a = t.at(j)
      if unit(a) {
        if loose(a) { return _strict-unit(a) }
        u.push(_unq(a)); j += 1
        // m^2, s^-1, m^(2) (math writes the exponent in parentheses)
        if t.at(j, default: none) == "^" {
          let ex = t.slice(j + 1, calc.min(j + 5, t.len()))
          let par = ex.at(0, default: none) == "("
          let ex = if par { ex.slice(1) } else { ex }
          let neg = ex.at(0, default: none) in ("-", "−")
          let ex = if neg { ex.slice(1) } else { ex }
          let n = ex.at(0, default: none)
          if n != none and n.match(regex("^\d+$")) != none and (not par or ex.at(1, default: none) == ")") {
            u.last() += "^" + (if neg { "-" } else { "" }) + n
            j += 2 + int(par) * 2 + int(neg)
          }
        }
      } else if group(j) != none {
        let (g, e, l) = group(j)
        if l != none { return _strict-unit(l) }
        u.push(g); j = e
      }
      else if a == "/" and (unit(t.at(j + 1, default: none)) or group(j + 1) != none) { u.push("/"); j += 1 }
      else { go = false }
    }
    let f = out.slice(b).join()
    // [A]: a unit without a number is shown as just the unit
    out = out.slice(0, b) + ("[" + (if f in (none, "") { "" } else { f + " " }) + u.join(" ") + "]",)
    i = j
  }
  out.join(" ")
}
// a whole math equation or inequality (from _str(…, q: true)): each side read with _math-src -> string, or an error
#let _math-eq(s, vars, cf) = {
  let rs = s.matches(regex("<=|>=|[=<>≤≥]"))
  let (out, at) = ("", 0)
  for r in rs + ((start: s.len(), end: s.len(), text: ""),) {
    let side = _math-src(s.slice(at, r.start), vars, cf)
    if _E(side) { return side }
    out += side.trim() + if r.text != "" { " " + r.text + " " }
    at = r.end
  }
  out
}
