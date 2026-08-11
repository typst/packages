// src/model/score.typ
/// This file defines the functions to handle the scoring of hands of cards.

#import "convert.typ": extract-card-data
#import "combinatorics.typ": choose-k-out-of-n, cartesian-product
#import "sort.typ": count-ranks, count-suits, group-ranks, group-suits, find-ranks, find-suits, sort-by-score


/// Check if the given cards contain n-of-a-kind.
/// n-of-a-kind is defined as having at least `n` cards of the same rank
/// 
/// -> bool
#let has-n-of-a-kind(
  /// The cards to check for n-of-a-kind. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards that must have the same rank to count as n-of-a-kind.
  /// Default: 2
  /// -> int
  n: 2,
) = {
  return {
    cards.len() >= n
  } and {
    count-ranks(cards).values().any((count) => count >= n)
  }
}

/// Check if the given cards correspond to a "n-of-a-kind", i.e. if they are `n` cards of the same rank.
/// This is a stricter version of the `has-n-of-a-kind` function, as it checks that all cards correspond to the requested hand.
/// 
/// -> bool
#let is-n-of-a-kind(
  /// The cards to check for n-of-a-kind. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards that must have the same rank to count as n-of-a-kind.
  /// Default: 2
  /// -> int
  n: 2,
) = {
  return {
    cards.len() == n
  } and {
    let first-rank = extract-card-data(cards.at(0)).rank
    cards.all((card) => extract-card-data(card).rank == first-rank)
  }
}

/// Returns all possible n-of-a-kind hands from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains `n` cards of the same rank.
/// Hands are sorted by the rank of the cards, according to the order defined in the `ranks` module.
/// If there are no n-of-a-kind hands, it returns an empty array.
/// 
/// -> array
#let extract-n-of-a-kind(
  /// The cards from which we try to extract a n-of-a-kind.
  /// -> array 
  cards,
  /// The number of cards that must have the same rank to count as n-of-a-kind.
  /// Default: 2
  n: 2,
) = {
  if cards.len() < n {
    return ()
  }
  let cards-by-rank = group-ranks(cards, add-zero: false, allow-invalid: false)
  // We filter the ranks to only include those that have at least `n` cards
  // Then, for each rank with at least `n` cards, we take ALL the possible combinations of `n` cards from that rank
  // This is done with the binomial coefficient.
  let cards-by-rank-with-n-cards = cards-by-rank
    .values() // Get the values (arrays of cards) from the dictionary
    .filter((cards-of-rank) => cards-of-rank.len() >= n) // Filter ranks that have at least n cards
  if cards-by-rank-with-n-cards.len() == 0 {
    return () // No n-of-a-kind hands found
  }
  else {
    return cards-by-rank-with-n-cards
      .map((cards-of-rank) => choose-k-out-of-n(n, cards-of-rank)) // Take all combinations of n cards of each rank
      .join() // Join all the combinations into a single array
  }
}


/// Check if the given cards contain a high card.
/// A high card is defined as having at least one card with a valid rank, regardless of which rank it is.
///
/// -> bool
#let has-high-card(
  /// The cards to check for high card. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return cards.len() > 0 and cards.any((card) => extract-card-data(card).rank != none)
}

/// Check if the given cards correspond to a high card.
/// A high card is defined as a single card with a valid rank.
/// 
/// -> bool
#let is-high-card(
  /// The cards to check for high card. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return cards.len() == 1 and extract-card-data(cards.at(0)).rank != none
}

/// Get all "high card" hands from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains a single card with a valid rank.
/// If there are no high card hands, it returns an empty array.
/// 
/// -> array
#let extract-high-card(
  /// The cards to check for high card. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return cards
    .filter((card) => extract-card-data(card).rank != none) // Remove invalid cards
    .map((card) => (card, )) // Each card can be considered a "high card" hand
}

/// Check if the given cards contain a pair.
/// A pair is defined as two cards of the same rank.
/// 
/// -> bool
#let has-pair(
  /// The cards to check for a pair. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return has-n-of-a-kind(cards, n: 2)
}

