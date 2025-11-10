#import "../data/suit.typ": *
#import "../data/rank.typ": *
#import "convert.typ": *

// Pre-prepared data structures

// Cards = a dictionary of all the cards in a deck.
// Structure: `cards.<suit>.<rank>`
#let cards = (:)
#for (suit, suit-symbol) in suits {
  cards.insert(suit, (:))
  for (rank, rank-symbol) in ranks {
    cards.at(suit).insert(rank, get-card-code(suit, rank))
  }
}

// Deck list
// A list of codes for all the cards in a deck.
#let deck = ()
#for (suit, suit-symbol) in suits {
  for (rank, rank-symbol) in ranks {
    deck.push(get-card-code(suit, rank))
  }
}