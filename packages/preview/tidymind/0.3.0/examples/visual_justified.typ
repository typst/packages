// Long labels inside a justified, hyphenated document: a label ignores the
// document's justification and hyphenation, so it neither splits words nor
// stretches its spaces.
#import "@preview/tidymind:0.3.0": mindmap, node
#set page(width: auto, height: auto, margin: 10pt)
#set text(lang: "en", hyphenate: true)
#set par(justify: true)
#let long = node([Packet switching techniques],
  node([Statistical multiplexing on demand]),
  node([Fragmentation with pipeline parallelism]),
)
#mindmap(long, style: "outline", node-max-width: 3.2cm)
