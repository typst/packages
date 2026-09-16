// Labels carry markup and emoji — the emoji needs a color font in the `font`
// fallback list, which the caller provides.
#import "@preview/tidymind:0.2.0": mindmap, node
#set page(width: auto, height: auto, margin: 10pt)
#mindmap(
  node([Git: #strong[what gets graded]],
    node([🥇 #strong[Remote sync] (35%)]),
    node([🥈 #strong[Merging branches] (30%)]),
    node([🥉 #strong[The three areas] (20%)]),
    node([⚪ #strong[Pointers (HEAD)] (15%)]),
  ),
  font: ("Inter", "Noto Color Emoji"),
)
