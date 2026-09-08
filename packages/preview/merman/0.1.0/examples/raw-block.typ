#import "@preview/merman:0.1.0": show-mermaid-blocks

#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  width: 100%,
  pipeline: "readable",
  alt: "A Mermaid diagram rendered from a raw block",
)

= merman Typst Raw Block Example

```mermaid
sequenceDiagram
  participant User
  participant Typst
  participant merman
  User->>Typst: Write a mermaid raw block
  Typst->>merman: Call the wasm plugin
  merman-->>Typst: Return SVG bytes
```
