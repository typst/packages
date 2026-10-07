#import "../src/options.typ": make-opts
#import "../src/tree.typ": normalize
#import "../src/layout.typ": measure-tree
#set page(width: auto, height: auto)

#context {
  let t = normalize((content: [A fairly long sample label], children: ((content: [x],),)))
  let m = measure-tree(t, make-opts(style: "boxed", node-max-width: 6cm))
  assert(m.w > 0)
  assert(m.h > 0)
  assert(m.w > m.children.at(0).w)
}
#[OK]
