#import "../../helpers.typ": *

#let solution(head) = {
  if head == none or head.nodes.len() == 0 {
    return head
  }

  // Get values and reverse
  let values = (head.values)()
  let reversed = values.rev()

  // Build new linked list
  linkedlist(reversed)
}
