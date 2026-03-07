// sort.typ
// This file defines the sorting functions for the Deckz package.

#import "../data/rank.typ": ranks
#import "../data/suit.typ": suits
#import "convert.typ": extract-card-data


/// Compare two cards based on their score, given the card data.
/// The score is determined by the rank of the card, where Ace comes first, followed by King, Queen, Jack, and then numbered cards from 10 to 2:
/// A, K, Q, J, 10, 9, 8, 7, 6, 5, 4, 3, 2.
/// 
/// -> key
#let score-comparator(
	/// The iterator of the card, from which the rank is extracted.
	/// -> card
	card-it,
) = {
	return (-extract-card-data(card-it).rank-score)
}

/// Sort a list of cards by their score.
/// The cards are sorted in descending order based on their score, which is determined by the rank of the card.
/// The order is as follows: Ace, King, Queen, Jack, 10, 9, 8, 7, 6, 5, 4, 3, 2.
///
/// -> cards
#let sort-by-score(
	/// The cards to sort.
	/// -> array
	cards,
) = {
	return cards.sorted(key: score-comparator)
}

/// Compare two cards based on their order in a standard sorted deck.
/// The order compares two cards by their suit (first) and rank (second).
/// Suits and ranks are ordered according to their attributes "suit-order" and "rank-order".
/// These are defined by default as:
/// - Suits: Hearts, Diamonds, Clubs, Spades
/// - Ranks: A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K
/// 
/// -> (key, key)
#let order-comparator(
	/// The iterator of the card, from which the suit and rank are extracted.
	/// -> card
	card-it,
) = {
	let card-data = extract-card-data(card-it)
	return (card-data.suit-order, card-data.rank-order)
}

/// Sort a list of cards by their order in a standard sorted deck.
/// The cards are sorted in ascending order based on their suit and rank.
/// 
/// -> cards
#let sort-by-order(
	/// The cards to sort.
	/// -> array
	cards,
) = {
	return cards.sorted(key: order-comparator)
}

/// Sort a list of cards based on a specified key.
/// The key can be "score", "order", or any other attribute of the card.
/// If the key is *"score"*, the cards are sorted by their score (see @cmd:deckz.arr:sort-by-score).
/// If the key is *"order"*, the cards are sorted by their order in a standard sorted deck (see @cmd:deckz.arr:sort-by-order).
/// If the key is not specified or is #value(auto), the behavior defaults to sorting by *order*.
/// Other keys will be interpreted as attributes of the card and sorted accordingly, as if using the `sorted` method with that key.
/// 
/// -> array
#let sort(
	/// The cards to sort.
	/// -> array
	cards,
	/// The key to sort by. Can be "score", "order", or any other attribute of the card.
	/// Defaults to "order" if not specified.
	/// -> string | auto
	by: auto,
) = {
	if by == "score" {
		return sort-by-score(cards)
	} else if by == "order" or by == auto {
		return sort-by-order(cards)
	} else {
		return cards.sorted(key: by)
	}
}

/// Get the count of each rank in the given cards.
/// This function returns a dictionary where the keys are the ranks and the values are the counts of how many times each rank appears in the provided cards.
/// 
/// -> dictionary
#let count-ranks(
  /// The cards to check for rank counts. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// If true, the function will add a zero count for ranks that do not appear in the cards. Default: false
  /// -> bool
  add-zero: false,
  /// If true, the function will also count cards that are not valid according to the `extract-card-data` function.
  /// This is useful for debugging or when you want to include all cards regardless of their validity
  /// Default: false
  /// -> bool
  allow-invalid: false,
) = {
  let rank-counts = if add-zero {
    // Initialize a dictionary with all ranks set to zero
    ranks.keys().map((rank) => (rank, 0)).to-dict()
  } else {
    (:) // Initialize an empty dictionary to count occurrences of each rank
  }
  for card in cards {
    let card-data = extract-card-data(card)
    let new-count = rank-counts.at(card-data.rank, default: 0) + 1
    rank-counts.insert(card-data.rank, new-count)
  }
  if none in rank-counts.keys() {
    if not allow-invalid {
      panic("Invalid card rank found in `count-ranks` function: " + cards.join(", "))
      return none
    }
  }
  return rank-counts
}

/// For each rank, check if it is present in the given cards.
/// This function returns a dictionary where the keys are the ranks and the values are booleans indicating whether that rank is present in the provided cards.
/// This is more efficient than counting the ranks with the function @cmd:deckz.arr:count-ranks, as it only checks for presence and does not count occurrences.
/// 
/// -> dictionary
#let find-ranks(
  /// The cards to check for rank presence. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// If true, the function will also count cards that are not valid according to the `extract-card-data` function. This will add one entry with the key `none` to the result if there are invalid cards.
  /// If false, the function will panic if it finds an invalid card, returning none.
  /// Default: false
  /// -> bool
  allow-invalid: false,
) = {
  let rank-presence = ranks.keys().map((rank) => (rank, false)).to-dict() // Initialize a dictionary with all ranks set to false
  if allow-invalid {
    rank-presence.insert(none, false) // Add an entry for invalid cards
  }
  // Check each card for its rank
  let remaining-ranks = rank-presence.len()
  for card in cards {
    let card-data = extract-card-data(card)
    if card-data.rank == none and not allow-invalid {
      panic("Invalid card rank found in `find-ranks` function: " + card)
      return none
    }
    if not rank-presence.at(card-data.rank, default: false) {
      rank-presence.insert(card-data.rank, true) // Set the rank to true if it is present
      remaining-ranks -= 1 // Decrease the count of remaining ranks
      if remaining-ranks == 0 {
        break // If all ranks are found, exit the loop early
      }
    }
  }
  return rank-presence
}

