#import "../../helpers.typ": *

#let solution(root, target-sum) = {
  if root.root == none {
    return false
  }

  let dfs(id, sum) = {
    if id == none {
      return false
    }
    let val = (root.get-val)(id)
    let left-id = (root.get-left)(id)
    let right-id = (root.get-right)(id)

    // Leaf node check
    if left-id == none and right-id == none {
      return val + sum == target-sum
    }

    dfs(left-id, val + sum) or dfs(right-id, val + sum)
  }

  dfs(root.root, 0)
}
