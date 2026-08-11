#import "../../helpers.typ": *

// Recursive solution with return value accumulation
#let solution(nums) = {
  let permute(remaining) = {
    if remaining.len() == 0 {
      return ((),)
    }
    if remaining.len() == 1 {
      return (remaining,)
    }

    let result = ()
    for (i, num) in remaining.enumerate() {
      let rest = remaining.slice(0, i) + remaining.slice(i + 1)
      let sub-perms = permute(rest)
      for perm in sub-perms {
        result.push((num,) + perm)
      }
    }
    result
  }

  permute(nums)
}

// Stack-based iterative solution (avoids return value copy overhead)
#let solution-extra(nums) = {
  let result = ()

  // Stack state: (remaining, path, idx)
  // remaining: elements left to permute
  // path: current permutation being built
  // idx: next index to try in remaining
  let stack = ((nums, (), 0),)

  while stack.len() > 0 {
    let (remaining, path, idx) = stack.pop()

    if remaining.len() == 0 {
      result.push(path)
      continue
    }

    // Skip if idx out of bounds
    if idx >= remaining.len() {
      continue
    }

    // Push next sibling choice first (will be processed later)
    if idx + 1 < remaining.len() {
      stack.push((remaining, path, idx + 1))
    }

    // Process current choice: pick remaining[idx]
    let num = remaining.at(idx)
    let rest = remaining.slice(0, idx) + remaining.slice(idx + 1)
    stack.push((rest, path + (num,), 0))
  }

  result
}
