// Regression coverage for fabox's smooth wet-glass and raised-joint finishes.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 15cm, height: auto, margin: 0.6cm, fill: rgb("#D8D8D8"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#fabox(
  title: [Wet glass], width: 6.2cm,
  colour: rgb("#424951"), frame: rgb("#171A1E"),
  back: rgb("#D5D9DC"), finish: "wet",
  shadow: "plain", shadow-colour: luma(70),
)[The wet rim is smooth and the body sheen sits underneath the text.]

#v(0.35cm)

#fabox(
  title: [Raised joint], width: 6.2cm,
  colour: rgb("#526A78"), frame: rgb("#263943"),
  back: rgb("#F0EEE7"), finish: "joint",
  finish-colour: rgb("#9CB5C2"), finish-depth: 3pt,
  shadow: "small", shadow-colour: luma(85),
)[A raised bead has a cast shadow, inner seam and upper-left highlight.]

#pagebreak()

#print-group[
  #fabox(
    title: [Printed wet finish], width: 6.2cm,
    finish: "wet", shadow: "plain",
  )[The highlight and dark rim remain legible in monochrome.]
  #v(0.3cm)
  #fabox(
    title: [Printed joint], width: 6.2cm,
    finish: "joint", finish-depth: 0.10,
  )[The material bead uses grayscale highlight and seam colours.]
]
