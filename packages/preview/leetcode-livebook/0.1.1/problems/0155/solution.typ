#import "../../helpers.typ": *

// MinStack design problem - simulate method calls
#let solution(operations, args) = {
  let stack = ()
  let min-stack = ()
  let results = ()

  for (i, op) in operations.enumerate() {
    if op == "MinStack" {
      stack = ()
      min-stack = ()
      results.push(none)
    } else if op == "push" {
      let val = args.at(i).at(0)
      stack.push(val)
      if min-stack.len() == 0 or val <= min-stack.last() {
        min-stack.push(val)
      } else {
        min-stack.push(min-stack.last())
      }
      results.push(none)
    } else if op == "pop" {
      let _ = stack.pop()
      let _ = min-stack.pop()
      results.push(none)
    } else if op == "top" {
      results.push(stack.last())
    } else if op == "getMin" {
      results.push(min-stack.last())
    }
  }

  results
}
