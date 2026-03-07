#import "/src/cetz.typ": canvas, draw

#import "draw/note.typ": get-box as get-note-box, get-size as get-note-size
#import "draw/participant.typ"
#import "draw/sync.typ": in-sync-render
#import "utils.typ": *
#import "/src/consts.typ": *

#let DEBUG-INVISIBLE = false

#let init-lifelines(participants) = {
  return participants.map(p => {
    p.insert("lifeline-lvl", 0)
    p.insert("max-lifelines", 0)
    p
  })
}

#let seq-update-lifelines(participants, pars-i, seq) = {
  let participants = participants
  let com = if seq.comment == none {""} else {seq.comment}
  let i1 = pars-i.at(seq.p1)
  let i2 = pars-i.at(seq.p2)
  let cell = (
    elmt: seq,
    i1: calc.min(i1, i2),
    i2: calc.max(i1, i2),
    cell: box(com, inset: 3pt)
  )

  if seq.disable-src or seq.destroy-src {
    let p = participants.at(i1)
    p.lifeline-lvl -= 1
    participants.at(i1) = p
  }
  if seq.disable-dst {
    let p = participants.at(i2)
    p.lifeline-lvl -= 1
    participants.at(i2) = p
  }
  if seq.enable-dst {
    let p = participants.at(i2)
    p.lifeline-lvl += 1
    p.max-lifelines = calc.max(p.max-lifelines, p.lifeline-lvl)
    participants.at(i2) = p
  }

  return (participants, cell)
}

#let evt-update-lifelines(participants, pars-i, evt) = {
  let par-name = evt.participant
  let i = pars-i.at(par-name)
  let par = participants.at(i)
  if evt.event == "disable" or evt.event == "destroy" {
    par.lifeline-lvl -= 1
  
  } else if evt.event == "enable" {
    par.lifeline-lvl += 1
    par.max-lifelines = calc.max(par.max-lifelines, par.lifeline-lvl)
  }
  participants.at(i) = par
  return participants
}

#let note-get-cell(pars-i, note) = {
  let (p1, p2) = (none, none)
  let cell = none
  if note.side == "left" {
    p1 = note.pos2
    p2 = note.pos
    cell = get-note-box(note)
  } else if note.side == "right" {
    p1 = note.pos
    p2 = note.pos2
    cell = get-note-box(note)
  } else if note.side == "over" and note.aligned-with != none {
    let box1 = get-note-box(note)
    let box2 = get-note-box(note.aligned-with)
    let m1 = measure(box1)
    let m2 = measure(box2)
    cell = box(
      width: (m1.width + m2.width) / 2,
      height: calc.max(m1.height, m2.height)
    )
    p1 = note.pos
    p2 = note.aligned-with.pos
  } else {
    return none
  }

  let i1 = pars-i.at(p1)
  let i2 = pars-i.at(p2)
  cell = (
    elmt: note,
    i1: calc.min(i1, i2),
    i2: calc.max(i1, i2),
    cell: cell
  )

  return cell
}

#let compute-max-lifeline-levels(participants, elements, pars-i) = {
  let cells = ()
  for elmt in elements {
    if elmt.type == "seq" {
      let cell
      (participants, cell) = seq-update-lifelines(
        participants,
        pars-i,
        elmt
      )
      cells.push(cell)
    } else if elmt.type == "evt" {
      participants = evt-update-lifelines(
        participants,
        pars-i,
        elmt
      )
    
    } else if elmt.type == "note" {
      let cell = note-get-cell(pars-i, elmt)
      if cell != none {
        cells.push(cell)
      }
    }
  }

  return (participants, elements, cells)
}

/// Compute minimum widths for participant names and shapes
#let participants-min-col-widths(participants) = {
  let widths = ()
  for i in range(participants.len() - 1) {
    let p1 = participants.at(i)
    let p2 = participants.at(i + 1)
    let m1 = participant.get-size(p1)
    let m2 = participant.get-size(p2)
    let w1 = m1.width
    let w2 = m2.width
    widths.push(w1 / 2pt + w2 / 2pt + PAR-SPACE)
  }
  return widths
}

/// Compute minimum width for over notes
#let notes-min-col-widths(elements, widths, pars-i) = {
  let widths = widths
  let notes = elements.filter(e => e.type == "note")
  for n in notes.filter(e => (e.side == "over" and 
                              type(e.pos) == str)) {
    
    let m = get-note-size(n)
    let i = pars-i.at(n.pos)

    if i < widths.len() {
      widths.at(i) = calc.max(
        widths.at(i),
        m.width / 2 + NOTE-GAP
      )
    }
    if i > 0 {
      widths.at(i - 1) = calc.max(
        widths.at(i - 1),
        m.width / 2 + NOTE-GAP
      )
    }
  }
  return widths
}

/// Compute minimum width for simple sequences (spanning 1 column)
#let simple-seq-min-col-widths(cells, widths) = {
  let widths = widths
  for cell in cells.filter(c => c.i2 - c.i1 == 1) {
    let m = measure(cell.cell)
    widths.at(cell.i1) = calc.max(
      widths.at(cell.i1),
      m.width / 1pt + COMMENT-PAD
    )
  }
  return widths
}

/// Compute minimum width for self sequences
#let self-seq-min-col-widths(cells, widths) = {
  let widths = widths
  for cell in cells.filter(c => (c.elmt.type == "seq" and
                                 c.i1 == c.i2)) {
    let m = measure(cell.cell)
    let i = cell.i1
    if cell.elmt.flip {
      i -= 1
    }
    if 0 <= i and i < widths.len() {
      widths.at(i) = calc.max(
        widths.at(i),
        m.width / 1pt + COMMENT-PAD
      )
    }
  }
  return widths
}

