#import "@preview/merman:0.1.0": mermaid

= merman Typst Basic Example

#mermaid(
  "flowchart TD
    A[Write Mermaid] --> B[Render with merman]
    B --> C[Embed SVG in Typst]
  ",
  width: 90%,
  alt: "A flowchart rendered by merman",
)
