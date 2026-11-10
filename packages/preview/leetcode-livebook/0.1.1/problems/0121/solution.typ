#import "../../helpers.typ": *

#let solution(prices) = {
  let min-price = prices.at(0)
  let max-profit = 0

  for price in prices {
    min-price = calc.min(min-price, price)
    max-profit = calc.max(max-profit, price - min-price)
  }

  max-profit
}
