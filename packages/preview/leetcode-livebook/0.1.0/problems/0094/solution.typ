#import "../../helpers.typ": *

#let solution(root) = {
  if root.root == none {
    return ()
  }

  let result = ()
  let stack = ()
  let curr = root.root

  while curr != none or stack.len() > 0 {
    while curr != none {
      stack.push(curr)
      curr = (root.get-left)(curr)
    }
    curr = stack.pop()
    result.push((root.get-val)(curr))
    curr = (root.get-right)(curr)
  }
  result
}
