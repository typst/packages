// worksheet: math calculated where it stands.
#import "core.typ": *

// what the engine defined so far, for defined(), editors and the tests
#let _rows(s, cf) = if _env(s).len() == 0 { () } else { _call(_p.defined, _env(s), (cfg: _req-cfg(cf))) }

// what went wrong, for editors to show at the source: the element it's in (none for equations passed to worksheet,
// which have no place of their own) and the statement solveng read there
#let _err-notes(loc, errors, source) = errors.map(m => [#metadata((kind: "error", element: loc, message: m, source: source))<solveng>]).join()

// a math equation in a worksheet: := defines (≔ in math), a trailing = shows the value (in the unit and form its
// clause gives, $t = #h, digits(3)$), -> the symbolic result or, with solve(x), solves for x; any other = states
// something. Equations that aren't formulas are left alone. quiet: only problems are shown (prose stays). loc: the
// equation in the document, for the errors' notes; auto is its own.
#let _math-def(it, quiet: false, loc: auto) = context {
  if _busy.get() > 0 or _reshown(it) or _own(it) { return it }
  let loc = if loc == auto { it.location() } else { loc }
  let children = if it.body.has("children") { it.body.children } else { (it.body,) }
  if children.any(c => c.func() == linebreak) {
    let groups = ((),)
    for c in children {
      if c.func() == linebreak { groups.push(()) } else { groups.last().push(c) }
    }
    return groups.map(g => _math-def(math.equation(g.join(), block: it.block), quiet: quiet, loc: loc)).join()
  }
  let cf = _cf.get() + (block: it.block)
  let src = _src(it.body)
  if _E(src) or src.trim() == "" { return it }
  _calc(src, cf, out => {
    let errs = out.errors.map(e => _errc(e, cf, wide: it.block)).join() + _err-notes(loc, out.errors, "")
    if out.prose { return _with-body(it, _restyle(it.body, cf)) + errs }
    if quiet { return errs }
    let shown = if out.mark == none { _restyle(it.body, cf) } else {
      let (head, m) = _split-eq(it.body, out.mark)
      // in a context after the head, which places the bindings it shows (their displays)
      let res = if out.result == none { [] } else { context _m(out.result, cf) }
      _restyle(head, cf) + (if m == "=" { _BEQ } else { $->$.body }) + res
    }
    _with-body(it, shown) + errs
  })
}

// ---------- what editors read ----------
// Typewright and other editors query <solveng> metadata after compiling: per element worksheet saw (by its
// location, which maps back to the source) whether it was calculated, per block what it defined, with values, and
// per problem (kind: "error") its message, element and statement, see _err-notes.
#let _block-note = context {
  let cf = _cf.get()
  let defined = _rows(_st.get(), cf).map(r => (name: r.name, kind: r.kind, value: r.plain))
  [#metadata((kind: "block", defined: defined))<solveng>]
}
// whether the innermost worksheet around calculates its math: its evaluate, one per worksheet, innermost first
#let _evaluates(cf) = cf.at("#evaluate", default: ()).at(0, default: true)
// the element `it` shown as `body`, followed by its record; `cf` is the configuration around it
#let _noted(it, kind, active, cf, body) = {
  let loc = it.location()
  if loc == none { return body }
  body + [#metadata((kind: kind, element: loc, active: active, evaluate: _evaluates(cf)))<solveng>]
}

// how many worksheets are around, kept with the configuration that every element reads anyway
#let _blocks(cf) = cf.at("#blocks", default: 0)
// `b` with math calculated (unless the innermost worksheet around an element says evaluate: false);
// hidden: what is calculated isn't shown (only its problems), the rest of `b` is.
// Not a `context`: that would hide `b` from show rules around it that read its structure (letmeout).
#let _rules(b, clear-at, hidden) = {
  show std.math.equation: it => context {
    if _busy.get() > 0 or _reshown(it) or _own(it) { return it }
    let cf = _cf.get()
    let on = _evaluates(cf)
    _noted(it, "math", on, cf, if on { _math-def(it, quiet: hidden) } else { it })
  }
  // start over at each heading (or whatever clear-at selects): back to the state at the start of the worksheet
  show selector(if clear-at == none { <solveng-never> } else { clear-at }): it => {
    if clear-at != none { _block-note + _st.update(_restart) }
    it
  }
  b
}

