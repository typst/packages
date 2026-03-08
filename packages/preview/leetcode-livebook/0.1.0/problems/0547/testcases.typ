// Test cases for Problem 0547
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (isConnected: ((1, 1, 0), (1, 1, 0), (0, 0, 1))),
  ),
  (
    input: (isConnected: ((1, 0, 0), (0, 1, 0), (0, 0, 1))),
  ),
  // Additional test cases
  (input: (isConnected: ((1,),))),
  (input: (isConnected: ((1, 1), (1, 1)))),
  (
    input: (
      isConnected: ((1, 0, 0, 1), (0, 1, 1, 0), (0, 1, 1, 1), (1, 0, 1, 1)),
    ),
  ),
)
