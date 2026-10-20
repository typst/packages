#import "@preview/cetz:0.4.2"

#let base-x = .24
#let delta-x = .4
#let base-deg = 22deg
#let base-radius = 2.5em
// 原子、离子结构示意图
#let ai-struct(
  proton: 0,
  electrons: (),
) = {
  if type(proton) == int {
    assert(proton > 0 and proton < 119, message: "proton expected integer between 1 and 118.")
  } else if type(proton) == content {
    panic("proton expected single character, integer between 1 and 118. found content.")
  } else if proton.len() > 1 {
    panic("proton expected single character.")
  }
  cetz.canvas({
    import cetz.draw: *
    set-style(stroke: .5pt)
    circle((), radius: 1em, name: "circle", anchor: "east")
    content("circle", [+#proton])
    let index = 0
    for e in electrons {
      arc(
        (index * delta-x, 0),
        start: base-deg,
        stop: -base-deg,
        anchor: "center",
        radius: base-radius + index * .4em,
      )
      content((base-x + index * .438, 0), box(fill: white)[#e])
      index += 1
    }
  })
}

