#import "@preview/cetz:0.5.2"
#import "parser/plugin.typ" as plugin-parser
#import "themes.typ": themes

/// Custom diamond filled mark.
/// -> content
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

/// Draw a class.
/// -> content
#let _draw-class(
  /// The class to draw.
  /// -> class
  class,
  /// The theme of this diagram.
  /// -> theme
  theme,
) = {
  let empty-attributes = class.attributes.len() == 0
  let empty-methods = class.methods.len() == 0

  cetz.draw.content(
    class.center,
    anchor: "mid",
    name: class.name + "-content",
    layout(size => grid(
      box(
        width: size.width,
        fill: theme.header-fill,
        inset: theme.inset,
        stroke: theme.stroke,
        radius: (
          top: theme.radius,
          bottom: if empty-attributes and empty-methods { theme.radius } else { 0pt },
        ),
        grid.cell(
          align: center,
          grid(
            align: center + horizon,
            text(class.name, weight: "black", fill: theme.header-text-fill),
            ..if (class.type != none) {
              (
                box(height: theme.inset),
                grid(
                  columns: 3,
                  column-gutter: 1pt,
                  text("<<", fill: theme.header-text-fill),
                  text(
                    class.type,
                    style: "italic",
                    fill: theme.header-text-fill,
                  ),
                  text(">>", fill: theme.header-text-fill),
                ),
              )
            },
          ),
        ),
      ),
      if not empty-attributes {
        box(
          width: size.width,
          fill: theme.body-fill,
          stroke: theme.stroke,
          inset: theme.inset,
          radius: (
            bottom: if empty-methods { theme.radius } else { 0pt },
          ),
          grid(
            row-gutter: 8pt,
            align: left,
            ..class.attributes.map(attr => grid(
              columns: 2,
              text(
                attr.at(0),
                weight: "black",
                stroke: theme.visibility-fill + 0.5pt,
                fill: theme.body-fill,
              ),
              text(
                attr.slice(1),
                fill: theme.body-text-fill,
              ),
            )),
          ),
        )
      },
      if not empty-methods {
        box(
          width: size.width,
          fill: theme.body-fill,
          stroke: theme.stroke,
          inset: theme.inset,
          radius: (
            bottom: theme.radius,
          ),
          grid(
            row-gutter: 8pt,
            align: left,
            ..class.methods.map(method => grid(
              columns: 2,
              text(
                method.at(0),
                weight: "black",
                fill: theme.visibility-fill,
              ),
              text(
                method.slice(1),
                fill: theme.body-text-fill,
              ),
            )),
          ),
        )
      },
    )),
  )

  cetz.draw.rect(
    (class.name + "-content.base-east"),
    (class.name + "-content.north-west"),
    name: class.name,
    stroke: none,
  )
}

