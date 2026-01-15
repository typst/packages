#import "../../helpers.typ": *

#let solution(s) = {
  let s = s.clusters()
  let t = ()
  for c in s {
    t.push("$")
    t.push(c)
  }
  t.push("$")
  let n = t.len()
  let a = fill(0, n)
  let l = 0
  let r = -1
  for i in range(n) {
    let j = if i > r { 1 } else { calc.min(a.at(l + r - i), r - i + 1) }
    while i >= j and i + j < n and t.at(i - j) == t.at(i + j) {
      j = j + 1
    }
    a.at(i) = j
    j = j - 1
    if i + j > r {
      l = i - j
      r = i + j
    }
  }

  let ans = 0
  let hi = 0
  for i in range(n) {
    if a.at(i) > hi {
      ans = i
      hi = a.at(i)
    }
  }

  let ret = ()
  for i in range(ans - hi + 1, ans + hi) {
    if t.at(i) != "$" {
      ret.push(t.at(i))
    }
  }

  ret.join()
}
