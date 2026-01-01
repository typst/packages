// Test cases for Problem 0207
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (numCourses: 2, prerequisites: ((1, 0),)),
    explanation: [There are a total of 2 courses to take. To take course 1 you should have finished course 0. So it is possible.],
  ),
  (
    input: (numCourses: 2, prerequisites: ((1, 0), (0, 1))),
    explanation: [There are a total of 2 courses to take. To take course 1 you should have finished course 0, and to take course 0 you should also have finished course 1. So it is impossible.],
  ),
  // Additional test cases
  (input: (numCourses: 4, prerequisites: ((1, 0), (2, 1), (3, 2)))),
  (input: (numCourses: 1, prerequisites: ())),
)
