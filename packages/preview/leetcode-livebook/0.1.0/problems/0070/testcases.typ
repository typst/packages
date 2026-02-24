// Test cases for Problem 0070
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (n: 2),
    explanation: [
      There are two ways to climb to the top: \
      1. 1 step + 1 step \
      2. 2 steps
    ],
  ),
  (
    input: (n: 3),
    explanation: [
      There are three ways to climb to the top: \
      1. 1 step + 1 step + 1 step \
      2. 1 step + 2 steps \
      3. 2 steps + 1 step
    ],
  ),
  // Additional test cases
  (input: (n: 1)),
  (input: (n: 4)),
  (input: (n: 5)),
  (input: (n: 10)),
  (input: (n: 20)),
  (input: (n: 45)),
)
