#import "@preview/merman:0.4.0": mermaid, mermaid-profile, show-mermaid-blocks

= Dagre layout

#let dagre = mermaid-profile(site-config: (layout: "dagre"))
#show raw.where(lang: "mermaid"): show-mermaid-blocks(profile: dagre)

#mermaid(
  "flowchart LR\n  Source --> Layout\n  Layout --> SVG",
  profile: dagre,
)

```mermaid
flowchart LR
  Source --> Profile
  Profile --> RawBlock
```
