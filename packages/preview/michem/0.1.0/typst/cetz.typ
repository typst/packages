#import "molecule.typ" as chemical

/// Draw a molecule in a CeTZ canvas, exposing bounds and named atom anchors.
/// `scale` scales the physical image; atom anchors use the same transformation.
/// The image center is placed at `at`; `unit` is the natural SVG pixel length.
#let molecule(
  mol,
  at: (0, 0),
  name: none,
  scale: 1,
  unit: 0.75pt,
  style: (:),
  layout: (:),
) = {
  import "@preview/cetz:0.5.2" as canvas
  assert(scale > 0, message: "molecule scale must be positive")
  assert(unit > 0pt, message: "molecule unit must be positive")
  canvas.draw.get-ctx(_ => {
    let data = chemical.diagram(mol, style: style, layout: layout)
    let width = data.width * unit * scale
    let height = data.height * unit * scale
    canvas.draw.scope({
      canvas.draw.set-origin(at)
      canvas.draw.group(name: name, {
        canvas.draw.get-ctx(ctx => {
          // CeTZ content scales on request but needs an explicit rotation angle.
          let direction = canvas.matrix.column(ctx.transform, 0)
          let angle = canvas.vector.angle2((0, 0, 0), direction)
          canvas.draw.content(
            (0, 0),
            image(bytes(data.svg), format: "svg", width: width, height: height),
            angle: angle,
            padding: 0pt,
            auto-scale: true,
          )
        })
        // A group anchor is zero-size and does not enlarge the image bounds.
        for atom in data.atoms {
          canvas.draw.anchor("atom-" + atom.id, (
            (atom.x - 0.5) * width,
            (atom.y - 0.5) * height,
          ))
        }
      })
    })
  })
}

/// Reaction connector with Typst conditions above and below a CeTZ arrow.
#let reaction(
  from,
  to,
  above: none,
  below: none,
  name: none,
  stroke: 0.7pt,
  label-gap: 3pt,
  label-side: "north",
) = {
  import "@preview/cetz:0.5.2" as canvas
  let sides = (
    north: ((0pt, label-gap), "south", "north"),
    south: ((0pt, -label-gap), "north", "south"),
    east: ((label-gap, 0pt), "west", "east"),
    west: ((-label-gap, 0pt), "east", "west"),
  )
  assert(
    label-side in sides,
    message: "label-side must be north, south, east, or west",
  )
  let (offset, above-anchor, below-anchor) = sides.at(label-side)
  canvas.draw.line(from, to, name: name, stroke: stroke, mark: (end: ">"))
  let midpoint = (from, 50%, to)
  if above != none {
    canvas.draw.content(
      (rel: offset, to: midpoint),
      above,
      anchor: above-anchor,
      padding: 0pt,
    )
  }
  if below != none {
    canvas.draw.content(
      (rel: offset.map(value => -value), to: midpoint),
      below,
      anchor: below-anchor,
      padding: 0pt,
    )
  }
}
