#import "@preview/cetz:0.2.2": draw
#import "consts.typ": *

#let PAR-SPECIALS = "?[]"
#let SHAPES = (
  "participant",
  "actor",
  "boundary",
  "control",
  "entity",
  "database",
  "collections",
  "queue",
  "custom"
)

#let _par(
  name,
  display-name: auto,
  from-start: true,
  invisible: false,
  shape: "participant",
  color: rgb("#E2E2F0"),
  custom-image: none,
  show-bottom: true,
  show-top: true,
) = {
  return ((
    type: "par",
    name: name,
    display-name: if display-name == auto {name} else {display-name},
    from-start: from-start,
    invisible: invisible,
    shape: shape,
    color: color,
    custom-image: custom-image,
    show-bottom: show-bottom,
    show-top: show-top
  ),)
}

#let _exists(participants, name) = {
  if name == "?" or name == "[" or name == "]" {
    return true
  }

  for p in participants {
    if name == p.name {
      return true
    }
  }
  return false
}

#let get-size(par) = {
  if par.invisible {
    return (width: 0pt, height: 0pt)
  }
  let m = measure(box(par.display-name))
  let w = m.width
  let h = m.height
  let (shape-w, shape-h) = (
    participant: (w + PAR-PAD.last() * 2, h + PAR-PAD.first() * 2),
    actor: (ACTOR-WIDTH * 1pt, ACTOR-WIDTH * 2pt + SYM-GAP * 1pt + h),
    boundary: (BOUNDARY-HEIGHT * 2pt, BOUNDARY-HEIGHT * 1pt + SYM-GAP * 1pt + h),
    control: (CONTROL-HEIGHT * 1pt, CONTROL-HEIGHT * 1pt + SYM-GAP * 1pt + h),
    entity: (ENTITY-HEIGHT * 1pt, ENTITY-HEIGHT * 1pt + 2pt + SYM-GAP * 1pt + h),
    database: (DATABASE-WIDTH * 1pt, DATABASE-WIDTH * 4pt / 3 + SYM-GAP * 1pt + h),
    collections: (
      w + COLLECTIONS-PAD.last() * 2 + calc.abs(COLLECTIONS-DX) * 1pt,
      h + COLLECTIONS-PAD.first() * 2 + calc.abs(COLLECTIONS-DY) * 1pt,
    ),
    queue: (
      w + QUEUE-PAD.last() * 2 + 3 * (h + QUEUE-PAD.first() * 2) / 4,
      h + QUEUE-PAD.first() * 2
    ),
    custom: (
      measure(par.custom-image).width,
      measure(par.custom-image).height + SYM-GAP * 1pt + h
    )
  ).at(par.shape)

  return (
    width: calc.max(w, shape-w),
    height: calc.max(h, shape-h)
  )
}

#let _render-participant(x, y, p, m, bottom) = {
  let w = m.width / 1pt
  let h = m.height / 1pt
  let x0 = x - w / 2 - PAR-PAD.last() / 1pt
  let x1 = x + w / 2 + PAR-PAD.last() / 1pt
  let y0 = y + h + PAR-PAD.first() / 1pt * 2
  if bottom {
    y0 = y
  }
  let y1 = y0 - h - PAR-PAD.first() / 1pt * 2

  draw.rect(
    (x0, y0),
    (x1, y1),
    radius: 2pt,
    fill: p.color,
    stroke: black + .5pt
  )
  draw.content(
    ((x0 + x1) / 2, (y0 + y1) / 2),
    p.display-name,
    anchor: "center"
  )
}

#let _render-actor(x, y, p, m, bottom) = {
  let w2 = ACTOR-WIDTH / 2
  let head-r = ACTOR-WIDTH / 4
  let height = ACTOR-WIDTH * 2
  let arms-y = height * 0.375

  let y0 = if bottom {y - m.height / 1pt - SYM-GAP} else {y + m.height / 1pt + height + SYM-GAP}
  draw.circle(
    (x, y0 - head-r),
    radius: head-r,
    fill: p.color,
    stroke: black + .5pt
  )
  draw.line((x, y0 - head-r * 2), (x, y0 - height + w2), stroke: black + .5pt)
  draw.line((x - w2, y0 - arms-y), (x + w2, y0 - arms-y), stroke: black + .5pt)
  draw.line((x - w2, y0 - height), (x, y0 - height + w2), (x + w2, y0 - height), stroke: black + .5pt)
  draw.content(
    (x, y),
    p.display-name,
    anchor: if bottom {"north"} else {"south"}
  )
}

