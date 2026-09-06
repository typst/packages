#import "@preview/merman:0.3.0": mermaid, mermaid-profile, show-mermaid-blocks

= Reusable diagram profile

#let diagram-profile = mermaid-profile(
  background: "#ffffff",
  theme-name: "base",
  typography: (
    font: ("Source Sans 3", "Arial", "sans-serif"),
    size: "16px",
  ),
  theme: (
    primaryColor: "#f8fafc",
    primaryTextColor: "#111827",
    primaryBorderColor: "#2563eb",
    lineColor: "#475569",
  ),
)

#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  profile: diagram-profile,
  width: 100%,
)

#mermaid(
  "flowchart LR
    Profile[Profile] --> Direct[Direct call]
    Profile --> Raw[Raw block]
  ",
  profile: diagram-profile,
  width: 100%,
)

```mermaid
sequenceDiagram
  participant Typst
  participant Profile
  participant merman
  Typst->>Profile: Reuse renderer settings
  Profile->>merman: Normalize to binding options
  merman-->>Typst: Return SVG
```
