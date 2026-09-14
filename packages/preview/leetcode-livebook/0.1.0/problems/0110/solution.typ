#import "../../helpers.typ": *

#let solution(root) = {
  let balanced(id) = {
    if id == none {
      return (true, 0)
    }
    let left = balanced((root.get-left)(id))
    let right = balanced((root.get-right)(id))
    (
      left.at(0) and right.at(0) and calc.abs(left.at(1) - right.at(1)) <= 1,
      calc.max(left.at(1), right.at(1)) + 1,
    )
  }

  if root.root == none {
    return true
  }
  balanced(root.root).at(0)
}
