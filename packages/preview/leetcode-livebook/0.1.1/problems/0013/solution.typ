#import "../../helpers.typ": *

#let solution(s) = {
  let s = s.clusters()
  let n = s.len()
  let d = ("I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000)
  let ans = 0
  for i in range(n) {
    if i < n - 1 and d.at(s.at(i)) < d.at(s.at(i + 1)) {
      ans -= d.at(s.at(i))
    } else {
      ans += d.at(s.at(i))
    }
  }
  ans
}
