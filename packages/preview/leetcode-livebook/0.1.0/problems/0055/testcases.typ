// Test cases for Problem 0055
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (nums: (2, 3, 1, 1, 4)),
    explanation: [Jump 1 step from index 0 to 1, then 3 steps to the last index.],
  ),
  (
    input: (nums: (3, 2, 1, 0, 4)),
    explanation: [You will always arrive at index 3 no matter what. Its maximum jump length is 0, which makes it impossible to reach the last index.],
  ),
  // Additional test cases
  (input: (nums: (0,))),
  (input: (nums: (2, 0, 0))),
)
