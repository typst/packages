// Test cases for Problem 0004
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (nums1: (1, 3), nums2: (2,)),
    explanation: [Merged array = `[1,2,3]` and median is 2.],
  ),
  (
    input: (nums1: (1, 2), nums2: (3, 4)),
    explanation: [Merged array = `[1,2,3,4]` and median is $(2 + 3) / 2 = 2.5$.],
  ),
  // Additional test cases
  (input: (nums1: range(100, step: 3), nums2: range(200, step: 6))),
)
