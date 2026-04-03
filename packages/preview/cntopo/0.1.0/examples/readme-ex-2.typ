#import "/src/main.typ": cetz, fletcher-shapes, icons
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(height: 20em, width: 50em, margin: 0pt)

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

#pad(x: 3em, y: 1em, cetz.canvas(length: 4em, {
  router((0, 0))
  w-dual-ap((3, 0))
  switch((6, 0))
  l3-switch((9, 0))
  server((0, 2.5))
  monitor((3, 2.5))
  lock((6, 2.5))
  cloud((9, 2.5))
}))
