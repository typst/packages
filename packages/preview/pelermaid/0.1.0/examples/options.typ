#import "@preview/pelermaid:0.1.0": mermaid

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "DejaVu Sans", size: 10pt)

#mermaid("
flowchart LR
    A[Start] --> B{Ready?}
    B -->|Yes| C[Go]
    B -->|No| D[Wait]
", width: 80%, base-theme: "dark")
