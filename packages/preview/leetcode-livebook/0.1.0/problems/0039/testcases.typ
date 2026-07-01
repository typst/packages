// Test cases for Problem 0039
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (candidates: (2, 3, 6, 7), target: 7),
    explanation: [2 and 3 are candidates, and 2 + 2 + 3 = 7. 7 is a candidate, and 7 = 7.],
  ),
  (
    input: (candidates: (2, 3, 5), target: 8),
  ),
  (
    input: (candidates: (2,), target: 1),
  ),
  // Additional test cases
  (input: (candidates: (1,), target: 1)),
  (input: (candidates: (1,), target: 2)),
  (input: (candidates: (1, 2), target: 4)),
)
