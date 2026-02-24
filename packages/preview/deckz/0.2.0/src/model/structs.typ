// structs.typ
/// This file contains some utility structs, already filled with data from the package.

#import "../data/suit.typ": *
#import "../data/rank.typ": *
#import "convert.typ": *


/// This is a dictionary of *all the cards in a deck*.
/// 
/// It is structured as #{`cards.<suit-k>.<rank-k>`}, where:
/// - `<suit-k>` is one of the keys from the `suits` dictionary, and
/// - `<rank-k>` is one of the keys from the `ranks` dictionary.
/// The value associated with each $("rank", "suit")$ pair is the *card code*, which is a string in the format #{`<rank-s><suit-s>`}, where `<rank-s>` is the rank symbol and `<suit-s>` is the first letter of the suit key in uppercase.
/// 
/// ```side-by-side
/// #deckz.cards52.heart.ace // Returns "AH"
/// #deckz.cards52.spade.king // Returns "KS"
/// #deckz.cards52.diamond.ten // Returns "10D"
/// #deckz.cards52.club.three // Returns "3C"
/// ```
/// 
/// This dictionary can be used to access any card in a standard deck of 52 playing cards by its suit and rank, and use it in various functions that require a card code. 
/// 
/// Here is an example using the @cmd:deckz:hand function:
/// 
/// ```side-by-side
/// #deckz.hand(
///   format: "small",
///   width: 128pt,
///   angle: 90deg,
///   ..deckz.cards52.heart.values(),
/// )
///```
/// 
/// -> dict
#let cards52 = (:)
#for (suit, suit-symbol) in suits {
  cards52.insert(suit, (:))
  for (rank, rank-symbol) in ranks {
    cards52.at(suit).insert(rank, get-card-code(suit, rank))
  }
}

/// A list of all the cards in a standard deck of 52 playing cards.
/// It is a _flat_ list of *card codes*, where each code is a string in the format `<rank-s><suit-s>`, where `<rank-s>` is the rank symbol and `<suit-s>` is the first letter of the suit key in uppercase.
/// It is created programmatically from the `suits` and `ranks` dictionaries.
/// 
/// ```side-by-side
/// #table(
///   columns: 13, 
///   align: center,
///   stroke: none,
///  ..deckz.deck52,
/// )
/// ```
/// 
/// This array can be used in various functions that require a list of card codes, such as @cmd:deckz:hand, @cmd:deckz:deck, or @cmd:deckz:heap.
/// 
/// Here is an example using the @cmd:deckz:heap function:
/// 
/// ```side-by-side
/// #deckz.heap(
///   format: "small",
///   width: 128pt,
///   height: 10cm,
///   ..deckz.deck52.slice(26, 52),
/// )
/// ```
/// 
/// 
/// -> array
#let deck52 = ()
#for (suit, suit-symbol) in suits {
  for (rank, rank-symbol) in ranks {
    deck52.push(get-card-code(suit, rank))
  }
}