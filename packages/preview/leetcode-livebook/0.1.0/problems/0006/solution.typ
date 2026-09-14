#import "../../helpers.typ": *

#let solution(s, numRows) = {
  if numRows == 1 {
    return s
  }

  let s = s.clusters()
  let n = s.len()
  let ret = ()
  let cycleLen = 2 * numRows - 2

  for i in range(numRows) {
    for j in range(0, n - i, step: cycleLen) {
      ret.push(s.at(j + i))
      if i != 0 and i != numRows - 1 and j + cycleLen - i < n {
        ret.push(s.at(j + cycleLen - i))
      }
    }
  }

  ret.join()
}
