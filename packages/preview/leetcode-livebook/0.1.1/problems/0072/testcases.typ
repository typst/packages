// Test cases for Problem 0072
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (word1: "horse", word2: "ros"),
    explanation: [horse → rorse (replace 'h' with 'r') → rose (remove 'r') → ros (remove 'e')],
  ),
  (
    input: (word1: "intention", word2: "execution"),
  ),
  // Additional test cases
  (input: (word1: "", word2: "")),
  (input: (word1: "a", word2: "")),
  (input: (word1: "", word2: "abc")),
  (input: (word1: "abc", word2: "abc")),
  (input: (word1: "abc", word2: "def")),
  (input: (word1: "kitten", word2: "sitting")),
)
