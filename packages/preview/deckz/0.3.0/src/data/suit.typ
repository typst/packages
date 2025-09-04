// suit.typ

/// A mapping of all *suit symbols* utilized in DECKZ.
/// 
/// Primarily intended for internal use within higher-level functions,
/// but can also be accessed directly, for example, to iterate over the four suits.
/// 
/// ```side-by-side
/// #stack(
///   dir: ltr,
///   spacing: 1em,
///   ..deckz.suits.values().map(suit-data => {
///     text(suit-data.color)[#suit-data.symbol]
///   })
/// )
/// ```
/// 
/// -> dictionary
#let suits = (
  heart: (
    name: "heart",
    code: "H",
    symbol: emoji.suit.heart,
    color: red,
    order: 1,
  ),
  diamond: (
    name: "diamond",
    code: "D",
    symbol: emoji.suit.diamond,
    color: red,
    order: 2,
  ),
  club: (
    name: "club",
    code: "C",
    symbol: emoji.suit.club,
    color: black,
    order: 3,
  ),
  spade: (
    name: "spade",
    code: "S",
    symbol: emoji.suit.spade,
    color: black,
    order: 4,
  ),
)
