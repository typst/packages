// Shared flow spacing for paragraphs, blocks, and grids. CSS margins collapse
// between neighbours; explicit block edges take precedence over automatic ones.
#import "css.typ": size

#let is-inline-body(it) = {
  let f = it.func()
  if repr(f) == "sequence" { return it.children.all(is-inline-body) }
  if repr(f) == "styled" { return is-inline-body(it.child) }
  if f == html.elem { return it.tag in ("span", "a", "em", "strong", "code", "sub", "sup", "mark", "s", "u", "small", "b", "i") }
  if f in (raw, math.equation, quote) { return not it.at("block", default: false) }
  if repr(f) == "space" { return true }
  if f in (text, linebreak, std.box, std.h, strong, emph, link, super, sub, smallcaps, lower, upper) { return true }
  false
}

#let flow-attrs(above: auto, below: auto) = (
  data-letmeout-flow: "true",
  data-above: if above == auto { "auto" } else { "explicit" },
  data-below: if below == auto { "auto" } else { "explicit" },
)

#let flow-style(above: auto, below: auto) = {
  let edge(v) = {
    if v == auto or type(v) == fraction { v = par.spacing }
    size(if type(v) == length { v.to-absolute() } else { v })
  }
  "--letmeout-above: " + edge(above) + "; --letmeout-below: " + edge(below)
}

#let flow-css = {
  let f = "[data-letmeout-flow]"
  let a = f + "[data-above=auto]"
  let b = f + "[data-below=auto]"
  let v = ".letmeout-v"
  (
    f + " { margin-block-start: var(--letmeout-above); margin-block-end: var(--letmeout-below); }",
    // A flow's outside spacing never leaks into its containing cell or block.
    f + ":first-child, .letmeout-shape-paint + " + f + " { margin-block-start: 0; } " + f + ":last-child { margin-block-end: 0; }",
    // Strong vertical space adds to one collapsed boundary, rather than to
    // both neighbours' automatic margins.
    b + ":has(+ " + v + "[data-weak=false]) { margin-block-end: 0; }",
    // Explicit block edges beat the automatic paragraph/grid spacing.
    b + ":has(+ " + f + "[data-above=explicit]), " + b + ":has(+ " + v + " + " + f + "[data-above=explicit]) { margin-block-end: 0; }",
    f + "[data-below=explicit] + " + a + ", " + f + "[data-below=explicit] + " + v + " + " + a + " { margin-block-start: 0; }",
    "letmeout-grid-flow { display: flow-root; min-width: 0; }",
  ).join("\n")
}

// Split a paragraph into inline runs and fractional boxes. Preserve style
// scopes on each leaf so text around growing boxes remains normal inline text.
#let fractional-leaves(body, wraps: ()) = {
  if repr(body.func()) == "sequence" {
    return body.children.map(it => fractional-leaves(it, wraps: wraps)).flatten()
  }
  if repr(body.func()) == "styled" {
    return fractional-leaves(body.child, wraps: wraps + ((body.func(), body.styles),))
  }
  let fractional = body.func() == std.box and type(body.at("width", default: std.box.width)) == fraction
  let wrapped = wraps.rev().fold(body, (acc, w) => w.at(0)(acc, w.at(1)))
  ((body: wrapped, fractional: fractional),)
}

#let fractional-body(body) = {
  let leaves = fractional-leaves(body)
  if not leaves.any(it => it.fractional) { return none }
  let run = []
  let out = []
  for leaf in leaves {
    if leaf.fractional {
      if run != [] { out += html.span(run); run = [] }
      out += leaf.body
    } else { run += leaf.body }
  }
  if run != [] { out += html.span(run) }
  out
}
