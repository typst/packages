// LeetCode Practice Workbook
// Start solving problems and test your solutions!

#import "@preview/leetcode-livebook:0.1.0": conf, solve

#show: conf.with(
  practice: true,
  // Uncomment to show reference solutions:
  // show-answer: true,
)

// Example: Solve "Two Sum" (Problem #1)
// Write your solution inside the code block, then compile to see test results!

#solve(1, code-block: ```typc
let solution(nums, target) = {
  // Your solution here
  // Hint: Use a dictionary to store seen values

  let seen = (:)
  for (i, num) in nums.enumerate() {
    let complement = target - num
    let key = str(complement)
    if key in seen {
      return (seen.at(key), i)
    }
    seen.insert(str(num), i)
  }
  none
}
```)

// Try more problems! Just add more #solve() calls:
// #solve(42)  // View problem without solution
// #solve(42, show-answer: true)  // View with reference solution
