#import "../src/tree.typ": normalize, prune
#set page(width: auto, height: auto)

// a three-level tree
#let t = normalize((content: [A], children: (
  (content: [B], children: ((content: [C], children: ()),)),
)))

// max-depth 1 → grandchildren (C) are cut, B stays
#let p = prune(t, 1)
#assert.eq(p.children.len(), 1)
#assert.eq(p.children.at(0).children.len(), 0)

// max-depth 0 → the root alone
#let p0 = prune(t, 0)
#assert.eq(p0.children.len(), 0)

#[OK]
