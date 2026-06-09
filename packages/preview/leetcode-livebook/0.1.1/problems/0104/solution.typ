#import "../../helpers.typ": *

#let solution(root) = {
  // Empty tree check
  if root.root == none {
    return 0
  }

  let max-depth(id) = {
    if id == none {
      return 0
    }
    let left = max-depth((root.get-left)(id))
    let right = max-depth((root.get-right)(id))
    1 + calc.max(left, right)
  }

  max-depth(root.root)
}
