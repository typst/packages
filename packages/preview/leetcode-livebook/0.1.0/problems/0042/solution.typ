#import "../../helpers.typ": *

#let solution(height) = {
  if height.len() == 0 { return }

  // Calculate water level at each position
  let n = height.len()
  let left-max = height.map(_ => 0)
  let right-max = height.map(_ => 0)

  // Left pass
  left-max.at(0) = height.at(0)
  for i in range(1, n) {
    left-max.at(i) = calc.max(left-max.at(i - 1), height.at(i))
  }

  // Right pass
  right-max.at(n - 1) = height.at(n - 1)
  for i in range(n - 1).rev() {
    right-max.at(i) = calc.max(right-max.at(i + 1), height.at(i))
  }

  // Water at each position
  let water = range(n).map(i => calc.max(
    0,
    calc.min(left-max.at(i), right-max.at(i)) - height.at(i),
  ))

  water.sum()
}
