

#let __digidraw-default-config = (
  size: 8mm,
  debug: false,
  tick-overshoot: 25%,
  wave-width: auto,
  symbol-width: 1.3,
  wave-height: 1,
  inset-1: 10%,
  inset-2: 20%,
  wave-gutter: 0.5,
  name-gutter: 0.4,
  mark-scale: 1,
  show-guides: false,
  stroke: (cap: "round", thickness: 0.5pt, paint: black, join: "round"),
  stroke-dashed: (cap: "round", join: "round", dash: (0.1em, 0.15em)),
  show-tick-lines: true,
  ticks-format: n => text(0.8em, numbering("1", n)),
  name-format: name => text(1em, weight: "bold", if type(name) != str [#name] else [#eval(name, mode: "markup")]),
  stroke-tick-lines: (cap: "round", thickness: 0.5pt, paint: gray, dash: "dashed"),
  stroke-guides: (cap: "round", thickness: 0.25pt, paint: gray),
  stroke-debug-line: (paint: red, thickness: 0.5pt),
  mark-debug-line: (symbol: ">", scale: 0.8, fill: white),
  debug-format: (value) => text(
    0.8em,
    font: "DejaVu Sans Mono",
    top-edge: "cap-height",
    bottom-edge: "bounds",
    box(
      radius: 0.2em,
      height: 1.1em,
      width: 1.1em,
      fill: red.lighten(50%),
      align(center + horizon, value),
    ),
  ),
  debug-offset: 0.5,
  data-format: value => text(
    0.9em,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    if type(value) != str [#value] else [#eval(value, mode: "markup")],
  ),
  bus-colors: (
    "2": white,
    "3": rgb("#ffffb4"),
    "4": rgb("#ffe0b9"),
    "5": rgb("#b9e0ff"),
    "6": rgb("#ccfdfe"),
    "7": rgb("#cdfdc5"),
    "8": rgb("#f0c1fb"),
    "9": rgb("#f8d0ce"),
    "x": tiling(size: (1.25mm, 1.25mm), box(width: 100%, height: 100%, fill: white, {
      set line(stroke: black + 0.3pt)
      place(std.line(start: (0%, 100%), end: (100%, 0%)))
      place(std.line(start: (90%, 110%), end: (110%, 90%)))
      place(std.line(start: (-10%, 10%), end: (10%, -10%)))
    })),
  ),
  s-spacing: 0.1,
  s-outside: 0.1,
)




#let __digidraw-x-pattern = tiling(size: (1.25mm, 1.25mm), box(width: 100%, height: 100%, fill: white, {
  set line(stroke: black + 0.3pt)
  place(std.line(start: (0%, 100%), end: (100%, 0%)))
  place(std.line(start: (90%, 110%), end: (110%, 90%)))
  place(std.line(start: (-10%, 10%), end: (10%, -10%)))
}))
