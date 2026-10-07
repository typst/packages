// NEPO (Open Roberta) blocks for the Calliope mini and the micro:bit.
//
// The same notation as scratch(); block text is Open Roberta's own German
// wording. `platform` picks the robot: calliope (default), calliopev3, microbit.
#import "@preview/blockst:0.4.0": nepo, set-blockst

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#set text(font: "Helvetica Neue", fallback: true)

#grid(
  columns: 2,
  column-gutter: 8mm,
  align: top,
  nepo("
Start
  Zeige Text \"Hallo\"
  Wiederhole unendlich oft
    Schalte RGB LED an (#ff0000)
  Ende
"),
  nepo("
Start
  Zeige Text \"Hi\"
", platform: "microbit"),
)
