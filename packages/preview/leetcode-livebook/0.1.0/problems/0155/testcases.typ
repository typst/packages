// Test cases for Problem 0155
// This is a design problem with method calls
// All cases are from LeetCode Examples

#let cases = (
  (
    input: (
      operations: (
        "MinStack",
        "push",
        "push",
        "push",
        "getMin",
        "pop",
        "top",
        "getMin",
      ),
      args: ((), (-2,), (0,), (-3,), (), (), (), ()),
    ),
    explanation: [
      `MinStack minStack = new MinStack();` \
      `minStack.push(-2);` \
      `minStack.push(0);` \
      `minStack.push(-3);` \
      `minStack.getMin();` // return -3 \
      `minStack.pop();` \
      `minStack.top();` // return 0 \
      `minStack.getMin();` // return -2
    ],
  ),
)
