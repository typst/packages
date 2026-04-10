#import "../../helpers.typ": *

#let solution(word1, word2) = {
  let m = word1.len()
  let n = word2.len()

  // dp[i] = min operations to convert word1[0..i-1] to word2[0..j-1]
  // Space optimized: only keep one row
  let dp = range(n + 1)

  for i in range(1, m + 1) {
    let prev = dp.at(0) // dp[i-1][0]
    dp.at(0) = i // dp[i][0] = i (delete all chars)

    for j in range(1, n + 1) {
      let temp = dp.at(j) // save dp[i-1][j] before overwriting

      if word1.at(i - 1) == word2.at(j - 1) {
        // Characters match, no operation needed
        dp.at(j) = prev
      } else {
        // min of: replace (prev), delete (dp[j]), insert (dp[j-1])
        dp.at(j) = 1 + calc.min(prev, dp.at(j), dp.at(j - 1))
      }

      prev = temp
    }
  }

  dp.at(n)
}
