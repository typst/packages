#import "/src/main.typ": cetz, fletcher-shapes, icons
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(height: 20em, width: 50em)
#set text(font: "FreeSans")
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
