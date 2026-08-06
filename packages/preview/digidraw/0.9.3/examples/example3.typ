#import "@preview/digidraw:0.9.3"
#set page(width: 14cm, height: auto, margin: 2mm)
#set align(center)

#digidraw.wave(
  (
    signal: (
      (wave: "ppPpppPppp", name: "Clock"),
      (wave: "l.10..10..", name: align(right)[Impulsinator\ 3000]),
      (wave: "xx2...3...", name: "State Machine", data: ("State A", "State B")),
    ),
  ),
  edge-overshoot: 0.5mm,
  guide-stroke: gray + 0.25pt,
  data-format: raw,
  tick-format: n => text(weight: "bold", font: "Liberation Sans", numbering("I", n)),
)
