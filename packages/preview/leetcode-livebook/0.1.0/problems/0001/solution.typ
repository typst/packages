#import "../../helpers.typ": *

#let solution(arr, target) = {
  let d = (:)
  let ans = (-1, -1)
  for (i, num) in arr.enumerate() {
    if str(target - num) in d {
      ans = (d.at(str(target - num)), i)
      break
    } else {
      d.insert(str(num), i)
    }
  }

  ans
}
