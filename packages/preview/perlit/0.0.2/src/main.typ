#import "@preview/cetz:0.4.2": canvas, draw

#import "draw/node.typ": draw_nodes, parse_nodes
#import "draw/edge.typ": draw_edges, parse_edges
#import "draw/label.typ": draw_labels

#import "utils/helpers.typ": array_to_dict

#let render(nodes, edges, ..args) = {
  draw_edges(edges, nodes, ..args)
  draw_nodes(nodes, ..args)
  draw_labels(edges, ..args)
}

/// Draws an Obisdian graph
///
/// ```typc
/// draw(json("/example.canvas"))
///
/// draw(
///   json("/testgraph.canvas"),
///	  velocity: 0.1,
///	  curve: false,
///	  file-handlers: (
///	    "jpg": (path: str, length: length, ..args) => {
///	      image(path, width: length)
///	    },
///   ),
///	)
///
/// ```
///
/// - data (dictionary): Parsed JSON Data of an Obsidian Graph.
/// - velocity (float): Amount at which an edge "leaves" a node
/// -> content
#let draw_graph(
  data,
  velocity: 0.1,
  nested: false,
  length: length,
  scale: 1,
  ..args,
) = {
  let safe_velocity = if velocity == 0 { 0.00000001 } else { velocity }

  let nodes = array_to_dict(parse_nodes(data.nodes), "id")
  let edges = array_to_dict(
    parse_edges(
      data.edges,
      nodes,
      velocity: safe_velocity,
    ),
    "id",
  )


  layout(ly => {
    let nomalized_length = if nested { length } else { ly.width } * scale
    canvas(
      length: nomalized_length,
      debug: false,
      render(nodes, edges, length: nomalized_length, ..args),
    )
  })
}


