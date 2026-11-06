#import "/src/cetz.typ": canvas, draw
#import "utils.typ": get-participants-i, get-style, normalize-units
#import "group.typ"
#import "participant.typ"
#import participant: PAR-SPECIALS
#import "sequence.typ"
#import "separator.typ"
#import "sync.typ"
#import "consts.typ": *
#import "note.typ" as note: get-note-box

#let DEBUG-INVISIBLE = false

#let get-columns-width(participants, elements) = {
  participants = participants.map(p => {
    p.insert("lifeline-lvl", 0)
    p.insert("max-lifelines", 0)
    p
  })
  let pars-i = get-participants-i(participants)
  let cells = ()

  // Unwrap syncs
  let i = 0
  while i < elements.len() {
    let elmt = elements.at(i)
    if elmt.type == "sync" {
      elements = elements.slice(0, i + 1) + elmt.elmts + elements.slice(i + 1)
    }
    i += 1
  }

  // Compute max lifeline levels
  for elmt in elements {
    if elmt.type == "seq" {
      let com = if elmt.comment == none {""} else {elmt.comment}
      let i1 = pars-i.at(elmt.p1)
      let i2 = pars-i.at(elmt.p2)
      cells.push(
        (
          elmt: elmt,
          i1: calc.min(i1, i2),
          i2: calc.max(i1, i2),
          cell: box(com, inset: 3pt)
        )
      )

      if elmt.disable-src or elmt.destroy-src {
        let p = participants.at(i1)
        p.lifeline-lvl -= 1
        participants.at(i1) = p
      }
      if elmt.disable-dst {
        let p = participants.at(i2)
        p.lifeline-lvl -= 1
        participants.at(i2) = p
      }
      if elmt.enable-dst {
        let p = participants.at(i2)
        p.lifeline-lvl += 1
        p.max-lifelines = calc.max(p.max-lifelines, p.lifeline-lvl)
        participants.at(i2) = p
      }
    } else if elmt.type == "evt" {
      let par-name = elmt.participant
      let i = pars-i.at(par-name)
      let par = participants.at(i)
      if elmt.event == "disable" or elmt.event == "destroy" {
        par.lifeline-lvl -= 1
      
      } else if elmt.event == "enable" {
        par.lifeline-lvl += 1
        par.max-lifelines = calc.max(par.max-lifelines, par.lifeline-lvl)
      }
      participants.at(i) = par
    
    } else if elmt.type == "note" {
      let (p1, p2) = (none, none)
      let cell = none
      if elmt.side == "left" {
        p1 = "["
        p2 = elmt.pos
        cell = get-note-box(elmt)
      } else if elmt.side == "right" {
        p1 = elmt.pos
        p2 = "]"
        cell = get-note-box(elmt)
      } else if elmt.side == "over" {
        if elmt.aligned-with != none {
          let box1 = get-note-box(elmt)
          let box2 = get-note-box(elmt.aligned-with)
          let m1 = measure(box1)
          let m2 = measure(box2)
          cell = box(width: (m1.width + m2.width) / 2, height: calc.max(m1.height, m2.height))
          p1 = elmt.pos
          p2 = elmt.aligned-with.pos
        }
      }

      if p1 != none and p2 != none and cell != none {
        let i1 = pars-i.at(p1)
        let i2 = pars-i.at(p2)
        cells.push(
          (
            elmt: elmt,
            i1: calc.min(i1, i2),
            i2: calc.max(i1, i2),
            cell: cell
          )
        )
      }
    }
  }

  // Compute column widths
  // Compute minimum widths for participant names and shapes
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

  // Compute minimum width for over notes
  for n in elements.filter(e => (e.type == "note" and
                                 e.side == "over" and 
                                 type(e.pos) == str)) {
    
    let m = note.get-size(n)
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

  // Compute minimum width for simple sequences (spanning 1 column)
  for cell in cells.filter(c => c.i2 - c.i1 == 1) {
    let m = measure(cell.cell)
    widths.at(cell.i1) = calc.max(
      widths.at(cell.i1),
      m.width / 1pt + COMMENT-PAD
    )
  }

  // Compute minimum width for self sequences
  for cell in cells.filter(c => c.elmt.type == "seq" and c.i1 == c.i2) {
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

  // Compute remaining widths for longer sequences (spanning multiple columns)
  let multicol-cells = cells.filter(c => c.i2 - c.i1 > 1)
  multicol-cells = multicol-cells.sorted(key: c => {
    c.i1 * 1000 + c.i2
  })
  for cell in multicol-cells {
    let m = measure(cell.cell)
    widths.at(cell.i2 - 1) = calc.max(
      widths.at(cell.i2 - 1),
      m.width / 1pt + COMMENT-PAD - widths.slice(cell.i1, cell.i2 - 1).sum()
    )
  }

  // Add lifeline widths
  for (i, w) in widths.enumerate() {
    let p1 = participants.at(i)
    let p2 = participants.at(i + 1)
    let w = w + p1.max-lifelines * LIFELINE-W / 2
    if p2.max-lifelines != 0 {
      w += LIFELINE-W / 2
    }
    widths.at(i) = w
  }

  for elmt in elements {
    if elmt.type == "col" {
      let i1 = pars-i.at(elmt.p1)
      let i2 = pars-i.at(elmt.p2)
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

      if elmt.width != auto {
        widths.at(i) = normalize-units(elmt.width)
      }

      let width = widths.at(i)
      width = calc.max(width, normalize-units(elmt.min-width))
      if elmt.max-width != none {
        width = calc.min(width, normalize-units(elmt.max-width))
      }
      widths.at(i) = width + normalize-units(elmt.margin)
    }
  }

  return widths
}

#let render(participants, elements) = context canvas(length: 1pt, {
  let shapes = ()
  let pars-i = get-participants-i(participants)

  let widths = get-columns-width(participants, elements)

  // Compute each column's X position
  let x-pos = (0,)
  for width in widths {
    x-pos.push(x-pos.last() + width)
  }

  let draw-seq = sequence.render.with(pars-i, x-pos, participants)
  let draw-group = group.render.with()
  let draw-else = group.render-else.with()
  let draw-sep = separator.render.with(x-pos)
  let draw-par = participant.render.with(x-pos)
  let draw-note = note.render.with(pars-i, x-pos)
  let draw-sync = sync.render.with(pars-i, x-pos, participants)
  
  // Draw participants (start)
  for p in participants {
    if p.from-start and not p.invisible and p.show-top {
      shapes += draw-par(p)
    }
  }

  let y = 0
  let groups = ()
  let lifelines = participants.map(_ => (
    level: 0,
    lines: ()
  ))

  // Draw elemnts
  for elmt in elements {
    // Sequences
    if elmt.type == "seq" {
      let shps
      (y, lifelines, shps) = draw-seq(elmt, y, lifelines)
      shapes += shps

    // Groups (start) -> reserve space for labels + store position
    } else if elmt.type == "grp" {
      y -= Y-SPACE
      let m = measure(
        box(
          elmt.name,
          inset: (left: 5pt, right: 5pt, top: 3pt, bottom: 3pt),
        )
      )
      groups = groups.map(g => {
        if g.at(1).min-i == elmt.min-i { g.at(2) += 1 }
        if g.at(1).max-i == elmt.max-i { g.at(3) += 1 }
        g
      })
      if elmt.grp-type == "alt" {
        elmt.insert("elses", ())
      }
      groups.push((y, elmt, 0, 0))
      y -= m.height / 1pt
    
    // Groups (end) -> actual drawing
    } else if elmt.type == "grp-end" {
      y -= Y-SPACE
      let (start-y, group, start-lvl, end-lvl) = groups.pop()
      let x0 = x-pos.at(group.min-i) - start-lvl * 10 - 20
      let x1 = x-pos.at(group.max-i) + end-lvl * 10 + 20
      shapes += draw-group(x0, x1, start-y, y, group)

      if group.grp-type == "alt" {
        for (else-y, else-elmt) in group.elses {
          shapes += draw-else(x0, x1, else-y, else-elmt)
        }
      }

    // Alt's elses -> reserve space for label + store position
    } else if elmt.type == "else" {
      y -= Y-SPACE
      let m = measure(text([\[#elmt.desc\]], weight: "bold", size: .8em))
      groups.last().at(1).elses.push((
        y, elmt
      ))
      y -= m.height / 1pt

    // Separator
    } else if elmt.type == "sep" {
      let shps
      (y, shps) = draw-sep(elmt, y)
      shapes += shps
    
    // Gap
    } else if elmt.type == "gap" {
      y -= elmt.size

    // Delay
    } else if elmt.type == "delay" {
      let y0 = y
      let y1 = y - elmt.size
      for (i, line) in lifelines.enumerate() {
        line.lines.push(("delay-start", y0))
        line.lines.push(("delay-end", y1))
        lifelines.at(i) = line
      }
      if elmt.name != none {
        let x0 = x-pos.first()
        let x1 = x-pos.last()
        shapes += draw.content(
          ((x0 + x1) / 2, (y0 + y1) / 2),
          anchor: "center",
          elmt.name
        )
      }
      y = y1
    
    // Event
    } else if elmt.type == "evt" {
      let par-name = elmt.participant
      let i = pars-i.at(par-name)
      let par = participants.at(i)
      let line = lifelines.at(i)
      if elmt.event == "disable" {
        line.level -= 1
        line.lines.push(("disable", y))
      
      } else if elmt.event == "destroy" {
        line.lines.push(("destroy", y))
      
      } else if elmt.event == "enable" {
        line.level += 1
        line.lines.push(("enable", y, elmt.lifeline-style))
      
      } else if elmt.event == "create" {
        y -= CREATE-OFFSET
        shapes += participant.render(x-pos, par, y: y)
        line.lines.push(("create", y))
      }
      lifelines.at(i) = line
    
    // Note
    } else if elmt.type == "note" {
      if not elmt.linked {
        if not elmt.aligned {
          y -= Y-SPACE
        }
        let shps
        (y, shps) = draw-note(elmt, y, lifelines)
        shapes += shps
      }

    // Synched sequences
    } else if elmt.type == "sync" {
      let shps
      (y, lifelines, shps) = draw-sync(elmt, y, lifelines)
      shapes += shps
    }
  }

  y -= Y-SPACE

  // Draw vertical lines + lifelines + end participants
  shapes += draw.on-layer(-1, {
    if DEBUG-INVISIBLE {
      for p in participants.filter(p => p.invisible) {
        let color = if p.name.starts-with("?") {green} else if p.name.ends-with("?") {red} else {blue}
        let x = x-pos.at(p.i)
        draw.line(
          (x, 0),
          (x, y),
          stroke: (paint: color, dash: "dotted")
        )
        draw.content(
          (x, 0),
          p.display-name,
          anchor: "west",
          angle: 90deg
        )
      }
    }
    
    for p in participants.filter(p => not p.invisible) {
      let x = x-pos.at(p.i)

      // Draw vertical line
      let last-y = 0

      let rects = ()
      let destructions = ()
      let lines = ()

      // Compute lifeline rectangles + destruction positions
      for line in lifelines.at(p.i).lines {
        let event = line.first()
        if event == "create" {
          last-y = line.at(1)

        } else if event == "enable" {
          if lines.len() == 0 {
            draw.line(
              (x, last-y),
              (x, line.at(1)),
              stroke: (
                dash: "dashed",
                paint: gray.darken(40%),
                thickness: .5pt
              )
            )
          }
          lines.push(line)
        
        } else if event == "disable" or event == "destroy" {
          let lvl = 0
          if lines.len() != 0 {
            let l = lines.pop()
            lvl = lines.len()
            rects.push((
              x + lvl * LIFELINE-W / 2,
              l.at(1),
              line.at(1),
              l.at(2)
            ))
            last-y = line.at(1)
          }

          if event == "destroy" {
            destructions.push((x + lvl * LIFELINE-W / 2, line.at(1)))
          }
        } else if event == "delay-start" {
          draw.line(
            (x, last-y),
            (x, line.at(1)),
            stroke: (
              dash: "dashed",
              paint: gray.darken(40%),
              thickness: .5pt
            )
          )
          last-y = line.at(1)
        } else if event == "delay-end" {
          draw.line(
            (x, last-y),
            (x, line.at(1)),
            stroke: (
              dash: "loosely-dotted",
              paint: gray.darken(40%),
              thickness: .8pt
            )
          )
          last-y = line.at(1)
        }
      }

      draw.line(
        (x, last-y),
        (x, y),
        stroke: (
          dash: "dashed",
          paint: gray.darken(40%),
          thickness: .5pt
        )
      )

      // Draw lifeline rectangles (reverse for bottom to top)
      for rect in rects.rev() {
        let (cx, y0, y1, style) = rect
        let style = get-style("lifeline", style)
        draw.rect(
          (cx - LIFELINE-W / 2, y0),
          (cx + LIFELINE-W / 2, y1),
          ..style
        )
      }

      // Draw lifeline destructions
      for dest in destructions {
        let (cx, cy) = dest
        draw.line((cx - 8, cy - 8), (cx + 8, cy + 8), stroke: COL-DESTRUCTION + 2pt)
        draw.line((cx - 8, cy + 8), (cx + 8, cy - 8), stroke: COL-DESTRUCTION + 2pt)
      }

      // Draw participants (end)
      if p.show-bottom {
        draw-par(p, y: y, bottom: true)
      }
    }
  })

  shapes
})