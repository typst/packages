#import "/src/cetz.typ": draw
#import "consts.typ": *

#let SIDES = (
  "left",
  "right",
  "over",
  "across"
)

#let SHAPES = (
  "default",
  "rect",
  "hex"
)

#let _note(side, content, pos: none, color: COL-NOTE, shape: "default", aligned: false) = {
  if side == "over" {
    if pos == none {
      panic("Pos cannot be none with side 'over'")
    }
  }
  if aligned {
    if side != "over" {
      panic("Aligned notes can only be over a participant (got side '" + side + "')")
    }
  }
  if color == auto {
    color = COL-NOTE
  }
  return ((
    type: "note",
    side: side,
    content: content,
    pos: pos,
    color: color,
    shape: shape,
    aligned: aligned,
    aligned-with: none
  ),)
}

#let get-note-box(note) = {
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

#let _get-base-x(pars-i, x-pos, note) = {
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

#let render(pars-i, x-pos, note, y, lifelines) = {
  let shapes = ()
  let PAD = if note.shape == "hex" {NOTE-HEX-PAD} else {NOTE-PAD}
  let m = measure(box(note.content))
  let w = m.width / 1pt + PAD.last() * 2
  let h = m.height / 1pt + PAD.first() * 2
  let total-w = w
  if note.shape == "default" {
    total-w += NOTE-CORNER-SIZE
  }

  let base-x = _get-base-x(pars-i, x-pos, note)

  let i = none
  if note.pos != none and type(note.pos) == str {
    i = pars-i.at(note.pos)
  }
  let x0 = base-x
  if note.side == "left" {
    x0 -= NOTE-GAP
    x0 -= total-w
    if lifelines.at(i).level != 0 {
      x0 -= LIFELINE-W / 2
    }
  } else if note.side == "right" {
    x0 += NOTE-GAP
    x0 += lifelines.at(i).level * LIFELINE-W / 2
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
    shapes += draw.merge-path(
      stroke: black + .5pt,
      fill: note.color,
      close: true,
      {
        draw.line(
          (x0, y0),
          (x1, y0),
          (x2, y0 - NOTE-CORNER-SIZE),
          (x2, y1),
          (x0, y1)
        )
      }
    )
    shapes += draw.line((x1, y0), (x1, y0 - NOTE-CORNER-SIZE), (x2, y0 - NOTE-CORNER-SIZE), stroke: black + .5pt)
  } else if note.shape == "rect" {
    shapes += draw.rect(
      (x0, y0),
      (x2, y1),
      stroke: black + .5pt,
      fill: note.color
    )
  } else if note.shape == "hex" {
    let lx = x0 + PAD.last()
    let rx = x2 - PAD.last()
    let my = (y0 + y1) / 2
    shapes += draw.merge-path(
      stroke: black + .5pt,
      fill: note.color,
      close: true,
      {
        draw.line(
          (lx, y0),
          (rx, y0),
          (x2, my),
          (rx, y1),
          (lx, y1),
          (x0, my),
        )
      }
    )
  }

  shapes += draw.content(
    ((x0 + x1)/2, (y0 + y1)/2),
    note.content,
    anchor: "center"
  )

  if note.aligned-with == none and (note.pos != none or note.side == "across") {
    y -= h
  }

  let r = (y, shapes)
  return r
}