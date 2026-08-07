#import "@preview/tableau-icons:0.344.0": ti-icon
#import "../src/wave.typ" as dd

#let toml = toml("../typst.toml")

#let data = (
  "signal": (
    (
      wave: "x2...LPp1d.pu2.xx",
      data: ([*D#text(0.7em, upper[igidraw])*], text(0.9em, font: "Libertinus Sans", [#toml.package.version])),
    ),
  ),
)

#let symbol-width = 1.75cm
#let symbol-height = 1.5cm
#let inset = 5mm

#set page(
  height: auto,
  width: auto,
  margin: 1mm,
)
#set align(horizon)
#set text(12pt, font: "Buenard", top-edge: "bounds", bottom-edge: "bounds")

#block(
  inset: 0mm,
  width: 35 * 5mm,
  fill: white,
  block(fill: white, stroke: blue + 0.5pt, dd.wave(
    (
      signal: (
        // | d |i| g |i| d |r | a |   w
        (wave: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"),
        (wave: "x1................................x"),
        (wave: "x1........2..Ph.....z.H.|.2....u..x"),
        (wave: "x0.5..0.50....51..50..............x"),
        (wave: "x1.50.50..........51..............x"),
        (wave: "x0.51.51505..0505..05.05..0515150.x"),
        (wave: "x1.50.5051505151505151.5151505051.x"),
        (wave: "x0.5..1.505..0505..050.5.5015151..x"),
        (wave: "x1..........51....................x"),
        (wave: "x0.hlH|.L.5..0.1..znnp....u.|.d2.0x"),
        (wave: "x0................................x"),
        (wave: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"),
      ),
    ),
    stroke: blue + 0.25pt,
    symbol-height: 5mm,
    wave-gutter: 0.3mm,
    step2: 20%,
    step1: 10%,
    symbol-width: 5mm,
    show-ticks: false,
    tick-format: none,
    bus-colors: (
      "5": blue,
      "x": dd.digidraw-x-pattern(stroke: blue + 0.3pt),
    ),
  ))
    + v(3mm, weak: true)
    + block(
      width: 100%,
      text()[Package Version $#toml.package.version$ #h(1fr) Created by #toml.package.authors.join()],
    ),
)
#let data = (signal: ((wave: "1203.2."),))
