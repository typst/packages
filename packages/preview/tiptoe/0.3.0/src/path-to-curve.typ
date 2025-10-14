


#let transform(a, b, mapper) = array.zip(a, b, exact: true).map(mapper)
#let add(a, b) = transform(a, b, ((x,y)) => x + y)
#let subtract(a, b) = transform(a, b, ((x,y)) => x - y)
#let multiply(a, c) = a.map(x => x * c)

#let path-to-curve(
  ..vertices,
  stroke: stroke(),
  fill: none,
  fill-rule: "even-odd",
  closed: false
) = {
  // place(std.path(..vertices, stroke: stroke, fill: fill, closed: closed))
  vertices = vertices.pos()
  if vertices.len() == 0 { return }

  let is-vertex(v) = (type(v) == array and type(v.first()) != array) or v.len() == 1
  let extract-vertex(v) = {
    if is-vertex(v) { 
      if v.len() == 2 {v}
      else { v.first() }
    } else { v.first() }
  }
  
  let curve-elements = ()
  let start-in = none
  let out = none
  for vertex in vertices {
    let v = extract-vertex(vertex)
    
    if is-vertex(vertex) {
      if out == none {
        curve-elements.push((v,))
      } else {
        curve-elements.push((out, none, v))
        out = none
      }
    } else {
      if vertex.len() == 2 {
        vertex.push(multiply(vertex.at(1), -1))
        // now its definitely a "cubic"!
      }
      if curve-elements.len() == 0 {
        curve-elements.push((v,))
        start-in = add(v, vertex.at(1))
      } else if out == none {
        curve-elements.push((auto, add(v, vertex.at(1)), v))
        out = auto
      } else {
        curve-elements.push((out, add(v, vertex.at(1)), v))
      }
      out = add(v, vertex.at(2))
    }
  }

  let to-curve-element(x) = {
    if x.len() == 1 { curve.line(..x) }
    else if x.len() == 2 { curve.quad(..x) }
    else if x.len() == 3 { curve.cubic(..x) }
  }
  curve-elements = curve-elements.map(to-curve-element)
  let start = extract-vertex(vertices.first())
  if closed {
    if out != none or start-in != none {
      curve-elements.push(curve.cubic(out, start-in, start))
    }
    curve-elements.push(curve.close(mode: "straight"))
  }
  
  std.curve(
    curve.move(start),
    fill: fill, stroke: stroke,
    ..curve-elements,
    fill-rule: fill-rule
    // stroke: yellow + .5pt
  )
}
