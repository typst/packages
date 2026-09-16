#import "util.typ": *
#import "/src/main.typ": cetz, fletcher-shapes, icons
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#show link: underline.with(stroke: 1pt + blue.lighten(70%))

#show "CeTZ": it => link("https://github.com/johannes-wolf/cetz", it)
#show "Fletcher": it => link(
  "https://github.com/Jollywatt/typst-fletcher/tree/main",
  it,
)

#set text(font: "FreeSans")

#let VERSION = toml("/typst.toml").package.version

#heading(outlined: false)[cntopo #VERSION]

A modular set of CeTZ-powered computer network topology icons with Fletcher integration.

#let (
  server,
  monitor,
  switch,
  router,
  l3-switch,
  cloud,
  w-dual-ap,
  firewall,
) = fletcher-shapes(
  stroke: blue.lighten(50%),
  stroke-inner: white,
  fill: blue,
  fill-inner: white,
  flat: false,
)
#let cloud = cloud.with(override-color: true, label-pos: right)
#let node = node.with(width: 6em, height: 6em)
#diagram(
  spacing: (1em, 1em),
  node-stroke: blue,
  node-fill: blue.lighten(80%),
  edge-stroke: black + 2pt,
  node((-1, 1.5), shape: monitor.with(label: "192.168.0.69"), name: <c1>),
  node((0, 2.5), shape: server.with(label: "192.168.0.101"), name: <srv1>),
  node((1, 3), shape: server.with(label: "192.168.0.102"), name: <srv2>),
  node(
    (-1, -2),
    shape: monitor.with(label: "10.0.0.33", label-pos: top),
    name: <c2>,
  ),
  node(
    (0, -1),
    shape: switch.with(
      detail: "S3",
    ),
    name: <s3>,
  ),
  node(
    (1, 2),
    shape: switch.with(detail: "S2"),
    name: <s2>,
  ),
  node((0, 1), shape: l3-switch.with(detail: "S1"), name: <s1>),
  node(
    (0, 0),
    shape: router.with(detail: "R1"),
    name: <r1>,
  ),
  node(
    (1, -2),
    shape: w-dual-ap.with(detail: "AP"),
    name: <ap>,
  ),
  node(
    (2, 0),
    shape: firewall,
    name: <fw>,
  ),
  node(
    (3, 0),
    shape: cloud.with(label: [WAN], label-pos: bottom),
    name: <wan>,
  ),
  node(
    enclose: (<s3>, <c2>, <ap>),
    inset: 5em,
    fill: white,
    shape: cloud.with(
      label: pad(left: 1em, text(size: 1.5em)[net2\ 10.0.0.0/24]),
    ),
  ),
  node(
    enclose: (<c1>, <srv1>, <srv2>, <s1>, <s2>),
    inset: 5em,
    fill: white,
    shape: cloud.with(
      label: pad(left: 1em, text(size: 1.5em)[net1\ 192.168.0.0/24]),
    ),
  ),
  edge(<fw>, <wan>),
  edge(<r1>, <fw>),
  edge(<s1>, <c1>),
  edge(<s3>, <c2>),
  edge(<s2>, <srv1>),
  edge(<s2>, <srv2>),
  edge(
    <r1>,
    <s1>,
    label: [192.168.0.1],
    label-side: center,
    label-pos: .75em,
  ),
  edge(
    <r1>,
    <s3>,
    label: [10.0.0.1],
    label-side: center,
    label-pos: .75em,
  ),
  edge(<s1>, <s2>),
  edge(<s3>, <ap>, dash: "dashed"),
)

#pagebreak()

#outline(depth: 4)

#pagebreak()

= Overview

`cntopo-typ` is a collection of computer network topology icons, designed to be easy to use, extensible and work well with existing frameworks like CeTZ or Fletcher. The two main functions it provides are `fletcher-shapes` and `icons`, yielding all of the icons for use with Fletcher and CeTZ respectively. Both are parametarized the same way, as well as most of the icons in this package. All `node` icons are provided with 2d (`flat: true`) and 3d (`flat: false`) variants.

Some important terms to clarify how the icon construction works: 

