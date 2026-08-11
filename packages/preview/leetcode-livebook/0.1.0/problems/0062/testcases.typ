// Test cases for Problem 0062
// First 2 cases are from LeetCode Examples

#let cases = (
  (input: (m: 3, n: 7)),
  (
    input: (m: 3, n: 2),
    explanation: [
      From the top-left corner, there are a total of 3 ways to reach the bottom-right corner: \
      1. Right → Down → Down \
      2. Down → Down → Right \
      3. Down → Right → Down
    ],
  ),
  // Additional test cases
  (input: (m: 1, n: 1)),
  (input: (m: 7, n: 3)),
)
