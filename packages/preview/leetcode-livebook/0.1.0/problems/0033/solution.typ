#import "../../helpers.typ": *

#let solution(nums, target) = {
  let n = nums.len()
  if n == 0 { return -1 }

  let lo = 0
  let hi = n - 1

  while lo <= hi {
    let mid = int((lo + hi) / 2)
    if nums.at(mid) == target {
      return mid
    }

    // Determine which half is sorted
    if nums.at(lo) <= nums.at(mid) {
      // Left half is sorted
      if nums.at(lo) <= target and target < nums.at(mid) {
        hi = mid - 1
      } else {
        lo = mid + 1
      }
    } else {
      // Right half is sorted
      if nums.at(mid) < target and target <= nums.at(hi) {
        lo = mid + 1
      } else {
        hi = mid - 1
      }
    }
  }

  -1
}
