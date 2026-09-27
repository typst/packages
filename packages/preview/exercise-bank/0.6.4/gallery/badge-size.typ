// Badge size - exercise-bank
// badge-scale multiplies the paddings of any badge shape; badge-pad-x,
// badge-pad-y and badge-radius replace them outright

#import "@preview/exercise-bank:0.6.4": *

#set page(width: 11cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)

#exo-setup(
  exercise-label: "Exercice",
  badge-position: "above",
  badge-color: rgb("#1a5276"),
  label-font-size: 10pt,
)

#for style in ("filled-rect", "pill") {
  for scale in (0.5, 1.0, 1.6) {
    exo-setup(badge-style: style, badge-scale: scale)
    exo(exercise: [`badge-style: "#style"`, `badge-scale: #scale`])
  }
}

#exo-setup(badge-style: "pill", badge-scale: 1.0,
  badge-pad-x: 6pt, badge-pad-y: 2pt, badge-radius: 7pt)
#exo(exercise: [`badge-pad-x: 6pt`, `badge-pad-y: 2pt`, `badge-radius: 7pt`])
