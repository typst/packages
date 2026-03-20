#import "@preview/tableau-icons:0.336.0": ti-icon

#let data = (
  "signal": (
    (
      wave: "xx2...LPp1d.pu2.xx",
      data: ([*Digidraw*], text(0.9em, font: "Libertinus Sans", [0.9.0]))
    ),
  ),
)


#set page(
  height: 2.5cm,
  width: 8mm * 2.2 * data.signal.first().wave.len() + 1cm,
  margin: 0mm,
  fill: white.transparentize(100%),
)
#set align(horizon)
#set text(40pt, font: "Buenard", top-edge: "bounds", bottom-edge: "bounds")



#block(
  fill: gradient.linear(
    ..(rgb("#378cb7"), rgb("#3a8bb7"), rgb("#2ca1a7"), rgb("#23b0ab"), rgb("#1eb3b4")),
    angle: -60deg,
  ),
  width: 100%,
  height: 100%,
  clip: true,
  radius: 5mm,
  {
    place(right + horizon, [

    ])
    place(block(
      fill: gradient.linear(
        ..(
          rgb("#378cb7"),
          rgb("#3a8bb7"),
          rgb("#2ca1a7").transparentize(60%),
          rgb("#23b0ab").transparentize(100%),
          rgb("#1eb3b4").transparentize(100%),
        ),
        angle: -60deg,
      ),
      width: 100%,
      height: 100%,
      radius: 5mm,
      text(white, [
        #import "../src/wave.typ"
        #set text(white, 0.6em)
        #set align(center)
        #wave.wave(
          data,
          stroke: (paint: white, thickness: 2pt, cap: "round", join: "round"),
          stroke-dashed: (dash: (3pt, 5pt)),
          wave-height: 2,
          symbol-width: 2.2,
          mark-scale: 2,
          ticks-format: none,
          data-format: value => text(1.5em, top-edge: "cap-height", bottom-edge: "baseline", value),


          show-tick-lines: false,
          bus-colors: (
            "2": none,
            "x": tiling(size: (2mm, 2mm), box(width: 100%, height: 100%, fill: none, {
              set line(stroke: white + 1pt)
              place(std.line(start: (0%, 100%), end: (100%, 0%)))
              place(std.line(start: (90%, 110%), end: (110%, 90%)))
              place(std.line(start: (-10%, 10%), end: (10%, -10%)))
            })),
          ),
        )
      ]),
    ))
  },
)
