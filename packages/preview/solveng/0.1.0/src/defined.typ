// defined().
#import "api.typ": *

/// Lists the definitions made so far, in order.
///
/// ```typ
/// #def("R = 7.2 kOhm", "U = 5 V", "I = U/R", "f(x) = x^2")
/// #defined()                                          // everything, in columns side by side
/// #defined(included: "given")                         // only plain values (also "computed", "function")
/// #defined(excluded: ("U", "function"))               // names and kinds
/// #defined(included: regex("^R"), style: "column")    // a regex, or a function name => bool
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
/// `included` / `excluded` take `"all"`, a kind (`"given"`: plain values, `"computed"`, `"function"`), a name, a regex, a function `name => bool` or an array of these; `excluded` wins. (`include` is a Typst keyword, hence the names.)
///
/// - included (str, regex, function, array): What to list. Default `"all"`.
/// - excluded (none, str, regex, function, array): What to leave out.
/// - style (auto, str): `"grid"`, `"column"`, `"inline"` or `"list"`, see above. `auto`: the option `defined-style` (default `"grid"`).
/// - show-si (auto, bool): Also show the SI value: `Q₀ = 3450 mAh = 12420 C`.
/// - digits, separator, form, … (auto): Every option of `solve-config` (except `units`) works here too, for this call only.
/// -> content
#let defined(
  included: "all", excluded: none, style: auto,
  digits: auto, trailing-zeros: auto, separator: auto, grouping: auto, scientific: auto, engineering: auto, multiplication: auto, form: auto,
  max-denominator: auto, fractions: auto, prefixes: auto, show-si: auto, preferred-units: auto, strict: auto, steps: auto, inline-steps: auto,
  layout: auto, implies: auto, approximate: auto, block: auto, max-solutions: auto, errors: auto,
) = _mine(context {
  let lc = _check(_given((defined-style: style, digits: digits, trailing-zeros: trailing-zeros, separator: separator, grouping: grouping, scientific: scientific, engineering: engineering, multiplication: multiplication, form: form, max-denominator: max-denominator, fractions: fractions, prefixes: prefixes, show-si: show-si, preferred-units: preferred-units, strict: strict, steps: steps, inline-steps: inline-steps, layout: layout, implies: implies, approximate: approximate, block: block, max-solutions: max-solutions, errors: errors)))
  if _E(lc) { return _errc(lc.err, _cf.get(), wide: true) }
  let cf0 = _cf.get() + lc
  let st = _st.get()
  let fns = st.at("#fn", default: (:))
  let ok(p) = p == none or type(p) in (str, regex, function) or (type(p) == array and p.all(ok))
  if not ok(included) or not ok(excluded) { return _errc("included/excluded: use \"all\", a kind, names, a regex or a function", cf0, wide: true) }
  let hit(e, p) = if p == none { false }
    else if type(p) == str { if p == "all" { true } else if p in ("given", "computed", "function") { e.kind == p } else { e.name == p } }
    else if type(p) == array { p.any(x => hit(e, x)) }
    else if type(p) == regex { e.name.match(p) != none }
    else { p(e.name) }
  let es = st.at("!", default: ()).filter(e => e.listed and hit(e, included) and not hit(e, excluded) and (e.name in st or e.name in fns))
  if es.len() == 0 { return }
  let rows = es.map(e => {
    let cf = cf0 + e.cf
    if e.kind == "function" {
      let fn = fns.at(e.name)
      ($#_name(e.name) (#fn.params.map(_name).join($, $))$, (_dp(fn.body, none, cf).at(0),), $=$)
    } else {
      let q = st.at(e.name)
      let U = _UT(cf)
      let si = _auto(q.d, U: U)
      let sv = (raw: none, u: si, n: q.v / _unit(si, U: U).at(0))
      (_name(e.name), if cf.show-si and q.u != si and _ushow(q.u, U: U) != _ushow(si, U: U) { (_qc(q, cf), _qc(sv, cf)) } else { (_qc(q, cf),) }, _relc(q, $=$))
    }
  })
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
      rows.map(((nm, vs, r0)) => html.elem("tr", td($#nm$, "right") + range(n).map(i => if i < vs.len() { td(if i == 0 { $#r0$ } else { $=$ }, "center") + td($#vs.at(i)$, "left") } else { td([], "left") + td([], "left") }).join())).join())
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
