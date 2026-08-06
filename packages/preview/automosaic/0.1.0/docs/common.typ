// Explanatory figure for the README, built with the package's own functions
// (dogfooding `display-content-tree` / `display-auto-layout` as the diagram
// renderer instead of hand-drawing boxes). Regenerate with:
//
//   cd packages/mosaic && typst compile --root . docs/figure.typ docs/how-it-works.png --format png --ppi 300

#import "../lib.typ": *

#let palette = (
  rgb("#3b82f6"), // blue
  rgb("#f97316"), // orange
  rgb("#10b981"), // green
  rgb("#a855f7"), // purple
  rgb("#ef4444"), // red
  rgb("#eab308"), // yellow
)

// Frame/chip colors for panel 2's nesting levels are deliberately a
// grayscale ramp, *not* drawn from `palette`: a frame doesn't correspond to
// any single leaf inside it (e.g. the "sub-group" frame wraps a red leaf and
// a whole other sub-group), so coloring it like a leaf would falsely imply
// that correspondence. Darker = shallower (closer to the top-level).
#let frame-colors = (
  rgb("#1e293b"), // top-level
  rgb("#475569"), // sub-group
  rgb("#64748b"), // sub-sub-group
)

// A colored "leaf" for the diagrams: a swatch with an explicit aspect ratio
// (so `make-content-dict` never needs to `measure()` it) and a label.
#let swatch(color, label, aspect: 1.0, weight: 1.0) = (
  body: box(width: 100%, height: 100%, fill: color, radius: 3pt)[
    #align(center + horizon, text(fill: white, weight: "bold", size: 10pt, label))
  ],
  aspect: aspect,
  weight: weight,
)

// A small pill-shaped annotation, overlaid via `place` so it never consumes
// layout flow space (which would otherwise throw off the aspect computed
// for the container it labels).
#let chip(color, label) = place(top + left, dx: 3pt, dy: -4pt, box(
  fill: color,
  inset: (x: 5pt, y: 2.5pt),
  radius: 2pt,
)[#text(size: 7.5pt, fill: white, weight: "bold", label)])

// A leaf content-dict from a swatch dict (body + aspect). Thin wrapper around
// `make-content-dict` so leaves and `framed-group` results (see below) can be
// combined with the same `combine`/`add-body-to-content-dict` calls.
#let leaf(s) = make-content-dict(s.body, aspect: s.aspect)

// Combine already-resolved content-dicts (leaves and/or nested groups) into
// one group, the same aggregation `parse-content-tree` does for an array --
// but starting from pre-built children instead of raw items, so a group that
// already carries its own `_c_h`/`_c_w` (e.g. from `framed-group`) keeps it.
#let combine(children, axis, gap) = resolve-aspect((
  bodies: children,
  gap: gap,
  _a: auto,
  _c_h: auto,
  _c_w: auto,
  _layout-axis: axis,
  stretchable_: false,
  _h-stretchable: 0,
  _v-stretchable: 0,
))

// Wraps already-built children in a dashed, labeled frame so the parent
// container itself becomes visible, not just its leaves, and returns a leaf
// content-dict for the *outer* group -- built with `make-content-dict` so its
// true `c_h`/`c_w` (not just its aspect) carry through. Forwarding only the
// aspect (e.g. via `parse-content-tree`'s `(body:, aspect:)` item shorthand,
// which can't express an independent c_h *and* c_w) makes the outer group
// size this cell slightly wrong -- exactly enough to leave a gap the size of
// the dropped gap-offset, in the dimension the frame's own axis controls.
// Built entirely from exported building blocks (`resolve-aspect` /
// `resolve-stretchable` / `fit-content-dict` / `make-content-dict`) -- the
// same pipeline `display-content-tree` itself runs -- so this needs no
// changes to the package.
#let framed-group(children, axis: "horizontal", gap: 0.6em, color: black, label: "", outset: 2pt) = {
  let cd = combine(children, axis, gap)
  let visual = box(
    width: 100%,
    height: 100%,
    stroke: (paint: color, thickness: 1pt, dash: "dashed"),
    radius: 4pt,
    outset: outset,
  )[
    #layout(size => fit-content-dict(resolve-stretchable(cd, axis), size))
    #chip(color, label)
  ]
  make-content-dict(visual, aspect: cd._a, c_h: cd._c_h, c_w: cd._c_w)
}

// ── Code snippets ────────────────────────────────────────────────────────────
//
// Each panel gets the plain, idiomatic call a user would actually write --
// *not* the `leaf`/`combine`/`framed-group` plumbing above, which only exists
// to draw dashed frames for illustration. Only the lines that reference a
// leaf are colored, matching that leaf's swatch, so the code and the diagram
// below it read as the same thing; structural syntax (the call itself,
// `axis:`/`gap:`/`selector:`, the array parens) stays neutral -- coloring
// those wouldn't correspond to anything in the diagram and would just be
// noise.
#let code-neutral = rgb("#6b7280")

#let codeline(txt, color: none) = {
  text(fill: if color == none { code-neutral } else { color }, raw(txt))
  linebreak()
}

#let codeblock(lines) = [
  #block(
    width: 100%,
    fill: rgb("#f8f9fb"),
    stroke: (paint: rgb("#e5e7eb"), thickness: 0.6pt),
    radius: 4pt,
    inset: (x: 8pt, y: 6pt),
  )[
    #set text(size: 7.6pt)
    #for (txt, color) in lines { codeline(txt, color: color) }
  ]
]

#let panel(diagram, width: 100%, height: 6.4cm, frame-label: none, frame-color: none) = [
  #box(
    width: width,
    height: height,
    stroke: (paint: rgb("#cccccc"), thickness: 0.6pt),
    radius: 6pt,
    inset: 0.6em,
    fill: rgb("#fafafa"),
  )[
    #align(center + horizon, diagram)
    #if frame-label != none { chip(frame-color, frame-label) }
  ]
]

#let page-config = (width: 10cm, height: 10cm, margin: 1cm, fill: white)