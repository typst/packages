#import "../../helpers.typ": *

#let solution(root, target-sum) = {
  if root.root == none {
    return ()
  }

  let dfs(id, sum, path) = {
    if id == none {
      return ()
    }
    let val = (root.get-val)(id)
    let left-id = (root.get-left)(id)
    let right-id = (root.get-right)(id)
    let new-path = (..path, val)

    // Leaf node check
    if left-id == none and right-id == none {
      if val + sum == target-sum {
        return (new-path,)
      }
      return ()
    }

    let left-results = dfs(left-id, val + sum, new-path)
    let right-results = dfs(right-id, val + sum, new-path)
    (..left-results, ..right-results)
  }

  dfs(root.root, 0, ())
}
