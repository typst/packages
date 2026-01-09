// Test cases for Problem 0116
// First 2 cases are from LeetCode Examples
#import "../../helpers.typ": binarytree

#let cases = (
  (
    input: (root: binarytree((1, 2, 3, 4, 5, 6, 7))),
    explanation: [Given the above perfect binary tree (Figure A), your function should populate each next pointer to point to its next right node, just like in Figure B. The serialized output is in level order as connected by the next pointers, with `'#'` signifying the end of each level.],
  ),
  (input: (root: binarytree(()))),
  // Additional test cases
  (input: (root: binarytree((1,)))),
  (input: (root: binarytree((1, 2, 3)))),
)
