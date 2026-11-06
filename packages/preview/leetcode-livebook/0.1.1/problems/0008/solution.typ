#import "../../helpers.typ": *

#let solution(s) = {
  let numerics = "0123456789"
  let d = (
    "0": 0,
    "1": 1,
    "2": 2,
    "3": 3,
    "4": 4,
    "5": 5,
    "6": 6,
    "7": 7,
    "8": 8,
    "9": 9,
  )
  let s = s.clusters()
  let n = s.len()
  let i = 0
  let sign = 1
  let ans = 0
  while i < n and s.at(i) == " " {
    i += 1
  }
  if i < n and s.at(i) == "-" {
    sign = -1
    i += 1
  } else if i < n and s.at(i) == "+" {
    i += 1
  }
  while i < n and s.at(i) in numerics {
    if ans > 214748364 or (ans == 214748364 and d.at(s.at(i)) > 7) {
      if sign == 1 {
        return 2147483647
      } else {
        return -2147483648
      }
    }
    ans = ans * 10 + d.at(s.at(i))
    i += 1
  }
  ans * sign
}