/// Check if the given cards correspond to a pair, i.e. if they are two cards of the same rank.
/// 
/// -> bool
#let is-pair(
  /// The cards to check for a pair. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return is-n-of-a-kind(cards, n: 2)
}

/// Get all pairs from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains two cards of the same rank.
/// If there are no pairs, it returns an empty array.
/// -> array
#let extract-pair(
  /// The cards to check for pairs. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return extract-n-of-a-kind(cards, n: 2)
}

/// Check if the given cards contain two pairs.
/// Two pairs are defined as two distinct pairs of cards, each of the same rank.
/// 
/// -> bool
#let has-two-pairs(
  /// The cards to check for two pairs. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return count-ranks(cards).values().filter((count) => count >= 2).len() >= 2
}

/// Check if the given cards correspond to two pairs, i.e. if they are four cards with two distinct pairs of the same rank.
/// This is done by checking that there are four cards in total, and that there are two distinct pairs of the same rank.
///
/// -> bool
#let is-two-pairs(
  /// The cards to check for two pairs. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return cards.len() == 4 and has-two-pairs(cards)
}

/// Get all two pairs from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains two distinct pairs of cards, each of the same rank.
/// If there are no two pairs, it returns an empty array.
/// 
/// -> array
#let extract-two-pairs(
  /// The cards to check for two pairs. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  let pairs-by-rank = group-ranks(cards, add-zero: false, allow-invalid: false)
    .values() // Get the values (arrays of cards) from the dictionary
    .filter((cards-of-rank) => cards-of-rank.len() >= 2) // Filter ranks that have at least 2 cards
    .map((cards-of-rank) => choose-k-out-of-n(2, cards-of-rank)) // Take all combinations of 2 cards of each rank
  if pairs-by-rank.len() < 2 {
    return () // No two pairs found
  }
  // We choose two ranks that can produce pairs
  return choose-k-out-of-n(2, pairs-by-rank)
    .map(((pairs-rank-1, pairs-rank-2)) => {
      return cartesian-product(pairs-rank-1, pairs-rank-2)
        .map((pair) => pair.join()) // Join the pairs into a single hand
    })
    .join() // Join all the combinations into a single array
}

/// Check if the given cards contain three of a kind.
/// Three of a kind is defined as three cards of the same rank.
/// 
/// -> bool
#let has-three-of-a-kind(
  /// The cards to check for three of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return has-n-of-a-kind(cards, n: 3)
}

/// Check if the given cards correspond to three of a kind, i.e. if they are three cards of the same rank.
/// 
/// -> bool
#let is-three-of-a-kind(
  /// The cards to check for three of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return is-n-of-a-kind(cards, n: 3)
}

/// Get all three of a kind from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains three cards of the same rank.
/// If there are no three of a kind, it returns an empty array.
/// 
/// -> array
#let extract-three-of-a-kind(
  /// The cards to check for three of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards
) = {
  return extract-n-of-a-kind(cards, n: 3)
}

/// Check if the given cards contain a straight.
/// A straight is defined as five consecutive ranks, regardless of suit.
/// 
/// -> bool
#let has-straight(
  /// The cards to check for a straight. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of consecutive ranks required for a straight. Default: 5
  /// -> int
  n: 5,
) = {
  if cards.len() < n {
    return false // Not enough cards to form a straight
  }
  let rank-presence = find-ranks(cards).values()
  // Add the first rank to the end to handle wrap-around (e.g., A, 2, 3, 4, 5 or 10, J, Q, K, A)
  rank-presence.push(rank-presence.at(0))
  return rank-presence
    .windows(n) // Get all windows of size n
    .any( // If any window of 5 consecutive ranks
      (window) => window.all(rank => rank) // All ranks in the window are present
    )
}

