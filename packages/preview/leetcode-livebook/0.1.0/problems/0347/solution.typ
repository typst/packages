#import "../../helpers.typ": *

#let solution(nums, k) = {
  // Count frequencies
  let freq = (:)
  for num in nums {
    let key = str(num)
    if key in freq {
      freq.at(key) += 1
    } else {
      freq.insert(key, 1)
    }
  }

  // Sort by frequency (descending) and take top k
  let sorted = freq.pairs().sorted(key: pair => -pair.at(1))

  sorted.slice(0, k).map(pair => int(pair.at(0)))
}
