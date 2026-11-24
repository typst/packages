#import "../prelude.typ": *

= First Real Chapter <chap:one>

We cite the article a second time @example-article.

An external image figure (drop your PNG/SVG/PDF files in `figures/`):
/*
#figure(
  image("../figures/example.svg", width: 55%),
  caption: [An external image — replace me.],
) <external-example>
*/
A diagram drawn in Typst with CeTZ (the TikZ equivalent):

#figure(
  cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: 0.7, fill: blue.lighten(80%), name: "a")
    rect((2.2, -0.5), (3.8, 0.5), fill: orange.lighten(70%), name: "b")
    line("a.east", "b.west", mark: (end: ">"))
    content((0, 0), [A])
    content((3, 0), [B])
  }),
  caption: [A CeTZ diagram — replace me.],
) <cetz-example>

//Reference figures with per-chapter numbers: see @fig:external-example
//and @fig:cetz-example.

#lorem(120)

== A Section

#lorem(100)
