#import "../src/options.typ": make-opts
#import "../src/tree.typ": normalize
#import "../src/layout.typ": measure-tree, layout-tree
#set page(width: auto, height: auto)

#context {
  let opts = make-opts(style: "technical")
  let leaf(s) = (content: s,)
  let t = normalize((content: [Root], children: (
    (content: [A], children: (leaf[A1], leaf[A2])),
    (content: [Bbbbbbbbbbbbbbbbbbbbbbbbbb], children: (leaf[B1],)),
    (content: [C], children: (leaf[C1], leaf[C2])),
    (content: [D], children: (leaf[D1],)),
  )))
  let m = measure-tree(t, opts)

  // right (default): every child to the right of the root
  let r = layout-tree(m, 40pt, 10pt)
  assert(r.children.all(c => c.side == 1 and c.x >= r.w + 40 - 0.01))

  // left: mirrored; the right edge of each branch sits h-gap left of the root
  let l = layout-tree(m, 40pt, 10pt, direction: "left")
  assert(l.children.all(c => c.side == -1 and calc.abs(c.x + c.w - (-40)) < 0.01))

  // both: split in order, balanced by subtree size, at least one per side
  let b = layout-tree(m, 40pt, 10pt, direction: "both")
  let right = b.children.filter(c => c.side == 1)
  let left = b.children.filter(c => c.side == -1)
  assert(right.len() >= 1 and left.len() >= 1)
  assert(right.at(0).content == [A], message: "the first branches go right")
  // grandchildren follow their branch's side
  assert(left.all(c => c.children.all(g => g.side == -1 and g.x + g.w <= c.x + 0.01)))

  // both with a single branch: it goes right and nothing breaks
  let one = layout-tree(measure-tree(normalize((content: [R], children: (leaf[Only],))), opts), 40pt, 10pt, direction: "both")
  assert(one.children.len() == 1 and one.children.at(0).side == 1)

  // align-levels: every depth-2 node on the same side starts at the same x
  let a = layout-tree(m, 40pt, 10pt, align-levels: true)
  let xs = a.children.map(c => c.children.map(g => g.x)).flatten()
  assert(xs.all(x => calc.abs(x - xs.at(0)) < 0.01), message: "aligned columns")
  // without it, a grandchild sits right after its own parent
  let free = layout-tree(m, 40pt, 10pt)
  assert(free.children.at(0).children.at(0).x < free.children.at(1).children.at(0).x)

  // the root sits between its two sides, on the middle of the taller one
  let span(g) = g.fold(0.0, (acc, c) => acc + c.ext) + 10 * (g.len() - 1)
  assert(calc.abs(b.y - calc.max(span(right), span(left)) / 2) < 0.01)
}
#[OK]
