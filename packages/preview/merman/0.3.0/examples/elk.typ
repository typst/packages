#import "@preview/merman:0.3.0": mermaid

= ELK layout

#mermaid(
  "---\nconfig:\n  layout: elk\n---\nflowchart LR\n  Source --> Layout\n  Layout --> SVG\n  Layout --> Details\n",
  width: 95%,
  alt: "A flowchart rendered with the ELK layout backend",
)
