// Test cases for Problem 0009
// All 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (x: 121),
    explanation: [121 reads as 121 from left to right and from right to left.],
  ),
  (
    input: (x: -121),
    explanation: [From left to right, it reads -121. From right to left, it becomes 121-. Therefore it is not a palindrome.],
  ),
  (
    input: (x: 10),
    explanation: [Reads 01 from right to left. Therefore it is not a palindrome.],
  ),
)
