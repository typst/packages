#import "../../helpers.typ": *

#let solution(nums) = {
  let result = ((),) // Start with empty subset

  for num in nums {
    // For each existing subset, create a new one with num added
    let new-subsets = result.map(subset => subset + (num,))
    result = result + new-subsets
  }

  result
}
