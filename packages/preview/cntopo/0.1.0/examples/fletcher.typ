#import "/src/main.typ": cetz, fletcher-shapes
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set text(font: "FreeSans")

#let ex = flat => {
  let (
    server,
    monitor,
    switch,
    router,
    l3-switch,
    cloud,
    w-dual-ap,
  ) = fletcher-shapes(
    stroke: blue.lighten(50%),
    stroke-inner: white,
    fill: blue,
    fill-inner: white,
    flat: flat,
  )
  let cloud = cloud.with(override-color: true)
  let node = node.with(width: 6em, height: 6em)
  diagram(
    node-stroke: blue,
    node-fill: blue.lighten(90%),
    node((-1, 1), shape: monitor.with(label: "192.168.0.69"), name: <c1>),
    node((-1, 2), shape: monitor.with(label: "192.168.0.33"), name: <c2>),
    node((0, 2.5), shape: server.with(label: "192.168.0.101"), name: <srv1>),
    node((1, 3), shape: server.with(label: "192.168.0.102"), name: <srv2>),
    node(
      (1, 2),
      shape: switch.with(
        detail: "S2",
      ),
      name: <s2>,
    ),
    node((0, 1), shape: l3-switch.with(detail: "S1"), name: <s1>),
    node(
      (1.75, 1),
      shape: router.with(detail: "R1"),
      name: <r1>,
    ),
    node(
      (3, 1),
      shape: w-dual-ap.with(detail: "AP"),
      name: <ap>,
    ),
    node(
      enclose: (<c1>, <c2>, <srv1>, <srv2>, <s1>, <s2>),
      inset: 5em,
      fill: white,
      // label: [net1\ 192.168.1.0/24],
      shape: cloud.with(
        label: pad(left: 1em)[net1\ 192.168.0.0/24],
        label-pos: right,
      ),
    ),
    edge(<s1>, <c1>),
    edge(<s1>, <c2>),
    edge(<s2>, <srv1>),
    edge(<s2>, <srv2>),
    edge(<r1>, <s1>, label: ".1", label-side: center, label-pos: .75em),
    edge(<s1>, <s2>),
    edge(<r1>, <ap>, dash: "dashed"),
  )
}
#ex(true)
#ex(false)

#let node = node.with(width: 4em, height: 4em)
#let (
  monitor,
  router,
  switch,
  l3-switch,
  server,
  cloud,
) = fletcher-shapes(flat: true)

#diagram(
  node-stroke: blue,
  node-fill: white,
  node((0, 0), shape: router, name: <c1>),
  node((1, 0), shape: router, name: <c2>),
  node((2, 0), shape: router, name: <c3>),
  node((0.5, 1), shape: router, name: <c4>),
  node((1.5, 1), shape: router, name: <c5>),
  edge(<c1>, (0, 0.5), label: ".1", label-pos: .6em, label-side: center),
  edge(<c2>, (1, 0.5), label: ".2", label-pos: .6em, label-side: center),
  edge(<c3>, (2, 0.5), label: ".3", label-pos: .6em, label-side: center),
  edge(<c4>, (0.5, 0.5), label: ".4", label-pos: .6em, label-side: center),
  edge(<c5>, (1.5, 0.5), label: ".5", label-pos: .6em, label-side: center),
  edge((-0.5, 0.5), (2.5, 0.5)),
  node((3, .5), stroke: none, [10.0.0.0/24]),
)

#let (
  monitor,
  router,
  switch,
  l3-switch,
  server,
  cloud,
) = fletcher-shapes(flat: false)

#let dr = router.with(detail: "DR")
#let bdr = router.with(detail: "BDR")
#let drother = router.with(detail: text(size: .7em)[DROTHER])
#diagram(
  node-stroke: blue,
  node-fill: white,
  node((1, 0), shape: dr, name: <c1>),
  node((2, 1), shape: bdr, name: <c2>),
  node((0, 1), shape: router, name: <c3>),
  node((1.5, 2), shape: router, name: <c4>),
  node((0.5, 2), shape: router, name: <c5>),
  edge(<c1>, <c2>, "<|--|>"),
  edge(<c1>, <c3>, "<|--|>"),
  edge(<c1>, <c4>, "<|--|>"),
  edge(<c1>, <c5>, "<|--|>"),
  edge(<c2>, <c3>, "<|--|>"),
  edge(<c2>, <c5>, "<|--|>"),
)

#diagram(
  node-stroke: blue,
  node-fill: white,
  node((1, 0), shape: dr, name: <c1>),
  node((2, 1), shape: bdr, name: <c2>),
  node(
    (0, 1),
    shape: drother,
    name: <c3>,
  ),
  node(
    (1.5, 2),
    shape: drother,
    name: <c4>,
  ),
  node(
    (0.5, 2),
    shape: drother,
    name: <c5>,
  ),
  edge(<c1>, <c2>, "<|--|>", label: "full"),
  edge(<c1>, <c3>, "<|--|>", label: "full"),
  edge(<c1>, <c4>, "<|--|>", label: "full"),
  edge(<c1>, <c5>, "<|--|>", label: "full"),
)

#diagram(
  node-stroke: blue,
  node-fill: white,
  node((0, 0), shape: router, name: <c1>),
  node((1, 0), shape: router, name: <c2>),
  node((2, 0), shape: router, name: <c3>),
  node((1, 1), shape: switch, name: <s>),
  node((0, 2), shape: router, name: <c4>),
  node((1, 2), shape: router, name: <c5>),
  node((2, 2), shape: router, name: <c6>),
  edge(<c1>, <s>),
  edge(<c2>, <s>),
  edge(<c3>, <s>),
  edge(<c4>, <s>),
  edge(<c5>, <s>),
  edge(<c6>, <s>),
  node(
    enclose: (<c1>, <c2>, <c3>, <c4>, <c5>, <c6>, <s>),
    inset: 4em,
    fill: blue.transparentize(90%),
    shape: cloud,
  ),
)
