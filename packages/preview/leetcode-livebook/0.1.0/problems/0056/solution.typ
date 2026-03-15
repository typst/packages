#import "../../helpers.typ": *

#let solution(intervals) = {
  if intervals.len() == 0 {
    return ()
  }

  // Sort by start time
  let sorted = intervals.sorted(key: interval => interval.at(0))

  let result = (sorted.at(0),)

  for i in range(1, sorted.len()) {
    let curr = sorted.at(i)
    let last = result.last()

    if curr.at(0) <= last.at(1) {
      // Overlapping, merge
      let merged = (last.at(0), calc.max(last.at(1), curr.at(1)))
      let _ = result.pop()
      result.push(merged)
    } else {
      result.push(curr)
    }
  }

  result
}
