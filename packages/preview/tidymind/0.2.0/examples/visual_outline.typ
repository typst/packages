// The "outline" style: no boxes at all. The root is a heading over a baseline
// rule, first-level branches rest on a rule in their own color, and everything
// deeper is plain text.
#import "@preview/tidymind:0.2.0": mindmap, node
#set page(width: auto, height: auto, margin: 10pt)
#mindmap(
  node([Cell biology],
    node([Membrane],
      node([Phospholipid bilayer]),
      node([Transport proteins]),
    ),
    node([Nucleus],
      node([Chromatin]),
      node([Nucleolus]),
    ),
    node([Organelles],
      node([Mitochondria]),
      node([Ribosomes]),
    ),
  ),
  style: "outline",
)
