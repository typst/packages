#import "@preview/pele-rs:0.3.0": mermaid

#set page(width: 12cm, height: 8cm, margin: 5mm, fill: white)
#set text(font: "Libertinus Serif")
#set align(center + horizon)

#mermaid(width: 100%, height: 100%, "
classDiagram
  class Diagram {
    +String kind
    +parse(source) Model
    +render(options) Svg
  }
  class Flowchart
  class Sequence
  Diagram <|-- Flowchart
  Diagram <|-- Sequence
")
