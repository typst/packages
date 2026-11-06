#import "@preview/cetz:0.4.2": canvas, draw

// lighten is for drawing duplicates
#let draw-individual(individual, x, y, lighten, draw-data) = {
  import draw: *
  let stroke-color = black.lighten(lighten)
  let stroke-style = {(paint: black); draw-data.default-stroke-style; individual.stroke-style}
  stroke-style.paint = stroke-style.at("paint", default: black).lighten(lighten)

  let empty-style
  if individual.empty-style != auto {
    empty-style = individual.empty-style.lighten(lighten)
  } else if draw-data.default-empty-style != auto {
    empty-style = draw-data.default-empty-style.lighten(lighten)
  } else {
    empty-style = white
  }

  let fill-style
  if individual.fill-style != auto {
    fill-style = individual.fill-style.lighten(lighten)
  } else if draw-data.default-fill-style != auto {
    fill-style = draw-data.default-fill-style.lighten(lighten)
  } else {
    fill-style = black.lighten(lighten)
  }

  let quadrants
  if individual.fill == "empty" {
    quadrants = ()
  } else if individual.fill in ("I-II-III-IV", "I-II-III", "I-II-IV", "I-II", "I-III-IV", "I-III", "I-IV", "I", "II-III-IV", "II-III", "II-IV", "II", "III-IV", "III", "IV") {
    quadrants = ()
    for substring in individual.fill.split("-") {
      if      substring == "I"   {quadrants.push(1)}
      else if substring == "II"  {quadrants.push(2)}
      else if substring == "III" {quadrants.push(3)}
      else if substring == "IV"  {quadrants.push(4)}
    }
  } else if individual.fill == "left" {
    quadrants = (2, 3)
  } else if individual.fill == "right" {
    quadrants = (1, 4)
  } else if individual.fill == "up" {
    quadrants = (1, 2)
  } else if individual.fill == "down" {
    quadrants = (3, 4)
  } else if individual.fill == "filled" {
    quadrants = (1, 2, 3, 4)
  } else if individual.fill == "dot" {
    quadrants = ()
  } else if individual.fill == "unknown" {
    quadrants = ()
  } else {
    panic("fill \"" + str(individual.fill) + "\" is not in 'empty', 'filled', 'unknown', 'dot', 'left', 'right', 'up', 'down', or uses quadrant notation")
  }

  // male
  if individual.sex == "male" {
    rect((x + 0.25, y + 0.25), (x - 0.25, y - 0.25), stroke: none, fill: empty-style)

    if individual.fill == "unknown" {
      for i in range(10) {
        line((x - 0.25, y + 0.25 - i/20), (x - 0.25 + i/20, y + 0.25), stroke: fill-style + 0.25pt * draw-data.length-scale)
        line((x - 0.25 + i/20, y - 0.25), (x + 0.25, y + 0.25 - i/20), stroke: fill-style + 0.25pt * draw-data.length-scale)
      }
    }
    if individual.fill == "dot" {
      circle((x, y), radius: 0.0625, stroke: none, fill: fill-style)
    }
    if 1 in quadrants {rect((x, y), (x + 0.25, y + 0.25), stroke: none, fill: fill-style)}
    if 2 in quadrants {rect((x, y), (x - 0.25, y + 0.25), stroke: none, fill: fill-style)}
    if 3 in quadrants {rect((x, y), (x - 0.25, y - 0.25), stroke: none, fill: fill-style)}
    if 4 in quadrants {rect((x, y), (x + 0.25, y - 0.25), stroke: none, fill: fill-style)}
    // place stroke on top of shapes
    rect((x + 0.25, y + 0.25), (x - 0.25, y - 0.25), stroke: stroke-style)
  }

  // female
  else if individual.sex == "female" {
    circle((x, y), radius: 0.25, stroke: none, fill: empty-style)

    if individual.fill == "unknown" {
      for i in range(4, 17) {
        let c = (i - 10)/5
        if calc.pow(c, 2) <= 2 {
          let discriminant = calc.sqrt(2 - calc.pow(c, 2))
          line((x + (c + discriminant)/8, y + (-c + discriminant)/8), (x + (c - discriminant)/8, y + (-c - discriminant)/8), stroke: fill-style + 0.25pt * draw-data.length-scale)
        }
      }
    }
    if individual.fill == "dot" {
      circle((x, y), radius: 0.0625, stroke: none, fill: fill-style)
    }

    if 1 in quadrants {
      arc((x + 0.25, y), start: 0deg, delta: 90deg, radius: 0.25, stroke: none, fill: fill-style, mode: "PIE")
    }
    if 2 in quadrants {
      arc((x, y + 0.25), start: 90deg, delta: 90deg, radius: 0.25, stroke: none, fill: fill-style, mode: "PIE")
    }
    if 3 in quadrants {
      arc((x - 0.25, y), start: 180deg, delta: 90deg, radius: 0.25, stroke: none, fill: fill-style, mode: "PIE")
    }
    if 4 in quadrants {
      arc((x, y - 0.25), start: 270deg, delta: 90deg, radius: 0.25, stroke: none, fill: fill-style, mode: "PIE")
    }
    circle((x, y), radius: 0.25, stroke: stroke-style)
  }

  // unknown sex
  else if individual.sex == "unknown" {
    polygon((x, y), 4, radius: 0.25, stroke: none, fill: empty-style)

    if individual.fill == "unknown" {
      for i in range(10) {
        line((x - 0.25 + i/40, y - i/40), (x + i/40, y + 0.25 - i/40), stroke: fill-style + 0.25pt * draw-data.length-scale)
      }
    }
    if individual.fill == "dot" {
      circle((x, y), radius: 0.0625, stroke: none, fill: fill-style)
    }
    if 1 in quadrants {line((x, y), (x + 0.25, y), (x, y + 0.25), stroke: none, fill: fill-style)}
    if 2 in quadrants {line((x, y), (x - 0.25, y), (x, y + 0.25), stroke: none, fill: fill-style)}
    if 3 in quadrants {line((x, y), (x - 0.25, y), (x, y - 0.25), stroke: none, fill: fill-style)}
    if 4 in quadrants {line((x, y), (x + 0.25, y), (x, y - 0.25), stroke: none, fill: fill-style)}
    polygon((x, y), 4, radius: 0.25, stroke: stroke-style)
  }

  // miscarriage
  else if individual.sex == "miscarriage" {
    let s1 = calc.sin(0*calc.pi/3); let c1 = calc.cos(0*calc.pi/3)
    let s2 = calc.sin(2*calc.pi/3); let c2 = calc.cos(2*calc.pi/3)
    let s3 = calc.sin(4*calc.pi/3); let c3 = calc.cos(4*calc.pi/3)
    // symbol is raised slightly
    line((x + 0.25 * s1, y + 0.0625 + 0.25 * c1), (x + 0.25 * s2, y + 0.0625 + 0.25 * c2), (x + 0.25 * s3, y + 0.0625 + 0.25 * c3), close: true, stroke: none, fill: empty-style)

    if individual.fill == "unknown" {
      for i in range(12) {
        let c = -(i - 5)/5
        if c > 1/(1 + calc.sqrt(3)) {
          line((x + 0.25 * (1 - c)/(1 - calc.sqrt(3)), y + 0.0625 + 0.25 * ((1 - c)/(1 - calc.sqrt(3)) + c)), (x + 0.25 * (1 - c)/(1 + calc.sqrt(3)), y + 0.0625 + 0.25 * ((1 - c)/(1 + calc.sqrt(3)) + c)), stroke: fill-style + 0.25pt * draw-data.length-scale)
        } else {
          line((x + 0.25 * (-0.5 - c), y + 0.0625 - 0.25 * 0.5), (x + 0.25 * (1 - c)/(1 + calc.sqrt(3)), y + 0.0625 + 0.25 * ((1 - c)/(1 + calc.sqrt(3)) + c)), stroke: fill-style + 0.25pt * draw-data.length-scale)
        }
      }
    }
    if individual.fill == "dot" {
      circle((x, y + 0.0625), radius: 0.0625, stroke: none, fill: fill-style)
    }

    if 1 in quadrants {
      line((x, y + 0.0625), (x + 0.25 * calc.sqrt(3)/3, y + 0.0625), (x, y + 0.0625 + 0.25), stroke: none, fill: fill-style)
    }
    if 2 in quadrants {
      line((x, y + 0.0625), (x - 0.25 * calc.sqrt(3)/3, y + 0.0625), (x, y + 0.0625 + 0.25), stroke: none, fill: fill-style)
    }
    if 3 in quadrants {
      line((x, y + 0.0625), (x - 0.25 * calc.sqrt(3)/3, y + 0.0625), (x + 0.25 * s3, y + 0.0625 + 0.25 * c3), (x, y + 0.0625 + 0.25 * c3), stroke: none, fill: fill-style)
    }
    if 4 in quadrants {
      line((x, y + 0.0625), (x + 0.25 * calc.sqrt(3)/3, y + 0.0625), (x + 0.25 * s2, y + 0.0625 + 0.25 * c2), (x, y + 0.0625 + 0.25 * c2), stroke: none, fill: fill-style)
    }
    line((x + 0.25 * s1, y + 0.0625 + 0.25 * c1), (x + 0.25 * s2, y + 0.0625 + 0.25 * c2), (x + 0.25 * s3, y + 0.0625 + 0.25 * c3), close: true, stroke: stroke-style)
  }

  // sex that does not exist
  else {
    panic("sex \"" + individual.sex + "\" is not in 'male', 'female', 'unknown', 'miscarriage'")
  }

  // dead marker
  let dead-style = {(paint: stroke-color); draw-data.default-dead-style; individual.dead-style}
  if individual.dead in (true, "true", "double", "single") {
    line((x + 0.375, y + 0.375), (x - 0.375, y - 0.375), stroke: dead-style)
  }
  if individual.dead == "double" {
    line((x - 0.375, y + 0.375), (x + 0.375, y - 0.375), stroke: dead-style)
  }
  // adopted marker
  let adopted-style = {(paint: stroke-color); draw-data.default-adopted-style; individual.adopted-style}
  if individual.adopted in ("true", true) {
    line((x - 0.25, y + 0.3125), (x - 0.3125, y + 0.3125), (x - 0.3125, y - 0.3125), (x - 0.25, y - 0.3125), stroke: adopted-style)
    line((x + 0.25, y + 0.3125), (x + 0.3125, y + 0.3125), (x + 0.3125, y - 0.3125), (x + 0.25, y - 0.3125), stroke: adopted-style)
  } else if individual.adopted == "alt" {
    line((x - 0.25, y + 0.3125), (x - 0.3125, y + 0.3125), (x - 0.3125, y + 0.125), stroke: adopted-style)
    line((x - 0.25, y - 0.3125), (x - 0.3125, y - 0.3125), (x - 0.3125, y - 0.125), stroke: adopted-style)
    line((x - 0.3125, y + 0.046875), (x - 0.3125, y - 0.046875), stroke: adopted-style)
    line((x + 0.25, y + 0.3125), (x + 0.3125, y + 0.3125), (x + 0.3125, y + 0.125), stroke: adopted-style)
    line((x + 0.25, y - 0.3125), (x + 0.3125, y - 0.3125), (x + 0.3125, y - 0.125), stroke: adopted-style)
    line((x + 0.3125, y + 0.046875), (x + 0.3125, y - 0.046875), stroke: adopted-style)
  }
  // propositus
  let propositus-alignment
  if type(individual.propositus) == bool {
    propositus-alignment = bottom + left
  } else {
    propositus-alignment = individual.propositus
  }
  if individual.propositus != false {
    let propositus-style = {(paint: stroke-color); draw-data.default-propositus-style; individual.propositus-style}
    let propositus-fill = propositus-style.at("paint", default: stroke-color)
    let offset = 0
    if individual.dead in (true, "true", "double") and propositus-alignment in (left, bottom, bottom + left, top + right) or individual.dead == "double" {
      offset = 0.125
    } else if individual.adopted in (true, "true", "alt") {
      offset = 0.0625
    }
    if propositus-alignment in (right, bottom + right) {
      mark((x + 0.265625 + offset, y - 0.265625 - offset), 135deg, symbol: ">", fill: propositus-fill, stroke: propositus-style, scale: draw-data.length-scale/2)
      line((x + 0.3125 + offset, y - 0.3125 - offset), (x + 0.4375 + offset, y - 0.4375 - offset), stroke: propositus-style)
    } else if propositus-alignment in (top, top + left) {
      mark((x - 0.265625 - offset, y + 0.265625 + offset), 315deg, symbol: ">", fill: propositus-fill, stroke: propositus-style, scale: draw-data.length-scale/2)
      line((x - 0.3125 - offset, y + 0.3125 + offset), (x - 0.4375 - offset, y + 0.4375 + offset), stroke: propositus-style)
    } else if propositus-alignment == (top + right) {
      mark((x + 0.265625 + offset, y + 0.265625 + offset), 225deg, symbol: ">", fill: propositus-fill, stroke: propositus-style, scale: draw-data.length-scale/2)
      line((x + 0.3125 + offset, y + 0.3125 + offset), (x + 0.4375 + offset, y + 0.4375 + offset), stroke: propositus-style)
    } else if propositus-alignment in (bottom, left, bottom + left) {
      mark((x - 0.265625 - offset, y - 0.265625 - offset), 45deg, symbol: ">", fill: propositus-fill, stroke: propositus-style, scale: draw-data.length-scale/2)
      line((x - 0.3125 - offset, y - 0.3125 - offset), (x - 0.4375 - offset, y - 0.4375 - offset), stroke: propositus-style)
    }
  }

  let label
  if individual.label == auto {
    label = text([#numbering("I", individual.generation)-#individual.ind-number], size: 4pt * draw-data.length-scale)
  } else if individual.label == none { // do nothing
  } else {
    label = text(individual.label, size: 4pt * draw-data.length-scale)
  }
  let label-size = measure(label)
  if label-size.width / draw-data.length >= 0.75 and (propositus-alignment in (bottom, left, bottom + left, right, bottom + right) or individual.dead not in (false, "false")) {
    content((x, y - 0.40625), label, anchor: "north")
  } else {
    content((x, y - 0.3125), label, anchor: "north")
  }
  let in-label-color = black.lighten(lighten)
  if quadrants.len() > 0 {
    in-label-color = white
  }
  if individual.sex == "miscarriage" {
    content((x, y + 0.0625), text(individual.in-label, size: 5.5pt * draw-data.length-scale, fill: in-label-color))
  } else {
    content((x, y), text(individual.in-label, size: 5.5pt * draw-data.length-scale, fill: in-label-color))
  }
}

#let draw-vertical-line(x, y-start, y-end, data, draw-data, exclude-childrens, exclude-unions, stroke-style) = {
  import draw: *
  import "processing.typ": *

  let obstructions = () // list of y-positions
  let obstructed-childrens = ()
  let obstructed-unions = ()
  let output = {}
  for children in iterate-childrens(data) {
    if children.id in exclude-childrens {
      continue
    }
    if children.childs.len() == 0 {
      continue
    }
    let horizontal-bounds = draw-data.childrens-x-bounds.at(children.id)
    let sibling-line-y = draw-data.generations-y.at(children.minimum-generation - 1) + 0.5
    if x >= horizontal-bounds.minimum-x and x <= horizontal-bounds.maximum-x and sibling-line-y <= y-start and sibling-line-y >= y-end {
      obstructions.push(sibling-line-y)
      obstructed-childrens.push(children-id)
    }
  }
  for union in iterate-unions(data) {
    if union.id in exclude-unions {
      continue
    }
    let x1 = draw-data.offsets.at(union.individual-1.ind-id)
    let x2 = draw-data.offsets.at(union.individual-2.ind-id)
    let y1 = draw-data.generations-y.at(union.individual-1.generation - 1)
    let y2 = draw-data.generations-y.at(union.individual-2.generation - 1)
    let intersection = y1 + (x - x1) * (y2 - y1)/(x2 - x1)
    if x > calc.min(x1, x2) and x < calc.max(x1, x2) and intersection <= y-start and intersection >= y-end {
      obstructions.push(intersection)
      obstructed-unions.push(union-id)
    }
  }
  obstructions = obstructions.sorted().rev()

  if obstructions.len() == 0 {
    output = {output; line((x, y-start), (x, y-end), stroke: stroke-style)}
    return (output, obstructed-childrens, obstructed-unions, false)
  } else {
    output = {output; line((x, y-start), (x, obstructions.at(0) + 0.125), stroke: stroke-style)}
    for obstruction in obstructions {
      output = {output; arc((x, obstruction + 0.125), start: 90deg, delta: -180deg, radius: 0.125, stroke: stroke-style)}
    }
    for i in range(obstructions.len() - 1) {
      output = {output; line((x, obstructions.at(i)), (x, obstructions.at(i + 1)), stroke: stroke-style)}
    }
    if y-end < obstructions.at(-1) - 0.125 {
      output = {output; line((x, y-end), (x, obstructions.at(-1) - 0.125), stroke: stroke-style)}
      return (output, obstructed-childrens, obstructed-unions, false)
    } else {
      return (output, obstructed-childrens, obstructed-unions, true)
    }
  }
}

