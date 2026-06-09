// Test cases for Problem 0101
// First 2 cases are from LeetCode Examples

#import "../../helpers.typ": binarytree

#let cases = (
  (
    input: (root: binarytree((1, 2, 2, 3, 4, 4, 3))),
  ),
  (
    input: (root: binarytree((1, 2, 2, none, 3, none, 3))),
  ),
  // Additional test cases
  (input: (root: binarytree((1,)))),
  (input: (root: binarytree((1, 2, 2)))),
  (input: (root: binarytree((1, 2, 3)))),
  (input: (root: binarytree(()))),
)
