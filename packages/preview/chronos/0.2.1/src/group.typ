#import "/src/cetz.typ": draw
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

#let _alt(desc, elmts, ..args) = {
  let all-elmts = ()
  all-elmts += elmts
  let args = args.pos()
  for i in range(0, args.len(), step: 2) {
    let else-desc = args.at(i)
    let else-elmts = args.at(i + 1, default: ())
    all-elmts.push((
      type: "else",
      desc: else-desc
    ))
    all-elmts += else-elmts
  }

  return _grp("alt", desc: desc, type: "alt", all-elmts)
}

#let _loop(desc, min: none, max: auto, elmts) = {
  let name = "loop"
  if min != none {
    if max == auto {
      max = "*"
    }
    name += "(" + str(min) + "," + str(max) + ")"
  }
  _grp(name, desc: desc, type: "loop", elmts)
}
#let _opt(desc, elmts) = grp("opt", desc: desc, type: "opt", elmts)
#let _break(desc, elmts) = grp("break", desc: desc, type: "break", elmts)

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

#let render-else(x0, x1, y, elmt) = {
  let shapes = draw.line(
    (x0, y),
    (x1, y),
    stroke: (dash: (2pt, 1pt), thickness: .5pt)
  )
  shapes += draw.content(
    (x0, y),
    text([\[#elmt.desc\]], weight: "bold", size: .8em),
    anchor: "north-west",
    padding: 3pt
  )
  return shapes
}