#let draw-pedigree(data, other-data) = {
  import "processing.typ": *
  context {canvas(length: other-data.length, {
    import draw: *
    let offsets = other-data.offsets

    // in this context, find the generation heights
    let generation-heights = (other-data.default-generation-height,) * data.maximum-generation
    for individual in iterate-individuals(data) {
      let generation = individual.generation // right here so duplicates are handled correctly
      if individual.individual.type == "duplicate" {
        individual = data.duplicates-individuals.at(individual.ind-id)
      }
      let label = individual.individual.label
      if label in (none, auto) {continue} // don't care about automatic numerical labels
      let label-size = measure(text(label, size: 4pt * other-data.length-scale))
      let label-height = label-size.height / other-data.length
      let individual-height = 1 + label-height
      generation-heights.at(generation - 1) = calc.max(generation-heights.at(generation - 1), individual-height)
    }
    // cumulative heights (negative)
    let generations-y = ()
    for i in range(generation-heights.len()) {
      if i == 0 {
        generations-y.push(0)
      } else {
        generations-y.push(generations-y.at(i - 1) - generation-heights.at(i - 1))
      }
    }
    let draw-data = {other-data; (generations-y: generations-y)}

    if draw-data.generation-labels {
      for (generation-id, generation-y) in generations-y.enumerate() {
        content((-0.5, generation-y), text([#numbering("I", generation-id + 1)], size: 6.5pt * draw-data.length-scale), anchor: "east")
      }
    }

    for children in iterate-childrens(data) {
      let line-of-descent-style = {draw-data.default-line-of-descent-style; children.children.line-of-descent-style}
      let sibling-line-style = {draw-data.default-sibling-line-style; children.children.sibling-line-style}
      if children.childs.len() == 0 {
        let parent-x
        let parent-y
        if children.parents.type == "union" {
          parent-x = (
            offsets.at(children.parents.individual-1.ind-id)
            + offsets.at(children.parents.individual-2.ind-id)
          ) / 2
          parent-y = (
            generations-y.at(children.parents.individual-1.generation - 1)
            + generations-y.at(children.parents.individual-2.generation - 1)
          ) / 2
        } else {
          parent-x = offsets.at(children.parents.ind-id)
          parent-y = generations-y.at(children.parents.generation - 1)
        }
        let no-children-style = {draw-data.default-no-children-style; children.children.no-children-style}
        line((parent-x, parent-y), (parent-x, parent-y - 0.5), stroke: line-of-descent-style)
        line((parent-x + 0.125, parent-y - 0.5), (parent-x - 0.125, parent-y - 0.5), stroke: no-children-style)
        if children.children.infertile {
          line((parent-x + 0.0625, parent-y - 0.5625), (parent-x - 0.0625, parent-y - 0.5625), stroke: no-children-style)
        }
        if children.children.label != none {
          content((parent-x - 0.05, parent-y - 0.45), text(children.children.label, 5.5pt * draw-data.length-scale), anchor: "base-east")
        }
        continue
      }
      let minimum-generation = children.minimum-generation
      let sibling-x-start = draw-data.childrens-x-bounds.at(children.id).minimum-x
      let sibling-x-end = draw-data.childrens-x-bounds.at(children.id).maximum-x
      let sibling-y = generations-y.at(minimum-generation - 1) + 0.5
      // sibling line is drawn later.
      let heredity-x-end
      let heredity-y-end
      let union-ids = () // just for a render-vertical-line
      if children.parents.type == "union" {
        union-ids.push(children.parents.id)
        heredity-x-end = (offsets.at(children.parents.individual-1.ind-id) + offsets.at(children.parents.individual-2.ind-id)) / 2
        heredity-y-end = (
          generations-y.at(children.parents.individual-1.generation - 1)
          + generations-y.at(children.parents.individual-2.generation - 1)
        ) / 2
      } else if children.parents.type in ("individual", "duplicate") {
        heredity-x-end = offsets.at(children.parents.id)
        heredity-y-end = generations-y.at(children.parents.generation - 1)
      }
      let heredity-x-start
      if sibling-x-start == sibling-x-end {
        heredity-x-start = sibling-x-start
      } else if heredity-x-end < sibling-x-start + 0.25 {
        heredity-x-start = sibling-x-start + 0.25
      } else if heredity-x-end > sibling-x-end - 0.25 {
        heredity-x-start = sibling-x-end - 0.25
      } else {
        heredity-x-start = heredity-x-end
      }
      let heredity-y-start = generations-y.at(minimum-generation - 1) + 0.5
      // vertical-horizontal-vertical instead of diagonal
      let (lines, descent-obstructed-childrens, descent-obstructed-unions, has-final-obstruction) = draw-vertical-line(heredity-x-start, heredity-y-start + 0.125, heredity-y-start, data, draw-data, (children.id,), union-ids, line-of-descent-style)
      lines

      if children.children.label != none {
        content((calc.min(heredity-x-end, heredity-x-start) - 0.05, sibling-y + 0.05), text(children.children.label, 5.5pt * draw-data.length-scale), anchor: "base-east")
      }

      // use end of the line of descent, which may vary if there is an obstruction
      line((sibling-x-start, sibling-y), (sibling-x-end, sibling-y), stroke: sibling-line-style) // sibling line
      line((heredity-x-start, heredity-y-start + 0.125), (heredity-x-end, heredity-y-start + 0.125), stroke: line-of-descent-style)
      let (lines, _, _, _) = draw-vertical-line(heredity-x-end, heredity-y-end, heredity-y-start + 0.125, data, draw-data, (children.id,), union-ids, line-of-descent-style)
      lines
      for (child, child-line-style) in children.childs.zip(children.children.child-line-style) {
        let child-line-style = {draw-data.default-child-line-style; child-line-style}
        let child-x
        let y-end
        if child.type in ("individual", "duplicate") {
          child-x = offsets.at(child.ind-id)
          y-end = generations-y.at(child.generation - 1)
        } else { // twin
          let twin-x = child.individuals.map(individual => offsets.at(individual.ind-id))
          child-x = (calc.min(..twin-x) + calc.max(..twin-x)) / 2
          y-end = generations-y.at(minimum-generation - 1) + 0.375

          if child.twin.label != none {
            content((child-x, sibling-y + 0.05), text(child.twin.label, 5.5pt * draw-data.length-scale), anchor: "base")
          }

          // draw twin lines
          let twin-style = {draw-data.default-twin-style; child.twin.style}
          for individual in child.individuals {
            line((offsets.at(individual.ind-id), generations-y.at(individual.generation - 1)), (child-x, y-end), stroke: twin-style)
          }
          // monozygosity
          let monozygotic-style = {draw-data.default-monozygotic-style; child.twin.monozygotic-style}
          for (i, monozygosity) in child.twin.monozygotic.enumerate() {
            let x1 = offsets.at(child.individuals.at(i).ind-id)
            let x2 = offsets.at(child.individuals.at(i + 1).ind-id)
            if monozygosity in (true, "true") {
              let y-average = generations-y.at(child.generation - 1) * 0.25 + y-end * 0.75
              line((x1 * 0.25 + child-x * 0.75, y-average), (x2 * 0.25 + child-x * 0.75, y-average), stroke: monozygotic-style)
            } else if monozygosity == "unknown" {
              content(((x1 + x2) / 2, generations-y.at(child.generation - 1)), text([?], size: 5.5pt * draw-data.length-scale))
            } else if monozygosity in (false, "false") {} // nothing
            else {
              panic("monozygosity \"" + monozygosity + "\" is not in 'true', 'false', 'unknown'")
            }
          }
        }
        let y-start
        if has-final-obstruction and children.childs.len() == 1 { // micro-manages jumps when the line of descent jumps over a sibling line at the same generation as the single child of this thing.
          y-start = generations-y.at(minimum-generation - 1) + 0.375
        } else {
          y-start = generations-y.at(minimum-generation - 1) + 0.5
        }

        let (lines, _, _, _) = draw-vertical-line(child-x, y-start, y-end, data, draw-data, (children.id,) + descent-obstructed-childrens, union-ids + descent-obstructed-unions, child-line-style)
        lines
      }
    }

    for union in iterate-unions(data) {
      let start-x = offsets.at(union.individual-1.ind-id)
      let start-y = generations-y.at(union.individual-1.generation - 1)
      let end-x = offsets.at(union.individual-2.ind-id)
      let end-y = generations-y.at(union.individual-2.generation - 1)
      let union-style = {draw-data.default-union-style; union.union.style}

      let label-sep
      if union.union.consanguineous {
        label-sep = 0.125
        let angle = calc.atan2(end-x - start-x, end-y - start-y)
        line((start-x, start-y), (end-x, end-y), stroke: white + 3pt * draw-data.length-scale)
        line((start-x + 0.05 * -calc.sin(angle), start-y + 0.05 * calc.cos(angle)), (end-x + 0.05 * -calc.sin(angle), end-y + 0.05 * calc.cos(angle)), stroke: union-style)
        line((start-x, start-y - 0.05), (end-x, end-y - 0.05), stroke: union-style)
      } else {
        label-sep = 0.0625
        line((start-x, start-y), (end-x, end-y), stroke: union-style)
      }

      let center-x = (start-x + end-x) / 2
      let center-y = (start-y + end-y) / 2
      let divorced-style = {draw-data.default-divorced-style; union.union.divorced-style}
      if union.union.divorced == 2 {
        line((center-x - 0.1875, center-y - 0.125), (center-x + 0.0625, center-y + 0.125), stroke: divorced-style)
        line((center-x - 0.0625, center-y - 0.125), (center-x + 0.1875, center-y + 0.125), stroke: divorced-style)
        label-sep = calc.max(0.1875, label-sep)
      } else if union.union.divorced in (1, true) {
        line((center-x - 0.125, center-y - 0.125), (center-x + 0.125, center-y + 0.125), stroke: divorced-style)
        label-sep = calc.max(0.1875, label-sep)
      }
      // label
      if union.union.label != none {
        let angle = calc.atan2(end-x - start-x, end-y - start-y)
        content((center-x + label-sep * -calc.sin(angle), center-y + label-sep * calc.cos(angle)), text(union.union.label, 5.5pt * draw-data.length-scale), anchor: "base", angle: angle)
      }
    }
    // draw duplicate lines
    for individual in iterate-individuals(data) {
      if individual.individual.type == "duplicate" and individual.individual.bezier != none {
        let x = offsets.at(individual.ind-id)
        let y = generations-y.at(individual.generation - 1) + 0.25
        let referred-individual = data.duplicates-individuals.at(individual.ind-id)
        let other-x = offsets.at(referred-individual.ind-id)
        let other-y = generations-y.at(referred-individual.generation - 1) + 0.25
        let middle-x = (x + other-x - individual.individual.bezier * (y - other-y))/2
        let middle-y = (y + other-y + individual.individual.bezier * (x - other-x))/2
        bezier((x, y), (other-x, other-y), (middle-x, middle-y), stroke: {(dash: "dashed"); draw-data.default-duplicate-curve-style; individual.individual.curve-style})
        if individual.individual.label != none {
          let angle = calc.atan2(x - other-x, y - other-y)
          let label-x = (x + other-x - 0.5 * individual.individual.bezier * (y - other-y))/2
          let label-y = (y + other-y + 0.5 * individual.individual.bezier * (x - other-x))/2
          let text-angle = angle
          if angle > 90deg and angle < 270deg {
            text-angle = 180deg - angle
          }
          let label = text(individual.individual.label, 5.5pt * draw-data.length-scale)
          if individual.individual.bezier * calc.cos(angle) < 0 {
            content((label-x + 0.05 * calc.sin(angle), label-y - 0.05 * calc.cos(text-angle)), label, anchor: "north", angle: text-angle)
          } else {
            content((label-x + 0.05 * calc.sin(angle), label-y + 0.05 * calc.cos(angle)), label, anchor: "base", angle: text-angle)
          }
        }
      }
    }

    for individual in iterate-individuals(data) {
      let x = offsets.at(individual.ind-id)
      let y = generations-y.at(individual.generation - 1)
      if individual.individual.type == "individual" {
        draw-individual(individual.individual, x, y, 0%, draw-data)
      } else if individual.individual.type == "duplicate" {
        let referred-individual = data.duplicates-individuals.at(individual.ind-id)
        draw-individual(referred-individual.individual, x, y, individual.individual.lightness, draw-data)
      }
    }

    if draw-data.draw != none {
      (draw-data.draw)()
    }
  })}
}
