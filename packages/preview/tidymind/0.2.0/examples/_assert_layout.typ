#import "../src/tree.typ": normalize
#import "../src/layout.typ": measure-tree, layout-tree
#set page(width: auto, height: auto)

#context {
  let t = normalize((content: [Root], children: (
    (content: [Child 1],), (content: [Child 2],), (content: [Child 3],),
  )))
  let m = measure-tree(t, 6cm, "Inter", 9pt, "boxed")
  let l = layout-tree(m, 40pt, 10pt)

  // the root sits to the left of its children
  assert(l.x < l.children.at(0).x)
  // siblings share one column
  assert(l.children.at(0).x == l.children.at(2).x)
  // siblings never overlap vertically: the gap between centers is at least the
  // average of their heights
  let y0 = l.children.at(0).y
  let y1 = l.children.at(1).y
  assert(calc.abs(y1 - y0) >= (l.children.at(0).h + l.children.at(1).h) / 2)
  // first-level branches are marked by position; the root is -1
  assert(l.branch-index == -1)
  assert(l.children.at(0).branch-index == 0)
  assert(l.children.at(2).branch-index == 2)
}
#[OK]
