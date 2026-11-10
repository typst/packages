#import "../../helpers.typ": *

#let solution(list1, list2) = {
  let ans = ()
  let curr1 = list1.head
  let curr2 = list2.head
  while (list1.get-val)(curr1) != none or (list2.get-val)(curr2) != none {
    let v1 = (list1.get-val)(curr1)
    let v2 = (list2.get-val)(curr2)
    if v1 != none and (v2 == none or v1 < v2) {
      ans.push(v1)
      curr1 = (list1.get-next)(curr1)
    } else {
      ans.push(v2)
      curr2 = (list2.get-next)(curr2)
    }
  }
  linkedlist(ans)
}
