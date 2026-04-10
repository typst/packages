#import "../../helpers.typ": *

#let solution(target, nums) = {
  let n = nums.len()
  let left = 0
  let sum = 0
  let min-len = n + 1 // Impossible value

  for (right, num) in nums.enumerate() {
    sum += num

    while sum >= target {
      min-len = calc.min(min-len, right - left + 1)
      sum -= nums.at(left)
      left += 1
    }
  }

  if min-len == n + 1 { 0 } else { min-len }
}
