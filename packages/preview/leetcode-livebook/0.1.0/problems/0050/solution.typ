#import "../../helpers.typ": *

#let solution(x, n) = {
  if n == 0 {
    return 1
  }
  if n < 0 {
    return 1 / solution(x, -n)
  }
  let ans = 1
  while n > 0 {
    if calc.rem(n, 2) == 1 {
      ans *= x
    }
    x *= x
    n = calc.floor(n / 2)
  }
  ans
}
