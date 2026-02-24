#set page(width: auto, height: auto, margin: .5cm)
#import "@preview/cetz:0.4.0"
#import "@preview/cetz-venn:0.1.4": venn2

#cetz.canvas({
  import cetz.draw: *

  venn2(name: "venn", a-fill: red, ab-fill: green)
  content("venn.a", [A])
  content("venn.b", [B])
})
