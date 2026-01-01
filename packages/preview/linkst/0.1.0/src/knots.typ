#import "@preview/cetz:0.3.3"



//
// NODE
//

#let node(
  position,
  connect: (),
  name: none,
  label: none,
  label-offset: (0, 0),
) = (
  type: "node",
  position: position,
  connection-points: (),
  connect: connect,
  name: name,
  label: label,
  label-offset: label-offset,
)

#let draw-node(
  node,
  index,
  style,
) = {
  import cetz.draw: *
  import cetz.vector: *

  group({
    anchor("node", node.position)

    if(node.connection-points.len() == 2 and node.connect.len() == 0) {
      bezier(node.connection-points.at(0), node.connection-points.at(1), "node", stroke: style.stroke)
    } else {
      group({

        for connection in node.connect {
          if(connection.len() == 2) {
            bezier(node.connection-points.at(connection.at(0)), node.connection-points.at(connection.at(1)), "node", stroke: style.stroke)
          } else if(type(connection.at(2)) == str) {
            if(connection.at(2) == "spike") {
              line(node.connection-points.at(connection.at(0)), "node", node.connection-points.at(connection.at(1)))
            }
          } else if(connection.at(2)) {
            bezier(node.connection-points.at(connection.at(0)), node.connection-points.at(connection.at(1)), "node", stroke: style.stroke, mark: (end: "bar", scale: 0, pos: style.bridge-space))
            bezier(node.connection-points.at(connection.at(1)), node.connection-points.at(connection.at(0)), "node", stroke: style.stroke, mark: (end: "bar", scale: 0, pos: style.bridge-space))
          }
        }
      })
    }

    if(style.debug == true or style.debug == "nodes") {

      circle("node", radius: style.connection-size, stroke: (thickness: 0.01, paint: red))

      for (i, connection) in node.connection-points.enumerate() {
        set-style(content: (frame: "circle", stroke: none, fill: rgb("#85f16fd1"), padding: .05))
        content(connection, [#text([#i], size: 6pt)])
      }

      set-style(content: (frame: "circle", stroke: none, fill: rgb("#d45555a2"), padding: .05))
      if(node.name == none) {
        content(node.position, [#index])
      } else {
        content(node.position, [#node.name])
      }
    } else {
      anchor("node", add(node.position, node.label-offset))
      content("node", node.label)
    }
  })
}

//
// EDGE
//

#let edge(
  start-node,
  end-node,
  bezier: (),
  arc: (),
  arr: none,
  double: false,
) = (
  type: "edge",
  start-node: start-node,
  end-node: end-node,
  bezier: bezier,
  arc: arc,
  double: double,
  arr: arr,
)

#let edge-type(
  edge,
) = {
  let edge-type = "line"
  if(edge.bezier.len() > 0) {
    edge-type = "bezier"
    if(edge.bezier.len() == 1) {
      edge-type += "-quadratic"
    } else if(edge.bezier.len() == 2) {
      edge-type += "-cubic"
    }
  } else if(edge.arc.len() > 0) {
    edge-type = "arc"
  }

  return edge-type
}

#let get-node-index(nodes, selector) = {
  if(type(selector) == str) {
    for (index, node) in nodes.enumerate() {
      if(node.name == selector) {
        return index;
      }
    }
  } else {
    return selector
  }
}

#let edge-connections(
  edge,
  start-node,
  end-node,
  type,
  style,
) = {
  import cetz.draw: *
  import cetz.vector: *

  let dist-restrict(start, end) = scale(norm(sub(end, start)), style.connection-size)

  if(type == "line") {
    let start-dist-restrict = dist-restrict(start-node.position, end-node.position)
    return (
      add(start-node.position, start-dist-restrict),
      sub(end-node.position, start-dist-restrict)
    )
  } else if(type == "bezier-quadratic") {
    let start-dist-restrict = dist-restrict(start-node.position, edge.bezier.at(0))
    let end-dist-restrict = dist-restrict(end-node.position, edge.bezier.at(0))

    return (
      add(start-node.position, start-dist-restrict),
      add(end-node.position, end-dist-restrict),
    )
  } else if(type == "bezier-cubic") {
    let start-dist-restrict = dist-restrict(start-node.position, edge.bezier.at(0))
    let end-dist-restrict = dist-restrict(end-node.position, edge.bezier.at(1))

    return (
      add(start-node.position, start-dist-restrict),
      add(end-node.position, end-dist-restrict),
    )
  } else if(type == "arc") {
    let start-angle = angle2(edge.arc.center, start-node.position)
    let end-angle = angle2(edge.arc.center, end-node.position)

    let switch = edge.arc.switch

    let rad = len(sub(start-node.position, edge.arc.center))
    let ang = style.connection-size * 1rad
    if(switch) {
      ang *= -1
    }
    let start-pos = add(scale((calc.cos(start-angle - ang), calc.sin(start-angle - ang)), rad), edge.arc.center)
    let end-pos = add(scale((calc.cos(end-angle + ang), calc.sin(end-angle + ang)), rad), edge.arc.center)

    return (
      start-pos,
      end-pos,
    )
  }
}

#let draw-edge(
  edge,
  start-connection,
  end-connection,
  index,
  style,
  draw-type,
) = {
  import cetz.draw: *
  import cetz.vector: *

  group({
    if(type(edge.arr) == bool) {
      if(edge.arr) {
        set-style(mark: (start: "straight", pos: 50%, scale: 0.5, width: 0.3))
      } else {
        set-style(mark: (end: "straight", pos: 50%, scale: 0.5, width: 0.3))
      }
      let new-edge = edge
      new-edge.arr = none
      group({
        set-style(mark: none)
        draw-edge(
          new-edge,
          start-connection,
          end-connection,
          index,
          style,
          draw-type,
        )
      })
    }
  
    if(draw-type == "line") {
      if(edge.double) {
        
        let space-vec = rotate-z(scale(norm(sub(end-connection, start-connection)), 0.05), 90deg)
        
        line(
          name: "edge",
          add(start-connection, space-vec),
          add(end-connection, space-vec),
          stroke: style.stroke,
        )
        
        line(
          name: "edge",
          sub(start-connection, space-vec),
          sub(end-connection, space-vec),
          stroke: style.stroke,
        )
      } else {
        line(
          name: "edge",
          start-connection,
          end-connection,
          stroke: style.stroke,
        )
      }
    } else if(draw-type == "bezier-quadratic") {
      bezier(
        name: "edge",
        start-connection,
        end-connection,
        edge.bezier.at(0),
        stroke: style.stroke,
      )
  
      if(style.debug == true or style.debug == "edges") {
        line(start-connection, edge.bezier.at(0), end-connection, mark: none, stroke: (paint: maroon, thickness: 0.01, dash: "dashed"))
        circle(edge.bezier.at(0), radius: 0.03, fill: purple, stroke: none)
      }
    } else if(draw-type == "bezier-cubic") {
      bezier(
        name: "edge",
        start-connection,
        end-connection,
        edge.bezier.at(0),
        edge.bezier.at(1),
        stroke: style.stroke,
      )
  
      if(style.debug == true or style.debug == "edges") {
        line(start-connection, edge.bezier.at(0), edge.bezier.at(1), end-connection, mark: none, stroke: (paint: maroon, thickness: 0.01, dash: "dashed"))
        circle(edge.bezier.at(0), radius: 0.03, fill: purple, stroke: none)
        circle(edge.bezier.at(1), radius: 0.03, fill: purple, stroke: none)
      }
    } else if(draw-type == "arc") {
      let start-angle = angle2(edge.arc.center, start-connection)
      let end-angle = angle2(edge.arc.center, end-connection)
  
      let switch = edge.arc.switch

      if(edge.double) {
        let line-gap = 0.05
        
        arc(
          name: "edge",
          sub(start-connection, scale(norm(sub(start-connection, edge.arc.center)), line-gap)),
          start: start-angle,
          stop: end-angle + {if(switch) {360deg} else {0deg}},
          radius: len(sub(start-connection, edge.arc.center)) - line-gap,
        )
        
        arc(
          name: "edge",
          add(start-connection, scale(norm(sub(start-connection, edge.arc.center)), line-gap)),
          start: start-angle,
          stop: end-angle + {if(switch) {360deg} else {0deg}},
          radius: len(sub(start-connection, edge.arc.center)) + line-gap,
        )
      } else {
        arc(
          name: "edge",
          start-connection,
          start: start-angle,
          stop: end-angle + {if(switch) {360deg} else {0deg}},
          radius: len(sub(start-connection, edge.arc.center))
        )
      }
  
      if(style.debug == true or style.debug == "edges") {
        circle(edge.arc.center, radius: 0.03, fill: purple, stroke: none)
        line("edge.start", edge.arc.center, "edge.end", end-connection, mark: none, stroke: (paint: maroon, thickness: 0.01, dash: "dashed"))
      }
    }
    
    if(style.debug == true or style.debug == "edges") {
      set-style(content: (frame: "circle", stroke: none, fill: rgb("#0707da56"), padding: .05))
      content("edge.mid", [#index])
    }
  })
}



//
// KNOT
//

#let knot(
  ..items
) = (
  type: "knot",
  items: items.pos(),
  knots: items.pos().filter(e => e.type == "knot"),
  nodes: items.pos().filter(e => e.type == "node"),
  edges: items.pos().filter(e => e.type == "edge"),
)

#let knot-calls(
  ..items,
  index: 0,
  style: (
    stroke: auto,
    scale: 1,
    debug: false,
    connection-size: 0.3,
    bridge-space: 0.4,
  )
) = {

  let temp-style = style  

  let style = (
    stroke: auto,
    scale: 1,
    debug: false,
    connection-size: 0.3,
    bridge-space: 0.4,
  )

  if(type(temp-style) == dictionary) {
    for (key, value) in temp-style.pairs() {
      style.insert(key, value)
    }
  }

  let knot = knot(..items)
  if(knot.items.filter(e => e.type == "link").len() > 0) {
    knot = knot.items.at(0).knots.at(index)
  } else if(knot.knots.len() > 0) {
    knot = knot.knots.at(index)
  }

  let lerp(a, b, t) = {
    import cetz.vector: *

    return add(a, scale(sub(b, a), t))
  }

  let draw-nodes(knot) = {
    for (i, node) in knot.nodes.enumerate() {
      draw-node(
        node,
        i,
        style,
      )
    }
  }
  
  let compute-edges(knot) = {
    import cetz.vector: *
    
    let _edges = knot.edges

    for (i, edge) in knot.edges.enumerate() {
      let type = edge-type(edge)

      let start-node = knot.nodes.at(get-node-index(knot.nodes, edge.start-node))
      let end-node = knot.nodes.at(get-node-index(knot.nodes, edge.end-node))

      if(edge.bezier.len() > 0) {
        edge.bezier = edge.bezier.map(
          pos => {
            if(pos.len() == 2) {
              return add(
                rotate-z(scale(sub(start-node.position, end-node.position), pos.at(0)), calc.pi/2),
                lerp(start-node.position, end-node.position, 0.5 * pos.at(1) + 0.5),
              )
            } else if(pos.at(2)) {
              return add(start-node.position, (pos.at(0), pos.at(1)))
            }
          }
        )

        _edges.at(i) = edge
      }

      let (start-connection, end-connection) = edge-connections(edge, start-node, end-node, type, style)

      knot.nodes.at(get-node-index(knot.nodes, edge.start-node)).connection-points.push(start-connection)
      knot.nodes.at(get-node-index(knot.nodes, edge.end-node)).connection-points.push(end-connection)
    }
    
    knot.edges = _edges

    return knot;
  }

  let draw-edges(knot) = {
    for (i, edge) in knot.edges.enumerate() {
      let type = edge-type(edge)

      let start-node = knot.nodes.at(get-node-index(knot.nodes, edge.start-node))
      let end-node = knot.nodes.at(get-node-index(knot.nodes, edge.end-node))
      let (start-connection, end-connection) = edge-connections(edge, start-node, end-node, type, style)

      draw-edge(
        edge,
        start-connection,
        end-connection,
        i,
        style,
        type,
      )
    }
  }

  import cetz.draw: *

  scale(style.scale)

  knot = compute-edges(knot)

  draw-edges(knot)
  draw-nodes(knot)
}

#let draw-knot(
  ..items,
  index: 0,
  style: (
    stroke: auto,
    scale: 1,
    debug: false,
    connection-size: 0.3,
    bridge-space: 0.4,
  )
) = {
  cetz.canvas({
    knot-calls(
      ..items,
      index: index,
      style: style
    )
  })
}


