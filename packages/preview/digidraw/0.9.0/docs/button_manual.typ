#import "@preview/tableau-icons:0.336.0": ti-icon

#let data = (
  "signal": (
    (
      wave: "x3...2....2.d.",
      data: (text(white)[*Click for*], `manual.pdf`, ti-icon("click"))
    ),
  ),
)


#set page(
  height: 1em + 2mm,
  width: 6mm * 1.1 * data.signal.first().wave.len() + 2mm,
  margin: 0mm,
)

#set align(horizon)
#set text(16pt, font: "Open Sauce Two", top-edge: "bounds", bottom-edge: "bounds")


#block(
  fill: white,
  width: 100%,
  height: 100%,
  text([
    #import "../src/wave.typ"
    #set text(0.6em, blue)
    #set align(center)
    #wave.wave(
      data,
      stroke: (paint: blue, thickness: 0.75pt, cap: "round", join: "round"),
      stroke-dashed: (dash: (3pt, 5pt)),
      wave-height: 1,
      size: 6mm,
      symbol-width: 1.1,
      mark-scale: 2,
      ticks-format: none,
      data-format: value => text(1.5em, top-edge: "cap-height", bottom-edge: "baseline", value),
      show-tick-lines: false,
      bus-colors: ("3": blue, 
        "x": tiling(size: (1.25mm, 1.25mm), box(width: 100%, height: 100%, fill: white, {
  set line(stroke: blue + 0.3pt)
  place(std.line(start: (0%, 100%), end: (100%, 0%)))
  place(std.line(start: (90%, 110%), end: (110%, 90%)))
  place(std.line(start: (-10%, 10%), end: (10%, -10%)))
}))

      )
    )
  ]),
)
