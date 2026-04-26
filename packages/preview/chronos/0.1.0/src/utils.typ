#let get-participants-i(participants) = {
  let pars-i = (:)
  for (i, p) in participants.enumerate() {
    pars-i.insert(p.name, i)
  }
  return pars-i
}

#let get-group-span(participants, group) = {
  let min-i = participants.len() - 1
  let max-i = 0
  let pars-i = get-participants-i(participants)

  for elmt in group.elmts {
    if elmt.type == "seq" {
      let i1 = pars-i.at(elmt.p1)
      let i2 = pars-i.at(elmt.p2)
      min-i = calc.min(min-i, i1, i2)
      max-i = calc.max(max-i, i1, i2)
    } else if elmt.type == "grp" {
      let (i0, i1) = get-group-span(participants, elmt)
      min-i = calc.min(min-i, i0)
      max-i = calc.max(max-i, i1)
    } else if elmt.type == "sync" {
      let (i0, i1) = get-group-span(participants, elmt)
      min-i = calc.min(min-i, i0)
      max-i = calc.max(max-i, i1)
    }
  }
  return (min-i, max-i)
}

#let get-style(base-name, mods) = {
  let style = if base-name == "lifeline" {(
    fill: white,
    stroke: black + 1pt
  )}

  if mods == auto {
    return style
  }
  if type(mods) == dictionary {
    return style + mods
  }

  panic("Invalid type for parameter mods, expected auto or dictionary, got " + str(type(mods)))
}

#let fit-canvas(canvas, width: auto) = layout(size => {
  let m = measure(canvas)
  let w = m.width
  let h = m.height
  let r = if w == 0pt {0} else {
    if width == auto {1}
    else if type(width) == length {
      width / w
    } else {
      size.width * width / w
    }
  }
  let new-w = w * r
  let new-h = h * r
  r *= 100%
  
  box(
    width: new-w,
    height: new-h,
    scale(x: r, y: r, reflow: true, canvas)
  )
})