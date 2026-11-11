#import "@preview/merman:0.6.0": mermaid, mermaid-profile, show-mermaid-blocks

#set page(width: 16cm, height: 9cm, margin: 12mm, fill: rgb("#111827"))
#set text(fill: rgb("#e5e7eb"))

#let slide-profile = mermaid-profile(
  theme-preset: "ayu",
  theme-appearance: "dark",
  background: "#111827",
)

#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  profile: slide-profile,
  document-context: true,
  width: 100%,
)

= Mermaid in slides

#mermaid(
  "flowchart LR
    Idea[Idea] --> Demo[Typst slide]
    Demo --> PDF[PDF deck]
  ",
  profile: slide-profile,
  document-context: true,
  width: 100%,
)

```mermaid
sequenceDiagram
  participant Speaker
  participant Typst
  participant merman
  Speaker->>Typst: Write a Mermaid fence
  Typst->>merman: Render with a compiled dark theme
  merman-->>Typst: Return themed SVG
```
