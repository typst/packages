// Test cases for Problem 0785
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (graph: ((1, 2, 3), (0, 2), (0, 1, 3), (0, 2))),
    explanation: [There is no way to partition the nodes into two independent sets such that every edge connects a node in one and a node in the other.],
  ),
  (
    input: (graph: ((1, 3), (0, 2), (1, 3), (0, 2))),
    explanation: [We can partition the nodes into two sets: `{0, 2}` and `{1, 3}`.],
  ),
  // Additional test cases
  (input: (graph: ((), ()))),
  (input: (graph: ((1,), (0,)))),
)
