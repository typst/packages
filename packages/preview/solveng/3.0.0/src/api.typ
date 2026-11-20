// Math settings, the implicit document scope, and explicit variable scopes.
#import "core.typ": *

// what the engine defined so far, for defined(), editors and the tests
#let _rows(s, cf) = if _env(s).len() == 0 { () } else { _call(_p.defined, _env(s), (cfg: _req-cfg(cf))) }

// what went wrong, for editors to show at the source: the element it's in (none for equations passed to math,
// which have no place of their own) and the statement solveng read there
#let _err-notes(loc, errors, source) = errors.map(m => [#metadata((kind: "error", element: loc, message: m, source: source))<solveng>]).join()

// a math equation in a worksheet: := defines (≔ in math), a trailing = shows the value (in the unit and number-form its
// clause gives, $t => #h, digits(3)$), -> the symbolic result or, with solve(x), solves for x; any other = states
// something. Equations that aren't formulas are left alone. quiet: only problems are shown (prose stays). loc: the
// equation in the document, for the errors' notes; auto is its own.
#let _math-def(it, quiet: false, loc: auto) = context {
  if _own(it) or _reshown(it) or _busy.get() > 0 { return it }
  let loc = if loc == auto { it.location() } else { loc }
  let children = if it.body.has("children") { it.body.children } else { (it.body,) }
  if children.any(c => c.func() == linebreak) {
    let groups = ((),)
    for c in children {
      if c.func() == linebreak { groups.push(()) } else { groups.last().push(c) }
    }
    return groups.map(g => _math-def(std.math.equation(g.join(), block: it.block), quiet: quiet, loc: loc)).join()
  }
  let cf = _cf.get() + (block: it.block)
  let src = _src(it.body)
  if _E(src) or src.trim() == "" { return it }
  _calc(src, cf, out => {
    let errs = out.errors.map(e => _errc(e, cf, wide: it.block)).join() + _err-notes(loc, out.errors, src)
    if out.prose { return _with-body(it, _restyle(it.body, cf)) + errs }
    if quiet { return errs }
    let shown = if out.mark == none { _restyle(it.body, cf) } else {
      let (head, m) = _split-eq(it.body, out.mark)
      // in a context after the head, which places the bindings it shows (their displays)
      let res = if out.result == none { [] } else { context _m(out.result, cf) }
      _restyle(head, cf) + (if m in ("⇒", "=") { _BEQ } else { $->$.body }) + res
    }
    _with-body(it, shown) + errs
  })
}

// ---------- what editors read ----------
// Typewright and other editors query <solveng> metadata after compiling: per element math processed (by its
// location, which maps back to the source) whether it was calculated, per block what it defined, with values, and
// per problem (kind: "error") its message, element and statement, see _err-notes.
#let _block-note = context {
  let cf = _cf.get()
  let defined = _rows(_st.get(), cf).map(r => (name: r.name, kind: r.kind, value: r.plain))
  [#metadata((kind: "block", defined: defined))<solveng>]
}
// whether the closest math settings enable processing: one evaluate entry per settings block, innermost first
#let _evaluates(cf) = cf.at("#evaluate", default: ()).at(0, default: true)
// the element `it` shown as `body`, followed by its record; `cf` is the configuration around it
#let _noted(it, kind, active, cf, body) = {
  let loc = it.location()
  if loc == none { return body }
  body + [#metadata((kind: kind, element: loc, active: active, evaluate: _evaluates(cf)))<solveng>]
}

