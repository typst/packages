#import "../../helpers.typ": *

#let solution(candidates, target) = {
  let candidates = candidates.sorted()
  let n = candidates.len()
  let result = ()

  // Stack: (start, path, remaining)
  let stack = ((0, (), target),)

  while stack.len() > 0 {
    let (start, path, remaining) = stack.pop()

    if remaining == 0 {
      result.push(path)
      continue
    }

    // Push children in reverse order (so smallest processed first)
    let i = n - 1
    while i >= start {
      let num = candidates.at(i)
      if num <= remaining {
        stack.push((i, (..path, num), remaining - num))
      }
      i -= 1
    }
  }

  result
}
