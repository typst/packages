// Test cases for Problem 0112
// All 3 cases are from LeetCode Examples
#import "../../helpers.typ": binarytree

#let cases = (
  (
    input: (
      root: binarytree((5, 4, 8, 11, none, 13, 4, 7, 2, none, none, none, 1)),
      target-sum: 22,
    ),
    explanation: [The root-to-leaf path with the target sum is shown.],
  ),
  (
    input: (root: binarytree((1, 2, 3)), target-sum: 5),
    explanation: [
      There are two root-to-leaf paths in the tree: \
      $(1 arrow.r 2)$: The sum is 3. \
      $(1 arrow.r 3)$: The sum is 4. \
      There is no root-to-leaf path with sum = 5.
    ],
  ),
  (
    input: (root: binarytree(()), target-sum: 0),
    explanation: [Since the tree is empty, there are no root-to-leaf paths.],
  ),
)