// how many math settings blocks are around, kept with the configuration that every element reads anyway
#let _blocks(cf) = cf.at("#blocks", default: 0)
// A reset belongs to the closest configuration and only the innermost variable scope.
// Remember element locations so matching outer rules cannot reset the same element again.
#let _reset-seen = state("solveng-reset-seen", ())
#let _math-rules(body, clear-at, hidden, evaluate) = {
  show std.math.equation: it => context {
    if _own(it) or _reshown(it) or _busy.get() > 0 { return it }
    let cf = _cf.get()
    // Measurement can discard state updates; explicit local options still apply.
    let on = if evaluate == auto { _evaluates(cf) } else { evaluate }
    _noted(it, "math", on, cf, if on { _math-def(it, quiet: if hidden == auto { cf.at("#hidden", default: false) } else { hidden }) } else { _with-body(it, it.body) })
  }
  show selector(if clear-at in (auto, none) { <solveng-never> } else { clear-at }): it => context {
    let cf = _cf.get()
    let loc = it.location()
    if cf.at("#clear-at", default: none) != clear-at or loc in _reset-seen.get() { return it }
    _reset-seen.update(seen => seen + (loc,))
    _block-note
    _st.update(_restart)
    it
  }
  body
}

/// Enables calculations and configures math without creating a variable scope.
///
/// `#show: math` processes the remaining math in the document's implicit global scope.
/// `#math(digits: 8)[…]` overrides settings locally; definitions made there remain in the current scope.
/// Closest settings win, option by option. Importing alone does not enable calculations.
/// `evaluate: false` leaves ordinary math as written, including a single equation.
/// An explicit `#math(evaluate: true)[…]` enables it again.
/// Nested mathscopes inherit settings, including evaluate and hidden.
/// Native Typst math functions remain available through `std.math`.
///
/// ```typ
/// #show: math.with(digits: 4)
/// $x := 12$
/// #math(digits: 8)[$y := x/7 =>$]
/// $y =>$ // defined in the same global scope
/// #math(evaluate: false)[$x =>$]
/// ```
///
/// - ..body (content): Content to process in the current variable scope.
/// - clear-at (auto, none, function, selector, label): Reset the innermost variable scope at matching headings or labels. `auto` inherits; `none` disables resets.
/// - hidden (auto, bool): Hide calculated math, keeping prose and problems. `auto` inherits.
/// - evaluate (auto, bool): Process ordinary math. `auto` inherits, initially true.
/// - digits (auto, int): Significant digits of computed values, 1…15. Default `4`: `57.5 h`, `123500`.
/// - trailing-zeros (auto, bool): Keep trailing zeros up to `digits` (`2.500 V`). Default `false`.
/// - decimal-separator (auto, str): Decimal decimal-separator, any string like `","`. `auto` (default): from the document language, `,` for de, fr, it, … and `.` otherwise.
/// - grouping (auto, none, str, symbol, content): Digit grouping for integer parts with 5+ digits, e.g. `sym.space.thin` → `12 345`. Default `none`.
/// - notation-thresholds (auto, none, array): `(low, high)`: plain notation while the exponent `e` is in `low ≤ e < high`, else `2.5 · 10⁻⁷`. Default `(-3, 6)`; `none` never switches. Only how results are written: `1.12e4` is 1.12 times the variable `e4`, not a number.
/// - notation (auto, str): `"auto"`, `"plain"`, `"scientific"` or `"engineering"`. Default `"auto"`.
/// - multiplication (auto, str): `"dot"` (default, `2 · 10⁶`) or `"times"` (`2 × 10⁶`).
/// - number-form (auto, str): How values are written. `"auto"` (default): as typed, results rounded · `"decimal"`: everything rounded to `digits` · `"fraction"`: exact fraction-style (`⅙ A`) · `"input"`: given values exactly as typed.
/// - max-denominator (auto, int): Largest denominator for `number-form: "fraction"`. Default `1000`.
/// - fraction-style (auto, str): How fraction-style are written: `"stacked"` (default) or `"slash"` (`1/2`).
/// - prefixes (auto, str, none, array): Prefixes picked for results: `"all"` (default: a f p n µ m k M G T; times from a minute on in min or h, not ks), `none` (base unit only) or an array like `("m", "k")` (`"u"` = µ).
/// - show-si (auto, bool): `defined` also shows the SI value (`Q₀ = 3450 mAh = 12420 C`). Default `false`.
/// - preferred-units (auto, content, array): Units for results and graph axes of their dimension, as math expressions of unit values: `($#m / #s$, $kWh$)`, before input units and automatic SI prefixes.
/// - show-approximation (auto, bool): Write `≈` when the shown result is rounded. Default `true`.
/// - block (auto, bool): Display equations (centred, default) or inline.
/// - max-solutions (auto, int): How many solutions are listed; all are found, `root` picks among all.
/// - defined-style (auto, str): How `defined` looks: `"grid"` (default: columns side by side, aligned at `=`), `"column"`, `"inline"` or `"list"`.
/// - errors (auto, str): `"document"` (default): problems are shown as red notes · `"panic"`: stop the compilation.
/// - show-types (auto, str): How types (`f(I: mA)`) are shown in the equations as written: `"chip"` (default): as a blue chip · `"plain"`: as written, f(I: mA) · `"none"`: left out (`$f(I: mA) := 2 I$` shows as f(I) ≔ 2 I).
/// - words (auto, dictionary): The word shown for any-unit types, for documents in other languages: `(any: "beliebig")`. What you type stays `any`.
/// - chips (auto, dictionary, function): The colours of the type chips, `(type: (fill: …, mark: …, ink: …))` (`mark` is the colour of `:`, `ink` the unit's), or a function `(kind, mark, unit) => content` drawing them, with `kind` `"type"` and `mark` and `unit` as content. In HTML export `dark: (fill: …, mark: …, ink: …)` beside them gives the colours of a dark page; a colour set only for the light page keeps there.
/// - unit-style (auto, function): A function given every shown unit as content, `u => text(fill: blue, u)`.
/// - unit-separator (auto, content, str, symbol): What goes between units, a thin dot by default (A·as): `sym.times`, `h(0.2em)`.
/// - constant-displays (auto, dictionary): How constants are shown, by identity: `(imaginary: $j$, "standard-gravity": $g_0$)`, over the built-in displays of `pi` (π), `euler` (e), `imaginary` (i) and `speed-of-light` (c) and the surrounding math settings. Results show them the same way. See `constant`.
/// - graph-colors (auto, color, array): The colors of the curves in graphs, curve after curve and repeating: `(gray, blue, rgb("#f98eff"))`. Default: Petroff's ten colors, chosen to stay apart for color-blind readers. `auto` inherits the surrounding settings, also for a single curve: `(auto, red)` changes only the second (and fourth, …). A graph's `colors` goes over it, the same way.
/// - graph-lines (auto, str, array, dictionary, none): The lines of the curves in graphs, like `graph-colors`: Typst dash patterns such as `"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, or lengths like `(4pt, 2pt)`; `none` draws a curve without lines. Default `("solid", "dashed", "dotted", "dash-dotted")`. A graph's `lines` goes over it.
/// - graph-dots (auto, str, array, none): The dots of the curves in graphs, like `graph-colors`: `"circle"`, `"square"`, `"triangle"`, `"triangle-down"`, `"diamond"`, `"pentagon"`, `"hexagon"`, `"star"`, `"cross"`, `"plus"`; `none` draws a curve without dots. Default `("circle", "square", "triangle", "diamond")`. A graph's `dots` goes over it.
/// - graph-joined (auto, bool, array): Whether everything a curve in a graph draws is joined with a line, like `graph-colors`. Default `false`. A graph's `joined` goes over it.
/// -> content
#let math(
  ..body,
  clear-at: auto, hidden: auto, evaluate: auto,
  digits: auto, trailing-zeros: auto, decimal-separator: auto, grouping: auto, notation-thresholds: auto, notation: auto, multiplication: auto, number-form: auto, max-denominator: auto, fraction-style: auto,
  prefixes: auto, show-si: auto, preferred-units: auto,
  show-approximation: auto, block: auto, max-solutions: auto,
  defined-style: auto, errors: auto, show-types: auto,
  words: auto, chips: auto, unit-style: auto, unit-separator: auto, constant-displays: auto,
  graph-colors: auto, graph-lines: auto, graph-dots: auto, graph-joined: auto,
) = {
  if body.named().len() > 0 {
    return _err-now("unknown argument '" + body.named().keys().first() + "' for math; use mathscope(scope: …) to create a variable scope")
  }
  let pos = body.pos()
  if pos.len() == 0 or not pos.all(x => type(x) == content) { return _err-now("math takes content, #math[…] or #math($x =>$)") }
  if evaluate != auto and type(evaluate) != bool { return _err-now("evaluate: auto, true or false, got " + _tn(evaluate)) }
  if hidden != auto and type(hidden) != bool { return _err-now("hidden: auto, true or false, got " + _tn(hidden)) }
  let level = if type(clear-at) == selector { repr(clear-at).match(regex("^heading\\.where\\(level: (\\d+)\\)$")) } else { none }
  if not (clear-at in (auto, none, heading) or type(clear-at) == label or (type(clear-at) == selector and (repr(clear-at) == "heading" or (level != none and int(level.captures.first()) > 0)))) {
    return _err-now("clear-at: auto, none, heading, heading.where(level: n) or a label like <exercise>, got " + repr(clear-at))
  }
  let lc = _check(_given((
    digits: digits, trailing-zeros: trailing-zeros, decimal-separator: decimal-separator, grouping: grouping, notation-thresholds: notation-thresholds, notation: notation, multiplication: multiplication, number-form: number-form, max-denominator: max-denominator, fraction-style: fraction-style,
    prefixes: prefixes, show-si: show-si, preferred-units: preferred-units,
    show-approximation: show-approximation, block: block, max-solutions: max-solutions,
    defined-style: defined-style, errors: errors, show-types: show-types,
    words: words, chips: chips, unit-style: unit-style, unit-separator: unit-separator, constant-displays: constant-displays,
    graph-colors: graph-colors, graph-lines: graph-lines, graph-dots: graph-dots, graph-joined: graph-joined,
  )))
  if _E(lc) { return _err-now(lc.err) }
  let up(c) = {
    let next = _merge(c, lc)
    if "constant-displays" in lc { next.insert("constant-displays", c.at("constant-displays", default: (:)) + lc.constant-displays) }
    next.insert("^", c)
    next.insert("#blocks", _blocks(c) + 1)
    next.insert("#evaluate", (if evaluate == auto { _evaluates(c) } else { evaluate },) + c.at("#evaluate", default: ()))
    if hidden != auto { next.insert("#hidden", hidden) }
    if clear-at != auto { next.insert("#clear-at", clear-at) }
    next
  }
  _cf.update(up)
  _math-rules(pos.join(), clear-at, hidden, evaluate)
  _block-note
  _cf.update(c => c.at("^"))
}

