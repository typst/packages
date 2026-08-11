#import "../../helpers.typ": *

#let solution(l1, l2) = {
  let p = ()
  let carry = 0
  let curr1 = l1.head
  let curr2 = l2.head
  while (l1.get-val)(curr1) != none or (l2.get-val)(curr2) != none {
    let x = if (l1.get-val)(curr1) != none { (l1.get-val)(curr1) } else { 0 }
    let y = if (l2.get-val)(curr2) != none { (l2.get-val)(curr2) } else { 0 }
    let sum = x + y + carry
    carry = calc.floor(sum / 10)
    p.push(calc.rem(sum, 10))
    // Always advance to next (which may be none)
    curr1 = (l1.get-next)(curr1)
    curr2 = (l2.get-next)(curr2)
  }
  if carry > 0 {
    p.push(carry)
  }
  linkedlist(p)
}
