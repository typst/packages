// longshot: odds formats, implied probability and margin removal.
// All functions are pure; prices are decimal odds internally.

/// Convert an American price (e.g. -110 or 150) to decimal odds.
#let american-to-decimal(a) = {
  assert(type(a) == int or type(a) == float, message: "american price must be a number")
  assert(calc.abs(a) >= 100, message: "american price must be <= -100 or >= +100")
  if a > 0 { 1 + a / 100 } else { 1 + 100 / calc.abs(a) }
}

/// Convert a fractional price given as numerator and denominator (e.g. 5, 2 for 5/2).
#let fractional-to-decimal(num, den) = {
  assert(den > 0, message: "denominator must be positive")
  1 + num / den
}

/// Convert decimal odds to an American price (rounded to the nearest integer).
#let decimal-to-american(d) = {
  assert(d > 1, message: "decimal odds must be greater than 1")
  if d >= 2 { int(calc.round((d - 1) * 100)) } else { int(calc.round(-100 / (d - 1))) }
}

/// Format an American price with its sign, e.g. "+150" or "-110".
#let fmt-american(a) = if a > 0 { "+" + str(a) } else { str(a) }

/// Implied probability of decimal odds (includes the bookmaker margin).
#let implied(d) = {
  assert(d > 1, message: "decimal odds must be greater than 1")
  1 / d
}

/// Bookmaker margin (overround) of a full market given as an array of decimal odds.
#let margin(prices) = prices.map(implied).sum() - 1

/// Fair (no-margin) probabilities of a full market, by proportional normalisation.
#let fair(prices) = {
  let raw = prices.map(implied)
  let total = raw.sum()
  raw.map(p => p / total)
}

/// Return on a stake at decimal odds (stake included).
#let returns(d, stake: 10) = stake * d

/// Format a probability as a percentage string.
#let pct(p, digits: 1) = str(calc.round(p * 100, digits: digits)) + "%"

/// A ready-made table for a full market.
/// `prices` are decimal odds; `labels` name each outcome.
#let market-table(prices, labels: none, stake: 10) = {
  let labels = if labels == none { range(prices.len()).map(i => "Outcome " + str(i + 1)) } else { labels }
  assert(labels.len() == prices.len(), message: "labels and prices must have the same length")
  let fp = fair(prices)
  table(
    columns: 5,
    align: (left, right, right, right, right),
    table.header[*Outcome*][*Decimal*][*Implied*][*Fair*][*Returns*],
    ..range(prices.len()).map(i => (
      labels.at(i),
      str(calc.round(prices.at(i), digits: 2)),
      pct(implied(prices.at(i))),
      pct(fp.at(i)),
      "$" + str(calc.round(returns(prices.at(i), stake: stake), digits: 2)),
    )).flatten(),
  )
}
