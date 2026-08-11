#import "../../helpers.typ": *

#let solution(x) = {
  let ans = 0
  let sign = if x >= 0 { 0 } else { -1 }
  if x == -2147483648 {
    return 0
  }

  x = calc.abs(x)
  while x != 0 {
    let pop = calc.rem(x, 10)
    x = calc.floor(x / 10)
    if ans > 214748364 or (ans == 214748364 and pop - sign > 7) {
      return 0
    }
    ans = ans * 10 + pop
  }
  ans * (2 * sign + 1)
}
