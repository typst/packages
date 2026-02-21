#import "../src/wave.typ"

#set page(width: 14cm, height: auto, margin: 2mm)
#set align(center)

#wave.wave(
  (
    signal: (
      (wave: "79..|8..xx", name: "Bus", data: ("Start", "Transmit","End")),
      (wave: "x0..|1..zz", name: "Signal \#2"),
      (wave: "00..|u.1..", name: "Output"),
    ),
  ),
  show-guides: true,
)
