// Test cases for Problem 0001
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (nums: (2, 7, 11, 15), target: 9),
    explanation: [Because `nums[0]` + `nums[1]` == 9, we return `[0, 1]`.],
  ),
  (
    input: (nums: (3, 2, 4), target: 6),
  ),
  (
    input: (nums: (3, 3), target: 6),
  ),
  // Additional test cases
  (input: (nums: (0, 0), target: 1)),
  (input: (nums: range(1, 100, step: 3), target: 191)),
)
