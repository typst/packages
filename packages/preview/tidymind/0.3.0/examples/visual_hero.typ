// The README hero: the full map in the "technical" style, with role tags and emoji.
// Each depth starts right after its parent (no `align-levels`), which keeps the
// map narrow enough to read at README width.
#import "@preview/tidymind:0.3.0": mindmap, node
#set page(width: auto, height: auto, margin: 12pt)
#let switching = node([🌐 Network switching],
  node([📞 Circuit switching],
    node([🎯 Dedicated channel],
      node([📻 `FDM` splits the frequency band]),
      node([⏱️ `TDM` splits time into slots]),
    ),
    node([🔁 Setup, transfer and teardown]),
    node([💸 Idle time wastes reserved bandwidth], emphasis: "warning"),
  ),
  node([📦 Message switching],
    node([💾 *Whole-message* store-and-forward], emphasis: "definition"),
    node([🚫 No fragmentation]),
  ),
  node([⚡ Packet switching],
    node([📊 Statistical multiplexing]),
    node([🔀 Modes],
      node([✉️ Datagram (connectionless)]),
      node([🛣️ Virtual circuit], node([🏷️ `MPLS`, Frame Relay], emphasis: "example")),
    ),
  ),
)
#mindmap(switching, style: "technical", markers: "role",
  font: ("Inter", "Noto Color Emoji"))
