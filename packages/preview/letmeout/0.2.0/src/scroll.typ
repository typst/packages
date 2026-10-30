// Content that can be wider than the screen scrolls sideways in its own area,
// so the page itself never does: block equations, code blocks, tables, and
// grids, shapes, blocks, and boxes with a fixed width. Neighbouring blocks
// share one scroll area, so a run of wide equations has a single scrollbar.
// A scroll area inside another one does not scroll on its own.
#import "page.typ": kind, invisible
#import "adapters.typ": math-marker
#import "css.typ": size, sides

#let scroll-css = (
  // `clip`, unlike `hidden`, keeps sticky elements working.
  "body, .letmeout-page { overflow-x: clip; }"
  // Scrolling also clips vertically. The padding, cancelled by the margin,
  // gives tall glyphs room, and strokes and outsets that reach past the
  // content (`--letmeout-bleed`).
  + " .letmeout-scroll { overflow-x: auto; overflow-y: hidden;"
  + " padding: calc(0.25em + var(--letmeout-bleed)) var(--letmeout-bleed);"
  + " margin: calc(-0.25em - var(--letmeout-bleed)) calc(-1 * var(--letmeout-bleed)); }"
  // An inline flex box keeps the baseline of its content, unlike an inline
  // block that scrolls.
  + " .letmeout-scroll-inline { display: inline-flex; max-width: 100%; overflow-x: auto; overflow-y: hidden;"
  + " padding: var(--letmeout-bleed); margin: calc(-1 * var(--letmeout-bleed)); }"
  + " .letmeout-scroll-inline > * { flex-shrink: 0; }"
  + " :is(.letmeout-scroll, .letmeout-scroll-inline) :is(.letmeout-scroll, .letmeout-scroll-inline)"
  + " { overflow: visible; padding: 0; margin: 0; max-width: none; }"
  // Code blocks have margins of their own. In a scroll area they would no
  // longer merge with the text around it, so the outer ones go.
  + " .letmeout-scroll:not(.letmeout-scroll *) > pre:first-child,"
  + " .letmeout-scroll:not(.letmeout-scroll *) > :first-child > pre:first-child { margin-top: 0; }"
  + " .letmeout-scroll:not(.letmeout-scroll *) > pre:last-child,"
  + " .letmeout-scroll:not(.letmeout-scroll *) > :last-child > pre:last-child { margin-bottom: 0; }"
  // Paper cannot scroll, and a scroll area would be cut off at the page end.
  + " @media print { .letmeout-scroll, .letmeout-scroll-inline { overflow: visible; } }"
)

// Whether a width or height stays the same on every screen.
#let fixed(value) = {
  if value == auto or type(value) in (fraction, ratio) { return false }
  let length = if type(value) == relative { value.length } else { value }
  length.abs != 0pt or length.em != 0
}

#let shapes = (rect, square, circle, ellipse, block)

// Whether a block-level element can be wider than the screen. Style nodes
// count by what they style. Before an element is shown, only the fields
// written out are known; set rules show later, in `scroll-rules`.
#let wide(it) = {
  if kind(it) == "styled" { return wide(it.child) }
  let f = it.func()
  if f == math.equation or f == raw { return it.at("block", default: false) }
  if f == table { return true }
  if f == grid { return it.at("columns", default: ()).any(fixed) }
  if f in shapes {
    let field(name) = it.at(name, default: auto)
    return fixed(field("width")) or (f in (square, circle) and fixed(field("height")))
  }
  false
}

// How far strokes and outsets of a shape or box reach past it. Needs context.
#let bleed(it) = {
  if kind(it) == "styled" { return bleed(it.child) }
  let f = it.func()
  if f not in shapes + (box,) { return 0pt }
  let thickness(v) = {
    if v == none { 0pt }
    else if v == auto { 1pt }
    else {
      let t = stroke(v).thickness
      if t == auto { 1pt } else { t.to-absolute() }
    }
  }
  let s = it.at("stroke", default: auto)
  // Shapes without a fill have a default stroke.
  if s == auto and f not in (block, box) and it.at("fill", default: none) == none { s = 1pt }
  let reach(v) = if v == none or v == auto or type(v) == ratio { 0pt }
    else if type(v) == relative { v.length.to-absolute() } else { v.to-absolute() }
  let strokes = sides(s).values().map(thickness)
  let outsets = sides(it.at("outset", default: 0pt)).values().map(reach)
  calc.max(0pt, ..strokes) / 2 + calc.max(0pt, ..outsets)
}

// The native block tells Typst this is block content, so the text around it
// still becomes paragraphs. Without styling it adds no element of its own;
// equations make blocks unbreakable, which would.
#let scroll(body, reach: 0pt, minimum: none) = {
  let attrs = (class: "letmeout-scroll", style: "--letmeout-bleed: " + size(reach))
  if minimum != none { attrs.insert("data-fit-width", size(minimum)) }
  let area = html.elem("div", attrs: attrs, body)
  if minimum == none { return block(breakable: true, area) }
  // A named size container tests the actual available width, including inside
  // nested cells. Leave overflowing grids scrollable on small screens, but let
  // SVG shadows and other ink overflow freely when the layout fits.
  block(breakable: true, html.elem("div", attrs: (
    class: "letmeout-fit", style: "container: letmeout-fit / inline-size; min-width: 0",
  ), {
    html.elem("style", "@container letmeout-fit (min-width: " + size(minimum) + ") { "
      + ".letmeout-fit > .letmeout-scroll[data-fit-width=\"" + size(minimum)
      + "\"] { overflow: visible; } }")
    area
  }))
}

#let scroll-inline(body, reach: 0pt) = html.elem("span", attrs: (
  class: "letmeout-scroll-inline", style: "--letmeout-bleed: " + size(reach)), body)

// Inside an equation, for example one that a show rule rebuilds, and inside
// `html.frame`, which is laid out like a page, elements stay native. Needs context.
#let native() = target() != "html" or math.equation.supplement == math-marker

// Each wide element scrolls on its own, wherever it ends up.
#let scroll-rules(body) = {
  let blocks = (math.equation.where(block: true), raw.where(block: true), table) + shapes
  show selector.or(..blocks): it => context {
    if native() or not wide(it) { it } else { scroll(it, reach: bleed(it)) }
  }
  show box: it => context {
    if native() or not fixed(it.at("width", default: auto)) { it }
    else { scroll-inline(it, reach: bleed(it)) }
  }
  body
}

// Wraps runs of wide elements in a sequence into one scroll area. Only the
// spaces, breaks, and invisible elements between them join the run. Needs context.
#let group-wide(it) = {
  let k = kind(it)
  if k == "styled" { return it.func()(group-wide(it.child), it.styles) }
  if k != "sequence" { return it }
  let out = ()
  let run = ()
  let members = ()
  let gap = ()
  let close(run, members) = if members.len() > 1 {
    (scroll(run.join(), reach: calc.max(..members.map(bleed))),)
  } else { run }
  for child in it.children {
    if wide(child) {
      run += gap + (child,)
      members.push(child)
      gap = ()
    } else if members.len() > 0 and kind(child) in invisible {
      gap.push(child)
    } else {
      out += close(run, members) + gap + (group-wide(child),)
      (run, members, gap) = ((), (), ())
    }
  }
  (out + close(run, members) + gap).join()
}
