#import "../../helpers.typ": *

#let solution(m, n) = {
  // C(m+n-2, m-1) = (m+n-2)! / ((m-1)! * (n-1)!)
  // Calculate using iterative multiplication to avoid overflow
  let result = 1

  for i in range(1, m) {
    result = result * (n - 1 + i) / i
  }

  int(result)
}
