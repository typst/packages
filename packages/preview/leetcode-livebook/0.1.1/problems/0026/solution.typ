#import "../../helpers.typ": *

#let solution(nums) = {
  let ans = ()
  for i in range(nums.len()) {
    if i > 0 and nums.at(i) == nums.at(i - 1) {
      continue
    }
    ans.push(nums.at(i))
  }
  ans
}
