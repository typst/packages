// A long label is capped at node-max-width (it wraps) instead of growing as a
// single line. `draw.typ` draws the box with `width: n.w`, so the drawing obeys
// exactly this measurement — without it the node overflowed its slot and ran
// off the page.
#import "../src/tree.typ": normalize
#import "../src/layout.typ": measure-tree
#set page(width: auto, height: auto)

#context {
  let long = [CASCADE — revokes, in a chain, every privilege handed down to dependent users and roles]
  let short = [GRANT]
  let mw = 6cm
  let ml = measure-tree(normalize((content: long, children: ())), mw, "Inter", 9pt, "boxed")
  let ms = measure-tree(normalize((content: short, children: ())), mw, "Inter", 9pt, "boxed")
  // long: capped at the maximum width, and taller (it wrapped onto 2+ lines)
  assert(ml.w <= mw.pt() + 0.1, message: "a long label should be capped at node-max-width")
  assert(ml.h > ms.h, message: "a wrapped label should be taller than a short one")
  // short: natural width, below the cap
  assert(ms.w < mw.pt(), message: "a short label should keep its natural width")
}
#[OK]
