// convert.typ
// Utility functions for converting card codes to data and vice versa.

#import "../data/suit.typ": *
#import "../data/rank.typ": *
#import "../data/style.typ": *

/// Get the card code for a given suit and rank.
/// 
/// The suit is given as a key from the `suits` dictionary, and the rank as a key from the `ranks` dictionary.
/// 
/// The resulting code is a string in the format "<rank><suit>", where `<rank>` is the rank symbol and `<suit>` is the first letter of the suit key in uppercase.
/// 
/// For example, if the suit is "heart" and the rank is "A", the resulting code will be "AH".
/// ```side-by-side
/// #deckz.get-card-code("heart", "ace") // Returns "AH"
/// #deckz.get-card-code("spade", "king") // Returns "KS"
/// #deckz.get-card-code("diamond", "ten") // Returns "10D"
/// #deckz.get-card-code("club", "three") // Returns "3C"
/// ```
/// 
/// -> string
#let get-card-code(suit-key, rank-key) = {
  ranks.at(rank-key) + upper(suit-key.at(0))
}


/// This function takes the code for a card and returns the corresponding data about its suit, color, and rank.
/// 
/// -> dictionary
#let extract-card-data(card-code) = {
  let my-suit = none
  for (curr-suit, _) in suits {
    if lower(card-code.at(-1)) == curr-suit.at(0) {
      my-suit = curr-suit
    }
  }
  let my-rank = none
  for (curr-rank, rank-symbol) in ranks {
    if upper(card-code.slice(0, -1)) == rank-symbol {
      my-rank = curr-rank
    }
  }
  return (
    suit: my-suit,
    color: if my-suit != none {suits-colors.at(my-suit, default: none)} else {none},
    rank: my-rank,
  )
}