#import "../../helpers.typ": *

#let solution(strs) = {
  let strs = strs.map(x => x.clusters())
  let i = 0
  let n = strs.len()
  let ans = ("",) // We put an empty string here to avoid returning none
  while i >= 0 {
    for j in range(n) {
      if strs.at(j).len() <= i or strs.at(j).at(i) != strs.at(0).at(i) {
        i = -1
        break
      }
    }
    if i != -1 {
      ans.push(strs.at(0).at(i))
      i += 1
    }
  }
  ans.join()
}
