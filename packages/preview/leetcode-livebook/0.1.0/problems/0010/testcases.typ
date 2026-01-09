// Test cases for Problem 0010
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (s: "aa", p: "a"),
    explanation: [`"a"` does not match the entire string `"aa"`.],
  ),
  (
    input: (s: "aa", p: "a*"),
    explanation: [`'*'` means zero or more of the preceding element, `'a'`. Therefore, by repeating `'a'` once, it becomes `"aa"`.],
  ),
  (
    input: (s: "ab", p: ".*"),
    explanation: [`".*"` means "zero or more (`*`) of any character (`.`)".],
  ),
  // Additional test cases
  (input: (s: "aab", p: "c*a*b")),
  (input: (s: "mississippi", p: "mis*is*p*.")),
  (input: (s: "ab", p: ".*c")),
  (input: (s: "ab", p: ".*c*")),
  (input: (s: "香蕉x牛奶", p: "香.*牛.")),
)
