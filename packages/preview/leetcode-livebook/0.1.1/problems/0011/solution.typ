#import "../../helpers.typ": *

#let solution(height) = {
  let n = height.len()
  let l = 0
  let r = n - 1
  let ans = 0
  while l < r {
    ans = calc.max(ans, calc.min(height.at(l), height.at(r)) * (r - l))
    if height.at(l) < height.at(r) {
      l += 1
    } else {
      r -= 1
    }
  }
  ans
}