/// Check if the given cards correspond to a straight.
/// A straight is defined as having exactly `n` consecutive ranks, regardless of suit.
#let is-straight(
  /// The cards to check for a straight. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of consecutive ranks required for a straight. Default: 5
  /// -> int
  n: 5,
) = {
  if cards.len() != n {
    return false // Not enough cards to form a straight
  }
  let rank-presence = find-ranks(cards).values()
  // Add the first rank to the end to handle wrap-around (e.g., A, 2, 3, 4, 5 or 10, J, Q, K, A)
  rank-presence.push(rank-presence.at(0))
  return rank-presence
    .windows(n) // Get all windows of size n
    .any( // Any window of 5 consecutive ranks
      (window) => window.all(rank => rank) // All ranks in the window are present
    )
}

/// Get all straights from the given cards.
/// This function returns an array of strings, where each string is a *hand* that contains `n` consecutive ranks.
/// If there are no straights, it returns an empty array.
/// 
/// -> array
#let extract-straight(
  /// The cards to check for a straight. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of consecutive ranks required for a straight. Default: 5
  /// -> int
  n: 5,
) = {
  if cards.len() < n {
    return () // Not enough cards to form a straight
  }
  let cards-by-rank = group-ranks(cards, add-zero: true, allow-invalid: false)
    .values() // Get the values (arrays of cards) from the dictionary
  cards-by-rank.push(cards-by-rank.at(0)) // Add the first rank to the end to handle 
  // wrap-around (e.g., A, 2, 3, 4, 5 or 10, J, Q, K, A)
  return cards-by-rank
    .windows(n) // Get all windows of size n
    .map((window) => {cartesian-product(..window)}) // Take one card from each rank in the window
    // If one of the ranks is not present, the window will be empty
    .join() // Join all the combinations into a single array
}

/// Check if the given cards contain a flush.
/// A flush is defined as having at least `n` cards of the same suit.
/// 
/// -> bool
#let has-flush(
  /// The cards to check for a flush. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards required for a flush. Default: 5
  /// -> int
  n: 5,
) = {
  return count-suits(cards, add-zero: false).values().any((count) => count >= n)
}

/// Check if the given cards correspond to a flush, i.e. the hand is composed by `n` cards of the same suit.
/// This is done by checking that there are `n` cards in total, and that there is only one suit present in the hand.
/// 
/// -> bool
#let is-flush(
  /// The cards to check for a flush. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards required for a flush. Default: 5
  /// -> int
  n: 5,
) = {
  return cards.len() == n and {
    let suit-presence = find-suits(cards, allow-invalid: false)
    return suit-presence.values().filter((present) => present).len() == 1 // Only one suit should be present
  }
}

/// Get all flushes from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains `n` cards of the same suit.
/// If there are no flushes, it returns an empty array.
/// 
/// -> array
#let extract-flush(
  /// The cards to check for a flush. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards required for a flush. Default: 5
  /// -> int
  n: 5,
) = {
  let result = group-suits(cards, add-zero: false, allow-invalid: false)
    .values() // Get the values (arrays of cards) from the dictionary
    .filter((cards-of-suit) => cards-of-suit.len() >= n) // Filter suits that have at least n cards
  if result.len() == 0 {
    return () // No flush hands found
  }
  return result
    .map((cards-of-suit) => choose-k-out-of-n(n, cards-of-suit)) // Take all combinations of n cards of each suit
    .join() // Join all the combinations into a single array
}

/// Check if the given cards contain a full house.
/// A full house is defined as having three of a kind and a pair.
/// 
/// -> bool
#let has-full-house(
  /// The cards to check for a full house. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return has-three-of-a-kind(cards) and has-two-pairs(cards)
}

/// Check if the given cards correspond to a full house.
/// A full house is defined as having three of a kind and a pair.
/// 
/// -> bool
#let is-full-house(
  /// The cards to check for a full house. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return cards.len() == 5 and has-full-house(cards)
}

