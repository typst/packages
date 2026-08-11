// Test cases for Problem 0023
// All 3 cases are from LeetCode Examples
#import "../../helpers.typ": linkedlist

#let cases = (
  (
    input: (
      lists: (linkedlist((1, 4, 5)), linkedlist((1, 3, 4)), linkedlist((2, 6))),
    ),
    explanation: [
      The linked-lists are: `1->4->5`, `1->3->4`, `2->6`. \
      Merging them into one sorted linked list: `1->1->2->3->4->4->5->6`.
    ],
  ),
  (input: (lists: ())),
  (input: (lists: (linkedlist(()),))),
)
