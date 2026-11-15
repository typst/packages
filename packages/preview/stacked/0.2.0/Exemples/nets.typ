#import "../solidunfold.typ": *
#import "../solidvertices.typ": *

#set page(height: auto,margin:4mm, width: auto)

#cylunfold(steps: (0, 0.4, 1), labels: ($t:0$, $t:0.4$, $t:1$), gap: 1.5, cote-labels: auto, cotes: true)

#polyunfold(vertices: ((-1,-1,-0.6),(1,-1,-0.6),(0,-1,1.1),(-1,1,-0.6),(1,1,-0.6),(0,1,1.1)), steps: (0, .12, 0.5, 1), length: .8cm,root: 1, gap: 2)

#grid(columns: 3, gutter: 16mm, align: horizon,
  polyunfold(vertices: regpolyhedron("icosaèdre", radius: 2), t: 0, length: 0.45cm),
  polyunfold(vertices: regpolyhedron("icosaèdre", radius: 2), view: "top", length: 0.45cm),
)

#stack(dir: ltr, spacing: 20mm,
  polyunfold(steps: (0, 0.5, 1), labels: ($t:0$, $t:0.5$, $t:1$), palette: (red.lighten(60%), green.lighten(60%), blue.lighten(60%), yellow.lighten(60%), orange.lighten(60%), purple.lighten(60%)), length: 0.5cm, gap: 2),
  polyunfold(view: "top", labels: ([view:"top"],), palette: (red.lighten(60%), green.lighten(60%), blue.lighten(60%), yellow.lighten(60%), orange.lighten(60%), purple.lighten(60%)), length: 0.5cm,)
)

#grid(columns: 4, column-gutter: 1mm, align: horizon,
  cylunfold(radius: 1.5, height: 2.5, t: 0, cotes: true, cote-labels: (r: auto, h: $H$), length: 0.5cm),
  cylunfold(radius: 1.5, height: 2.5, view: "top", cotes: true, cote-labels: auto, cote-unit: "cm", length: 0.5cm, ),
  coneunfold(radius: 3, height: 4, t:0, cotes: true, cote-labels: auto, cote-unit: "cm", length: 0.5cm,),
  coneunfold(radius: 3, height: 4, view: "top", cotes: true, cote-labels: auto, cote-unit: "cm", length: 0.5cm, ),
)