#let extract-full-house(
  /// The cards to check for a full house. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  let cards-by-rank = group-ranks(cards, add-zero: false, allow-invalid: false)
  let cards-min-2 = cards-by-rank
    .pairs()
    .filter(((rank, cards-of-rank)) => cards-of-rank.len() >= 2) // Get ranks with at least 2 cards
    .map(((rank, cards-of-rank)) => (rank, choose-k-out-of-n(2, cards-of-rank))) // Take all combinations of 2 cards of each rank
  let cards-min-3 = cards-by-rank
    .pairs()
    .filter(((rank, cards-of-rank)) => cards-of-rank.len() >= 3) // Get ranks with at least 3 cards (starting from those with at least 2 cards)
    .map(((rank, cards-of-rank)) => (rank, choose-k-out-of-n(3, cards-of-rank))) // Take all combinations of 3 cards of each rank

  // Simple check
  if cards-min-3.len() < 1 or cards-min-2.len() < 2 {
    // Not enough cards to form a full house
    // There should be at least one rank with 3 cards and at least two ranks with 2 cards (one of which can be the same as the first)
    return () // No full house hands found
  }
  // Now we can form the full house hands by taking one combination of 3 cards from the first rank and one combination of 2 cards from the second rank
  return cartesian-product(cards-min-3, cards-min-2)
    .map((((rank-3, three-cards), (rank-2, two-cards))) => {
      if rank-3 == rank-2 {
        // Filtering out the case where the same rank is used for both three of a kind and pair
        // This is not a valid full house hand, so we return an empty array
        return ()
      } else {
        // Otherwise, we can form a full house hand
        // We combine each combination of three cards with each combination of two cards
        return cartesian-product(three-cards, two-cards)
          .map((x) => x.join())
      }
    })
    .join()
}

/// Check if the given cards contain four of a kind.
/// Four of a kind is defined as four cards of the same rank.
/// 
/// -> bool
#let has-four-of-a-kind(
  /// The cards to check for four of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return has-n-of-a-kind(cards, n: 4)
}

/// Check if the given cards correspond to four of a kind, i.e. if they are four cards of the same rank.
/// 
/// -> bool
#let is-four-of-a-kind(
  /// The cards to check for four of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return is-n-of-a-kind(cards, n: 4)
}

/// Get all four of a kind from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains four cards of the same rank.
/// If there are no four of a kind, it returns an empty array.
/// 
/// -> array
#let extract-four-of-a-kind(
  /// The cards to check for four of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return extract-n-of-a-kind(cards, n: 4)
}

/// Check if the given cards contain a straight flush.
/// A straight flush is defined as having a straight and a flush at the same time.
/// 
/// Note: This function may accept more than `n` cards (default: more than 5 cards). This means that it will return true if there is a straight and if there is a flush, regardless of the number of cards. This means that the two conditions may not be met by the same cards.
/// 
/// -> bool
#let has-straight-flush(
  /// The cards to check for a straight flush. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards required for a straight flush. Default: 5
  /// -> int
  n: 5,
) = {
  return has-straight(cards, n: n) and has-flush(cards, n: n)
}

/// Check if the given cards correspond to a straight flush, i.e. a straight and a flush at the same time.
/// 
/// -> bool
#let is-straight-flush(
  /// The cards to check for a straight flush. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards required for a straight flush. Default: 5
  /// -> int
  n: 5,
) = {
  return is-straight(cards, n: n) and is-flush(cards, n: n)
}

/// Get all straight flushes from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains `n` consecutive ranks of the same suit.
/// If there are no straight flushes, it returns an empty array.
///
/// -> array
#let extract-straight-flush(
  /// The cards to check for a straight flush. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// The number of cards required for a straight flush. Default: 5
  /// -> int
  n: 5,
) = {
  if cards.len() < n {
    return () // Not enough cards to form a straight flush
  }
  return group-suits(cards, add-zero: false, allow-invalid: false)
    .values() // Get the values (arrays of cards) from the dictionary
    .map((cards-of-suit) => extract-straight(cards-of-suit, n: n)) // Get all straights for each suit
    .join()
}

/// Check if the given cards contain five of a kind.
/// Five of a kind is defined as five cards of the same rank.
/// 
/// -> bool
#let has-five-of-a-kind(
  /// The cards to check for five of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return has-n-of-a-kind(cards, n: 5)
}

/// Check if the given cards correspond to five of a kind, i.e. if they are five cards of the same rank.
///
/// -> bool
#let is-five-of-a-kind(
  /// The cards to check for five of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return is-n-of-a-kind(cards, n: 5)
}

