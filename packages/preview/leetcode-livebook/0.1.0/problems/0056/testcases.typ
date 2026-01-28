// Test cases for Problem 0056
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (intervals: ((1, 3), (2, 6), (8, 10), (15, 18))),
    explanation: [Since intervals `[1,3]` and `[2,6]` overlap, merge them into `[1,6]`.],
  ),
  (
    input: (intervals: ((1, 4), (4, 5))),
    explanation: [Intervals `[1,4]` and `[4,5]` are considered overlapping.],
  ),
  (
    input: (intervals: ((4, 7), (1, 4))),
    explanation: [Intervals `[1,4]` and `[4,7]` are considered overlapping.],
  ),
  // Additional test cases
  (input: (intervals: ((1, 4), (2, 3)))),
)
