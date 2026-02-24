#import "../../helpers.typ": *

#let solution(n, trust) = {
  if n == 1 { return 1 }

  // Count in-degree and out-degree for each person
  // Judge: in-degree = n-1, out-degree = 0
  let in-degree = fill(0, n + 1)
  let out-degree = fill(0, n + 1)

  for t in trust {
    let (a, b) = t
    out-degree.at(a) += 1
    in-degree.at(b) += 1
  }

  // Find the judge
  for i in range(1, n + 1) {
    if in-degree.at(i) == n - 1 and out-degree.at(i) == 0 {
      return i
    }
  }

  -1
}
