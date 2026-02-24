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
  ranks.at(rank-key).code + suits.at(suit-key).code
}


/// This function takes the code for a card and returns the corresponding data about its suit, color, and rank.
/// 
/// -> dictionary
#let extract-card-data(card-code) = {
  let card-data = (:)

  for (suit-key, suit-data) in suits.pairs() {
    if upper(card-code.at(-1)) == suit-data.code {
      card-data.suit = suit-key
      for (k, v) in suit-data.pairs() {
        card-data.insert("suit-" + k, v)
      }
      break
    }
  }
  for (rank-key, rank-data) in ranks.pairs() {
    if type(card-code) == str and card-code.starts-with(rank-data.code) {
      card-data.rank = rank-key
      for (k, v) in rank-data.pairs() {
        card-data.insert("rank-" + k, v)
      }
      break
    }
  }
  if not "suit" in card-data {
    card-data.suit = none
  }
  if not "rank" in card-data {
    card-data.rank = none
  }
  return card-data
}


#import "@preview/digestify:0.1.0": sha256 // Hashing library, used to create a seed from the cards

/// Generate a seed based on the card values.
/// -> int
#let get-seed-from-cards(
  /// An array of cards to generate a seed from.
  /// -> array
  cards,
) = {
  // Generate a seed based on the card values
  return int(array(sha256(bytes(cards.join()))).sum())
}
