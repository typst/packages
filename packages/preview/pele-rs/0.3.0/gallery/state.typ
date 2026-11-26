#import "@preview/pele-rs:0.3.0": mermaid

#set page(width: 12cm, height: 8cm, margin: 5mm, fill: white)
#set text(font: "Libertinus Serif")
#set align(center + horizon)

#mermaid(width: 100%, height: 100%, theme: (
  bg: rgb("#1e1e2e"), fg: rgb("#cdd6f4"), line: rgb("#89b4fa"),
  surface: rgb("#313244"), border: rgb("#6c7086"),
), "
stateDiagram-v2
  direction LR
  [*] --> Draft
  Draft --> Review: submit
  Review --> Draft: changes
  Review --> Published: approve
  Published --> [*]
")
