#import "@preview/cetz:0.3.1": draw
#import "consts.typ": *

#let _sep(name) = {
  return ((
    type: "sep",
    name: name
  ),)
}

#let _delay(name: none, size: 30) = {
  return ((
    type: "delay",
    name: name,
    size: size
  ),)
}

#let render(x-pos, elmt, y) = {
  let shapes = ()
  y -= Y-SPACE

  let x0 = x-pos.first() - 20
  let x1 = x-pos.last() + 20
  let m = measure(
    box(
      elmt.name,
      inset: (left: 3pt, right: 3pt, top: 5pt, bottom: 5pt)
    )
  )
  let w = m.width / 1pt
  let h = m.height / 1pt
  let cx = (x0 + x1) / 2
  let xl = cx - w / 2
  let xr = cx + w / 2

  y -= h / 2
  shapes += draw.rect(
    (x0, y),
    (x1, y - 3),
    stroke: none,
    fill: white
  )
  shapes += draw.line((x0, y), (x1, y))
  //shapes += draw.line((x0, y), (xl, y))
  //shapes += draw.line((xr, y), (x1, y))
  y -= 3
  shapes += draw.line((x0, y), (x1, y))
  //shapes += draw.line((x0, y), (xl, y))
  //shapes += draw.line((xr, y), (x1, y))
  shapes += draw.content(
    ((x0 + x1) / 2, y + 1.5),
    elmt.name,
    anchor: "center",
    padding: (5pt, 3pt),
    frame: "rect",
    fill: COL-SEP-NAME
  )
  y -= h / 2

  let r = (y, shapes)
  return r
}