#import "/src/cetz.typ": draw

#import "/src/consts.typ": *
#import "/src/core/utils.typ": get-ctx, set-ctx, expand-parent-group

#let display-name(name) = text(name, weight: "bold")
#let display-desc(desc) = text([\[#desc\]], weight: "bold", size: .8em)

#let render-start(grp) = get-ctx(ctx => {
  let grp = grp
  ctx.y -= Y-SPACE
  let m = measure(
    box(
      grp.name,
      inset: (
        left: 5pt,
        right: 5pt,
        top: 3pt,
        bottom: 3pt
      ),
    )
  )
  ctx.groups = ctx.groups.map(g => {
    if g.group.min-i == grp.min-i { g.start-lvl += 1 }
    if g.group.max-i == grp.max-i { g.end-lvl += 1 }
    g
  })
  if grp.grp-type == "alt" {
    grp.insert("elses", ())
  }
  ctx.groups.push((
    start-y: ctx.y,
    group: grp,
    start-lvl: 0,
    end-lvl: 0,
    min-x: ctx.x-pos.at(grp.min-i) - 10,
    max-x: ctx.x-pos.at(grp.max-i) + 10
  ))
  ctx.y -= m.height / 1pt

  set-ctx(c => {
    c.y = ctx.y
    c.groups = ctx.groups
    return c
  })
})


#let draw-group(x0, x1, y0, y1, group) = {
  let name = display-name(group.name)
  let m = measure(name)
  let w = m.width / 1pt + 15
  let h = m.height / 1pt + 6
  draw.rect(
    (x0, y0),
    (x1, y1)
  )
  draw.line(
    (x0, y0),
    (x0 + w, y0),
    (x0 + w, y0 - h / 2),
    (x0 + w - 5, y0 - h),
    (x0, y0 - h),
    fill: COL-GRP-NAME,
    close: true
  )
  draw.content(
    (x0, y0),
    name,
    anchor: "north-west",
    padding: (left: 5pt, right: 10pt, top: 3pt, bottom: 3pt)
  )

  if group.desc != none {
    draw.content(
      (x0 + w, y0),
      display-desc(group.desc),
      anchor: "north-west",
      padding: 3pt
    )
  }
}

#let draw-else(x0, x1, y, elmt) = {
  draw.line(
    (x0, y),
    (x1, y),
    stroke: (dash: (2pt, 1pt), thickness: .5pt)
  )
  draw.content(
    (x0, y),
    display-desc(elmt.desc),
    anchor: "north-west",
    padding: 3pt
  )
}

#let render-end(group) = get-ctx(ctx => {
  ctx.y -= Y-SPACE
  let (
    start-y,
    group,
    start-lvl,
    end-lvl,
    min-x,
    max-x
  ) = ctx.groups.pop()
  let x0 = min-x - 10
  let x1 = max-x + 10
  
  // Fit name and descriptions
  let name-m = measure(display-name(group.name))
  let width = name-m.width / 1pt + 15
  if group.desc != none {
    let desc-m = measure(display-desc(group.desc))
    width += desc-m.width / 1pt + 6
  }
  if group.grp-type == "alt" {
    width = calc.max(width, ..group.elses.map(e => {
      let elmt = e.at(1)
      let desc-m = measure(display-desc(elmt.desc))
      return desc-m.width / 1pt + 6
    }))
  }
  x1 = calc.max(x1, x0 + width + 3)
  
  draw-group(x0, x1, start-y, ctx.y, group)

  if group.grp-type == "alt" {
    for (else-y, else-elmt) in group.elses {
      draw-else(x0, x1, else-y, else-elmt)
    }
  }

  set-ctx(c => {
    c.y = ctx.y
    c.groups = ctx.groups
    return c
  })

  expand-parent-group(x0, x1)
})

#let render-else(else_) = set-ctx(ctx => {
  ctx.y -= Y-SPACE
  let m = measure(text([\[#else_.desc\]], weight: "bold", size: .8em))
  ctx.groups.last().group.elses.push((
    ctx.y, else_
  ))
  ctx.y -= m.height / 1pt
  return ctx
})