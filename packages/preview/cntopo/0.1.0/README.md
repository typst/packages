# cntopo-typ

A modular set of CeTZ-powered computer network topology icons with Fletcher integration.

## Overview

`cntopo-typ` is a collection of computer network topology icons, designed to be easy to use, extensible and work well with existing frameworks like CeTZ or Fletcher. The two main functions it provides are `fletcher-shapes` and `icons`, yielding all of the icons for use with Fletcher and CeTZ respectively. Both are parametarized the same way, as well as most of the icons in this package. All `node` icons are provided with 2d (`flat: true`) and 3d (`flat: false`) variants.

## Usage

```typst
#import "@preview/cntopo:0.1.0": cetz, icons

#let ip = text.with(font: "FreeMono", weight: "bold")

#let (router, w-router, w-sec-router, cl-router) = icons(
  fill: blue,
  fill-inner: white,
  stroke-inner: white,
  stroke: blue.lighten(50%) + 2pt,
  flat: false,
)

#cetz.canvas(length: 4em, {
  router((0, 0), detail: "R1", label: ip[192.168.0.1])
  w-router((3, 0))
  w-sec-router((6, 0), label: ip[10.0.0.1])
  cl-router((9, 0))

  router((0, 2), detail: "R1", label: ip[192.168.0.1])
  router((3, 2), wireless: true)
  router((6, 2), wireless: true, detail: "secure", label: ip[10.0.0.1])
  router((9, 2), detail: "cloud")
})
```

![example 1](https://raw.githubusercontent.com/omega-800/cntopo-typ/refs/heads/main/examples/readme-ex-1.svg)

```typst
#import "@preview/cntopo:0.1.0": cetz, icons

#let (
  router,
  w-dual-ap,
  switch,
  l3-switch,
  server,
  monitor,
  lock,
  cloud,
) = icons(
  fill: gradient.linear(black, green),
  fill-inner: white,
  stroke-inner: white,
  stroke: black.lighten(60%) + 2pt,
  flat: true,
)

#cetz.canvas(length: 4em, {
  router((0, 0))
  w-dual-ap((3, 0))
  switch((6, 0))
  l3-switch((9, 0))
  server((0, 2.5))
  monitor((3, 2.5))
  lock((6, 2.5))
  cloud((9, 2.5))
})
```

![example 2](https://raw.githubusercontent.com/omega-800/cntopo-typ/refs/heads/main/examples/readme-ex-2.svg)


```typst
#import "@preview/cntopo:0.1.0": cetz, fletcher-shapes
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

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
  node-stroke: blue,
  node-fill: blue.lighten(95%),
  node((-1, 1), shape: monitor.with(label: "192.168.0.69"), name: <c1>),
  node((-1, 2), shape: monitor.with(label: "192.168.0.33"), name: <c2>),
  node((0, 2.5), shape: server.with(label: "192.168.0.101"), name: <srv1>),
  node((1, 3), shape: server.with(label: "192.168.0.102"), name: <srv2>),
  node((1, 2), shape: switch.with(detail: "S2"), name: <s2>),
  node((0, 1), shape: l3-switch.with(detail: "S1"), name: <s1>),
  node((1.75, 1), shape: router.with(detail: "R1"), name: <r1>),
  node((3, 1), shape: w-dual-ap.with(detail: "AP"), name: <ap>),
  node(
    enclose: (<c1>, <c2>, <srv1>, <srv2>, <s1>, <s2>),
    inset: 5em,
    fill: white,
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
```

![example 3](https://raw.githubusercontent.com/omega-800/cntopo-typ/refs/heads/main/examples/readme-ex-3.svg)

## More examples

- [Icons showcase](https://raw.githubusercontent.com/omega-800/cntopo-typ/refs/heads/main/examples/all-icons.pdf)
- [Fletcher integration](https://raw.githubusercontent.com/omega-800/cntopo-typ/refs/heads/main/examples/fletcher.pdf)
