#import "@preview/parsely:0.1.1"
#import "@preview/cetz:0.5.2"

#show "CeTZ": link.with("https://cetz-package.github.io/")

= Drawing expression trees

#let eq = $a x^2 + b x + c$

You can use the built-in functions `tree()` and `waterfall()` in the `parsely.render` module to quickly visualise syntax trees.

For example, here is the syntax tree for the equation #eq parsed with the grammar `parsely.common.arithmetic` and rendered as a tree and waterfall:

#let (tree, rest) = parsely.parse(eq, parsely.common.arithmetic)
#grid(
  columns: (2fr, 3fr),
  align: center + horizon,
  parsely.render.tree(tree),
  parsely.render.waterfall(tree),
)

The CeTZ package can also draw trees represented as nested arrays.
You can transform Parsely's syntax trees from their dictionary form into array form `(node, ..children)` with a simple post-walk.

#let eqn-tree(eqn) = {
  let (tree, rest) = parsely.parse(eqn, parsely.common.arithmetic)

  let array-tree = parsely.walk(tree, post: it => (
    strong(raw(it.head)),
    ..it.args,
    ..it.slots.pairs().map(((slot, it)) => {
      // convert slots into unary nodes
      (text(gray, 0.8em, raw(slot)), it)
    }),
  ), leaf: math.equation)

  cetz.canvas({
    cetz.draw.set-style(
      content: (padding: .1),
      stroke: 1pt + gray,
    )
    cetz.tree.tree(
      array-tree,
      grow: 0.5, spread: 0.15,
      draw-edge: (src, tgt) => {
        cetz.draw.bezier(
          (name: src.group-name, anchor: "south"),
          (name: tgt.group-name, anchor: "north"),
          (tgt.name, 60%, (tgt.name, "|-", src.name)),
          stroke: 2pt/(1 + tgt.depth/3)
        )
      }
    )
  })
}

#let eqn = $((-1)^(n - 1) (2n)!)/(4^n (n!)^2 (2n - 1))$
For example, the $n$th coefficient in the series expansion of $sqrt(1 + x)$ is:
$ eqn quad equiv quad #eqn-tree(eqn) $
