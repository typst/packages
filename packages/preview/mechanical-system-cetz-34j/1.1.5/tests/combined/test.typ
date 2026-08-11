#import "../../src/lib.typ": damper, spring, wall, wire
#import "@preview/cetz:0.4.2"

#set page(paper: "jis-b9", flipped: true)
#set align(center + horizon)
#cetz.canvas({
  import cetz.draw: *
  circle((0, 0), radius: 0.3, name: "mass1")
  spring((0.5, 0), name: "spring1", n: 8, inverse: false)
  circle((2, 0), radius: 0.3, name: "mass2")
  spring((3, -0.5), name: "spring2", n: 7)
  damper((3.15, 0.5), name: "damper", inverse: true)
  wall(
    (5, -1.2),
    b: (5, 1.2),
    name: "wall",
    inverse: false,
    inverse-lines: false,
  )
  line("mass1", "spring1")
  line("spring1", "mass2")
  line("spring1", "mass2")
  wire("mass2", "spring2")
  wire("mass2", "damper")
  wire("spring2", "wall")
  wire("damper", "wall")
  content("mass1", $M_1$)
  content("mass2", $M_2$)
  content("spring1.bottom", $k_1$)
  content("spring2.bottom", $k_1$)
  content("damper.top", $c_1$)
})
