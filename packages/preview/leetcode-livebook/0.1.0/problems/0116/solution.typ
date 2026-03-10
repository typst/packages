#import "../../helpers.typ": *

#let solution(root) = {
  // Empty tree
  if root.root == none {
    return root
  }

  // We need to work with a mutable copy of nodes
  let nodes = root.nodes

  // BFS level by level
  let level = (root.root,)

  while level.len() > 0 {
    let next-level = ()

    // Connect nodes in current level
    for i in range(level.len()) {
      let id = level.at(i)

      // Set next pointer to the node on the right (or none if last in level)
      let next-id = if i + 1 < level.len() { level.at(i + 1) } else { none }

      // Modify the node to add next pointer
      let node = nodes.at(id)
      nodes.insert(id, (..node, next: next-id))

      // Collect children for next level
      let left-id = node.left
      let right-id = node.right
      if left-id != none { next-level.push(left-id) }
      if right-id != none { next-level.push(right-id) }
    }

    level = next-level
  }

  // Return a new tree structure with modified nodes
  (
    type: "binarytree",
    root: root.root,
    get-val: id => if id == none { none } else { nodes.at(id).val },
    get-left: id => if id == none { none } else { nodes.at(id).left },
    get-right: id => if id == none { none } else { nodes.at(id).right },
    get-next: id => if id == none { none } else { nodes.at(id).next },
    get-node: id => if id == none { none } else { nodes.at(id) },
    nodes: nodes,
  )
}
