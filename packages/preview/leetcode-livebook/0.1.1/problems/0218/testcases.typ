// Test cases for Problem 0218
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (
      buildings: (
        (2, 9, 10),
        (3, 7, 15),
        (5, 12, 12),
        (15, 20, 10),
        (19, 24, 8),
      ),
    ),
    explanation: [The colored rectangles show the buildings. The red line traces the skyline contour, with key points marking height changes.],
  ),
  (
    input: (
      buildings: (
        (0, 2, 3),
        (2, 5, 3),
      ),
    ),
  ),
  // Additional test cases
  (
    input: (
      buildings: (
        (0, 5, 10),
      ),
    ),
  ),
  (
    input: (
      buildings: (
        (0, 10, 5),
        (2, 8, 10),
        (4, 6, 15),
      ),
    ),
  ),
  (
    input: (
      buildings: (
        (0, 3, 5),
        (3, 6, 5),
        (6, 9, 5),
      ),
    ),
  ),
)
