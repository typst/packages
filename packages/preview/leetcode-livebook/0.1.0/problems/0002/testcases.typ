// Test cases for Problem 0002
// First 3 cases are from LeetCode Examples
#import "../../helpers.typ": linkedlist

#let cases = (
  (
    input: (l1: linkedlist((2, 4, 3)), l2: linkedlist((5, 6, 4))),
    explanation: [$342 + 465 = 807$.],
  ),
  (
    input: (l1: linkedlist((0,)), l2: linkedlist((0,))),
  ),
  (
    input: (
      l1: linkedlist((9, 9, 9, 9, 9, 9, 9)),
      l2: linkedlist((9, 9, 9, 9)),
    ),
  ),
  // Additional test cases
  (input: (l1: linkedlist((2, 4, 3)), l2: linkedlist((5, 6, 4, 9)))),
)
