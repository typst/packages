#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge
#import fletcher.shapes: diamond
#set text(font: "Comic Neue", weight: 600)


#let dia1 = diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
  edge("-|>"),
  node((0,1), align(center)[
    Hey, wait,\ this flowchart\ is a trap!
  ], shape: diamond),
  edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1)
)

#let fig-dia-showcase = figure(
  kind: "diagram",
  supplement: [Diagram],
  dia1,
  caption: "Helpful diagram", 
)