- #link(<node>, "Node"): An icon representing a node in a network which is not a client
- #link(<client>, "Client"): An icon representing a client node in a network
- #link(<shape>, "Shape"): The container holding the node's characteristics (icon, name, details...), eg. circle
- #link(<class>, "Class"): The large portion of a node containing an icon or content
- #link(<detail>, "Detail"): The small bottom portion of a node containing an icon or content

== Note

Whenever `..pos` is used, the positional arguments can be one of:

- none $=>$ defaults to the position ```typst (0,0)``` and a preconfigured default size for the specific shape
- ```typst (x, y)``` $=>$ sets the position of the icon to the x and y value
- ```typst (x, y), (w, h)``` $=>$ sets the position of the icon to the x and y value and its radius to w (x radius) and h (y radius)
- ```typst (x, y), r``` $=>$ sets the radius of the icon to ```typst (r, r)```

It is recommended to explicitly set the `node` sizes when working with Fletcher like so: 

```typst
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let node = node.with(width: 4em, height: 4em)

#diagram( ... )
```

#pagebreak()

= API

== Main

#show-module("main")

== Node shapes <shape>

All node shapes can be accessed in these three ways:

```typst
// Example: rect
node(shape: node-shape-rect)
node(shape: node-shapes.rect)
node(shape: "rect")           // -> recommended
```

A custom node shape can be passed to the #link(<-node.shape>, `shape`) parameter. It must return a cetz object and conform to the following signature:

```typst
#let my-custom-shape = (
  sx,     /// width
  sy,     /// height
  radius, /// corner radius
  stroke, /// stroke
  fill,   /// fill
  flat    /// if shape is 3d
) => { ... }
```

#show-module("node-shape")

== Node classes <class>

All node classes can be accessed in these three ways:

```typst
// Example: router
node(class: node-class-router)
node(class: node-classes.router)
node(class: "router")         // -> recommended
```

A custom node class can be passed to the #link(<-node.class>, `class`) parameter. It must return a cetz object and conforort to the following signature:

```typst
#let my-custom-class = (
  sx,     /// parent node width
  sy,     /// parent node height
  stroke, /// stroke
  fill    /// fill
) => { ... }
```

Classes can also be regular content:

```typst
node(class: [ABC])
```

Classes can also be used as #link(<detail>, "details") and vice-versa.

NOTE: Classes influence the node's #link(<-node.shape>, `shape`) if it's set to `auto`

#show-module("node-class")

== Node details <detail>

All node details can be accessed in these three ways:

```typst
// Example: secure
node(detail: node-detail-secure)
node(detail: node-details.secure)
node(detail: "secure")        // -> recommended
```

A custom node detail can be passed to the #link(<-node.detail>, "detail") parameter. It must return a cetz object and conform to the following signature:

```typst
#let my-custom-detail = (
  sx,     /// parent node width
  sy,     /// parent node height
  stroke, /// stroke
  fill    /// fill
) => { ... }
```

Just like classes, details can also be regular content:

```typst
node(detail: [ABC])
```

#show-module("node-detail")

== Nodes <node>

#show-module("nodes")

== Clients <client>

#show-module("clients")

== Miscellaneous

#show-module("misc")

== Shapes

#show-module("shapes")

// == Util

// #show-module("util")

#pagebreak()

#set page(header: text(size: 2em)[```typst flat: true```])

= Shapes <all-shapes>

These are all of the shapes provided by #link(<-icon-presets>, `icon-presets`)

#let icon-set = icons(
  fill: blue,
  fill-inner: white,
  stroke-inner: white,
  stroke: blue.lighten(50%) + 2pt,
  flat: false,
)

#let w = 6
#let h = 6
#let render-all = i => {
  for on-page in i.pairs().chunks(w * h) {
    cetz.canvas(length: 3.5em, {
      cetz.draw.grid(
        (0, 0),
        (w * 2, h * 3 - 1),
        stroke: blue,
        step: 1,
      )
      on-page
        .chunks(w)
        .enumerate()
        .map(((y, c)) => c
          .rev()
          .enumerate()
          .map(((x, (k, v))) => v(
            ((w - x) * 2 - 1, (h - y) * 3 - 2),
            label: box(fill: white)[#k],
          )))
        .flatten()
    })
  }
}

#render-all(icon-set)

#set page(header: text(size: 2em)[```typst flat: false```])

#render-all(icon-set.pairs().map(((k, v)) => (k, v.with(flat: true))).to-dict())
