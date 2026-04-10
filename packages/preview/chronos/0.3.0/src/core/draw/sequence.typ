#import "/src/cetz.typ": draw, vector, coordinate

#import "note.typ"
#import "/src/consts.typ": *
#import "/src/core/utils.typ": get-ctx, set-ctx, expand-parent-group

#let get-arrow-marks(sym, color) = {
  if sym == none {
    return none
  }
  if type(sym) == array {
    return sym.map(s => get-arrow-marks(s, color))
  }
  (
    "": none,
    ">": (symbol: ">", fill: color),
    ">>": (symbol: "straight"),
    "\\": (symbol: ">", fill: color, harpoon: true),
    "\\\\": (symbol: "straight", harpoon: true),
    "/": (symbol: ">", fill: color, harpoon: true, flip: true),
    "//": (symbol: "straight", harpoon: true, flip: true),
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

#let render(seq) = get-ctx(ctx => {
  ctx.y -= Y-SPACE

  let i1 = ctx.pars-i.at(seq.p1)
  let i2 = ctx.pars-i.at(seq.p2)
  let width = calc.abs(ctx.x-pos.at(i1) - ctx.x-pos.at(i2))

  let h = 0
  let comment = if seq.comment == none {none} else {
    let w = calc.min(width * 1pt, measure(seq.comment).width)
    box(
      width: if i1 == i2 {auto} else {w},
      seq.comment
    )
  }
  // Reserve space for comment
  if comment != none {
    h = calc.max(h, measure(comment).height / 1pt + 6)
  }
  h = calc.max(
    h,
    ..seq.linked-notes.map(n => {
      note.get-size(n).height / 2
    })
  )
  ctx.y -= h

  let start-info = (
    i: i1,
    x: ctx.x-pos.at(i1),
    y: ctx.y,
    ll-lvl: ctx.lifelines.at(i1).level * LIFELINE-W / 2
  )
  let end-info = (
    i: i2,
    x: ctx.x-pos.at(i2),
    y: ctx.y,
    ll-lvl: ctx.lifelines.at(i2).level * LIFELINE-W / 2
  )
  let slant = if seq.slant == auto {
    DEFAULT-SLANT
  } else if seq.slant != none {
    seq.slant
  } else {
    0
  }
  end-info.y -= slant
  if seq.p1 == seq.p2 {
    end-info.y -= 10
  }

  if seq.disable-src {
    let src-line = ctx.lifelines.at(i1)
    src-line.level -= 1
    src-line.lines.push(("disable", start-info.y))
    ctx.lifelines.at(i1) = src-line
  }
  if seq.destroy-src {
    let src-line = ctx.lifelines.at(i1)
    src-line.lines.push(("destroy", start-info.y))
    ctx.lifelines.at(i1) = src-line
  }
  if seq.disable-dst {
    let dst-line = ctx.lifelines.at(i2)
    dst-line.level -= 1
    dst-line.lines.push(("disable", end-info.y))
    ctx.lifelines.at(i2) = dst-line
  }
  if seq.destroy-dst {
    let dst-line = ctx.lifelines.at(i2)
    dst-line.lines.push(("destroy", end-info.y))
    ctx.lifelines.at(i2) = dst-line
  }
  if seq.enable-dst {
    let dst-line = ctx.lifelines.at(i2)
    dst-line.level += 1
    ctx.lifelines.at(i2) = dst-line
  }
  if seq.create-dst {
    let par = ctx.participants.at(i2)
    let m = measure(box(par.display-name))
    let f = if i1 > i2 {-1} else {1}
    end-info.x -= (m.width + PAR-PAD.last() * 2) / 2pt * f
    (par.draw)(par, y: end-info.y)
  }

  end-info.ll-lvl = ctx.lifelines.at(i2).level * LIFELINE-W / 2

  // Compute left/right position at start/end
  start-info.insert("rx", start-info.x + start-info.ll-lvl)
  end-info.insert("rx", end-info.x + end-info.ll-lvl)
  let start-lx = start-info.x
  let end-lx = end-info.x
  if seq.outer-lifeline-connect {
    if start-info.ll-lvl != 0 {start-lx -= LIFELINE-W / 2}
    if end-info.ll-lvl != 0 {end-lx -= LIFELINE-W / 2}
  } else {
    if start-info.ll-lvl != 0 {start-lx = start-info.rx - LIFELINE-W}
    if end-info.ll-lvl != 0 {end-lx = end-info.rx - LIFELINE-W}
  }
  start-info.insert("lx", start-lx)
  end-info.insert("lx", end-lx)

  // Choose correct points to link
  let x1 = start-info.rx
  let x2 = end-info.lx

  if (start-info.i > end-info.i) {
    x1 = start-info.lx
    x2 = end-info.rx
  }

  let style = (
    mark: (
      start: get-arrow-marks(seq.start-tip, seq.color),
      end: get-arrow-marks(seq.end-tip, seq.color),
      scale: 1.2
    ),
    stroke: (
      dash: if seq.dashed {(2pt,2pt)} else {"solid"},
      paint: seq.color,
      thickness: .5pt
    )
  )

  let y0 = start-info.y
  for n in seq.linked-notes {
    (n.draw)(n, y: start-info.y, forced: true)
  }

  let flip-mark = end-info.i <= start-info.i
  if seq.flip {
    flip-mark = not flip-mark
  }
  if flip-mark {
    style.mark.end = reverse-arrow-mark(style.mark.end)
  }

  let pts
  let comment-pt
  let comment-anchor
  let comment-angle = 0deg

  if seq.p1 == seq.p2 {
    if seq.flip {
      x1 = start-info.lx
    } else {
      x2 = end-info.rx
    }

    let x-mid = if seq.flip {
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

    if comment != none {
      comment-anchor = (
        start: if x-mid < x1 {"south-east"} else {"south-west"},
        end: if x-mid < x1 {"south-west"} else {"south-east"},
        left: "south-west",
        right: "south-east",
        center: "south",
      ).at(seq.comment-align)

      comment-pt = (
        start: pts.first(),
        end: pts.at(1),
        left: if x-mid < x1 {pts.at(1)} else {pts.first()},
        right: if x-mid < x1 {pts.first()} else {pts.at(1)},
        center: (pts.first(), 50%, pts.at(1))
      ).at(seq.comment-align)
    }

    expand-parent-group(
      calc.min(x1, x2, x-mid),
      calc.max(x1, x2, x-mid)
    )

  } else {
    pts = (
      (x1, start-info.y),
      (x2, end-info.y)
    )

    if comment != none {
      let start-pt = pts.first()
      let end-pt = pts.last()
      if seq.start-tip != "" {
        start-pt = (pts.first(), COMMENT-PAD, pts.last())
      }
      if seq.end-tip != "" {
        end-pt = (pts.last(), COMMENT-PAD, pts.first())
      }

      comment-pt = (
        start: start-pt,
        end: end-pt,
        left: if x2 < x1 {end-pt} else {start-pt},
        right: if x2 < x1 {start-pt} else {end-pt},
        center: (start-pt, 50%, end-pt)
      ).at(seq.comment-align)

      comment-anchor = (
        start: if x2 < x1 {"south-east"} else {"south-west"},
        end: if x2 < x1 {"south-west"} else {"south-east"},
        left: "south-west",
        right: "south-east",
        center: "south",
      ).at(seq.comment-align)
    }

    let (p1, p2) = pts
    if x2 < x1 {
      (p1, p2) = (p2, p1)
    }
    comment-angle = vector.angle2(p1, p2)

    expand-parent-group(
      calc.min(x1, x2),
      calc.max(x1, x2)
    )
  }

  // Start circle tip
  if is-circle-tip(seq.start-tip) {
    draw.circle(
      pts.first(),
      radius: CIRCLE-TIP-RADIUS,
      stroke: none,
      fill: seq.color,
      name: "_circle-start-tip"
    )
    pts.at(0) = "_circle-start-tip"
  
  // Start cross tip
  } else if is-cross-tip(seq.start-tip) {
    let size = CROSS-TIP-SIZE
    let cross-pt = (
      pts.first(),
      size * 2,
      pts.at(1)
    )
    draw.line(
      (rel: (-size, -size), to: cross-pt),
      (rel: (size, size), to: cross-pt),
      stroke: seq.color + 1.5pt
    )
    draw.line(
      (rel: (-size, size), to: cross-pt),
      (rel: (size, -size), to: cross-pt),
      stroke: seq.color + 1.5pt
    )
    pts.at(0) = cross-pt
  }

  // End circle tip
  if is-circle-tip(seq.end-tip) {
    draw.circle(
      pts.last(),
      radius: 3,
      stroke: none,
      fill: seq.color,
      name: "_circle-end-tip"
    )
    pts.at(pts.len() - 1) = "_circle-end-tip"
  
  // End cross tip
  } else if is-cross-tip(seq.end-tip) {
    let size = CROSS-TIP-SIZE
    let cross-pt = (
      pts.last(),
      size * 2,
      pts.at(pts.len() - 2)
    )
    draw.line(
      (rel: (-size, -size), to: cross-pt),
      (rel: (size, size), to: cross-pt),
      stroke: seq.color + 1.5pt
    )
    draw.line(
      (rel: (-size, size), to: cross-pt),
      (rel: (size, -size), to: cross-pt),
      stroke: seq.color + 1.5pt
    )
    pts.at(pts.len() - 1) = cross-pt
  }

  draw.line(..pts, ..style)

  if comment != none {
    draw.content(
      comment-pt,
      comment,
      anchor: comment-anchor,
      angle: comment-angle,
      padding: 3pt,
      name: "comment"
    )

    // TODO: Improve this
    draw.get-ctx(c => {
      let (_, left, right) = coordinate.resolve(
        c,
        "comment.west",
        "comment.east"
      )
      expand-parent-group(
        left.at(0),
        right.at(0)
      )
    })

  }

  if seq.create-dst {
    let dst-line = ctx.lifelines.at(i2)
    dst-line.lines.push(("create", end-info.y))
    ctx.lifelines.at(i2) = dst-line
  }
  if seq.enable-dst {
    let dst-line = ctx.lifelines.at(i2)
    dst-line.lines.push(("enable", end-info.y, seq.lifeline-style))
    ctx.lifelines.at(i2) = dst-line
  }

  if seq.linked-notes.len() != 0 {
    end-info.y = calc.min(
      end-info.y,
      y0 - calc.max(..seq.linked-notes.map(n => {
        let m = note.get-size(n)
        return m.height / 2
      }))
    )
  }

  set-ctx(c => {
    c.y = end-info.y
    c.lifelines = ctx.lifelines
    c.last-drawn = (
      type: "seq",
      start-info: start-info,
      end-info: end-info
    )
    return c
  })
})
