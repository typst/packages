#import "@preview/merman:0.3.0": mermaid-figure, mermaid-profile

= Mermaid figure

#let diagram-profile = mermaid-profile(
  pipeline: "resvg-safe",
  background: "#ffffff",
  typography: (
    font: ("Source Sans 3", "Arial", "sans-serif"),
    size: "16px",
  ),
  figure: (
    placement: bottom,
    scope: "parent",
    caption-position: top,
    caption-separator: [ -- ],
    gap: 1em,
    outlined: false,
  ),
)

#mermaid-figure(
  "flowchart TD
    Source[Mermaid source] --> Diagram[SVG image]
    Diagram --> Figure[Typst figure]
  ",
  caption: [A Mermaid diagram rendered as a Typst figure.],
  profile: diagram-profile,
  width: 90%,
  alt: "A Mermaid diagram rendered as a Typst figure",
)

#set text(font: "Arial", size: 12pt)

#mermaid-figure(
  "sequenceDiagram
    participant Typst
    participant merman
    Typst->>merman: Render with document context
    merman-->>Typst: Embed as a figure
  ",
  caption: [A document-context Mermaid figure.],
  document-context: true,
  profile: diagram-profile,
  caption-position: bottom,
  width: 100%,
  alt: "A document-context Mermaid sequence diagram",
)
