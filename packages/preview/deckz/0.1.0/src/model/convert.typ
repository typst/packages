#import "../data/suit.typ": *
#import "../data/rank.typ": *
#import "../data/style.typ": *

// Utility conversion functions

// Get the card string code, given the suit and rank
#let get-card-code(suit-key, rank-key) = {
  ranks.at(rank-key) + upper(suit-key.at(0))
}


// Takes the code for a card and returns the corresponding data about its suit, color, and rank.
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
    color: suits-colors.at(my-suit),
    rank: my-rank,
  )
}