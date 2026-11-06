// Typesetting expressions, errors and HTML.
/// ## Errors
///
/// Problems (an unknown unit, a missing value, units that don't match, a typo) are shown as a red note where they happen; the rest of the document still compiles:
///
/// > ⚠ solveng: 1 equation but 2 unknowns (Q0, t) in 'Q0/2 = I t' – define the missing values first, or pass unknown: …
///
/// `#show: solve-config.with(errors: "panic")` stops the compilation instead (useful in CI). Unknown named arguments of `def`, `solve`, `defined`, `graph`, `solve-config` and `solve-block` are reported the same way; those of `lambdify` stop the compilation.
///
/// ## HTML
///
/// With `typst compile --features html --format html`, equations become MathML, `defined` columns that reflow with the width (or a table with `style: "column"`), graphs inline SVGs (via `html.frame`) that shrink with the page, errors styled notes. One small stylesheet is added to the page (math font STIX Two Math / Cambria Math / Latin Modern Math, spacing, table stripes; classes `solveng`, `solveng-defs`, `solveng-list`, `solveng-plot`, `solveng-error`). HTML export is experimental in Typst; in column layout browsers drop the space after a leading `=`.

#import "numeric.typ": *

// ---------- display ----------
#let _GR = "alpha|beta|gamma|Gamma|delta|Delta|epsilon|zeta|eta|theta|Theta|iota|kappa|lambda|Lambda|mu|nu|xi|Xi|pi|Pi|rho|sigma|Sigma|tau|upsilon|phi|Phi|chi|psi|Psi|omega|Omega"
#let _name(n) = {
  let g(b) = if b.match(regex("^(" + _GR + ")$")) != none or b.match(regex("^\\p{L}$")) != none { eval(b, mode: "math") } else if b.clusters().len() == 1 { math.italic(b) } else { math.upright(b) }
  if n.starts-with("Delta") and n.len() > 5 { return $Delta #_name(n.slice(5).trim("_", at: start))$ }
  let m = n.match(regex("^(" + _GR + "|\\p{L})(\\d+)$"))
  let (b, s) = if n.contains("_") { let p = n.split("_"); (p.first(), p.slice(1).join("_")) } else if m != none { m.captures } else { (n, "") }
  if s == "" { g(b) } else { math.attach(g(b), br: math.upright(s)) }
}
#let _dp(e, s, cf) = { // -> (content, precedence)
  let P(x, p) = { let (c, q) = _dp(x, s, cf); if q < p { $(#c)$ } else { c } }
  let (k, ..a) = e
  if k == "tuple" { return (a.map(t => _dp(t, s, cf).at(0)).join($, $), 0) }
  if k == "n" { (_nc(.._fmt(a.first(), cf + (digits: 6, trailing-zeros: false)), cf), if a.first() < 0 { 2 } else { 9 }) }
  else if k == "q" { (_qc(a.first(), cf), if a.first().u != "" { 3 } else { 9 }) }
  else if k == "c" { (if a.first() == "e" { $e$ } else { $pi$ }, 9) }
  else if k == "v" { if s != none and a.first() in s { s.at(a.first()) } else { (_name(a.first()), 9) } }
  else if k == "+" { (a.enumerate().map(((i, t)) => if t.at(0) == "-" { $- #P(t.at(1), 2)$ } else if i == 0 { P(t, 1) } else { $+ #P(t, 1)$ }).join(), 1) }
  else if k == "-" { ($-#P(a.first(), 3)$, 2) }
  else if k == "*" { (a.enumerate().map(((i, t)) => if i > 0 and (s != none or t.at(0) in ("n", "q") or a.at(i - 1).at(0) == "q") { $dot #P(t, 3)$ } else { P(t, 3) }).join(), 3) }
  else if k == "/" { (math.frac(_dp(a.at(0), s, cf).at(0), _dp(a.at(1), s, cf).at(0)), 4) }
  else if k == "^" { (math.attach(P(a.at(0), 9), tr: _dp(a.at(1), s, cf).at(0)), 5) }
  else {
    let (f, x) = a
    let c = _dp(x, s, cf).at(0)
    if f == "sqrt" { (math.sqrt(c), 9) } else if f == "abs" { (math.abs(c), 9) } else if f == "exp" { (math.attach($e$, tr: c), 5) }
    else if f in _F { ($#math.op(f) (#c)$, 9) } else { ($#_name(f) (#c)$, 9) }
  }
}

// HTML: one stylesheet per document (browsers set math fonts on <math> itself, so inline styles can't reach it)
#let _css-done = state("solveng-css", false)
#let _CSS = ".solveng, .solveng-list { font-size: 1.12em; }
.solveng { margin: 0.9em 0; overflow-x: auto; overflow-y: hidden; }
.solveng math, .solveng-list math { font-family: 'STIX Two Math', 'Cambria Math', 'Latin Modern Math', math; }
.solveng-list { border-collapse: collapse; margin: 0.7em 0; }
.solveng-defs { columns: var(--w) auto; column-gap: 2.5em; margin: 0.7em 0; font-size: 1.12em; }
.solveng-defs > div { break-inside: avoid; display: flex; gap: 0.3em; padding: 0.15em 0; white-space: nowrap; }
.solveng-defs > div > span:first-child { flex: 0 0 var(--n); text-align: right; }
.solveng-plot { margin: 0.9em 0; text-align: center; }
.solveng-plot svg { max-width: 100%; height: auto !important; margin: 0 auto; }
.solveng-defs math { font-family: 'STIX Two Math', 'Cambria Math', 'Latin Modern Math', math; }
.solveng-list td { padding: 0.25em 0.4em; white-space: nowrap; }
.solveng-list tr:nth-child(even) td { background: rgba(127, 127, 127, 0.07); }
.solveng-error { color: #b3261e; background: #fdecea; border-radius: 3px; padding: 0.1em 0.35em; font-size: 0.9em; }
div.solveng-error { border-left: 3px solid #b3261e; padding: 0.4em 0.7em; margin: 0.6em 0; }"
#let _css() = context if not _css-done.get() { html.elem("style", _CSS); _css-done.update(true) }
// math block or inline; in HTML a spaced, scrollable block
#let _eqn(body, cf) = {
  let e = math.equation(block: cf.block, body)
  if cf.block and _target() == "html" { _css(); html.elem("div", attrs: (class: "solveng"), e) } else { e }
}
// problems are shown where they happen (solve-config(errors: "panic") stops instead)
#let _errc(msg, cf, wide: false) = {
  if cf.at("errors", default: "document") == "panic" { panic("solveng: " + msg) }
  if _target() == "html" {
    _css()
    html.elem(if wide { "div" } else { "span" }, attrs: (class: "solveng-error"), "⚠ solveng: " + msg)
  } else {
    let t = text(fill: rgb("#b3261e"), size: 0.9em)[⚠ solveng: #msg]
    if wide { block(width: 100%, fill: rgb("#fdecea"), stroke: (left: 2pt + rgb("#b3261e")), inset: (x: 8pt, y: 6pt), radius: 2pt, t) }
    else { box(fill: rgb("#fdecea"), inset: (x: 3pt, y: 1pt), outset: (y: 2pt), radius: 2pt, t) }
  }
}
#let _err-now(msg) = context _errc(msg, _cf.get(), wide: true)
// output of the package: its equations are not read as definitions by solve-block's math rule
#let _busy = state("solveng-busy", 0)
#let _mine(body) = _busy.update(n => n + 1) + body + _busy.update(n => n - 1)
#let _tn(x) = if x == none { "none" } else if x == auto { "auto" } else { str(type(x)) }