/// Creates an explicit variable scope, inheriting math settings.
///
/// The document already has a global scope. Use math to change settings without creating another scope.
/// Scope behavior is identical for one equation and a content block.
///
/// ```typ
/// #show: math
/// $x := 12$
/// #mathscope(scope: "inherit")[$x := 99$]
/// $x =>$ // still 12
/// ```
///
/// - ..body (content): Content in the new variable scope.
/// - scope (str): `"isolated"` starts empty; `"inherit"` reads outer definitions and keeps changes local; `"shared"` also keeps changes in the parent. Default `"isolated"`.
/// -> content
#let mathscope(..body, scope: "isolated") = {
  if body.named().len() > 0 { return _err-now("unknown argument '" + body.named().keys().first() + "' for mathscope; use math(…) to configure calculations") }
  if scope not in _CH.scope { return _err-now("scope: \"isolated\", \"inherit\" or \"shared\", got " + repr(scope)) }
  let pos = body.pos()
  if pos.len() == 0 or not pos.all(x => type(x) == content) { return _err-now("mathscope takes content, #mathscope[…]") }
  _st.update(d => {
    let n = if scope == "isolated" { (:) } else { d }
    n.insert("^", d)
    n.insert("^0", n)
    n
  })
  math(pos.join())
  _st.update(d => {
    let outer = d.at("^")
    let last = if "last" in d { (last: d.last) } else { (:) }
    if scope == "shared" { outer + (env: _env(d)) + last } else { outer + last }
  })
}
