#import "@preview/cetz:0.5.2"

#let _register-diamond-filled() = {
  cetz.draw.register-mark("diamond-filled", style => {
    let (l, w) = (style.length, style.width)
    let fill = style.stroke.paint

    cetz.draw.line(
      (0, 0),
      (l / 2, w / 2),
      (l, 0),
      (l / 2, -w / 2),
      close: true,
      stroke: style.stroke,
      fill: fill,
    )
    cetz.draw.anchor("tip", (0, 0))
    cetz.draw.anchor("base", (l, 0))
  })
}

#let _draw-class(c, theme) = {
  let class-content = box(
    inset: theme.inset,
    grid(
      columns: 1,
      row-gutter: 14pt,
      align: center,
      grid(
        columns: 1,
        row-gutter: 6pt,
        align(center, text(c.name, weight: theme.name-weight, fill: theme.text-color)),
        ..if c.type != none {
          (
            align(
              center,
              box(
                radius: theme.type-radius,
                stroke: theme.type-stroke,
                inset: theme.type-inset,
                fill: theme.type-fill,
                align(center, text(c.type, weight: theme.type-weight, fill: theme.text-color)),
              ),
            ),
          )
        } else { () },
      ),
      grid(
        columns: 1,
        row-gutter: 8pt,
        align: left,
        ..c.attributes.map(attr => text(attr, weight: theme.text-weight, fill: theme.text-color)),
        ..c.methods.map(method => text(method, weight: theme.text-weight, fill: theme.text-color)),
      ),
    ),
  )

  cetz.draw.hide(cetz.draw.content(
    c.center,
    class-content,
    anchor: "center",
    name: c.name + "-content",
  ))

  cetz.draw.rect(
    (c.name + "-content.north-west"),
    (c.name + "-content.south-east"),
    fill: theme.fill,
    radius: theme.radius,
    stroke: theme.stroke,
    name: c.name,
  )

  cetz.draw.content(
    c.center,
    class-content,
    anchor: "center",
  )
}

#let _draw-relationship(relationship, theme) = {
  let mark-size = 0.4cm * theme.mark-size.pt()

  cetz.draw.group(name: relationship.name, ctx => {
    for relationship-mark in (relationship.start-mark, relationship.end-mark) {
      if relationship-mark != none {
        cetz.draw.set-style(
          mark: (
            start: relationship-mark,
            length: mark-size,
            width: mark-size,
          ),
        )
      }
    }

    let (_, start-pos, end-pos) = cetz.coordinate.resolve(
      ctx,
      relationship.start,
      relationship.end,
      update: false,
    )

    let offsets = (
      north-south: (0, 1, 0, -1),
      north-east: (0, 1, 1, 0),
      north-west: (0, 1, -1, 0),
      south-east: (0, -1, 1, 0),
      south-west: (0, -1, -1, 0),
      east-west: (1, 0, -1, 0),
      south-north: (0, -1, 0, 1),
      east-north: (0, -1, -1, 0),
      west-north: (0, -1, 1, 0),
      east-south: (0, 1, -1, 0),
      west-south: (0, 1, 1, 0),
      west-east: (-1, 0, 1, 0),
    )

    let o = offsets.at(relationship.from-side + "-" + relationship.to-side)
    let v = 0.7 * theme.mark-size.pt()
    let start = (start-pos.at(0) + o.at(0) * v, start-pos.at(1) + o.at(1) * v)
    let end = (end-pos.at(0) + o.at(2) * v, end-pos.at(1) + o.at(3) * v)

    cetz.draw.line(
      start-pos,
      start,
      end,
      end-pos,
      stroke: (
        dash: relationship.line.map(v => v * theme.line-thickness.pt()),
        paint: theme.line-paint,
        thickness: theme.line-thickness,
        cap: "round",
      ),
    )
  })
}

#let _from-side-to-side(from-rect, to-rect) = {
  let from-center = from-rect.center
  let to-center = to-rect.center

  let dx = to-center.at(0) - from-center.at(0)
  let dy = to-center.at(1) - from-center.at(1)

  let from-side = "west"
  let to-side = "east"
  if calc.abs(dx) < calc.abs(dy) {
    if dy > 0 {
      return ("north", "south")
    } else {
      return ("south", "north")
    }
  } else {
    if dx > 0 {
      return ("east", "west")
    } else {
      return ("west", "east")
    }
  }

  return (from-side, to-side)
}

#let draw-uml-diagram(classes, relationships, theme) = {
  cetz.canvas({
    _register-diamond-filled()

    for c in classes {
      _draw-class(c, theme)
    }

    for r in relationships {
      if r.from-side == none or r.to-side == none {
        let (from-side, to-side) = _from-side-to-side(
          classes.filter(c => c.name == r.from-rect).at(0),
          classes.filter(c => c.name == r.to-rect).at(0),
        )
        r.insert("from-side", from-side)
        r.insert("to-side", to-side)
      }
      r.insert("start", r.from-rect + "." + r.from-side)
      r.insert("end", r.to-rect + "." + r.to-side)
      _draw-relationship(r, theme)
    }
  })
}