/// Calculates the math you write, like a Mathcad worksheet.
///
/// `#show: worksheet` calculates the rest of the document, `#worksheet[…]` its content (on its own unless `scope` says otherwise), and `#worksheet($…$)` single equations, also outside a worksheet.
///
/// ```typ
/// #import units: mA, mAh, h
/// #show: worksheet
/// The battery holds $Q_0 := 3450 mAh$ and the load draws $I := 30 mA$,
/// so it lasts $t := Q_0 / I = #h$.
/// ```
///
/// **Math.** As in Mathcad:
///
/// - `:=` defines (shown as ≔), symbolically: `$I := 30 mA$`, `$P := U I$`, `$f(x) := x^2 + 1$`. Names not defined yet stay names until they are, see *Calculating like Mathcad*.
/// - `=` inside an expression compares, 1 or 0: `$M := 1 = 2 =$` is 0.
/// - `=` at the end shows the value, with a bold =: `$t =$` → t **=** 115 h, `$t := Q_0/I =$` defines and shows it. What follows it is the unit and modifiers: `$t = #h$`, `$t = min, digits(2)$`.
/// - `->` at the end shows the symbolic result, the known values put in, exactly: `$f := (x^2 - 1)/(x - 1) -> simplify$`. With `solve(x)` it solves an equation for x (and defines it when the solution is a value): `$Q_0/2 = I t -> solve(t)$`, `$x^2 - 4 = 0 -> solve(x)$`, `$x + y = 3, x - y = 1 -> solve(x, y)$`, `$R <= U/I -> solve(R)$`.
///
/// Modifiers, imported from `modifiers` where you use them (`#import modifiers: solve, digits`): `solve(x, …)`, `substitute(x, …)` (these variables' formulas put in, other names kept), `simplify`, `fraction` (exact fractions), `digits(n)` (decimals with n significant digits), `sci` (scientific notation), `eng` (engineering notation). Any other equation with `=` states something: it's checked when everything in it is known (`$U = R I$` after defining them) and left alone as prose when not (`$E = m c^2$`).
///
/// **Units, constants, operations and modifiers** are Typst bindings, imported where you use them: `#import units: mA, s`, `#import constants: pi, i`, `#import operations: tri`, `#import modifiers: solve`, then `$30 mA$`, `$2 #s$`, `$2 pi$`. A binding of a single letter needs a `#` in math. Quoted text names worksheet variables; it never means a unit or operation. Raw blocks, also ```` ```solveng ```` ones, are ordinary text.
///
/// **Calls.** `#worksheet($U := 5 #V$, $I := U/R =$)` calculates its equations where it stands, with the definitions made before. Its options are for these only; with content, for the content.
///
/// **Evaluate.** `#worksheet(evaluate: false)[…]` leaves its math alone: only `#worksheet(…)` calls in it are calculated. Nested worksheets don't inherit it, so a `#worksheet[…]` or `#worksheet($t =$)` inside calculates its math again.
///
/// ```typ
/// #import units: s
/// #worksheet[
///   $t := 5 #s$
///   #worksheet(evaluate: false, scope: "inherit")[
///     $E = m c^2$ stays as written, and so does $t = 3 #s$;
///     #worksheet($t =$) is still calculated.
///   ]
/// ]
/// ```
///
/// **Hidden.** `hidden: true` calculates without showing what is calculated: the equations of a call, or in `#worksheet(hidden: true)[…]` the math it calculates – its text, headings and prose equations (`$E = m c^2$`) stay. Problems are still shown. Nested worksheets don't inherit it, so a `#worksheet($t =$)` inside shows its equation again.
///
/// ```typ
/// #import units: V, Ω, mA
/// #worksheet(hidden: true)[
///   The values for the example:
///   $U := 5 #V$, $R := 100 #Ω$, $I := U/R$
///   The current is #worksheet($I = mA$).
/// ]
/// ```
///
/// **Scopes.** `scope` says what a worksheet sees and keeps: `"isolated"` starts empty and its definitions end with it; `"inherit"` sees the definitions made before, and its own end with it; `"shared"` sees them, and what it defines stays afterwards, replacing names of the same name (variables, functions and solved values alike). `auto`: isolated for content (`#worksheet[…]`, `#show: worksheet`), shared for equations passed to `worksheet`. Typst makes a content block holding only one equation the same value as that equation, so `#worksheet[$x := 1$]` is shared; write `scope: "isolated"` to keep it local. Nested worksheets don't inherit the scope. Clearing never reaches outside: `clear`, `clear-at` and `clear(all: true)` don't delete the outer definitions. Units, constants and operations aren't definitions: they are bindings, the same in every worksheet where they're visible.
///
/// ```typ
/// #import units: V, Ω, mA
/// #show: worksheet
/// $U := 12 #V$
/// #worksheet(scope: "shared")[
///   $R := 100 #Ω$
///   $I := U/R = mA$
/// ]
/// $I = mA$ // 120 mA, kept from the block
/// #worksheet($U := 5 #V$, scope: "inherit") // local to this call
/// $U =$ // still 12 V
/// ```
///
/// **Editors.** Each equation the worksheet sees leaves a `metadata` labelled `<solveng>` with its `location()`, whether it was calculated and whether math is evaluated there; each problem one with `kind: "error"`, its `message`, the `element` it's in (`none` for equations passed to `worksheet`) and the `source` statement; at the end (and before each match of `clear-at`) one lists everything defined, with values. Editors like Typewright read them after compiling: `query(<solveng>)`.
///
/// **Starting over.** `clear-at` clears every definition at each match; `#clear(all: true)` inside a worksheet does the same once: back to how it started (with `scope: "inherit"` or `"shared"` the outer definitions stay), and `#clear("x", "f")` forgets only those names. After a `#worksheet[…]` the outer definitions come back; with `scope: "shared"`, its final definitions are merged over them.
///
/// ```typ
/// #show: worksheet.with(clear-at: heading)                    // every heading
/// #show: worksheet.with(clear-at: heading.where(level: 1))    // only top-level ones
/// #show: worksheet.with(clear-at: <exercise>)                 // every element labelled, = Task <exercise>
/// #show: worksheet.with(clear-at: heading, scope: "inherit")  // keep the definitions made before
/// ```
///
/// **Options.** Every option defaults to `auto`, which keeps the current setting, so only what you pass changes. For the whole document: `#show: worksheet.with(digits: 3)`; for a part: `#worksheet(evaluate: false, digits: 2)[…]`; for equations or content it calculates: `#worksheet($R := U/I =$, digits: 2)`; or keep them in a dictionary: `#let opts = (digits: 2, separator: ",")`, then `#worksheet($P := U I =$, ..opts)`. `defined` and `graph` take the same options. Unknown options and values of the wrong type are shown as an error in the document.
///
/// ```typ
/// #import units: V, mA
/// #show: worksheet.with(digits: 3, form: "fraction")   // your defaults, the whole document
/// $U := 5 #V$, $I := 30 mA$
/// #worksheet($I/3 =$, digits: 2)                        // only this equation
/// #worksheet(evaluate: false, multiplication: "times")[Prose and $E = m c^2$ stay as written.]
/// ```
///
/// `form`:
///
/// - `"auto"`: plain numbers as typed (`7.20 kΩ` keeps its zero), arithmetic evaluated (`3450/2 mAh` → 1725 mAh), results rounded to `digits`.
/// - `"decimal"`: everything rounded to `digits`, including what you typed.
/// - `"fraction"`: exact fractions, simplified (`$frac(2, 4) #A$` → ½ A, `I/3` → ⅙ A); values that are no fraction with denominator ≤ `max-denominator` fall back to decimals.
/// - `"input"`: given values exactly as typed (`3450/2 mAh` stays a fraction).
///
/// An explicit unit (`$I = mA$`) always wins, then `preferred-units`, then the non-SI unit of the inputs (h, mAh, bar), then the SI unit with a prefix.
///
/// To reuse your defaults in many documents, keep a small file of your own:
///
/// ```typ
/// // my-defaults.typ
/// #import "@preview/solveng:1.0.0": *
/// #let setup = worksheet.with(digits: 3, multiplication: "times", constants: (imaginary: $j$))
///
/// // in a document
/// #import "my-defaults.typ": *
/// #show: setup
/// ```
///
/// - ..body (content): The content, or equations to calculate.
/// - scope (auto, str): What the worksheet sees and keeps: `"isolated"` (starts empty, its definitions end with it), `"inherit"` (sees the definitions made before, its own end with it) or `"shared"` (sees them, and its definitions stay afterwards, over the outer ones). `auto` (default): isolated for content, shared for equations.
/// - clear-at (none, function, selector, label): Clear every definition at each match: `heading` (every heading), `heading.where(level: n)` (headings of level n) or a label like `<exercise>` (every element with it, e.g. `= Task <exercise>`): the definitions made since are forgotten, like `#clear(all: true)`.
/// - hidden (bool): Calculate without showing what is calculated (only problems are shown): the equations, or the math of the content. Not inherited by nested worksheets.
/// - evaluate (bool): Calculate the math in the content; `false`: only its `#worksheet(…)` calls are. Not inherited by nested worksheets, and not for equations, which are always calculated.
/// - digits (auto, int): Significant digits of computed values, 1…15. Default `4`: `57.5 h`, `123500`.
/// - trailing-zeros (auto, bool): Keep trailing zeros up to `digits` (`2.500 V`). Default `false`.
/// - separator (auto, str): Decimal separator, any string like `","`. `auto` (default): from the document language, `,` for de, fr, it, … and `.` otherwise.
/// - grouping (auto, none, str, symbol, content): Digit grouping for integer parts with 5+ digits, e.g. `sym.space.thin` → `12 345`. Default `none`.
/// - scientific (auto, none, array): `(low, high)`: plain notation while the exponent `e` is in `low ≤ e < high`, else `2.5 · 10⁻⁷`. Default `(-3, 6)`; `none` never switches. Only how results are written: `1.12e4` is 1.12 times the variable `e4`, not a number.
/// - engineering (auto, bool): Engineering notation, exponents in steps of 3. Default `false`.
/// - multiplication (auto, str): `"dot"` (default, `2 · 10⁶`) or `"times"` (`2 × 10⁶`).
/// - form (auto, str): How values are written. `"auto"` (default): as typed, results rounded · `"decimal"`: everything rounded to `digits` · `"fraction"`: exact fractions (`⅙ A`) · `"input"`: given values exactly as typed.
/// - max-denominator (auto, int): Largest denominator for `form: "fraction"`. Default `1000`.
/// - fractions (auto, str): How fractions are written: `"stacked"` (default) or `"slash"` (`1/2`).
/// - prefixes (auto, str, none, array): Prefixes picked for results: `"all"` (default: a f p n µ m k M G T; times from a minute on in min or h, not ks), `none` (base unit only) or an array like `("m", "k")` (`"u"` = µ).
/// - show-si (auto, bool): `defined` also shows the SI value (`Q₀ = 3450 mAh = 12420 C`). Default `false`.
/// - preferred-units (auto, content, array): Units for results and graph axes of their dimension, as math expressions of unit values: `($#m / #s$, $kWh$)`, before input units and automatic SI prefixes.
/// - approximate (auto, bool): Write `≈` when the shown result is rounded. Default `true`.
/// - block (auto, bool): Display equations (centred, default) or inline.
/// - max-solutions (auto, int): How many solutions are listed; all are found, `root` picks among all.
/// - defined-style (auto, str): How `defined` looks: `"grid"` (default: columns side by side, aligned at `=`), `"column"`, `"inline"` or `"list"`.
/// - errors (auto, str): `"document"` (default): problems are shown as red notes · `"panic"`: stop the compilation.
/// - show-types (auto, str): How types (`f(I: mA)`) are shown in the equations as written: `"chip"` (default): as a blue chip · `"plain"`: as written, f(I: mA) · `"no"`: left out (`$f(I: mA) := 2 I$` shows as f(I) ≔ 2 I).
/// - words (auto, dictionary): The word shown for any-unit types, for documents in other languages: `(any: "beliebig")`. What you type stays `any`.
/// - chips (auto, dictionary, function): The colours of the type chips, `(type: (fill: …, mark: …, ink: …))` (`mark` is the colour of `:`, `ink` the unit's), or a function `(kind, mark, unit) => content` drawing them, with `kind` `"type"` and `mark` and `unit` as content. In HTML export `dark: (fill: …, mark: …, ink: …)` beside them gives the colours of a dark page; a colour set only for the light page keeps there.
/// - unit-style (auto, function): A function given every shown unit as content, `u => text(fill: blue, u)`.
/// - unit-separator (auto, content, str, symbol): What goes between units, a thin dot by default (A·as): `sym.times`, `h(0.2em)`.
/// - constants (auto, dictionary): How constants are shown, by identity: `(imaginary: $j$, "standard-gravity": $g_0$)`, over the built-in displays of `pi` (π), `euler` (e), `imaginary` (i) and `speed-of-light` (c) and the ones of the worksheets around. Results show them the same way. See `constant`.
/// - graph-colors (auto, color, array): The colors of the curves in graphs, curve after curve and repeating: `(gray, blue, rgb("#f98eff"))`. Default: Petroff's ten colors, chosen to stay apart for color-blind readers. `auto` keeps the worksheet's around, also for a single curve: `(auto, red)` changes only the second (and fourth, …). A graph's `colors` goes over it, the same way.
/// - graph-lines (auto, str, array, dictionary, none): The lines of the curves in graphs, like `graph-colors`: Typst dash patterns such as `"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, or lengths like `(4pt, 2pt)`; `none` draws a curve without lines. Default `("solid", "dashed", "dotted", "dash-dotted")`. A graph's `lines` goes over it.
/// - graph-dots (auto, str, array, none): The dots of the curves in graphs, like `graph-colors`: `"circle"`, `"square"`, `"triangle"`, `"triangle-down"`, `"diamond"`, `"pentagon"`, `"hexagon"`, `"star"`, `"cross"`, `"plus"`; `none` draws a curve without dots. Default `("circle", "square", "triangle", "diamond")`. A graph's `dots` goes over it.
/// - graph-joined (auto, bool, array): Whether everything a curve in a graph draws is joined with a line, like `graph-colors`. Default `false`. A graph's `joined` goes over it.
/// -> content
#let worksheet(
  ..body,
  scope: auto, clear-at: none, hidden: false, evaluate: true,
  digits: auto, trailing-zeros: auto, separator: auto, grouping: auto, scientific: auto, engineering: auto, multiplication: auto, form: auto, max-denominator: auto, fractions: auto,
  prefixes: auto, show-si: auto, preferred-units: auto,
  approximate: auto, block: auto, max-solutions: auto,
  defined-style: auto, errors: auto, show-types: auto,
  words: auto, chips: auto, unit-style: auto, unit-separator: auto, constants: auto,
  graph-colors: auto, graph-lines: auto, graph-dots: auto, graph-joined: auto,
) = {
  let pos = body.pos()
  if body.named().len() > 0 {
    let k = body.named().keys().first()
    if k in ("inherit", "export") { return _err-now(k + " was replaced by scope: \"isolated\" | \"inherit\" | \"shared\" (inherit: true is scope: \"inherit\", inherit and export: true is scope: \"shared\")") }
    return _err-now("unknown argument '" + k + "' for worksheet (arguments: scope, clear-at, hidden, evaluate and the options " + _DEF.keys().join(", ") + ")")
  }
  let lc = _check(_given((
    digits: digits, trailing-zeros: trailing-zeros, separator: separator, grouping: grouping, scientific: scientific, engineering: engineering, multiplication: multiplication, form: form, max-denominator: max-denominator, fractions: fractions,
    prefixes: prefixes, show-si: show-si, preferred-units: preferred-units,
    approximate: approximate, block: block, max-solutions: max-solutions,
    defined-style: defined-style, errors: errors, show-types: show-types,
    words: words, chips: chips, unit-style: unit-style, unit-separator: unit-separator, constants: constants,
    graph-colors: graph-colors, graph-lines: graph-lines, graph-dots: graph-dots, graph-joined: graph-joined,
  )))
  if _E(lc) { return _err-now(lc.err) }
  if type(hidden) != bool { return _err-now("hidden: true or false, got " + _tn(hidden)) }
  if type(evaluate) != bool { return _err-now("evaluate: true or false, got " + _tn(evaluate)) }
  if scope != auto and scope not in _CH.scope { return _err-now("scope: auto, \"isolated\", \"inherit\" or \"shared\", got " + repr(scope)) }
  let eqs = pos.len() > 0 and pos.all(x => type(x) == content and x.func() == math.equation)
  let scope = if scope != auto { scope } else if eqs { "shared" } else { "isolated" }
  let finish(d) = {
    let outer = d.at("^")
    // what the last line gave stays readable afterwards, whatever the scope
    let last = if "last" in d { (last: d.last) } else { (:) }
    if scope == "shared" { outer + (env: _p.merge(_env(outer), _env(d))) + last } else { outer + last }
  }
  let out = if eqs {
    if clear-at != none { return _err-now("clear-at is for a worksheet's content, #worksheet[…]") }
    if not evaluate { return _err-now("evaluate: false is for a worksheet's content, #worksheet(evaluate: false)[…]; equations passed to worksheet are always calculated") }
    let shown = pos.map(x => _math-def(x, quiet: hidden)).join()
    if scope == "shared" { shown } else {
      _st.update(d => { let inner = if scope == "inherit" { d } else { (:) }; inner.insert("^", d); inner })
      shown
      _st.update(finish)
    }
  } else {
    let b = pos.at(0, default: [])
    if pos.len() != 1 or type(b) != content { return _err-now("worksheet takes content, #worksheet[…], or equations, #worksheet($U := 5 V$)") }
    let level = if type(clear-at) == selector { repr(clear-at).match(regex("^heading\\.where\\(level: (\\d+)\\)$")) } else { none }
    if not (clear-at == none or clear-at == heading or type(clear-at) == label or (type(clear-at) == selector and (repr(clear-at) == "heading" or (level != none and int(level.captures.first()) > 0)))) {
      return _err-now("clear-at: none, heading, heading.where(level: n) or a label like <exercise>, got " + repr(clear-at)) + b
    }
    // "^": the state outside, restored at the end; "^0": the state at the start, for clear-at and clear(all: true)
    _st.update(d => { let n = if scope == "isolated" { (:) } else { d }; n.insert("^", d); n.insert("^0", n); n })
    _cf.update(c => c + ("#blocks": _blocks(c) + 1, "#evaluate": (evaluate,) + c.at("#evaluate", default: ())))
    _rules(b, clear-at, hidden)
    _block-note
    _cf.update(c => c + ("#blocks": _blocks(c) - 1, "#evaluate": c.at("#evaluate").slice(1)))
    _st.update(finish)
  }
  if lc.len() == 0 and scope != "isolated" { out } else {
    // displays of constants add to the ones around
    let up(c) = _merge(c, lc) + (if "constants" in lc { (constants: c.at("constants", default: (:)) + lc.constants) } else { (:) }) + ("^": c)
    _cf.update(up)
    out
    _cf.update(c => c.at("^"))
  }
}
