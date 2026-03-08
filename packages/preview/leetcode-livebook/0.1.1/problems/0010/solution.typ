#import "../../helpers.typ": *

#let solution(s, p) = {
  let s = s.clusters()
  let p = p.clusters()
  let m = s.len()
  let n = p.len()
  let dp = fill(fill(false, n + 1), m + 1)
  dp.at(0).at(0) = true
  for i in range(0, m + 1) {
    for j in range(1, n + 1) {
      if p.at(j - 1) != "*" {
        if i > 0 and (p.at(j - 1) == "." or p.at(j - 1) == s.at(i - 1)) {
          dp.at(i).at(j) = dp.at(i - 1).at(j - 1)
        }
      } else {
        if j >= 2 {
          dp.at(i).at(j) = dp.at(i).at(j) or dp.at(i).at(j - 2)
        }
        if (
          i >= 1
            and j >= 2
            and (p.at(j - 2) == "." or p.at(j - 2) == s.at(i - 1))
        ) {
          dp.at(i).at(j) = dp.at(i).at(j) or dp.at(i - 1).at(j)
        }
      }
    }
  }
  dp.at(m).at(n)
}