#let _render-boundary(x, y, p, m, bottom) = {
  let circle-r = BOUNDARY-HEIGHT / 2
  let y0 = if bottom {y - m.height / 1pt - SYM-GAP} else {y + m.height / 1pt + BOUNDARY-HEIGHT + SYM-GAP}
  let x0 = x - BOUNDARY-HEIGHT
  let y1 = y0 - circle-r
  let y2 = y0 - BOUNDARY-HEIGHT

  draw.circle(
    (x + circle-r, y1),
    radius: circle-r,
    fill: p.color,
    stroke: black + .5pt
  )
  draw.line(
    (x0, y0), (x0, y2),
    stroke: black + .5pt
  )
  draw.line(
    (x0, y1), (x, y1),
    stroke: black + .5pt
  )
  draw.content(
    (x, y),
    p.display-name,
    anchor: if bottom {"north"} else {"south"}
  )
}

#let _render-control(x, y, p, m, bottom) = {
  let r = CONTROL-HEIGHT / 2
  let y0 = if bottom {y - m.height / 1pt - SYM-GAP} else {y + m.height / 1pt + CONTROL-HEIGHT + SYM-GAP}

  draw.circle(
    (x, y0 - r),
    radius: r,
    fill: p.color,
    stroke: black + .5pt
  )
  draw.mark((x, y0), (x - r / 2, y0), symbol: "stealth", fill: black)
  draw.content(
    (x, y),
    p.display-name,
    anchor: if bottom {"north"} else {"south"}
  )
}

#let _render-entity(x, y, p, m, bottom) = {
  let r = ENTITY-HEIGHT / 2
  let y0 = if bottom {y - m.height / 1pt - SYM-GAP} else {y + m.height / 1pt + ENTITY-HEIGHT + SYM-GAP}
  let y1 = y0 - ENTITY-HEIGHT - 1.5

  draw.circle(
    (x, y0 - r),
    radius: r,
    fill: p.color,
    stroke: black + .5pt
  )
  draw.line(
    (x - r, y1),
    (x + r, y1),
    stroke: black + .5pt
  )
  draw.content(
    (x, y),
    p.display-name,
    anchor: if bottom {"north"} else {"south"}
  )
}

#let _render-database(x, y, p, m, bottom) = {
  let height = DATABASE-WIDTH * 4 / 3
  let rx = DATABASE-WIDTH / 2
  let ry = rx / 2
  let y0 = if bottom {y - m.height / 1pt - SYM-GAP} else {y + m.height / 1pt + height + SYM-GAP}
  let y1 = y0 - height

  draw.merge-path(
    close: true,
    fill: p.color,
    stroke: black + .5pt,
    {
      draw.bezier((x - rx, y0 - ry), (x, y0), (x - rx, y0 - ry/2), (x - rx/2, y0))
      draw.bezier((), (x + rx, y0 - ry), (x + rx/2, y0), (x + rx, y0 - ry/2))
      draw.line((), (x + rx, y1 + ry))
      draw.bezier((), (x, y1), (x + rx, y1 + ry/2), (x + rx/2, y1))
      draw.bezier((), (x - rx, y1 + ry), (x - rx/2, y1), (x - rx, y1 + ry/2))
    }
  )
  draw.merge-path(
    stroke: black + .5pt,
    {
      draw.bezier((x - rx, y0 - ry), (x, y0 - ry*2), (x - rx, y0 - 3*ry/2), (x - rx/2, y0 - ry*2))
      draw.bezier((), (x + rx, y0 - ry), (x + rx/2, y0 - ry*2), (x + rx, y0 - 3*ry/2))
    }
  )
  draw.content(
    (x, y),
    p.display-name,
    anchor: if bottom {"north"} else {"south"}
  )
}

