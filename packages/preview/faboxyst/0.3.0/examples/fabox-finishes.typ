// Two new material finishes for fabox: wet glass and a raised joint bead.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 17cm, height: 10cm, margin: 0.65cm, fill: rgb("#C7C7C8"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center)[
  #text(size: 15pt, weight: "bold")[fabox · material finishes]
  #v(0.35cm)
  #grid(columns: (1fr, 1fr), gutter: 0.45cm,
    fabox(
      title: [Water glass],
      colour: rgb("#424951"),
      frame: rgb("#171A1E"),
      back: rgb("#D5D9DC"),
      title-fill: rgb("#242A30"),
      title-colour: white,
      finish: "wet",
      finish-depth: 0.09,
      shadow: "plain",
      shadow-colour: luma(70),
      shadow-spread: 0.12,
      width: 100%,
    )[
      A smooth, translucent-looking face with a dark glass edge and clean
      white specular streaks. The existing box shadow remains independently
      adjustable.
    ],
    fabox(
      title: [Raised joint],
      colour: rgb("#526A78"),
      frame: rgb("#263943"),
      back: rgb("#F0EEE7"),
      title-fill: rgb("#526A78"),
      title-colour: white,
      finish: "joint",
      finish-colour: rgb("#9CB5C2"),
      finish-depth: 0.10,
      shadow: "small",
      shadow-colour: luma(85),
      width: 100%,
    )[
      A continuous raised cordon: soft cast shadow, rounded bead, inner seam
      and a narrow highlight on the light-facing edges.
    ],
  )
]
