#set page(width: auto, height: auto, margin: .5cm)
#import "@preview/cetz:0.3.1"
#import "@preview/cetz-venn:0.1.2": venn3

#cetz.canvas({
  import cetz.draw: *

  scale(1.5)
  venn3(name: "venn", a-fill: red, b-fill: green, c-fill: blue,
    ab-fill: yellow, abc-fill: gray, bc-fill: gray)

  content("venn.a", [1], angle: 45deg)
  content("venn.b", [2])
  content("venn.c", [3])
  content("venn.ab", [4])
  content("venn.bc", [5])
  content("venn.ac", [6])
  content("venn.abc", [7])
})