//
// LINK
//

#let link(
  ..items
) = (
  type: "link",
  items: items.pos(),
  knots: items.pos().filter(e => (type(e) != "array" and e.type == "knot") or e.at(0).type == "knot")
)

#let draw-link(
  ..items,
  style: (
    stroke: auto,
    scale: 1,
    debug: false,
    connection-size: 0.3,
    bridge-space: 0.4,
  )
) = {

  let temp-style = style  

  let style = (
    stroke: auto,
    scale: 1,
    debug: false,
    connection-size: 0.3,
    bridge-space: 0.4,
  )

  if(type(temp-style) == "dictionary") {
    for (key, value) in temp-style.pairs() {
      style.insert(key, value)
    }
  }

  let link
  if(items.pos().find(e => e.type == "link") == none) {
    link = link(..items)
  } else {
    link = items.pos().find(e => e.type == "link")
  }
  let knots = link.knots.map(e => {
    if(type(e) == "array") {e}
    else {(e, (0, 0))}
  })

  cetz.canvas({
    import cetz.draw: *

    // Error :(
    /* intersections("i", {
      for (knot, pos) in knots {
        group({
          translate(pos)
          knot-calls(
            ..knot.items,
            style: style,
            index: 0,
          )
        })
      }
    })

    for-each-anchor("i", (name) => {
      circle("i." + name, radius: .1, fill: blue)
    }) */
  })

}