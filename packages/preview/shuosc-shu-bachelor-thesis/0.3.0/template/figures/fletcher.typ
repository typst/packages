#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: rect

#let resnet_block(size) = {
  set text(1em * size)
  diagram(
    node-stroke: 0.05em,
    node((0, 0.2)),
    edge("-|>", [$x$]),
    node((0, 1), [weight layer], shape: rect, corner-radius: 0.3em),
    edge("-|>", [Relu]),
    node((0, 2), [weight layer], shape: rect, corner-radius: 0.3em),
    edge("-|>"),
    node((0, 2.65), [+], radius: 0.5em, inset: 0em),
    edge((0, 3), "-|>", [Relu]),
    edge((0, 0.5), "r,d,d", (1, 2.65), (0, 2.65), "-|>"),

    node((-0.7, 1.5), [$f(x)$], stroke: none),
    node((-0.7, 2.65), [$f(x)+x$], stroke: none),
  )
}
