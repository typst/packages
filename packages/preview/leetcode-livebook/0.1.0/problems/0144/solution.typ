#import "../../helpers.typ": *

#let solution(root) = {
  if root.root == none {
    return ()
  }

  let stack = (root.root,)
  let output = ()

  while stack.len() > 0 {
    let id = stack.pop()
    output.push((root.get-val)(id))

    let right-id = (root.get-right)(id)
    let left-id = (root.get-left)(id)
    if right-id != none { stack.push(right-id) }
    if left-id != none { stack.push(left-id) }
  }
  output
}
