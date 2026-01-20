#import "../../helpers.typ": *

#let solution(nums, target) = {
  let lo = 0
  let hi = nums.len()

  while lo < hi {
    let mid = calc.quo(lo + hi, 2)
    if nums.at(mid) < target {
      lo = mid + 1
    } else {
      hi = mid
    }
  }

  lo
}