#let _render-collections(x, y, p, m, bottom) = {
  let w = m.width / 1pt
  let h = m.height / 1pt
  let dx = COLLECTIONS-DX
  let dy = COLLECTIONS-DY
  let total-w = w + PAR-PAD.last() * 2 / 1pt + calc.abs(dx)
  let total-h = h + PAR-PAD.first() * 2 / 1pt + calc.abs(dy)

  let x0 = x - total-w / 2
  let x1 = x0 + calc.abs(dx)
  let x3 = x0 + total-w
  let x2 = x3 - calc.abs(dx)
  
  let y0 = if bottom {y} else {y + total-h}
  let y1 = y0 - calc.abs(dy)
  let y3 = y0 - total-h
  let y2 = y3 + calc.abs(dy)

  let r1 = (x1, y0, x3, y2)
  let r2 = (x0, y1, x2, y3)

  if dx < 0 {
    r1.at(0) = x0
    r1.at(2) = x2
    r2.at(0) = x1
    r2.at(2) = x3
  }

  if dy < 0 {
    r1.at(1) = y1
    r1.at(3) = y3
    r2.at(1) = y0
    r2.at(3) = y2
  }
  draw.rect(
    (r1.at(0), r1.at(1)),
    (r1.at(2), r1.at(3)),
    fill: p.color,
    stroke: black + .5pt
  )
  draw.rect(
    (r2.at(0), r2.at(1)),
    (r2.at(2), r2.at(3)),
    fill: p.color,
    stroke: black + .5pt
  )
  
  draw.content(
    ((r2.at(0) + r2.at(2)) / 2, (r2.at(1) + r2.at(3)) / 2),
    p.display-name,
    anchor: "center"
  )
}

#let _render-queue(x, y, p, m, bottom) = {
  let w = (m.width + QUEUE-PAD.last() * 2) / 1pt
  let h = (m.height + QUEUE-PAD.first() * 2) / 1pt
  let total-h = h
  let ry = total-h / 2
  let rx = ry / 2
  let total-w = w + 3 + 3 * rx

  let x0 = x - total-w / 2
  let y0 = if bottom {y} else {y + total-h}
  let y1 = y0 - total-h
  let x-left = x0 + rx
  let x-right = x-left + w + rx
  draw.merge-path(
    close: true,
    fill: p.color,
    stroke: black + .5pt,
    {
      draw.bezier((x-right, y0), (x-right + rx, y0 - ry), (x-right + rx/2, y0), (x-right + rx, y0 - ry/2))
      draw.bezier((), (x-right, y1), (x-right + rx, y1 + ry/2), (x-right + rx/2, y1))
      draw.line((), (x-left, y1))
      draw.bezier((), (x-left - rx, y0 - ry), (x-left - rx/2, y1), (x-left - rx, y1 + ry/2))
      draw.bezier((), (x-left, y0), (x-left - rx, y0 - ry/2), (x-left - rx/2, y0))
    }
  )
  draw.merge-path(
    stroke: black + .5pt,
    {
      draw.bezier((x-right, y0), (x-right - rx, y0 - ry), (x-right - rx/2, y0), (x-right - rx, y0 - ry/2))
      draw.bezier((), (x-right, y1), (x-right - rx, y1 + ry/2), (x-right - rx/2, y1))
    }
  )
  draw.content(
    ((x-left + x-right - rx) / 2, y0 - ry),
    p.display-name,
    anchor: "center"
  )
}

#let _render-custom(x, y, p, m, bottom) = {
  let image-m = measure(p.custom-image)
  let y0 = if bottom {y - m.height / 1pt - SYM-GAP} else {y + m.height / 1pt + image-m.height / 1pt + SYM-GAP}
  draw.content((x - image-m.width / 2pt, y0), p.custom-image, anchor: "north-west")
  draw.content(
    (x, y),
    p.display-name,
    anchor: if bottom {"north"} else {"south"}
  )
}

#let render(x-pos, p, y: 0, bottom: false) = {
  let m = measure(box(p.display-name))
  let func = (
    participant: _render-participant,
    actor: _render-actor,
    boundary: _render-boundary,
    control: _render-control,
    entity: _render-entity,
    database: _render-database,
    collections: _render-collections,
    queue: _render-queue,
    custom: _render-custom,
  ).at(p.shape)
  func(x-pos.at(p.i), y, p, m, bottom)
}