#import "@preview/digidraw:0.9.3"

#set page(width: 14cm, height: auto, margin: 2mm)
#set align(center)

#digidraw.wave(
  (
    signal: (
      (wave: "12.00..13", name: "Haha fancy ticks!"),
      (wave: "xxx45...x", name: ":)"),
    ),
  ),
  show-ticks: n => n in (0,1,3,5,4,7,8,),
  tick-stroke: n => {
    if      n in (0,)      { (paint: red) }
    else if n in (5, 7, 8) { (paint: blue) }
    else if n in (4,)      { (paint: orange) }
    else { auto }
  },
  tick-format: n => align(horizon, text(font: if calc.rem(n, 2) == 0 { "Fantasque Sans Mono" } else { "Libertinus Keyboard" })[#n]),
)