/// Get all five of a kind from the given cards.
/// This function returns an array of arrays, where each inner array is a *hand* that contains five cards of the same rank.
/// If there are no five of a kind, it returns an empty array. 
/// 
/// -> array
#let extract-five-of-a-kind(
  /// The cards to check for five of a kind. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
) = {
  return extract-n-of-a-kind(cards, n: 5)
}

// --- Wrappers for the functions above

/// Extract a scoring combination from the given cards.
/// This function accepts a scoring combination name as a string and returns the corresponding hand.
/// The scoring combinations are defined as follows:
/// 
/// - "high-card": A single card with a valid rank.
/// - "pair": Two cards of the same rank.
/// - "two-pairs": Two distinct pairs of cards, each of the same rank.
/// - "three-of-a-kind": Three cards of the same rank.
/// - "straight": Five consecutive ranks, regardless of suit.
/// - "flush": Five cards of the same suit.
/// - "full-house": Three of a kind and a pair.
/// - "four-of-a-kind": Four cards of the same rank.
/// - "straight-flush": A straight and a flush at the same time.
/// - "five-of-a-kind": Five cards of the same rank.
/// 
/// If the scoring combination is not recognized, the function will panic.
/// If the scoring combination is recognized, but the cards don't have such combination, the function will return an empty array.
/// 
/// -> array
#let extract(
  /// The scoring combination to extract.
  /// -> string
  scoring-combination,
  /// The cards to check for the scoring combination. This can be an array or any iterable collection of card codes.
  /// -> array
  cards, 
) = {
  if scoring-combination == "high-card" {
    return extract-high-card(cards)
  } else if scoring-combination == "pair" {
    return extract-pair(cards)
  } else if scoring-combination == "two-pairs" {
    return extract-two-pairs(cards)
  } else if scoring-combination == "three-of-a-kind" {
    return extract-three-of-a-kind(cards)
  } else if scoring-combination == "straight" {
    return extract-straight(cards)
  } else if scoring-combination == "flush" {
    return extract-flush(cards)
  } else if scoring-combination == "full-house" {
    return extract-full-house(cards)
  } else if scoring-combination == "four-of-a-kind" {
    return extract-four-of-a-kind(cards)
  } else if scoring-combination == "straight-flush" {
    return extract-straight-flush(cards)
  } else if scoring-combination == "five-of-a-kind" {
    return extract-five-of-a-kind(cards)
  } else {
    panic("Unknown scoring combination: " + scoring-combination)
    return ()
  }
}

/// Return all the combinations of the first valid scoring combination found in the given cards, starting from the highest scoring combination.
/// This function checks the cards for the highest scoring combination and returns the corresponding hand.
/// If the cards do not contain any valid scoring combination, the function will return an empty array.
/// 
/// -> array
#let extract-highest(
  /// The cards to check for the highest scoring combination. This can be an array or any iterable collection of card codes.
  /// -> array
  cards,
  /// If true, the function will first sort the cards by their score. This is needed if you want the highest combination among multiple combinations of the same type. E.g. if you have more than one pair, the function will return the pair with the highest rank (i.e. the card with the highest score).
  /// Default: true
  sort: true,
) = {
  if sort {
    cards = sort-by-score(cards)
  }

  if has-five-of-a-kind(cards) {
    return extract-five-of-a-kind(cards)
  } else if has-straight-flush(cards) {
    return extract-straight-flush(cards)
  } else if has-four-of-a-kind(cards) {
    return extract-four-of-a-kind(cards)
  } else if has-full-house(cards) {
    return extract-full-house(cards)
  } else if has-flush(cards) {
    return extract-flush(cards)
  } else if has-straight(cards) {
    return extract-straight(cards)
  } else if has-three-of-a-kind(cards) {
    return extract-three-of-a-kind(cards)
  } else if has-two-pairs(cards) {
    return extract-two-pairs(cards)
  } else if has-pair(cards) {
    return extract-pair(cards)
  } else if has-high-card(cards) {
    return extract-high-card(cards)
  } else {
    return () // No valid hand found
  }
}