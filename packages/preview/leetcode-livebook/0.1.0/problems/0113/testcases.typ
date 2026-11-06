// Test cases for Problem 0113
// All 3 cases are from LeetCode Examples
#import "../../helpers.typ": binarytree

#let cases = (
  (
    input: (
      root: binarytree((5, 4, 8, 11, none, 13, 4, 7, 2, none, none, 5, 1)),
      target-sum: 22,
    ),
    explanation: [
      There are two paths whose sum equals `targetSum`: \
      $5 + 4 + 11 + 2 = 22$ \
      $5 + 8 + 4 + 5 = 22$
    ],
  ),
  (input: (root: binarytree((1, 2, 3)), target-sum: 5)),
  (input: (root: binarytree((1, 2)), target-sum: 0)),
)
