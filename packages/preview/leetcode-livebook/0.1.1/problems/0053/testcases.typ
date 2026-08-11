// Test cases for Problem 0053
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (nums: (-2, 1, -3, 4, -1, 2, 1, -5, 4)),
    explanation: [The subarray `[4,-1,2,1]` has the largest sum 6.],
  ),
  (
    input: (nums: (1,)),
    explanation: [The subarray `[1]` has the largest sum 1.],
  ),
  (
    input: (nums: (5, 4, -1, 7, 8)),
    explanation: [The subarray `[5,4,-1,7,8]` has the largest sum 23.],
  ),
  // Additional test cases
  (input: (nums: (-1,))),
  (input: (nums: (-2, -1))),
  (input: (nums: (1, 2, 3, 4, 5))),
  (input: (nums: (-1, -2, -3, -4))),
)
