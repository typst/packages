#import "../../helpers.typ": *

#let solution(head) = {
  let vals = (head.values)()
  let n = vals.len()
  for i in range(n) {
    if calc.rem(i, 2) == 1 {
      let tmp = vals.at(i - 1)
      vals.at(i - 1) = vals.at(i)
      vals.at(i) = tmp
    }
  }

  linkedlist(vals)
}
