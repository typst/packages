
/// The default tiling/fill for the `"x"`-bus (but not limited to it). It can be customized with color (@-digidraw-x-pattern.stroke), sizing (@-digidraw-x-pattern.size) and direction (@-digidraw-x-pattern.dir).
/// 
///#example(```
///#let data = (signal: ((wave: "x.1.0.x."),))
///
///*Default*
///#dd.wave(data)
/// 
///#dd.wave(data,
///  bus-colors: (
///    "x": dd.digidraw-x-pattern(
///      stroke: red,
///      size: 3mm,
///      dir: ttb
///    )
///  ) 
///)
///```)
/// 
/// -> tiling
#let digidraw-x-pattern(
  /// Color of the diagonal lines
  /// 
  /// -> stroke
  stroke: black + 0.3pt,
  /// Vertical or horizontal spacing of the lines. The tiling uses a square box, in which one line segment is drawn.
  /// 
  /// -> length
  size: 1.25mm,
  /// Direction of the diagonal lines.
  /// 
  /// - `btt` goes from bottom-left to top-right
  /// - `ttb` goes from top-left to bottom-right
  ///  
  /// -> direction
  dir: btt,
  ) = tiling(size: (size, size), box(width: 100%, height: 100%, fill: white, {
  set line(stroke: stroke )
  if dir == btt {
    place(std.line(start: (0%, 100%), end: (100%, 0%)))
    place(std.line(start: (90%, 110%), end: (110%, 90%)))
    place(std.line(start: (-10%, 10%), end: (10%, -10%)))

  } else if dir == ttb {
    place(std.line(start: (0%, 0%), end: (100%, 100%)))
    place(std.line(start: (90%, -10%), end: (110%, 10%)))
    place(std.line(start: (-10%, 90%), end: (10%, 110%)))

  } else {
    panic("Given ")
  }
}))


#let __digidraw-default-config = (
  tick-overshoot: 20%,
  wave-width: auto,
  symbol-width: 1.5cm,
  symbol-height: 1cm,
  step1: 12.5%,
  step2: 25%,
  step3: 50%,
  edge-overshoot: 10%,
  wave-gutter: 100%,
  name-gutter: 30%,
  tick-gutter: 20%,
  s-spacing: 10%,
  s-width: 20%,
  s-outside: 15%,
  mark-scale: 1,
  guide-stroke: none,
  stroke: 0.5pt + black,
  stroke-dashed: (dash: (2pt, 1.75pt)),
  show-ticks: true,
  tick-format: n => text(0.8em, numbering("1", n)),
  name-format: name => text(1em, weight: "bold", bottom-edge: "baseline", if type(name) != str [#name] else [#eval(
    name,
    mode: "markup",
  )]),

  data-format: data => text(
    0.9em,
    bottom-edge: "baseline",
    if type(data) != str [#data] else [#eval(data, mode: "markup")],
  ),

  // TODO: include function capability
  tick-stroke: (thickness: 0.5pt, paint: gray, dash: "densely-dashed"),

  bus-colors: (
    "=": white,
    "2": white,
    "3": rgb("#ffffb4"),
    "4": rgb("#ffe0b9"),
    "5": rgb("#b9e0ff"),
    "6": rgb("#ccfdfe"),
    "7": rgb("#cdfdc5"),
    "8": rgb("#f0c1fb"),
    "9": rgb("#f8d0ce"),
    "x": digidraw-x-pattern(),
  ),
)



