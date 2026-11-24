// Scope-wide defaults for `diagram()`.
//
// `#set` is reserved by the language for *element* functions, so
// `#set zx.diagram(..)` is a hard compile error and no package can change
// that. Three mechanisms cover the same ground — see "Setting defaults" in
// `docs/API.md`:
//
//   1. `zx.diagram.with(..)` — Typst's own partial application. The idiomatic
//      choice, free at runtime, and `let`-shadowing gives scoped defaults.
//   2. `#set text(..)` — already works: labels are set in `1em` and inherit
//      the surrounding text style.
//   3. `config()` — this function, for when the call sites are not yours to
//      change (e.g. diagrams inside an `#include`d chapter). It is the only
//      one of the three that reaches those, and the only one needing `state`.
//
#import "style.typ": merge-style, merge-per-kind

// Implemented as a *stack* in state so scopes nest properly and a nested
// `config()` reverts cleanly when it ends. The state is read during the
// diagram's existing contextual layout work; it does not add another pass.

#let defaults-state = state("@local/cvzx:0.2.0/config-defaults", ((:),))

#let config-keys = (
  "scale", "scale-edges", "font-size", "grid", "inset", "anchor",
  "math-axis", "baseline", "port-spacing", "node-styles", "edge-styles",
)

// The defaults in force at this point in the document. Must be called from
// inside a `context` block (`diagram()` already is one).
#let current-defaults() = defaults-state.get().last()

/// Sets `diagram()` defaults for everything in `body`. Accepts the same
/// named arguments as `diagram()` — `scale`, `scale-edges`, `font-size`,
/// `grid`, `inset`, `anchor`, `math-axis`, `baseline`, `port-spacing`, `node-styles`,
/// `edge-styles` — and they apply to every diagram in the scope that does
/// not override them itself:
///
/// ```typc
/// #show: zx.config.with(font-size: 9pt, scale: 0.8cm)   // whole document
/// ```
///
/// or, for one section only:
///
/// ```typc
/// #zx.config(font-size: 7pt)[
///   ... diagrams here are small ...
/// ]
/// ```
///
/// `node-styles`/`edge-styles` merge with (rather than replace) the
/// package defaults, and a diagram's own `node-styles:` merges on top of
/// the configured ones.
#let config(body, ..opts) = {
  assert(opts.pos().len() == 0, message: "config() takes only named arguments, plus the body")
  let given = opts.named()
  let unknown = given.keys().filter(key => key not in config-keys)
  assert(
    unknown.len() == 0,
    message: "unknown config option(s) " + unknown.map(repr).join(", ")
      + " — available: " + config-keys.map(repr).join(", "),
  )
  defaults-state.update(stack => {
    let next = stack.last()
    for (key, value) in given {
      if key == "node-styles" {
        next.insert(key, merge-per-kind(next.at(key, default: (:)), value))
      } else if key == "edge-styles" {
        next.insert(key, merge-style(next.at(key, default: (:)), value))
      } else {
        next.insert(key, value)
      }
    }
    stack + (next,)
  })
  body
  defaults-state.update(stack => if stack.len() > 1 { stack.slice(0, -1) } else { stack })
}
