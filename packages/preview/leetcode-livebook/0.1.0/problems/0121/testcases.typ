// Test cases for Problem 0121
// First 2 cases are from LeetCode Examples

#let cases = (
  (
    input: (prices: (7, 1, 5, 3, 6, 4)),
    explanation: [Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = $6 - 1 = 5$. Note that buying on day 2 and selling on day 1 is not allowed because you must buy before you sell.],
  ),
  (
    input: (prices: (7, 6, 4, 3, 1)),
    explanation: [In this case, no transactions are done and the max profit = 0.],
  ),
  // Additional test cases
  (input: (prices: (1, 2))),
  (input: (prices: (2, 1))),
)
