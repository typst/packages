///! Percentage formatting.

#import "number.typ": format-number, forward-decimals

// `scale: 100` suits a proportion; pass `scale: 1` when the values already sit
// on a 0 to 100 range.
#let format-percent(
  columns,
  rows: auto,
  // `auto` means one decimal place, and yields to `significant`: see
  // `forward-decimals` in src/format/number.typ.
  decimals: auto,
  scale: 100,
  symbol: [%],
  space: true,
  ..options
) = format-number(
  columns,
  rows: rows,
  decimals: forward-decimals(decimals, options, 1),
  scale: scale,
  scope: "format-percent",
  suffix: if space { sym.space.nobreak + symbol } else { symbol },
  ..options,
)
