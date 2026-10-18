#import "/src/main.typ": cetz, fletcher-shapes
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(height: 38em, width: 45em)

#set text(font: "FreeSans")

#let (
  server,
  monitor,
  switch,
  router,
  l3-switch,
  cloud,
  w-dual-ap,
) = fletcher-shapes(
  flat: false,
)
#let node = node.with(width: 4em, height: 4em)
#diagram(
  node-stroke: black,
  node-fill: white,
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
    shape: cloud.with(label: [net1\ 192.168.0.0/24], label-pos: right),
  ),
  edge(<s1>, <c1>),
  edge(<s1>, <c2>),
  edge(<s2>, <srv1>),
  edge(<s2>, <srv2>),
  edge(<r1>, <s1>),
  edge(<s1>, <s2>),
  edge(<r1>, <ap>, dash: "dashed"),
)
