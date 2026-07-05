#import "@preview/synkit:0.0.1": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

A less serious tree.

#tree(
  "[S [NP the 🐈] [VP[V sat][PP[P on] [NP the mat]]]]",
  content-size: 1,
  drop: 0.8,
  spread: 1.5,
  dash-branches: (
    ("VP1", "V1"),
    ("S1", "VP1"),
  ),
  color: (
    ("S1", green.darken(20%)),
    ("NP1", red),
    ("NP2", red),
    ("P1down", blue),
    ("VP1", "V1", orange),
  ),
  font: "Comic Sans MS",
)
