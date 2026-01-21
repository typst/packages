// Test cases for Problem 0016
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (nums: (-1, 2, 1, -4), target: 1),
    explanation: [The sum that is closest to the target is 2. $(-1) + 2 + 1 = 2$.],
  ),
  (
    input: (nums: (0, 0, 0), target: 1),
    explanation: [The sum that is closest to the target is 0. $0 + 0 + 0 = 0$.],
  ),
  // Additional test cases
  (input: (nums: (0, 1, 1), target: 2)),
  (input: (nums: range(-10, 20, step: 3), target: 20)),
  (input: (nums: range(-10, 10), target: 30)),
)
