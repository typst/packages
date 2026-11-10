// Test cases for Problem 0008
// All 5 cases are from LeetCode Examples

#let cases = (
  (
    input: (s: "42"),
  ),
  (
    input: (s: "   -042"),
    explanation: [Leading whitespace is read and ignored. `'-'` is read, so the result should be negative. `"042"` is read in, leading zeros ignored in the result.],
  ),
  (
    input: (s: "1337c0d3"),
    explanation: [`"1337"` is read in; reading stops because the next character is a non-digit.],
  ),
  (
    input: (s: "0-1"),
    explanation: [`"0"` is read in; reading stops because the next character is a non-digit.],
  ),
  (
    input: (s: "words and 987"),
    explanation: [Reading stops at the first non-digit character `'w'`.],
  ),
)
