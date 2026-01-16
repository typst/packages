// Test cases for Problem 0049
// All 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (strs: ("eat", "tea", "tan", "ate", "nat", "bat")),
    explanation: [
      - There is no string in `strs` that can be rearranged to form `"bat"`. \
      - The strings `"nat"` and `"tan"` are anagrams as they can be rearranged to form each other. \
      - The strings `"ate"`, `"eat"`, and `"tea"` are anagrams as they can be rearranged to form each other.
    ],
  ),
  (input: (strs: ("",))),
  (input: (strs: ("a",))),
)
