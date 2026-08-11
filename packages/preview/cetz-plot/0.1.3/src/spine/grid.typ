#import "/src/cetz.typ": vector, draw

// Draw cartesian grid in a rect
//
// - proj (function): Axis value->coordinate translation
// - offset (float): Offset
// - length (float): Length
// - direction (vector): Direction vector
// - ticks (array): List of ticks
// - style (style): Style dictionary
// - mode (int): Grid mode 0: no grid, 1 major, 2 minor, 3 both
#let draw-cartesian(proj, offset, length, direction, ticks, style, mode) = {
  let direction = vector.norm(direction)
  let length = direction.map(v => {
    v * length
  })
  let offset = direction.map(v => {
    v * -offset
  })

  let major-stroke = style.stroke
  let minor-stroke = style.minor-stroke


  draw.on-layer(style.at("grid-layer", default: 0), {
    for (value, _, is-major) in ticks {
      if (if is-major { 1 } else { 2 }).bit-and(mode) != 0 {
        let origin = vector.add(proj(value), offset)
        draw.line(origin, vector.add(origin, length),
          stroke: if is-major { major-stroke } else { minor-stroke })
      }
    }
  })
}
