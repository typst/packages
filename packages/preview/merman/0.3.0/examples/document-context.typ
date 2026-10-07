#import "@preview/merman:0.3.0": mermaid, show-mermaid-blocks

#set page(width: 16cm, margin: 18mm)
#set text(font: "Arial", size: 13pt)

#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  document-context: true,
  width: 100%,
)

= Document context example

#mermaid(
  "flowchart LR
    A[Document font] --> B[document-context render]
    B --> C[Respects container width]
  ",
  document-context: true,
  width: 100%,
)

```mermaid
sequenceDiagram
  participant Typst
  participant merman
  Typst->>merman: Use document-context raw blocks
  merman-->>Typst: Render with the current document context
```
