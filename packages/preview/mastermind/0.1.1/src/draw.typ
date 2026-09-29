#import "@preview/cetz:0.5.2"

#let _multiply-line-array(arr, factor) = {
  return (arr.at(0) * factor, arr.at(1) * factor)
}

#let _register-diamond-filled() = {
  cetz.draw.register-mark("diamond-filled", style => {
    let (l, w) = (style.length, style.width)
    let fill = if style.fill in (none, auto) { style.stroke.paint } else { style.fill }

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

#let _draw-class(r, theme) = {
  cetz.draw.content(
    r.center,
    box(
      inset: theme.inset,
      fill: theme.fill,
      radius: theme.radius,
      stroke: theme.stroke,
      grid(
        columns: 1,
        rows: (20pt, 10pt),
        row-gutter: 5pt,
        align(center + horizon, text(r.name, weight: "black", fill: theme.text-color)),
        ..if r.type != none {
          (
            align(
              center + horizon,
              box(
                radius: theme.type-radius,
                stroke: theme.type-stroke,
                inset: theme.type-inset,
                fill: theme.type-fill,
                align(center + horizon, text(r.type, fill: theme.text-color)),
              ),
            ),
          )
        } else { () },
        ..r.attributes.map(attr => text(attr, fill: theme.text-color)),
        ..r.methods.map(method => text(method, fill: theme.text-color)),
      ),
    ),
    anchor: "center",
    name: r.name,
  )
  cetz.draw.rect(
    (r.name + ".north-west"),
    (r.name + ".south-east"),
    stroke: none,
    name: r.name,
  )
}

#let _draw-relationship(relationship, theme) = {
  let mark-size = 0.2cm * theme.line-thickness.pt()
  cetz.draw.group(name: relationship.name, {
    if relationship.start-mark != none {
      cetz.draw.set-style(mark: (start: relationship.start-mark, length: mark-size, width: mark-size))
    }
    if relationship.end-mark != none {
      cetz.draw.set-style(mark: (end: relationship.end-mark, length: mark-size, width: mark-size))
    }

    cetz.draw.line(
      relationship.start,
      relationship.end,
      stroke: (
        dash: relationship.line.map(v => v * theme.line-thickness.pt()),
        paint: theme.line-paint,
        thickness: theme.line-thickness,
        cap: "round",
      ),
    )
  })
}

#let draw-class-diagram(classes, relationships, theme) = {
  cetz.canvas({
    _register-diamond-filled()

    for (name, r) in classes {
      _draw-class(r, theme)
    }

    for relationship in relationships {
      _draw-relationship(relationship, theme)
    }
  })
}
