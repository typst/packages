#import "../../helpers.typ": *

#let solution(nums, target) = {
  let nums = nums.sorted()
  let n = nums.len()
  let ans = 2147483647
  for i in range(n) {
    if i > 0 and nums.at(i) == nums.at(i - 1) {
      continue
    }
    let l = i + 1
    let r = n - 1
    while l < r {
      let sum = nums.at(i) + nums.at(l) + nums.at(r)
      if sum < target {
        l += 1
      } else if sum > target {
        r -= 1
      } else {
        return target
      }
      if calc.abs(sum - target) < calc.abs(ans - target) {
        ans = sum
      }
    }
  }
  ans
}