/// Compute remaining widths for longer sequences (spanning multiple columns)
#let long-seq-min-col-widths(participants, cells, widths) = {
  let widths = widths
  let multicol-cells = cells.filter(c => c.i2 - c.i1 > 1)
  multicol-cells = multicol-cells.sorted(key: c => {
    c.i1 * 1000 + c.i2
  })
  for cell in multicol-cells {
    let m = measure(cell.cell)

    let i1 = cell.i1
    let i2 = cell.i2 - 1
    let i = i2
    if cell.i1 == 0 and participants.at(0).name == "[" {
      i = 0
      i1 += 1
      i2 += 1
    }
    let width = (
      m.width / 1pt +
      COMMENT-PAD -
      widths.slice(i1, i2).sum()
    )
    
    widths.at(i) = calc.max(
      widths.at(i), width
    )
  }
  return widths
}

/// Add lifeline widths
#let col-widths-add-lifelines(participants, widths) = {
  return widths.enumerate().map(((i, w)) => {
    let p1 = participants.at(i)
    let p2 = participants.at(i + 1)
    w += p1.max-lifelines * LIFELINE-W / 2
    if p2.max-lifelines != 0 {
      w += LIFELINE-W / 2
    }
    return w
  })
}

#let process-col-elements(elements, widths, pars-i) = {
  let widths = widths
  let cols = elements.filter(e => e.type == "col")
  for col in cols {
    let i1 = pars-i.at(col.p1)
    let i2 = pars-i.at(col.p2)
    if calc.abs(i1 - i2) != 1 {
      let i-min = calc.min(i1, i2)
      let i-max = calc.max(i1, i2)
      let others = pars-i.pairs()
                         .sorted(key: p => p.last())
                         .slice(i-min + 1, i-max)
                         .map(p => "'" + p.first() + "'")
                         .join(", ")
      panic(
        "Column participants must be consecutive (participants (" +
        others +
        ") are in between)"
      )
    }
    let i = calc.min(i1, i2)

    let width = widths.at(i)

    if col.width != auto {
      width = normalize-units(col.width)
    }

    width = calc.max(
      width,
      normalize-units(col.min-width)
    )
    if col.max-width != none {
      width = calc.min(
        width,
        normalize-units(col.max-width)
      )
    }
    widths.at(i) = width + normalize-units(col.margin)
  }
  return widths
}

#let compute-columns-width(participants, elements, pars-i) = {
  elements = elements.filter(is-elmt)

  let cells
  (participants, elements, cells) = compute-max-lifeline-levels(participants, elements, pars-i)

  let widths = participants-min-col-widths(participants)
  widths = notes-min-col-widths(elements, widths, pars-i)
  widths = simple-seq-min-col-widths(cells, widths)
  widths = self-seq-min-col-widths(cells, widths)
  widths = long-seq-min-col-widths(participants, cells, widths)
  widths = col-widths-add-lifelines(participants, widths)
  widths = process-col-elements(elements, widths, pars-i)
  return widths
}

#let setup-ctx(participants, elements) = (ctx => {
  let state = ctx.at("shared-state", default: (:))

  let chronos-ctx = (
    participants: init-lifelines(participants),
    pars-i: get-participants-i(participants),
    y: 0,
    groups: (),
    lifelines: participants.map(_ => (
      level: 0,
      lines: ()
    )),
    in-sync: false
  )
  chronos-ctx.insert(
    "widths",
    compute-columns-width(
      chronos-ctx.participants,
      elements,
      chronos-ctx.pars-i
    )
  )

  // Compute each column's X position
  let x-pos = (0,)
  for width in chronos-ctx.widths {
    x-pos.push(x-pos.last() + width)
  }
  chronos-ctx.insert("x-pos", x-pos)
  state.insert("chronos", chronos-ctx)
  ctx.shared-state = state
  return (
    ctx: ctx
  )
},)

#let render-debug() = get-ctx(ctx => {
  for p in ctx.participants.filter(p => p.invisible) {
    let color = if p.name.starts-with("?") {green} else if p.name.ends-with("?") {red} else {blue}
    let x = ctx.x-pos.at(p.i)
    draw.line(
      (x, 0),
      (x, ctx.y),
      stroke: (paint: color, dash: "dotted")
    )
    draw.content(
      (x, 0),
      p.display-name,
      anchor: "west",
      angle: 90deg
    )
  }
})

#let render(participants, elements) = context canvas(length: 1pt, {
  setup-ctx(participants, elements)
  
  // Draw participants (start)
  get-ctx(ctx => {
    for p in ctx.participants {
      if p.from-start and not p.invisible and p.show-top {
        (p.draw)(p)
      }
    }
  })

  // Draw elements
  for elmt in elements {
    if not is-elmt(elmt) {
      (elmt,)
    } else if "draw" in elmt and elmt.type != "par" {
      get-ctx(ctx => {
        if ctx.in-sync and elmt.type != "sync-end" {
          in-sync-render(elmt)
        } else {
          (elmt.draw)(elmt)
        }
      })
    }
  }

  set-ctx(ctx => {
    ctx.y -= Y-SPACE
    return ctx
  })

  draw.on-layer(-1, {
    if DEBUG-INVISIBLE {
      render-debug()
    }
    
    participant.render-lifelines()
  })
})