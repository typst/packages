#import "../../helpers.typ": *

#let solution(nums) = {
  let nums = nums.sorted()
  let n = nums.len()
  let ans = ()
  for i in range(n) {
    if i > 0 and nums.at(i) == nums.at(i - 1) {
      continue
    }
    let l = i + 1
    let r = n - 1
    while l < r {
      let sum = nums.at(i) + nums.at(l) + nums.at(r)
      if sum < 0 {
        l += 1
      } else if sum > 0 {
        r -= 1
      } else {
        ans.push((nums.at(i), nums.at(l), nums.at(r)))
        while l < r and nums.at(l) == nums.at(l + 1) {
          l += 1
        }
        while l < r and nums.at(r) == nums.at(r - 1) {
          r -= 1
        }
        l += 1
        r -= 1
      }
    }
  }
  ans
}
