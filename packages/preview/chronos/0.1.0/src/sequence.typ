#import "@preview/cetz:0.2.2": draw, vector
#import "consts.typ": *
#import "participant.typ"
#import "note.typ"

#let get-arrow-marks(sym, color) = {
  if type(sym) == array {
    return sym.map(s => get-arrow-marks(s, color))
  }
  (
    "": none,
    ">": (symbol: ">", fill: color),
    ">>": (symbol: "straight"),
    "\\": (symbol: ">", fill: color, harpoon: true, flip: true),
    "\\\\": (symbol: "straight", harpoon: true, flip: true),
    "/": (symbol: ">", fill: color, harpoon: true),
    "//": (symbol: "straight", harpoon: true),
    "x": none,
    "o": none,
  ).at(sym)
}

#let reverse-arrow-mark(mark) = {
  if type(mark) == array {
    return mark.map(m => reverse-arrow-mark(m))
  }
  let mark2 = mark
  if type(mark) == dictionary and mark.at("harpoon", default: false) {
    let flipped = mark.at("flip", default: false)
    mark2.insert("flip", not flipped)
  }
  return mark2
}

#let is-tip-of-type(type_, tip) = {
  if type(tip) == str and tip == type_ {
    return true
  }
  if type(tip) == array and tip.contains(type_) {
    return true
  }
  return false
}
#let is-circle-tip = is-tip-of-type.with("o")
#let is-cross-tip = is-tip-of-type.with("x")

#let _seq(
  p1,
  p2,
  comment: none,
  comment-align: "left",
  dashed: false,
  start-tip: "",
  end-tip: ">",
  color: black,
  flip: false,
  enable-dst: false,
  create-dst: false,
  disable-dst: false,
  destroy-dst: false,
  disable-src: false,
  destroy-src: false,
  lifeline-style: auto,
  slant: none
) = {
  return ((
    type: "seq",
    p1: p1,
    p2: p2,
    comment: comment,
    comment-align: comment-align,
    dashed: dashed,
    start-tip: start-tip,
    end-tip: end-tip,
    color: color,
    flip: flip,
    enable-dst: enable-dst,
    create-dst: create-dst,
    disable-dst: disable-dst,
    destroy-dst: destroy-dst,
    disable-src: disable-src,
    destroy-src: destroy-src,
    lifeline-style: lifeline-style,
    slant: slant
  ),)
}

