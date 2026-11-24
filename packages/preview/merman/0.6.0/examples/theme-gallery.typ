#import "@preview/merman:0.6.0": mermaid

#set page(width: 600pt, height: auto, margin: 16pt, fill: white)
#set text(font: "Arial", size: 13pt, fill: rgb("#172033"))

#let source = "flowchart TD
  A[Write] --> B{Review}
  B --> C[Publish]
  B --> D[Revise]
"

#let sample(title, preset, appearance, canvas, ink) = block(
  width: 100%,
  fill: rgb(canvas),
  inset: 16pt,
  radius: 6pt,
)[
  #text(size: 17pt, weight: "bold", fill: rgb(ink), title)
  #v(10pt)
  #align(center)[
    #mermaid(
      source,
      theme-preset: preset,
      theme-appearance: appearance,
      width: 100%,
      height: 170pt,
      alt: title + ": Write, Review, Publish, and Revise",
    )
  ]
]

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  sample("Editor · Light", "editor", "light", "#ffffff", "#172033"),
  sample("Editor · Dark", "editor", "dark", "#0f172a", "#f5f5f5"),
  sample("Paper Cut", "paper-cut", "light", "#fff8ec", "#3d3127"),
  sample("Pop Art", "pop-art", "light", "#fff9df", "#161616"),
)
