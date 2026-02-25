#import "../../helpers.typ": *

#let solution(root) = {
  // Empty tree is symmetric
  if root.root == none {
    return true
  }

  // Check if two subtrees are mirrors of each other
  let is-mirror(left-id, right-id) = {
    // Both none - symmetric
    if left-id == none and right-id == none {
      return true
    }
    // One none, one not - not symmetric
    if left-id == none or right-id == none {
      return false
    }

    let left-val = (root.get-val)(left-id)
    let right-val = (root.get-val)(right-id)

    // Values must match
    if left-val != right-val {
      return false
    }

    // Recursively check:
    // - left's left with right's right
    // - left's right with right's left
    let ll = (root.get-left)(left-id)
    let lr = (root.get-right)(left-id)
    let rl = (root.get-left)(right-id)
    let rr = (root.get-right)(right-id)

    is-mirror(ll, rr) and is-mirror(lr, rl)
  }

  let root-left = (root.get-left)(root.root)
  let root-right = (root.get-right)(root.root)
  is-mirror(root-left, root-right)
}
