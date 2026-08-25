#import "@preview/merman:0.2.0": mermaid, mermaid-profile, show-mermaid-blocks

#set page(width: 16cm, height: 9cm, margin: 12mm, fill: rgb("#111827"))
#set text(fill: rgb("#e5e7eb"))

#let slide-profile = mermaid-profile(
  presentation-profile: "merman-modern",
  background: "#111827",
  host-theme: (
    appearance: "dark",
    roles: (
      canvas: "#111827",
      surface: "#1f2937",
      text: "#e5e7eb",
      border: "#475569",
      line: "#93c5fd",
      "actor-background": "#1f2937",
      "actor-border": "#60a5fa",
      "actor-text": "#e5e7eb",
    ),
  ),
)

#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  profile: slide-profile,
  width: 100%,
)

= Mermaid in slides

#mermaid(
  "flowchart LR
    Idea[Idea] --> Demo[Typst slide]
    Demo --> PDF[PDF deck]
  ",
  profile: slide-profile,
  width: 100%,
)

```mermaid
sequenceDiagram
  participant Speaker
  participant Typst
  participant merman
  Speaker->>Typst: Write a Mermaid fence
  Typst->>merman: Render with the dark host theme
  merman-->>Typst: Return presentation-aware SVG
```
