///! Currency formatting.
///!
///! The symbol fills the prefix or the suffix slot the alignment stage already
///! reserves, so a column of prices lines up on its separator with the symbols
///! under one another.

#import "../utils/errors.typ": fail-enum
#import "number.typ": format-number, forward-decimals

// The currencies worth spelling. Anything else is written as its code, which is
// what a reader would accept and what an unknown symbol could not be.
#let _SYMBOLS = (
  EUR: [€],
  GBP: [£],
  USD: [\$],
  JPY: [¥],
  CHF: [CHF],
)

// Currencies without a minor unit. Two decimals on a yen figure would invent a
// precision the currency does not circulate in.
#let _WHOLE = ("JPY",)

#let format-currency(
  columns,
  rows: auto,
  currency: "EUR",
  decimals: auto,
  symbol: auto,
  position: start,
  space: auto,
  ..options
) = {
  if position not in (start, end) {
    fail-enum("format-currency", "position", position, ("start", "end"))
  }

  let mark = if symbol == auto { _SYMBOLS.at(currency, default: [#currency]) } else { symbol }
  // A trailing symbol takes a space, as "1 234,00 €" is written; a leading one
  // sits against its number, as "€1,234.00" is. The space never breaks, so the
  // symbol cannot begin a line on its own.
  let spaced = if space == auto { position == end } else { space }
  let affix = if not spaced { mark } else if position == end {
    sym.space.nobreak + mark
  } else {
    mark + sym.space.nobreak
  }

  format-number(
    columns,
    rows: rows,
    // The currency's own count yields to `significant`: see `forward-decimals`
    // in src/format/number.typ.
    decimals: forward-decimals(decimals, options, if currency in _WHOLE { 0 } else { 2 }),
    scope: "format-currency",
    ..if position == end { (suffix: affix) } else { (prefix: affix) },
    ..options,
  )
}
