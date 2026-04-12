#import "../../helpers.typ": graph
#import "../../visualize.typ": visualize-graph

#let custom-display(input) = {
  // Trust relationships: trust[i] = [a, b] means a trusts b
  // Note: people are labeled 1 to n, but graph uses 0-indexed
  let edges = input.trust.map(t => (t.at(0) - 1, t.at(1) - 1))
  let g = graph(input.n, edges, directed: true)
  [*Input:* #input.n people, #input.trust.len() trust relationships]
  linebreak()
  visualize-graph(g)
}
