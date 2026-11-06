#import "@preview/tidy:0.4.3"
#import "/src/main.typ" as cntopo
#import "/docs/style.typ"

#let show-module = module => tidy.show-module(
  tidy.parse-module(
    read("/src/" + module + ".typ"),
    scope: (cntopo: cntopo, cetz: cntopo.cetz, canvas: cntopo.cetz.canvas),
    preamble: "
    #import \"@preview/fletcher:0.5.8\": diagram, node, edge
    #import cntopo: *
    #let (monitor, server, router, lock, cloud) = icons()
    ",
    // name: upper(module.first()) + lower(module.slice(1)),
  ),
  style: style,
  first-heading-level: 3,
  // show-module-name: false
)
