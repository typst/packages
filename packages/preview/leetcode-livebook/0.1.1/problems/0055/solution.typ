#import "../../helpers.typ": *

#let solution(nums) = {
  let n = nums.len()
  let max-reach = 0

  for (i, jump) in nums.enumerate() {
    if i > max-reach {
      return false
    }
    max-reach = calc.max(max-reach, i + jump)
    if max-reach >= n - 1 {
      return true
    }
  }

  true
}
