// A node label is a label, not a paragraph. Inside a justified, hyphenated
// document (the common case for a mind map embedded in a report), the label
// used to inherit both: words split with a hyphen and gaps opened between
// them. And the root, capped at the leaves' width, broke mid-word too.
#import "../src/options.typ": make-opts
#import "../src/tree.typ": normalize
#import "../src/layout.typ": dressing, measure-tree, measure-node
#import "../src/style.typ": node-spec
#set page(width: auto, height: auto)
#set text(lang: "pt", hyphenate: true)
#set par(justify: true)

#context {
  // A root wider than the leaves' 4cm cap, but well within its own.
  let root = [Técnicas de Comutação]
  let t = normalize((content: root, children: ((content: [x],),)))

  // The root gets its own cap: at 4cm for leaves and auto (8cm) for the root, it stays on one line.
  let m = measure-tree(t, make-opts(style: "outline", node-max-width: 4cm, root-max-width: 8cm))
  let one-line = measure(text(font: "Inter", size: 9pt * 1.5, weight: "bold")[Técnicas de Comutação])
  assert(m.w < 8cm.pt(), message: "the root should fit its own cap")
  assert(m.w >= one-line.width.pt(), message: "the root should keep its natural width on one line")

  // A root longer than its cap wraps BETWEEN words: no hyphen means the
  // wrapped width never exceeds the cap and every line is a whole word.
  let long = normalize((content: [Comutação Comutação Comutação Comutação Comutação], children: ()))
  let ml = measure-tree(long, make-opts(style: "outline", node-max-width: 4cm, root-max-width: 5cm))
  let word = measure(text(font: "Inter", size: 9pt * 1.5, weight: "bold")[Comutação]).height.pt()
  assert(ml.w <= 5cm.pt() + 0.1, message: "a long root is capped at root-max-width")
  assert(ml.h > word * 2, message: "a long root wraps onto more lines")

  // Hyphenation must not leak into a label. Pick a leaf width where it would
  // SAVE a line: wide enough for "Comutação Comu-" and "tação Comutação"
  // (2 lines, hyphenated), too narrow for "Comutação Comutação". A label that
  // keeps its words whole needs 3 lines there.
  let label = [Comutação Comutação Comutação]
  let spec = node-spec("outline", 2)
  let tw(c) = measure(text(font: "Inter", size: 9pt * spec.scale, weight: spec.weight, hyphenate: false)[#c]).width
  let hyphenated = calc.max(tw[Comutação Comu-], tw[tação Comutação])
  let whole = tw[Comutação Comutação]
  let inset = spec.inset.x * 2
  let w = (hyphenated + whole) / 2 + inset
  assert(w < whole + inset, message: "the width must be too narrow for two whole words")
  let leaf(c, max-w) = {
    let opts = make-opts(style: "outline", node-max-width: max-w)
    measure-node(c, 2, opts, dressing(normalize((content: c)), 2, 0, opts)).h
  }
  let two-lines = leaf([Comutação #linebreak() Comutação], 100cm)
  let h = leaf(label, w)
  assert(h > two-lines, message: "a label keeps its words whole: no hyphenation from the document")
}
#[OK]
