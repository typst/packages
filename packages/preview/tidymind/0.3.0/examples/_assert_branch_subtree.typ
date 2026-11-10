// An explicit `branch` colors the node AND its whole subtree (edges, rules,
// numbers, markers, surfaces), until a descendant sets its own `branch`.
#import "../src/options.typ": make-opts
#import "../src/tree.typ": normalize
#import "../src/layout.typ": measure-tree, layout-tree
#import "../src/draw.typ": _branch-color
#set page(width: auto, height: auto)

#context {
  let opts = make-opts(style: "technical")
  let t = normalize((content: [Root], children: (
    (content: [One], children: ((content: [One.1], children: ((content: [One.1.1],),)),)),
    (content: [Two], branch: 5, children: (
      (content: [Two.1], children: (
        (content: [Two.1.1],),
        (content: [Two.1.2], branch: 1, children: ((content: [Two.1.2.1],),)),
      )),
    )),
    (content: [Three], children: ((content: [Three.1], children: ((content: [Three.1.1],),)),)),
  )))
  let palette = range(6).map(i => rgb(40 * i, 0, 0))
  let idx(n) = palette.position(c => c == _branch-color(n, palette))

  for dir in ("right", "left", "both") {
    let l = layout-tree(measure-tree(t, opts), 40pt, 10pt, direction: dir)
    let (one, two, three) = l.children.sorted(key: c => c.position)
    assert.eq(idx(l), 0, message: "the root keeps the first color")
    assert.eq(idx(one), 0)
    assert.eq(idx(one.children.at(0)), 0)
    assert.eq(idx(one.children.at(0).children.at(0)), 0)
    assert.eq(idx(two), 4, message: "branch: 5 is palette index 4")
    let two1 = two.children.at(0)
    assert.eq(idx(two1), 4, message: "the child inherits the override")
    assert.eq(idx(two1.children.at(0)), 4, message: "so does the grandchild")
    let own = two1.children.at(1)
    assert.eq(idx(own), 0, message: "a descendant's own branch wins")
    assert.eq(idx(own.children.at(0)), 0, message: "and passes on to its subtree")
    assert.eq(idx(three), 2)
    assert.eq(idx(three.children.at(0)), 2)
    assert.eq(idx(three.children.at(0).children.at(0)), 2)
  }
}
#[OK]