/// Draw a relatioship.
/// -> content
#let _draw-relationship(
  /// The relationship to draw.
  /// -> relantionship
  relationship,
  /// The theme of this diagram.
  /// -> theme
  theme,
) = {
  let mark-size = 0.4cm * theme.mark-size.pt()

  cetz.draw.group(name: relationship.name, ctx => {
    if relationship.start-mark != none {
      cetz.draw.set-style(
        mark: (
          start: relationship.start-mark,
          length: mark-size,
          width: mark-size,
        ),
      )
    }

    if relationship.end-mark != none {
      cetz.draw.set-style(
        mark: (
          end: relationship.end-mark,
          length: mark-size,
          width: mark-size,
        ),
      )
    }

    let (_, start-pos, end-pos) = cetz.coordinate.resolve(
      ctx,
      relationship.start,
      relationship.end,
      update: false,
    )

    if theme.line == "bezier" {
      let side-vectors = (
        north: (0, 1),
        south: (0, -1),
        east: (1, 0),
        west: (-1, 0),
      )

      let start-dir = side-vectors.at(relationship.from-side)
      let end-dir = side-vectors.at(relationship.to-side)

      let control-distance = 1.5 * theme.mark-size.pt()

      let control-start = (
        start-pos.at(0) + start-dir.at(0) * control-distance,
        start-pos.at(1) + start-dir.at(1) * control-distance,
      )

      let control-end = (
        end-pos.at(0) + end-dir.at(0) * control-distance,
        end-pos.at(1) + end-dir.at(1) * control-distance,
      )

      cetz.draw.bezier(
        start-pos,
        end-pos,
        control-start,
        control-end,
        stroke: (
          dash: relationship.line.map(v => v * theme.line-thickness.pt()),
          paint: theme.line-color,
          thickness: theme.line-thickness,
          cap: "round",
        ),
      )
    } else if theme.line == "line" {
      let offsets = (
        north-south: (0, 1, 0, -1),
        north-east: (0, 1, 1, 0),
        north-west: (0, 1, -1, 0),
        south-east: (0, -1, 1, 0),
        south-west: (0, -1, -1, 0),
        east-west: (1, 0, -1, 0),
        south-north: (0, -1, 0, 1),
        east-north: (1, 0, 0, 1),
        west-north: (-1, 0, 0, 1),
        east-south: (1, 0, 0, -1),
        west-south: (-1, 0, 0, -1),
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
          paint: theme.line-color,
          thickness: theme.line-thickness,
          cap: "round",
        ),
      )
    }
  })
}

/// Draw a line from a class side to another.
/// -> array
#let _from-side-to-side(
  /// Starting class.
  /// -> string
  from-rect,
  /// Ending class.
  /// -> string
  to-rect,
) = {
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

/// Draw a UML diagram.
/// -> content
#let draw-uml-diagram(
  /// The classes to draw.
  /// -> class
  classes,
  /// The relationships to draw.
  /// -> relationship
  relationships,
  /// The theme of this diagram.
  /// -> theme
  theme: themes.blueprint,
) = {
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
        if r.from-side == none {
          r.insert("from-side", from-side)
        }
        if r.to-side == none {
          r.insert("to-side", to-side)
        }
      }
      r.insert("start", r.from-rect + "." + r.from-side)
      r.insert("end", r.to-rect + "." + r.to-side)
      _draw-relationship(r, theme)
    }
  })
}

/// Draw a UML diagram by parsing a source code file.
/// -> content
#let draw-source-uml-diagram(
  /// The source files.
  /// -> array
  sources,
  /// The theme of this diagram.
  /// -> theme
  theme,
  /// The parser to apply.
  /// -> function
  parser,
) = {
  let classes = ()
  let relations = ()
  for s in sources {
    let text = read(s.path)
    // A path value is origin-aware but cannot expose its basename directly in
    // Typst 0.15. Its representation still contains the Blade filename.
    let blade = repr(s.path).match(regex("([a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*)\\.blade\\.php"))
    let parsed = if parser == plugin-parser.parse-php and blade != none {
      parser(text, filename: blade.text)
    } else {
      parser(text)
    }
    for (i, c) in parsed.classes.enumerate() {
      c.insert("center", (s.center.at(0) + i * 4, s.center.at(1)))
      classes.push(c)
    }
    relations += parsed.relations
  }

  cetz.canvas({
    _register-diamond-filled()

    for c in classes {
      _draw-class(c, theme)
    }

    for r in relations {
      let from = classes.filter(c => c.name == r.from-rect)
      let to = classes.filter(c => c.name == r.to-rect)
      if from.len() != 0 and to.len() != 0 {
        let (from-side, to-side) = _from-side-to-side(
          classes.filter(c => c.name == r.from-rect).at(0),
          classes.filter(c => c.name == r.to-rect).at(0),
        )
        r.insert("from-side", from-side)
        r.insert("to-side", to-side)
        r.insert("start", r.from-rect + "." + r.from-side)
        r.insert("end", r.to-rect + "." + r.to-side)
        _draw-relationship(r, theme)
      }
    }
  })
}