/// Sort the given cards by their rank.
/// This function returns a dictionary where the keys are the ranks and the values are arrays of cards that have that rank.
/// 
/// -> dictionary
#let group-ranks(
  /// The cards to sort by rank. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// If true, the function will add an entry for each rank, even if the rank does not appear in the cards. 
  /// This entry will have the rank as the key and an empty array as the value.
  /// Default: false
  /// -> bool
  add-zero: false,
  /// If true, the function will also count cards that are not valid according to the `extract-card-data` function.
  /// If false, the function will simply ignore invalid cards. (No error will be raised.)
  /// Default: false
  /// -> bool
  allow-invalid: false,
) = {
  let cards-by-rank = if add-zero {
    // Initialize a dictionary with all ranks set to an empty array
    ranks.keys().map((rank) => (rank, ())).to-dict()
  } else {
    (:) // Initialize an empty dictionary to hold the sorted cards
  }
  for card in cards {
    let card-data = extract-card-data(card)
    if card-data.rank != none or allow-invalid {
      let current-cards = cards-by-rank.at(card-data.rank, default: ())
      cards-by-rank.insert(card-data.rank, current-cards + (card, )) // Append the card to the list for its rank
    }
  }
  return cards-by-rank
}

/// Get the count of each suit in the given cards.
/// This function returns a dictionary where the keys are the suits and the values are the counts of how many times each suit appears in the provided cards.
///
/// -> dictionary
#let count-suits(
  /// The cards to check for suit counts. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// If true, the function will add a zero count for suits that do not appear in the cards. Default: false
  /// -> bool
  add-zero: false,
  /// If true, the function will also count cards that are not valid according to the `extract-card-data` function.
  /// This is useful for debugging or when you want to include all cards regardless of their validity
  /// Default: false
  /// -> bool
  allow-invalid: false,
) = {
  let suit-counts = if add-zero {
    // Initialize a dictionary with all suits set to zero
    suits.keys().map((suit) => (suit, 0)).to-dict()
  } else {
    (:) // Initialize an empty dictionary to count occurrences of each suit
  }
  for card in cards {
    let card-data = extract-card-data(card)
    let new-count = suit-counts.at(card-data.suit, default: 0) + 1
    suit-counts.insert(card-data.suit, new-count)
  }
  if none in suit-counts.keys() {
    if not allow-invalid {
      panic("Invalid card suit found in `count-suits` function: " + cards.join(", "))
      return none
    }
  }
  return suit-counts
}

/// For each suit, check if it is present in the given cards.
/// This function returns a dictionary where the keys are the suits and the values are booleans indicating whether that suit is present in the provided cards.
/// This is more efficient than counting the suits with the function @cmd:deckz.arr:count-suits, as it only checks for presence and does not count occurrences.
///
/// -> dictionary
#let find-suits(
  /// The cards to check for suit presence. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// If true, the function will also count cards that are not valid (i.e. whose rank symbol does not correspond to any of the known ranks). This will add one entry with the key `none` to the result if there are invalid cards.
  /// If false, the function will panic if it finds an invalid card, returning none.
  /// Default: false
  /// -> bool
  allow-invalid: false,
) = {
  let suit-presence = suits.keys().map((suit) => (suit, false)).to-dict() // Initialize a dictionary with all suits set to false
  if allow-invalid {
    suit-presence.insert(none, false) // Add an entry for invalid cards
  }
  // Check each card for its suit
  let remaining-suits = suit-presence.len()
  for card in cards {
    let card-data = extract-card-data(card)
    if card-data.suit == none and not allow-invalid {
      panic("Invalid card suit found in `find-suits` function: " + card)
      return none
    }
    if not suit-presence.at(card-data.suit, default: false) {
      suit-presence.insert(card-data.suit, true) // Set the suit to true if it is present
      remaining-suits -= 1 // Decrease the count of remaining suits
      if remaining-suits == 0 {
        break // If all suits are found, exit the loop early
      }
    }
  }
  return suit-presence
}

/// Sort the given cards by their suit.
/// This function returns a dictionary where the keys are the suits and the values are arrays of cards that have that suit.
///
/// -> dictionary
#let group-suits(
  /// The cards to sort by suit. This can be a list or any iterable collection of card codes.
  /// -> array
  cards,
  /// If true, the function will add an entry for each suit, even if the suit does not appear in the cards. 
  /// This entry will have the suit as the key and an empty array as the value.
  /// Default: false
  /// -> bool
  add-zero: false,
  /// If true, the function will also count cards that are not valid according to the `extract-card-data` function.
  /// If false, the function will simply ignore invalid cards. (No error will be raised.)
  /// Default: false
  /// -> bool
  allow-invalid: false,
) = {
  let cards-by-suit = if add-zero {
    // Initialize a dictionary with all suits set to an empty array
    suits.keys().map((suit) => (suit, ())).to-dict()
  } else {
    (:) // Initialize an empty dictionary to hold the sorted cards
  }
  for card in cards {
    let card-data = extract-card-data(card)
    if card-data.suit != none or allow-invalid {
      let current-cards = cards-by-suit.at(card-data.suit, default: ())
      cards-by-suit.insert(card-data.suit, current-cards + (card, )) // Append the card to the list for its suit
    }
  }
  return cards-by-suit
}
