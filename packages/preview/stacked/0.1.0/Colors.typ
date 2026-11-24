#let petroff10 = (
  rgb(63, 144, 218),
  rgb(255, 169, 14),
  rgb(189, 31, 1),
  rgb(148, 164, 162),
  rgb(131, 45, 182),
  rgb(169, 107, 89),
  rgb(231, 99, 0),
  rgb(185, 172, 112),
  rgb(113, 117, 129),
  rgb(146, 218, 221)
)

#let okabe-ito = (
 rgb(0, 114, 178),
 rgb(230, 159, 0),
 rgb(0, 158, 115),
 rgb(204, 121, 167),
 rgb(86, 180, 233),
 rgb(213, 94, 0),
 rgb(240, 228, 66).darken(4%),
)
#let typst16 = (blue,   purple,   teal,  red,  aqua, orange, eastern, fuchsia.darken(10%), green, 
              maroon.lighten(15%), olive, yellow, lime, navy, black, gray)

#let wildscale = (
  // oklch(100%, 0, 90deg),
  oklch(93.51%, 0.121, 105.91deg),
  oklch(77.22%, 0.136, 15.42deg),
  oklch(74.54%, 0.265, 327.84deg),
  oklch(69.92%, 0.165, 249.09deg),
  oklch(85.09%, 0.21, 155.14deg),
  oklch(69.86%, 0.235, 142.04deg),
  oklch(58.27%, 0.214, 33.2deg),
  oklch(57.35%, 0.231, 4.13deg),
  oklch(36.03%, 0.213, 279.18deg),
  oklch(25.25%, 0.055, 236.78deg),
  // oklch(0%, 0, 0deg),
)

#let wildscale2 = (
  // oklch(100%, 0, 90deg),
  oklch(87.86%, 0.08, 60.49deg),
  oklch(80.43%, 0.186, 325.72deg),
  oklch(88.81%, 0.18, 168.04deg),
  oklch(72.74%, 0.149, 84.64deg),
  oklch(69.55%, 0.316, 330.72deg),
  oklch(65.78%, 0.18, 248.72deg),
  oklch(52.97%, 0.179, 142.14deg),
  oklch(46.98%, 0.19, 24.28deg),
  oklch(23.85%, 0.133, 264.32deg),
  oklch(0%, 0, 0deg),
)

#let wildscale3 = (
  // oklch(100%, 0, 90deg),
  oklch(0%, 0, 0deg),
  oklch(42.2%, 0.141, 141.57deg),
  oklch(28.11%, 0.138, 315.67deg),
  oklch(84.75%, 0.13, 332.09deg),
  oklch(89.73%, 0.16, 180.14deg),
  oklch(68.14%, 0.21, 34.7deg),
  oklch(72.82%, 0.161, 237.74deg),
  oklch(60.7%, 0.151, 54.5deg),
  oklch(49.58%, 0.285, 272.08deg),
).rev()

#let paired12 = ("#a6cee3",
"#1f78b4",
"#b2df8a",
"#33a02c",
"#fb9a99",
"#e31a1c",
"#fdbf6f",
"#ff7f00",
"#cab2d6",
"#6a3d9a",
"#ffff99",
"#b15928",).map(rgb)
//multicolors.map(x=>x.darken(25%))

#let multicolors = (
  rgb("#e41a1c"),
  rgb("#377eb8"),
  rgb("#4daf4a"),
  rgb("#984ea3"),
  rgb("#ff7f00"),
  rgb("#a65628"),
  rgb("#ffff33"),
  rgb("#f781bf"),
  rgb("#999999"),
)

// #import "@preview/splash:0.5.0": xcolor

// #xcolor

// #let rosewater = rgb(220, 138, 120)
// #let flamingo = rgb(221, 120, 120)
// #let pink = rgb(234, 118, 203)
// #let mauve = rgb(136, 57, 239)
// #let red = rgb(210, 15, 57)
// #let maroon = rgb(230, 69, 83)
// #let peach = rgb(254, 100, 11)
// #let yellow = rgb(223, 142, 29)
// #let green = rgb(64, 160, 43)
// #let teal = rgb(23, 146, 153)
// #let sky = rgb(4, 165, 229)
// #let sapphire = rgb(32, 159, 181)
// #let blue = rgb(30, 102, 245)
// #let lavender = rgb(114, 135, 253)
// #let text = rgb(76, 79, 105)
// #let subtext1 = rgb(92, 95, 119)
// #let subtext0 = rgb(108, 111, 133)
// #let overlay2 = rgb(124, 127, 147)
// #let overlay1 = rgb(140, 143, 161)
// #let overlay0 = rgb(156, 160, 176)
// #let surface2 = rgb(172, 176, 190)
// #let surface1 = rgb(188, 192, 204)
// #let surface0 = rgb(204, 208, 218)
// #let base = rgb(239, 241, 245)
// #let mantle = rgb(230, 233, 239)
// #let crust = rgb(220, 224, 232)

// #for i in paired12 {box(rect(fill:i))}

// #for i in wildscale2 {box(rect(fill:i))}

// #import "@preview/qcm:0.1.0": colormap

// #colormap("Set1", 9)

// #for i in colormap("Set1", 9) {box(rect(fill:i))}