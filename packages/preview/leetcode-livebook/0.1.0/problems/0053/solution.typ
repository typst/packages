#import "../../helpers.typ": *

#let solution(nums) = {
  // Kadane's Algorithm
  // max_ending_here: maximum sum ending at current position
  // max_so_far: global maximum sum found so far

  let max-ending-here = nums.at(0)
  let max-so-far = nums.at(0)

  for i in range(1, nums.len()) {
    let num = nums.at(i)
    // Either extend previous subarray or start new one
    max-ending-here = calc.max(num, max-ending-here + num)
    max-so-far = calc.max(max-so-far, max-ending-here)
  }

  max-so-far
}
