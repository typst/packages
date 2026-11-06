#import "@preview/pele-rs:0.3.0": mermaid

#set page(width: 12cm, height: 8cm, margin: 5mm, fill: white)
#set text(font: "Libertinus Serif")
#set align(center + horizon)

#mermaid(width: 100%, height: 100%, "
flowchart LR
  A[Write Mermaid] --> B{Valid?}
  B -->|yes| C[(Render)]
  B -.->|no| D>Fix the syntax]
  D --> A
  subgraph Typst
    C --> E((PDF))
  end
")
