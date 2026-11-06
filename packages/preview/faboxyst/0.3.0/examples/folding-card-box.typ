// One open folding card with a numbered flap, title wing, icon, and description.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#F5F6F7"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #folding-card-box(
    number: [01],
    title: [Target the next milestone],
    front-text: [Keep the next action visible while the team works toward the outcome.],
    body: [Bring the right people together, agree on a clear outcome, and make the next step easy to act on.],
    width: 7.8cm,
    colour: rgb("#079ED9"),
  )
]
