#import "@preview/pelermaid:0.1.0": mermaid

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "DejaVu Sans", size: 10pt)

#mermaid("
flowchart TD
    A((Start)) --> B[/Input score/]
    B --> C{Score >= 5?}
    C -->|Yes| D[/Output Pass/]
    C -->|No| E[/Output Fail/]
    D --> F((End))
    E --> F
", width: 100%)
