#import "../../helpers.typ": *

#let solution(nums1, nums2) = {
  if nums1.len() > nums2.len() {
    return solution(nums2, nums1)
  }

  let imax = 4000000000
  let imin = -4000000000

  let m = nums1.len()
  let n = nums2.len()
  let left = 0
  let right = m
  let med1 = 0
  let med2 = 0

  while left <= right {
    let i = calc.floor((left + right) / 2)
    let j = calc.floor((m + n + 1) / 2) - i

    let nums_im1 = if i == 0 { imin } else { nums1.at(i - 1) }
    let nums_i = if i == m { imax } else { nums1.at(i) }
    let nums_jm1 = if j == 0 { imin } else { nums2.at(j - 1) }
    let nums_j = if j == n { imax } else { nums2.at(j) }

    if nums_im1 <= nums_j {
      med1 = calc.max(nums_im1, nums_jm1)
      med2 = calc.min(nums_i, nums_j)
      left = i + 1
    } else {
      right = i - 1
    }
  }

  if calc.rem(m + n, 2) == 0 {
    (med1 + med2) / 2
  } else {
    med1
  }
}
