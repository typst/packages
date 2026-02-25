// Test cases for Problem 0210
// First 3 cases are from LeetCode Examples

#let cases = (
  (
    input: (numCourses: 2, prerequisites: ((1, 0),)),
    explanation: [There are a total of 2 courses to take. To take course 1 you should have finished course 0. So the correct course order is `[0,1]`.],
  ),
  (
    input: (numCourses: 4, prerequisites: ((1, 0), (2, 0), (3, 1), (3, 2))),
    explanation: [There are a total of 4 courses to take. To take course 3 you should have finished both courses 1 and 2. Both courses 1 and 2 should be taken after you finished course 0. So one correct course order is `[0,1,2,3]`. Another correct ordering is `[0,2,1,3]`.],
  ),
  (input: (numCourses: 1, prerequisites: ())),
  // Additional test case: cycle
  (input: (numCourses: 2, prerequisites: ((1, 0), (0, 1)))),
)
