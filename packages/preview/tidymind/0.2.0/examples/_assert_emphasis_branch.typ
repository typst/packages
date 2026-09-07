// Branch and emphasis must survive normalization and pruning: the caller speaks
// by NAME (branch index, node role) and the package resolves the color. If
// `normalize` drops either one, the drawing silently loses the author's intent.
#import "../src/tree.typ": normalize, prune
#set page(width: auto, height: auto)

#context {
  let t = normalize((
    content: [Root],
    children: (
      (content: [Branch], branch: 5, children: (
        (content: [Leaf], emphasis: "warning", children: ()),
      )),
    ),
  ))

  assert(t.branch == none, message: "the root declares no branch")
  assert(t.children.at(0).branch == 5, message: "an explicit branch must survive")
  assert(
    t.children.at(0).children.at(0).emphasis == "warning",
    message: "emphasis must survive normalization",
  )

  // Pruning cuts children, not attributes.
  let p = prune(t, 1)
  assert(p.children.len() == 1)
  assert(p.children.at(0).branch == 5, message: "pruning must not erase the branch")
  assert(p.children.at(0).children.len() == 0)
}
