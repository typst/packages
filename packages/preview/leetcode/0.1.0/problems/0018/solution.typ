#import "../../helpers.typ": *

#let solution(nums, target) = {
  let nums = nums.sorted()
  let n = nums.len()
  let ans = ()
  for i in range(n) {
    if i > 0 and nums.at(i) == nums.at(i - 1) {
      continue
    }
    for j in range(i + 1, n) {
      if j > i + 1 and nums.at(j) == nums.at(j - 1) {
        continue
      }
      let l = j + 1
      let r = n - 1
      while l < r {
        let sum = nums.at(i) + nums.at(j) + nums.at(l) + nums.at(r)
        if sum < target {
          l += 1
        } else if sum > target {
          r -= 1
        } else {
          ans.push((nums.at(i), nums.at(j), nums.at(l), nums.at(r)))
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
  }
  ans
}
