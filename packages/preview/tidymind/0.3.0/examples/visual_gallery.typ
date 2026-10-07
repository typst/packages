// The five styles on the same map, each with its usual edge.
#import "@preview/tidymind:0.3.0": mindmap, node
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "Inter", size: 9pt, fill: rgb("#64748b"))
#let switching = node([Network switching],
  node([Circuit switching],
    node([Dedicated channel],
      node([`FDM` splits the frequency band]),
      node([`TDM` splits time into slots]),
    ),
    node([Setup, transfer and teardown]),
    node([Idle time wastes reserved bandwidth], emphasis: "warning"),
  ),
  node([Message switching],
    node([Whole-message store-and-forward], emphasis: "definition"),
    node([No fragmentation]),
  ),
  node([Packet switching],
    node([Statistical multiplexing]),
    node([Modes],
      node([Datagram (connectionless)]),
      node([Virtual circuit], node([`MPLS`, Frame Relay], emphasis: "example")),
    ),
  ),
)
// One map per row, with a short caption under it.
#let variant(caption, map) = stack(spacing: 6pt, map, { show raw: set text(size: 1.25em); caption })
#stack(spacing: 24pt,
  ..("boxed", "outline", "technical", "bar", "block").map(style => {
    let edge = if style == "bar" { "tapered" } else { "curved" }
    variant(raw("style: \"" + style + "\"" + if edge != "curved" { ", edge: \"" + edge + "\"" }),
      mindmap(switching, style: style, edge: edge, markers: "role"))
  }),
)
