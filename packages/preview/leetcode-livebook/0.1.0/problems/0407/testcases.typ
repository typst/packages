// Test cases for Problem 0407
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (
      heightMap: (
        (1, 4, 3, 1, 3, 2),
        (3, 2, 1, 3, 2, 4),
        (2, 3, 3, 2, 3, 1),
      ),
    ),
    explanation: [After the rain, water is trapped between the blocks. We have two small ponds 1 and 3 units trapped. The total volume of water trapped is 4.],
  ),
  (
    input: (
      heightMap: (
        (3, 3, 3, 3, 3),
        (3, 2, 2, 2, 3),
        (3, 2, 1, 2, 3),
        (3, 2, 2, 2, 3),
        (3, 3, 3, 3, 3),
      ),
    ),
  ),
  // Additional test cases
  (
    input: (
      heightMap: (
        (1, 2, 1),
        (2, 0, 2),
        (1, 2, 1),
      ),
    ),
  ),
  (
    input: (
      heightMap: (
        (1, 1, 1),
        (1, 1, 1),
        (1, 1, 1),
      ),
    ),
  ),
  (
    input: (
      heightMap: (
        (1, 2),
        (2, 1),
      ),
    ),
  ),
)
