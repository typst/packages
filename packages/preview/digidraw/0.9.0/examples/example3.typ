#import "../src/wave.typ"

#set page(width: 14cm, height: auto, margin: 2mm)
#set align(center)

#wave.wave(
  (
    signal: (
      (wave: "ppPpppPppp", name: "Clock"),
      (wave: "l.10..10..", name: align(right)[Impulsinator\ 3000]),
      (wave: "xx2...3...", name: "State Machine", data: ("State A", "State B")),
    ),
  ),
  show-guides: true,
  data-format: raw,
  ticks-format: n => text(weight: "bold", font: "Liberation Sans", numbering("I", n)),
)
