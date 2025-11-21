#import "@preview/cetz:0.4.1"

// ======================原子/离子结构示意图================

#let ai-struct(
  proton: 0,
  electrons: (),
) = {
  assert(type(proton) == int and proton >= 0 or type(proton) == str, message: "proton must be an positive integer or a string")
  cetz.canvas({
    import cetz.draw: *
    set-style(stroke: .5pt)
    let _radius = if type(proton) == str or proton < 10 { .75em } else if proton < 100 { 1.15em } else { 1.25em }
    circle((), radius: _radius, name: "proton", anchor: "east")
    content("proton", [#text(font: "Lucida Sans Unicode")[+]#proton])
    let index = 0
    let base-x = .24
    let base-deg = 22deg
    let delta-x = .4
    let base-radius = 2.5em
    for e in electrons {
      arc(
        (index * delta-x, 0),
        start: base-deg,
        stop: -base-deg,
        anchor: "center",
        radius: base-radius + index * .4em,
      )
      content((.24 + index * .438, 0), [#box(fill: white)[#e]])
      index += 1
    }
  })
}


