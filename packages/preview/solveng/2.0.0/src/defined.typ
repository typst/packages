// defined().
#import "api.typ": *

/// Lists the definitions made so far, in order.
///
/// ```typ
/// #import units: kΩ, V
/// #show: worksheet
/// $R := 7.2 kΩ$, $U := 5 #V$, $I := U/R$, $f(x) := x^2$
/// #defined()                                          // everything, in columns side by side
/// #defined(kinds: "given")                             // only plain values (also "computed", "function")
/// #defined(names: regex("^R"), style: "column")      // a regex, or a function name => bool
/// #defined(show-si: true, digits: 3)                  // any option, for this list only
/// ```
///
/// Styles (`style:` here, option `defined-style` for all of them):
///
/// - `"grid"` (default): as many columns side by side as fit, filled top to bottom, each aligned at `=`. In HTML the columns reflow with the window width.
/// - `"column"`: one column aligned at `=` (in HTML a table).
/// - `"inline"`: comma separated in the text.
/// - `"list"`: bullets.
///
/// - names (str, regex, function, array): Definition names to show; strings match names literally, except "all".
/// - kinds (str, array): given, computed or function; all three by default.
/// - where (function): Additional predicate on each definition name.
/// - style (auto, str): `"grid"`, `"column"`, `"inline"` or `"list"`, see above. `auto`: the option `defined-style` (default `"grid"`).
/// - show-si (auto, bool): Also show the SI value: `Q₀ = 3450 mAh = 12420 C`.
/// - digits, decimal-separator, number-form, … (auto): Every option of `worksheet` works here too, for this call only.
/// -> content
#let defined(
  ..args, names: "all", kinds: ("given", "computed", "function"), where: name => true,
  style: auto,
  digits: auto, trailing-zeros: auto, decimal-separator: auto, grouping: auto, notation-thresholds: auto, notation: auto, multiplication: auto, number-form: auto,
  max-denominator: auto, fraction-style: auto, prefixes: auto, show-si: auto, preferred-units: auto,
  show-approximation: auto, block: auto, max-solutions: auto, errors: auto, show-types: auto,
  words: auto, chips: auto, unit-style: auto, unit-separator: auto, constant-displays: auto,
) = _mine(context {
  if args.pos().len() > 0 { return _err-now("defined takes named arguments") }
  if args.named().len() > 0 { return _err-now("unknown argument '" + args.named().keys().first() + "' for defined") }
  let lc = _check(_given((defined-style: style, digits: digits, trailing-zeros: trailing-zeros, decimal-separator: decimal-separator, grouping: grouping, notation-thresholds: notation-thresholds, notation: notation, multiplication: multiplication, number-form: number-form, max-denominator: max-denominator, fraction-style: fraction-style, prefixes: prefixes, show-si: show-si, preferred-units: preferred-units, show-approximation: show-approximation, block: block, max-solutions: max-solutions, errors: errors, show-types: show-types, words: words, chips: chips, unit-style: unit-style, unit-separator: unit-separator, constant-displays: constant-displays)))
  if _E(lc) { return _errc(lc.err, _cf.get(), wide: true) }
  let outer = _cf.get()
  let cf0 = outer + lc + (constant-displays: outer.at("constant-displays", default: (:)) + lc.at("constant-displays", default: (:)))
  let kinds = if type(kinds) == str { (kinds,) } else { kinds }
  if type(kinds) != array or kinds.any(k => k not in ("given", "computed", "function")) { return _errc("kinds: given, computed or function", cf0, wide: true) }
  if type(where) != function { return _errc("where: a predicate on a definition name", cf0, wide: true) }
  let ok(p) = p == none or type(p) in (str, regex, function) or (type(p) == array and p.all(ok))
  if not ok(names) { return _errc("names: use \"all\", a name, regex or function", cf0, wide: true) }
  let named(e, p) = if type(p) == str { p == "all" or e.name == p } else if type(p) == array { p.any(x => named(e, x)) } else if type(p) == regex { e.name.match(p) != none } else if p == none { false } else { p(e.name) }
  let es = _rows(_st.get(), cf0).filter(e => e.listed and e.kind in kinds and named(e, names) and where(e.name))
  if es.len() == 0 { return }
  let rows = es.map(e => ($#_m(e.lhs, cf0)$, e.values.map(v => _m(v, cf0)), if e.rel == "=" { $=>$ } else { _m(e.rel, cf0) }))
  let style = cf0.defined-style
  let eqs = rows.map(((nm, vs, r0)) => (nm, vs.enumerate().map(((i, v)) => if i == 0 { $#r0 #v$ } else { $= #v$ }).join()))
  if style == "list" { std.list(..eqs.map(((nm, v)) => $#nm #v$)) }
  else if style == "inline" { eqs.map(((nm, v)) => $#nm #v$).join(", ") }
  else if _target() == "html" and style == "column" {
    // a table aligned at '=': name | = | value | = SI value
    _css()
    let td(c, al) = html.elem("td", attrs: (style: "text-align: " + al), c)
    let n = calc.max(..rows.map(r => r.at(1).len()))
    html.elem("table", attrs: (class: "solveng-list"),
      rows.map(((nm, vs, r0)) => html.elem("tr", td($#nm$, "right") + range(n).map(i => if i < vs.len() { td(if i == 0 { $#r0$ } else { $=>$ }, "center") + td($#vs.at(i)$, "left") } else { td([], "left") + td([], "left") }).join())).join())
  } else if _target() == "html" {
    // CSS columns flow top to bottom and reflow with the width; sizes measured with Typst's fonts, plus slack for the browser's
    _css()
    let em(c) = measure($#c$).width / text.size
    let nw = calc.max(..eqs.map(((nm, _)) => em(nm))) * 1.15 + 0.2
    let vw = calc.max(..eqs.map(((_, v)) => em(v))) * 1.15 + 1
    html.elem("div", attrs: (class: "solveng-defs", style: "--n: " + str(calc.round(nw, digits: 2)) + "em; --w: " + str(calc.round(nw + vw, digits: 2)) + "em"),
      eqs.map(((nm, v)) => html.elem("div", html.elem("span", $#nm$) + html.elem("span", $#v$))).join())
  } else if style == "column" { _eqn(eqs.map(((nm, v)) => $#nm & #v$.body).join(linebreak()), cf0 + (block: true)) }
  else {
    // as many columns as fit, filled top to bottom, each aligned at '='
    std.block(width: 100%, std.layout(size => {
      let cells = eqs.map(((nm, v)) => ($#nm$, $#v$))
      let ws = cells.map(((a, b)) => (measure(a).width, measure(b).width))
      let (g, sp) = (2.5em.to-absolute(), 0.3em.to-absolute())
      // widths per column for n columns: (rows, ((name, value), …))
      let fit(n) = {
        let rows = calc.ceil(cells.len() / n)
        let cs = range(calc.ceil(cells.len() / rows)).map(c => ws.slice(c * rows, calc.min((c + 1) * rows, ws.len())))
        (rows, cs.map(c => (calc.max(..c.map(w => w.at(0))), calc.max(..c.map(w => w.at(1))))))
      }
      // the most columns that fit; one column at least
      let width(cw) = cw.map(((a, b)) => a + sp + b).sum() + g * (cw.len() - 1)
      let (rows, cw) = range(cells.len(), 0, step: -1).map(fit).find(((_, cw)) => cw.len() == 1 or width(cw) <= size.width)
      let n = cw.len()
      let out = ()
      for r in range(rows) {
        for c in range(n) {
          let i = c * rows + r
          let (a, b) = cells.at(i, default: ([], []))
          out += (a, b)
          if c < n - 1 { out.push([]) }
        }
      }
      align(center, grid(columns: cw.enumerate().map(((c, w)) => w + if c < n - 1 { (g - 2 * sp,) } else { () }).flatten(), column-gutter: sp, row-gutter: 0.75em, align: (x, _) => (if calc.rem(x, 3) == 0 { right } else { left }) + horizon, ..out))
    }))
  }
})
