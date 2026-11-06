#import "@preview/pele-rs:0.3.0": mermaid

#set page(width: 12cm, height: 8cm, margin: 5mm, fill: white)
#set text(font: "Libertinus Serif")
#set align(center + horizon)

#mermaid(width: 100%, height: 100%, "
mindmap
  root((pele))
    Engine
      Parsing
      Layout
      SVG
    Package
      lib.typ
      WASM plugin
    Tests
      Fixtures
      CI
")
