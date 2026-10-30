#import "@preview/pele-rs:0.3.0": mermaid

#set page(width: 12cm, height: 8cm, margin: 5mm, fill: white)
#set text(font: "Libertinus Serif")
#set align(center + horizon)

#mermaid(width: 100%, height: 100%, "
sequenceDiagram
  participant T as Typst
  participant P as Plugin
  participant R as pele_rs
  T->>P: render(source, options)
  P->>R: parse and lay out
  R-->>P: SVG
  Note over P: inline CSS variables
  P-->>T: SVG bytes
")
