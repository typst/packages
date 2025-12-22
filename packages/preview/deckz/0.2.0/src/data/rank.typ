// rank.typ

/// A mapping of all *rank symbols* utilized in DECKZ.
/// 
/// ```example
/// #deckz.ranks
/// ```
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
  "ace": "A",
  "two": "2",
  "three": "3", 
  "four": "4",
  "five": "5", 
  "six": "6", 
  "seven": "7", 
  "eight": "8", 
  "nine": "9", 
  "ten": "10", 
  "jack": "J", 
  "queen": "Q", 
  "king": "K",
)

#import "@preview/linguify:0.4.2": *

#let lang-data = toml("lang.toml")

#let get-rank-symbol(rank-key) = {
  if rank-key in ranks.keys() {
    return linguify(rank-key + "-symbol", from: lang-data, default: ranks.at(rank-key))
  } else {
    // Error
    panic("Cannot recognise key \"" + str(rank-key) + "\" as a rank")
  }
}