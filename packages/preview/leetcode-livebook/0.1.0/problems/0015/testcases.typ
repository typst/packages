// Test cases for Problem 0015
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (nums: (-1, 0, 1, 2, -1, -4)),
    explanation: [
      `nums[0] + nums[1] + nums[2]` = $(-1) + 0 + 1 = 0$. \
      `nums[1] + nums[2] + nums[4]` = $0 + 1 + (-1) = 0$. \
      `nums[0] + nums[3] + nums[4]` = $(-1) + 2 + (-1) = 0$. \
      The distinct triplets are `[-1,0,1]` and `[-1,-1,2]`.
    ],
  ),
  (
    input: (nums: (0, 1, 1)),
    explanation: [The only possible triplet does not sum up to 0.],
  ),
  (
    input: (nums: (0, 0, 0)),
    explanation: [The only possible triplet sums up to 0.],
  ),
  // Additional test cases
  (input: (nums: range(-10, 20, step: 3))),
  (input: (nums: range(-10, 10))),
)