#let render(pars-i, x-pos, participants, elmt, y, lifelines) = {
  let shapes = ()

  y -= Y-SPACE

  let h = 0
  // Reserve space for comment
  if elmt.comment != none {
    h = calc.max(h, measure(box(elmt.comment)).height / 1pt + 6)
  }
  if "linked-note" in elmt {
    h = calc.max(h, note.get-size(elmt.linked-note).height / 2)
  }
  y -= h

  let i1 = pars-i.at(elmt.p1)
  let i2 = pars-i.at(elmt.p2)

  let start-info = (
    i: i1,
    x: x-pos.at(i1),
    y: y,
    ll-lvl: lifelines.at(i1).level * LIFELINE-W / 2
  )
  let end-info = (
    i: i2,
    x: x-pos.at(i2),
    y: y,
    ll-lvl: lifelines.at(i2).level * LIFELINE-W / 2
  )
  let slant = if elmt.slant == auto {
    DEFAULT-SLANT
  } else if elmt.slant != none {
    elmt.slant
  } else {
    0
  }
  end-info.y -= slant
  if elmt.p1 == elmt.p2 {
    end-info.y -= 10
  }

  if elmt.disable-src {
    let src-line = lifelines.at(i1)
    src-line.level -= 1
    src-line.lines.push(("disable", start-info.y))
    lifelines.at(i1) = src-line
  }
  if elmt.destroy-src {
    let src-line = lifelines.at(i1)
    src-line.lines.push(("destroy", start-info.y))
    lifelines.at(i1) = src-line
  }
  if elmt.disable-dst {
    let dst-line = lifelines.at(i2)
    dst-line.level -= 1
    dst-line.lines.push(("disable", end-info.y))
    lifelines.at(i2) = dst-line
  }
  if elmt.destroy-dst {
    let dst-line = lifelines.at(i2)
    dst-line.lines.push(("destroy", end-info.y))
    lifelines.at(i2) = dst-line
  }
  if elmt.enable-dst {
    let dst-line = lifelines.at(i2)
    dst-line.level += 1
    lifelines.at(i2) = dst-line
  }
  if elmt.create-dst {
    let par = participants.at(i2)
    let m = measure(box(par.display-name))
    let f = if i1 > i2 {-1} else {1}
    end-info.x -= (m.width + PAR-PAD.last() * 2) / 2pt * f
    shapes += participant.render(x-pos, par, y: end-info.y - CREATE-OFFSET)
  }

  end-info.ll-lvl = lifelines.at(i2).level * LIFELINE-W / 2

  // Compute left/right position at start/end
  start-info.insert("lx", start-info.x)
  if start-info.ll-lvl != 0 { start-info.lx -= LIFELINE-W / 2 }
  end-info.insert("lx", end-info.x)
  if end-info.ll-lvl != 0 { end-info.lx -= LIFELINE-W / 2 }

  start-info.insert("rx", start-info.x + start-info.ll-lvl)
  end-info.insert("rx", end-info.x + end-info.ll-lvl)

  // Choose correct points to link
  let x1 = start-info.rx
  let x2 = end-info.lx

  if (start-info.i > end-info.i) {
    x1 = start-info.lx
    x2 = end-info.rx
  }

  let style = (
    mark: (
      start: get-arrow-marks(elmt.start-tip, elmt.color),
      end: get-arrow-marks(elmt.end-tip, elmt.color),
      scale: 1.2
    ),
    stroke: (
      dash: if elmt.dashed {(2pt,2pt)} else {"solid"},
      paint: elmt.color,
      thickness: .5pt
    )
  )

  let y0 = start-info.y
  if "linked-note" in elmt {
    let shps = note.render(pars-i, x-pos, elmt.linked-note, start-info.y, lifelines).last()
    shapes += shps
  }

  let flip-mark = end-info.i <= start-info.i
  if elmt.flip {
    flip-mark = not flip-mark
  }
  if flip-mark {
    style.mark.end = reverse-arrow-mark(style.mark.end)
  }

  let pts
  let comment-pt
  let comment-anchor
  let comment-angle = 0deg

  if elmt.p1 == elmt.p2 {
    if elmt.flip {
      x1 = start-info.lx
    } else {
      x2 = end-info.rx
    }

    let x-mid = if elmt.flip {
      calc.min(x1, x2) - 20
    } else {
      calc.max(x1, x2) + 20
    }

    pts = (
      (x1, start-info.y),
      (x-mid, start-info.y),
      (x-mid, end-info.y),
      (x2, end-info.y)
    )

    if elmt.comment != none {
      comment-anchor = (
        start: if x-mid < x1 {"south-east"} else {"south-west"},
        end: if x-mid < x1 {"south-west"} else {"south-east"},
        left: "south-west",
        right: "south-east",
        center: "south",
      ).at(elmt.comment-align)

      comment-pt = (
        start: pts.first(),
        end: pts.at(1),
        left: if x-mid < x1 {pts.at(1)} else {pts.first()},
        right: if x-mid < x1 {pts.first()} else {pts.at(1)},
        center: (pts.first(), 50%, pts.at(1))
      ).at(elmt.comment-align)
    }

  } else {
    pts = (
      (x1, start-info.y),
      (x2, end-info.y)
    )

    if elmt.comment != none {
      let start-pt = pts.first()
      let end-pt = pts.last()
      if elmt.start-tip != "" {
        start-pt = (pts.first(), COMMENT-PAD, pts.last())
      }
      if elmt.end-tip != "" {
        end-pt = (pts.last(), COMMENT-PAD, pts.first())
      }

      comment-pt = (
        start: start-pt,
        end: end-pt,
        left: if x2 < x1 {end-pt} else {start-pt},
        right: if x2 < x1 {start-pt} else {end-pt},
        center: (start-pt, 50%, end-pt)
      ).at(elmt.comment-align)

      comment-anchor = (
        start: if x2 < x1 {"south-east"} else {"south-west"},
        end: if x2 < x1 {"south-west"} else {"south-east"},
        left: "south-west",
        right: "south-east",
        center: "south",
      ).at(elmt.comment-align)
    }

    let (p1, p2) = pts
    if x2 < x1 {
      (p1, p2) = (p2, p1)
    }
    comment-angle = vector.angle2(p1, p2)
  }

  // Start circle tip
  if is-circle-tip(elmt.start-tip) {
    shapes += draw.circle(pts.first(), radius: CIRCLE-TIP-RADIUS, stroke: elmt.color, fill: none, name: "_circle-start-tip")
    pts.at(0) = "_circle-start-tip"
  
  // Start cross tip
  } else if is-cross-tip(elmt.start-tip) {
    let size = CROSS-TIP-SIZE
    let cross-pt = (pts.first(), size * 2, pts.at(1))
    shapes += draw.line(
      (rel: (-size, -size), to: cross-pt),
      (rel: (size, size), to: cross-pt),
      stroke: elmt.color + 1.5pt
    )
    shapes += draw.line(
      (rel: (-size, size), to: cross-pt),
      (rel: (size, -size), to: cross-pt),
      stroke: elmt.color + 1.5pt
    )
    pts.at(0) = cross-pt
  }

  // End circle tip
  if is-circle-tip(elmt.end-tip) {
    shapes += draw.circle(pts.last(), radius: 3, stroke: elmt.color, fill: none, name: "_circle-end-tip")
    pts.at(pts.len() - 1) = "_circle-end-tip"
  
  // End cross tip
  } else if is-cross-tip(elmt.end-tip) {
    let size = CROSS-TIP-SIZE
    let cross-pt = (pts.last(), size * 2, pts.at(pts.len() - 2))
    shapes += draw.line(
      (rel: (-size, -size), to: cross-pt),
      (rel: (size, size), to: cross-pt),
      stroke: elmt.color + 1.5pt
    )
    shapes += draw.line(
      (rel: (-size, size), to: cross-pt),
      (rel: (size, -size), to: cross-pt),
      stroke: elmt.color + 1.5pt
    )
    pts.at(pts.len() - 1) = cross-pt
  }

  shapes += draw.line(..pts, ..style)

  if elmt.comment != none {
    shapes += draw.content(
      comment-pt,
      elmt.comment,
      anchor: comment-anchor,
      angle: comment-angle,
      padding: 3pt
    )
  }

  if elmt.enable-dst {
    let dst-line = lifelines.at(i2)
    dst-line.lines.push(("enable", end-info.y, elmt.lifeline-style))
    lifelines.at(i2) = dst-line
  }
  if elmt.create-dst {
    end-info.y -= CREATE-OFFSET
    let dst-line = lifelines.at(i2)
    dst-line.lines.push(("create", end-info.y))
    lifelines.at(i2) = dst-line
  }

  if "linked-note" in elmt {
    let m = note.get-size(elmt.linked-note)
    end-info.y = calc.min(end-info.y, y0 - m.height / 2)
  }

  let r = (end-info.y, lifelines, shapes)
  return r
}