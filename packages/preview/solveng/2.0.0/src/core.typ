// clear.
#import "engine.typ": *

// ---------- public API ----------

#let _restart(d) = if "^0" in d { let z = d.at("^0"); z.insert("^0", z); z } else { (:) }
/// Forgets definitions: the names given, or with `all: true` every one made so far.
///
/// A value and a function share their name – defining one replaces the other – so `clear("f")` forgets `f` either way (`"f()"` and `"f(x)"` are read the same). Names are written as strings (`"Q_0"`, `"tau"`) or in math (`$Q_0$`). A name that isn't defined is shown as a problem. With `all: true` inside a `worksheet` it's back to how the worksheet started (with `scope: "inherit"` the outer definitions stay). Units, constants and operations are bindings, not definitions: `clear` leaves them alone.
///
/// ```typ
/// #import units: mA, A, V
/// #show: worksheet
/// $I := 30 mA$, $f(x) := 2 x$, $U := 5 #V$
/// #clear("I", $f$)
/// $I := 1 #A$
/// #clear(all: true)
/// $U := 12 #V$
/// ```
///
/// - ..names (str, content): The names to forget, as strings or math.
/// - all (bool): Forget every definition instead.
/// -> content
#let clear(..names, all: false) = {
  if names.named().len() > 0 { return _err-now("unknown argument '" + names.named().keys().first() + "' for clear (arguments: the names, all)") }
  if type(all) != bool { return _err-now("clear: all: true or false, got " + _tn(all)) }
  let ns = names.pos()
  if all {
    if ns.len() > 0 { return _err-now("clear: either names or all: true, not both") }
    return _st.update(_restart)
  }
  if ns.len() == 0 { return _err-now("clear: which names – clear(\"x\", \"f\") – or every one, clear(all: true)") }
  let bad = ns.filter(n => type(n) != str and not (type(n) == content and n.func() == math.equation))
  if bad.len() > 0 { return _err-now("clear: names as strings or math, clear(\"x\", $f$), got " + _tn(bad.first())) }
  let req = ns.map(n => if type(n) == str { n } else { let s = _src(n.body); if _E(s) { repr(n.body) } else { s } })
  _st.update(s => {
    let r = _call(_p.clear, _env(s), (names: req))
    s + (env: r.env, last: _out(errors: r.errors, operation: "clear"))
  })
  context { let cf = _cf.get(); let errors = _st.get().last.errors; errors.map(m => _errc(m, cf, wide: true)).join() + errors.map(m => [#metadata((kind: "error", element: none, message: m, source: ""))<solveng>]).join() }
}
