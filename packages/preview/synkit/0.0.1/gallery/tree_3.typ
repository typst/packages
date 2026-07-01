#import "@preview/synkit:0.0.1": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

Tree from David Chiang's tutorial on `tikz-qtree`.

#garden(
  (
    input: "[S [NP [Det the] [N cat]] [VP [V sat] [PP [P on] [NP [Det the] [N mat]]]]]",
    spread: 1.55,
    content-size: 1,
  ),
  (
    input: "[S [NP 猫が] [VP [PP [NP [NP マット] [Part の] [NP 上] ] [P に]] [V 土]]]",
    direction: "up",
    content-size: 1,
  ),
  equivalence: (
    ("Det1-1", "NP1-2"),
    ("P1-1", "P1-2"),
    ("P1-1", "NP4-2"),
    ("N1-1", "NP1-2"),
    ("N2-1", "NP3-2"),
    ("Det2-1", "NP3-2"),
    ("V1-1", "V1-2"),
  ),
  gap: 2.5,
  scale: 0.7,
)
