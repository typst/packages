#import "../../helpers.typ": *

#let solution(head, n) = {
  let values = (head.values)()

  let remove-index = values.len() - n
  let filtered = ()
  for i in range(values.len()) {
    if i != remove-index {
      filtered.push(values.at(i))
    }
  }
  linkedlist(filtered)
}
