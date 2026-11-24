#import "@preview/digidraw:0.9.3" as dd

#set page(width: 14cm, height: auto, margin: 2mm)
#set align(center)

#dd.wave(
  (
    signal: (
      (wave: "79..|8..xx", name: "Bus", data: ("Start", "Transmit","End")),
      (wave: "x0..|1..zz", name: "Signal #2"),
      (wave: "00..|u.1..", name: "Output"),
    ),
  ),
  edge-overshoot: 0.5mm,
  guide-stroke: gray + 0.25pt,
)
