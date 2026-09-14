// Custom display for Problem 0112 - Path Sum
// Highlights the nodes on paths that sum to target

#import "../../visualize.typ": find-path-sum-paths, visualize-binarytree
#import "../../display.typ": display

#let custom-display(input) = {
  let tree = input.root
  let target = input.at("target-sum")

  // Find all paths that sum to target
  let paths = find-path-sum-paths(tree, target)

  // Collect all node IDs from matching paths
  let highlighted = ()
  for path in paths {
    for id in path {
      if id not in highlighted {
        highlighted.push(id)
      }
    }
  }

  // Display input info
  [*target-sum:* #target]
  linebreak()
  [*root:*]
  linebreak()

  // Render tree with highlighted path nodes
  visualize-binarytree(tree, highlighted-nodes: highlighted)
}
