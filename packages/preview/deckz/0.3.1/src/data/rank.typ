// rank.typ

/// A mapping of all *rank symbols* utilized in DECKZ.
/// 
/// This dictionary is primarily intended for internal use within higher-level functions, but can also be accessed directly, for example, to iterate over the ranks.
/// 
/// ```side-by-side
/// #table(
///   columns: 5 * (1fr, ),
///   ..deckz.ranks.keys()
/// )
/// ```
/// 
/// -> dictionary
#let ranks = (
  ace: (
    code: "A",
    order: 1,
    score: 14,
  ),
  two: (
    code: "2",
    order: 2,
    score: 2,
  ),
  three: (
    code: "3",
    order: 3,
    score: 3,
  ),
  four: (
    code: "4",
    order: 4,
    score: 4,
  ),
  five: (
    code: "5",
    order: 5,
    score: 5,
  ),
  six: (
    code: "6",
    order: 6,
    score: 6,
  ),
  seven: (
    code: "7",
    order: 7,
    score: 7,
  ),
  eight: (
    code: "8",
    order: 8,
    score: 8,
  ),
  nine: (
    code: "9",
    order: 9,
    score: 9,
  ),
  ten: (
    code: "10",
    order: 10,
    score: 10,
  ),
  jack: (
    code: "J",
    order: 11,
    score: 11,
  ),
  queen: (
    code: "Q",
    order: 12,
    score: 12,
  ),
  king: (
    code: "K",
    order: 13,
    score: 13,
  ),
)

#import "@preview/linguify:0.4.2": *

#let lang-data = toml("lang.toml")

// Overwrite rank names and symbols with linguified versions
#{
  ranks = ranks.pairs().map(((rank-key, rank-data)) => {
    let name = linguify(
      rank-key + "-name", 
      from: lang-data, 
      default: rank-key,
    )
    let symbol = linguify(
      rank-key + "-symbol", 
      from: lang-data, 
      default: rank-data.code,
    )
    rank-data.insert("name", name)
    rank-data.insert("symbol", symbol)
    return (rank-key, rank-data)
  }).to-dict()
}