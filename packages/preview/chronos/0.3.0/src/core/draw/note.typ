#import "/src/cetz.typ": draw

#import "/src/consts.typ": *
#import "/src/core/utils.typ": get-ctx, set-ctx, expand-parent-group

#let get-size(note) = {
  let PAD = if note.shape == "hex" {NOTE-HEX-PAD} else {NOTE-PAD}
  let m = measure(box(note.content))
  let w = m.width / 1pt + PAD.last() * 2
  let h = m.height / 1pt + PAD.first() * 2
  if note.shape == "default" {
    w += NOTE-CORNER-SIZE
  }
  return (
    width: w,
    height: h
  )
}

#let get-base-x(pars-i, x-pos, note) = {
  if note.side == "across" {
    return (x-pos.first() + x-pos.last()) / 2
  }
  if note.side == "over" {
    if type(note.pos) == array {
      let xs = note.pos.map(par => x-pos.at(pars-i.at(par)))
      return (calc.min(..xs) + calc.max(..xs)) / 2
    }
  }
  return x-pos.at(pars-i.at(note.pos))
}

#let get-box(note) = {
  let PAD = if note.shape == "hex" {NOTE-HEX-PAD} else {NOTE-PAD}
  let inset = (
    left: PAD.last() * 1pt,
    right: PAD.last() * 1pt,
    top: PAD.first() * 1pt,
    bottom: PAD.first() * 1pt,
  )
  if note.shape == "default" {
    inset.right += NOTE-CORNER-SIZE * 1pt
  }
  if note.side == "left" {
    inset.right += NOTE-GAP * 1pt
  } else if note.side == "right" {
    inset.left += NOTE-GAP * 1pt
  }
  return box(note.content, inset: inset)
}

#let render(note, y: auto, forced: false) = {
  if not note.linked {
    if not note.aligned {
      set-ctx(c => {
        c.y -= Y-SPACE
        return c
      })
    }
  } else if not forced {
    return ()
  }

  get-ctx(ctx => {
    let y = y
    if y == auto {
      y = ctx.y
    }
    

    let PAD = if note.shape == "hex" {NOTE-HEX-PAD} else {NOTE-PAD}
    let m = measure(box(note.content))
    let w = m.width / 1pt + PAD.last() * 2
    let h = m.height / 1pt + PAD.first() * 2
    let total-w = w
    if note.shape == "default" {
      total-w += NOTE-CORNER-SIZE
    }

    let base-x = get-base-x(ctx.pars-i, ctx.x-pos, note)

    let i = none
    if note.pos != none and type(note.pos) == str {
      i = ctx.pars-i.at(note.pos)
    }
    let x0 = base-x
    if note.side == "left" {
      x0 -= NOTE-GAP
      x0 -= total-w
      if ctx.lifelines.at(i).level != 0 {
        x0 -= LIFELINE-W / 2
      }
    } else if note.side == "right" {
      x0 += NOTE-GAP
      x0 += ctx.lifelines.at(i).level * LIFELINE-W / 2
    } else if note.side == "over" or note.side == "across" {
      x0 -= total-w / 2
    }

    let x1 = x0 + w
    let x2 = x0 + total-w
    let y0 = y

    if note.linked {
      y0 += h / 2
    }
    let y1 = y0 - h

    if note.shape == "default" {
      draw.line(
        (x0, y0),
        (x1, y0),
        (x2, y0 - NOTE-CORNER-SIZE),
        (x2, y1),
        (x0, y1),
        stroke: black + .5pt,
        fill: note.color,
        close: true
      )
      draw.line(
        (x1, y0),
        (x1, y0 - NOTE-CORNER-SIZE),
        (x2, y0 - NOTE-CORNER-SIZE),
        stroke: black + .5pt
      )
    } else if note.shape == "rect" {
      draw.rect(
        (x0, y0),
        (x2, y1),
        stroke: black + .5pt,
        fill: note.color
      )
    } else if note.shape == "hex" {
      let lx = x0 + PAD.last()
      let rx = x2 - PAD.last()
      let my = (y0 + y1) / 2
      draw.line(
        (lx, y0),
        (rx, y0),
        (x2, my),
        (rx, y1),
        (lx, y1),
        (x0, my),
        stroke: black + .5pt,
        fill: note.color,
        close: true
      )
    }

    draw.content(
      ((x0 + x1)/2, (y0 + y1)/2),
      note.content,
      anchor: "center"
    )

    if note.aligned-with == none and (note.pos != none or note.side == "across") {
      set-ctx(c => {
        c.y -= h
        return c
      })
    }

    expand-parent-group(x0, x2)
  })
}