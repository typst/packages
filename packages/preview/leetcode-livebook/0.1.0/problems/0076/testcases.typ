// Test cases for Problem 0076
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (s: "ADOBECODEBANC", t: "ABC"),
    explanation: [The minimum window substring "BANC" includes 'A', 'B', and 'C' from string t.],
  ),
  (
    input: (s: "a", t: "a"),
  ),
  (
    input: (s: "a", t: "aa"),
  ),
  // Additional test cases
  (input: (s: "aa", t: "aa")),
  (input: (s: "abc", t: "b")),
  (input: (s: "cabwefgewcwaefgcf", t: "cae")),
)
