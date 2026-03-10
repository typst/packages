#import "../../helpers.typ": *

#let solution(n) = {
  let current = (("", 0, 0),)
  for i in range(2 * n) {
    let next = ()
    for s in current {
      if s.at(1) < n {
        next.push((s.at(0) + "(", s.at(1) + 1, s.at(2)))
      }
      if s.at(2) < s.at(1) {
        next.push((s.at(0) + ")", s.at(1), s.at(2) + 1))
      }
    }
    current = next
  }
  current.map(s => s.at(0))
  none
}
