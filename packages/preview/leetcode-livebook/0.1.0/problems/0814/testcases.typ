// Test cases for Problem 0814
// All 3 cases are from LeetCode Examples
#import "../../helpers.typ": binarytree

#let cases = (
  (
    input: (root: binarytree((1, none, 0, 0, 1))),
    explanation: [Only the red nodes satisfy the property "every subtree not containing a 1". The diagram on the right represents the answer.],
  ),
  (input: (root: binarytree((1, 0, 1, 0, 0, 0, 1)))),
  (input: (root: binarytree((1, 1, 0, 1, 1, 0, 1, 0)))),
)
