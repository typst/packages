#import "../../helpers.typ": *

#let solution(n) = {
  // Dynamic programming approach
  // dp[i] = number of ways to reach step i
  // dp[i] = dp[i-1] + dp[i-2] (Fibonacci sequence)

  if n <= 2 {
    return n
  }

  let prev2 = 1 // ways to reach step 1
  let prev1 = 2 // ways to reach step 2

  for i in range(3, n + 1) {
    let curr = prev1 + prev2
    prev2 = prev1
    prev1 = curr
  }

  prev1
}
