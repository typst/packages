#import "@preview/cetz:0.2.2": draw
#import "../util.typ": rotate-anchor

#let add-port(
  elmt-id, side, port, pos,
  prev: none,
  next: none,
  debug: false
) = {
  let name = port.at("name", default: "")
  let name-rotate = port.at("vertical", default: false)

  if (port.at("clock", default: false)) {
    if prev == none or next == none {
      panic("Clock port must have previous and next positions")
    }
    
    let size = if port.at("small", default: false) {8pt} else {1em}
    let offset
    if      (side == "north") { offset = (    0, -size) }
    else if (side == "east")  { offset = (-size,     0) }
    else if (side == "south") { offset = (    0,  size) }
    else if (side == "west")  { offset = ( size,     0) }

    let pos1 = (rel: offset, to: pos)

    // TODO: use context or vectors to have the height relative to the width
    draw.line(prev, pos1, next)
  }
  draw.content(
    pos,
    anchor: if name-rotate {rotate-anchor(side)} else {side},
    padding: 2pt,
    angle: if name-rotate {90deg} else {0deg},
    name
  )
  let id = elmt-id + "-port-" + port.at("id")

  if debug {
    draw.circle(
      pos,
      name: id,
      radius: .1,
      stroke: none,
      fill: red
    )
    
  } else {
    draw.hide(draw.circle(
      pos,
      radius: 0,
      stroke: none,
      name: id
    ))
  }
}

#let add-ports(
  elmt-id,
  tl, tr, br, bl,
  ports,
  ports-margins,
  debug: false
) = {
  let sides = (
    "north": (tl, tr),
    "east": (tr, br),
    "south": (bl, br),
    "west": (tl, bl)
  )

  if type(ports) != dictionary {
    return
  }

  for (side, props) in sides {
    let side-ports = ports.at(side, default: ())
    let space = 100% / (side-ports.len() + 1)

    for (i, port) in side-ports.enumerate() {
      let pct = (i + 1) * space
      let pt0 = props.at(0)
      let pt1 = props.at(1)

      if side in ports-margins {
        let (a, b) = (pt0, pt1)
        let margins = ports-margins.at(side)
        a = (pt0, margins.at(0), pt1)
        b = (pt0, 100% - margins.at(1), pt1)
        pt0 = a
        pt1 = b
      }
      
      let pos = (pt0, pct, pt1)
      let pct-prev = (i + 0.5) * space
      let pct-next = (i + 1.5) * space
      let pos-prev = (pt0, pct-prev, pt1)
      let pos-next = (pt0, pct-next, pt1)

      if port.at("small", default: false) {
        pos-prev = (pos, 4pt, pt0)
        pos-next = (pos, 4pt, pt1)
      }

      add-port(
        elmt-id,
        side,
        port,
        pos,
        prev: pos-prev,
        next: pos-next,
        debug: debug
      )
    }
  }
}