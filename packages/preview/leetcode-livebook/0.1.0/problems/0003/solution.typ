#import "../../helpers.typ": *

#let solution(s) = {
  let s = s.clusters()
  let n = s.len()
  let ans = 1
  let l = 0
  let d = (:)
  for r in range(n) {
    let c = s.at(r)
    while c in d {
      let cl = s.at(l)
      let _ = d.remove(cl)
      l += 1
    }
    d.insert(c, 1)
    ans = calc.max(ans, r - l + 1)
  }
  ans
}
