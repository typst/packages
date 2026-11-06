#import "../../helpers.typ": graph-from-adj
#import "../../visualize.typ": visualize-graph

#let custom-display(input) = {
  let g = graph-from-adj(input.graph)
  [*Input:* #input.graph.len() nodes (adjacency list)]
  linebreak()
  visualize-graph(g)
}
