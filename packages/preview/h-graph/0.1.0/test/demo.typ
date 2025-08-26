#import "../src/lib.typ": *
#let use-render = "polar-render"
#show raw.where(lang: "graph"): enable-graph-in-raw(eval(use-render, scope: (
  tree-render: tree-render,
  polar-render: polar-render,
)))

#set page(height: auto, margin: (bottom: 30pt, top: 30pt, right: 0pt, left: 30pt))
#let content = "
#scl: 0.7;
#cir_n: 2;
N1 - N2.N20;
N8 - N9;
N9 - N10;
N1.N3
-bend: 50deg,
 \"-|>\", stroke: (10pt + gradient.linear(..color.map.rainbow))-
 N6.N7;
"
#{
  set align(center)
  text(size: 20pt)[Use *#use-render*]
}
#v(10pt)
#stack(
  block(fill: luma(91.37%), inset: 15pt, radius: 10pt)[
    #set text(font: "Ubuntu Mono")
    #content.trim()
  ],
  h(20pt),
  [#set align(horizon + center)
    #eval("
  ```graph
  " + content + "```"),
  ],
)
