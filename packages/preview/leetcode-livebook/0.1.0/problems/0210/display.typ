#import "../../helpers.typ": graph
#import "../../visualize.typ": visualize-graph

#let custom-display(input) = {
  let g = graph(input.numCourses, input.prerequisites, directed: true)
  [*Input:* #input.numCourses courses, #input.prerequisites.len() prerequisites]
  linebreak()
  visualize-graph(g)
}
