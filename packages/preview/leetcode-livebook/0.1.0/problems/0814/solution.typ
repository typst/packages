#import "../../helpers.typ": *

#let solution(root) = {
  if root.root == none {
    return root
  }

  // Returns (should-keep, new-tree) where new-tree has pruned nodes
  // Since we can't really delete nodes, we'll rebuild the tree with only kept nodes
  let prune(id) = {
    if id == none {
      return (false, none)
    }

    let val = (root.get-val)(id)
    let left-id = (root.get-left)(id)
    let right-id = (root.get-right)(id)

    let (keep-left, _) = prune(left-id)
    let (keep-right, _) = prune(right-id)

    // Keep this node if val != 0 or any child is kept
    let keep = val != 0 or keep-left or keep-right
    (keep, none)
  }

  // Actually rebuild the tree by collecting kept values in level order
  // This is a simplified approach - we mark nodes to prune and rebuild
  let collect-kept(id) = {
    if id == none {
      return ()
    }

    let val = (root.get-val)(id)
    let left-id = (root.get-left)(id)
    let right-id = (root.get-right)(id)

    let left-vals = collect-kept(left-id)
    let right-vals = collect-kept(right-id)

    // If no children and val == 0, prune (return empty)
    if left-vals.len() == 0 and right-vals.len() == 0 and val == 0 {
      return ()
    }

    // Return this subtree as nested structure for reconstruction
    ((val: val, left: left-vals, right: right-vals),)
  }

  let nested = collect-kept(root.root)
  if nested.len() == 0 {
    return binarytree(())
  }

  // Convert nested result back to level-order array
  let to-level-order(nested) = {
    if nested.len() == 0 {
      return ()
    }
    let node = nested.at(0)
    let result = (node.val,)
    let queue = ((node.left, node.right),)
    let qi = 0

    while qi < queue.len() {
      let (left, right) = queue.at(qi)
      qi += 1

      if left.len() > 0 {
        let ln = left.at(0)
        result.push(ln.val)
        queue.push((ln.left, ln.right))
      } else {
        result.push(none)
      }

      if right.len() > 0 {
        let rn = right.at(0)
        result.push(rn.val)
        queue.push((rn.left, rn.right))
      } else {
        result.push(none)
      }
    }

    // Trim trailing nones
    while result.len() > 0 and result.at(-1) == none {
      let _ = result.pop()
    }
    result
  }

  binarytree(to-level-order(nested))
}
