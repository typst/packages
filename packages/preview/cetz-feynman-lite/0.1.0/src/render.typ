#import "@preview/cetz:0.5.2"
#import "paths.typ": offset-point, add, mul
#import "annotations.typ": momentum-data, arrow-data
#import "strokes.typ": stroke-points
#import "crossings.typ": crossing-parts
#let arrowhead(tip, direction, stroke) = {
  import cetz.draw: line
  let normal = (-direction.at(1), direction.at(0))
  let back = add(tip, mul(direction, -0.13))
  line(add(back, mul(normal, 0.06)), tip, add(back, mul(normal, -0.06)), stroke: stroke)
}
/// Draw an existing diagram-data result as CeTZ drawing elements.
/// -> array
#let draw-diagram(
  /// The dictionary returned by diagram-data.
  /// -> dictionary
  result,
  /// Crossing gap half-length in canvas units; zero disables gaps.
  /// -> int | float
  crossing-gap: 0,
) = {
  import cetz.draw: *
  let sampled = (:)
  for route in result.routes { sampled.insert(route.id, stroke-points(route)) }
  let parts = crossing-parts(result, sampled, gap: crossing-gap)
  for route in result.routes {
    let st = route.style
    let stroke = (paint: st.paint, thickness: st.thickness,
      dash: if st.line == "dashed" {"dashed"} else if st.line == "dotted" {"dotted"} else {"solid"})
    for points in parts.at(route.id) { line(..points, stroke: stroke) }
    if st.line == "double" { line(..stroke-points(route, offset-sign: -1), stroke: stroke) }
    if route.arrow != "none" {
      let a = arrow-data(route)
      arrowhead(a.tip, a.direction, (paint: st.paint, thickness: st.thickness))
    }
  }
  for v in result.vertices {
    let p = result.positions.at(v.id)
    if ("dot", "circle", "blob").contains(v.marker) {
      circle(p, radius: v.size, fill: if v.marker == "circle" {none} else {v.fill}, stroke: if v.marker == "dot" {none} else {v.stroke})
    } else if v.marker == "cross" {
      line(add(p, (-v.size, -v.size)), add(p, (v.size, v.size)), stroke: v.stroke)
      line(add(p, (-v.size, v.size)), add(p, (v.size, -v.size)), stroke: v.stroke)
    }
    if v.label != none { content(add(p, v.label-offset), v.label) }
  }
  for route in result.routes {
    if route.label != none { content(offset-point(route.table, route.label-at, route.label-offset), route.label) }
    let m = momentum-data(route)
    if m != none {
      let stroke = (paint: route.style.paint, thickness: 0.7pt)
      line(..m.points, stroke: stroke)
      arrowhead(m.tip, m.direction, stroke)
      if m.label != none { content(m.label-position, m.label) }
    }
  }
}
/// Render existing diagram data in a standalone CeTZ canvas.
/// -> content
#let render(
  /// The dictionary returned by diagram-data.
  /// -> dictionary
  result,
  /// The physical length of one canvas unit.
  /// -> length
  unit: 9mm,
  /// Crossing gap half-length in canvas units; zero disables gaps.
  /// -> int | float
  crossing-gap: 0,
) = cetz.canvas(length: unit, draw-diagram(result, crossing-gap: crossing-gap))
