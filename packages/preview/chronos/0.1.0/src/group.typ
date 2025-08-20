#import "@preview/cetz:0.2.2": draw
#import "consts.typ": *

#let _grp(name, desc: none, type: "default", elmts) = {
  return ((
    type: "grp",
    name: name,
    desc: desc,
    grp-type: type,
    elmts: elmts
  ),)
}

#let render(x0, x1, y0, y1, group) = {
  let shapes = ()
  let name = text(group.name, weight: "bold")
  let m = measure(box(name))
  let w = m.width / 1pt + 15
  let h = m.height / 1pt + 6
  shapes += draw.rect(
    (x0, y0),
    (x1, y1)
  )
  shapes += draw.merge-path(
    fill: COL-GRP-NAME,
    close: true,
    {
      draw.line(
        (x0, y0),
        (x0 + w, y0),
        (x0 + w, y0 - h / 2),
        (x0 + w - 5, y0 - h),
        (x0, y0 - h)
      )
    }
  )
  shapes += draw.content(
    (x0, y0),
    name,
    anchor: "north-west",
    padding: (left: 5pt, right: 10pt, top: 3pt, bottom: 3pt)
  )

  if group.desc != none {
    shapes += draw.content(
      (x0 + w, y0),
      text([\[#group.desc\]], weight: "bold", size: .8em),
      anchor: "north-west",
      padding: 3pt
    )
  }

  return shapes
}