// A label on the left side ends where its edge arrives: a wrapped label is
// right-aligned there, so its lines meet the edge instead of leaving a gap
// before it. Alignment never changes the box, so measuring (which does not
// know the side) still reserves exactly what is drawn. And the document's own
// alignment (a map inside a centered figure) does not leak into a label.
#import "@preview/tidymind:0.3.0": mindmap, node
#import "../src/options.typ": make-opts
#import "../src/tree.typ": normalize
#import "../src/layout.typ": dressing, measure-node
#import "../src/style.typ": node-body, node-paint, node-spec
#set page(width: auto, height: auto, margin: 0pt)

#let opts = make-opts(style: "technical", markers: "role", node-max-width: 3cm)
#let wl = [Whole-message store-and-forward]
#let dress = dressing(normalize((content: wl, emphasis: "definition")), 2, 0, opts)
#let spec = node-spec("technical", 2, emphasized: dress.emphasized, surfaced: dress.surfaced)
#let paint = node-paint(spec, 2, red, opts.ink, none, role: blue)
#let body(c, side, width) = node-body(c, spec, paint, opts.font, opts.text-size, width: width,
  number: dress.number, tag: dress.tag, mono-font: opts.mono-font, side: side)

// The same box on either side, natural and wrapped.
#context {
  let reserved = measure-node(wl, 2, opts, dress)
  for width in (auto, reserved.w * 1pt) {
    let l = measure(body(wl, -1, width))
    let r = measure(body(wl, 1, width))
    assert(l == r, message: "the side changed the box at width " + repr(width))
  }
  let drawn = measure(body(wl, -1, reserved.w * 1pt))
  assert(drawn.height.pt() > 1.8 * measure(body([X], -1, auto)).height.pt(), message: "the test label should wrap")
  assert(calc.abs(drawn.width.pt() - reserved.w) < 0.001 and calc.abs(drawn.height.pt() - reserved.h) < 0.001,
    message: "a left-side label: reserved box differs from drawn box")
}

// Where the last line ends: a probe at the end of the label, in a box wider
// than the text. Inside a centered block, so a leaked alignment shows too.
#let probe(side, name) = body([Store and forward#box(width: 0pt)[#metadata(name) <probe>]], side, 6cm)
#align(center, block(width: 10cm, context {
  probe(1, "end-right")
  linebreak()
  probe(-1, "end-left")
}))

#context {
  let found(name) = query(<probe>).filter(m => m.value == name)
  assert(query(<probe>).len() == 2, message: "both probes should be laid out")
  if found("end-right").len() > 0 and found("end-left").len() > 0 {
    let r = found("end-right").first().location().position().x
    let l = found("end-left").first().location().position().x
    let start = (10cm - 6cm) / 2
    // Right side: the text starts at the left inset, so it ends well before the right edge.
    assert(r < start + 4cm, message: "a right-side label should be left-aligned, ends at " + repr(r))
    // Left side: the text ends at the right edge, minus the inset.
    let edge = start + 6cm - spec.inset.x
    assert(calc.abs(l - edge) < 0.5pt, message: "a left-side label should end at its right edge: " + repr(l) + " vs " + repr(edge))
  }
}

// In a map: a wrapped leaf on the left ends where its edge starts. The leaf's
// right edge is the root's left edge minus the gap; a probe at the start of
// the root and at the end of the leaf measures both.
#let gap = 30pt
#mindmap(
  node([#box(width: 0pt)[#metadata(none) <root-start>]Root],
    node([Whole-message store-and-forward#box(width: 0pt)[#metadata(none) <leaf-end>]])),
  style: "outline", direction: "left", node-max-width: 2.6cm, h-gap: gap,
)
#context {
  let r = query(<root-start>)
  let e = query(<leaf-end>)
  assert(r.len() == 1 and e.len() == 1, message: "the map probes should be laid out")
  if r.len() > 0 and e.len() > 0 {
    let root-x = r.first().location().position().x
    let leaf-end = e.first().location().position().x
    // outline: the root's left inset is 2pt, a branch's right inset 3pt.
    let expected = root-x - 2pt - gap - 3pt
    assert(calc.abs(leaf-end - expected) < 0.5pt,
      message: "a wrapped left-side leaf should end at its edge: " + repr(leaf-end) + " vs " + repr(expected))
  }
}
#[OK]
