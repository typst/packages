#import "../../helpers.typ": *

#let solution(x) = {
  if x < 2 {
    return x
  }

  let lo = 1
  let hi = x / 2

  while lo <= hi {
    let mid = (lo + hi) / 2
    let sq = mid * mid

    if sq == x {
      return mid
    } else if sq < x {
      lo = mid + 1
    } else {
      hi = mid - 1
    }
  }

  hi
}
