// src/logic/mix.typ

#import "random.typ": prepare-rng, attach-rng-if-from-outside, suiji


/// Shuffle the given cards and return the *shuffled array*, i.e. a new array with the same elements in a different (random) order.
/// 
/// To handle randomness, this function accepts a *random number generator* (`rng`) as an optional parameter. This `rng` follows the conventions of the #universe("suiji") library, which provides a random number generator. See the @cmd:deckz.mix:shuffle.rng parameter documentation for more information.
/// 
/// This function also relies on the `suiji.shuffle-f` function from the #universe("suiji") library to shuffle the cards.
/// 
/// The return value of this function depends on the `rng` parameter:
/// 
/// - If `rng` is set to #value(auto), the function will return only the shuffled cards, i.e. an array of cards in a random order.
/// - If `rng` is set to a specific `rng`, the function will return a tuple containing the updated `rng` and the shuffled cards. _(This is useful if you want to use the same `rng` across multiple calls to the `shuffle` function, or if you want to use a specific random number generator that you have already created.)_
/// 
/// -> array
#let shuffle(
  /// The cards to shuffle.
  /// -> array
  cards,
  /// The *random number generator* (`rng`) to use, from the #universe("suiji") package.
  /// 
  /// - *Default value* is #value(auto), which corresponds to creating a new `rng` internally and automatically, using a seed derived from the cards.
  ///   _(This means that the shuffling will be deterministic based on the input cards, and the same cards will always produce the same shuffled order.)_
  ///   Using the #value(auto) value is recommended for most use cases, especially when this is the only time you need a pseudo-random number generator in your code.
  /// - The other option is to provide an *externally-defined* `rng`, which will be used and updated according to the Suiji library's conventions.
  ///   This is useful when you want to use the same `rng` across multiple calls to the `shuffle` function, or when you want to use a specific random number generator that you have already created.
  /// 
  /// The value of this parameter also influences the return value of the function:
  /// - If `rng` is set to #value(auto), the function will return *only the shuffled cards*.
  /// - If `rng` is set to a specific `rng`, the function will return *a tuple* containing the updated `rng` and the shuffled cards.
  /// 
  /// -> (suiji.rng)
  rng: auto
) = {
  let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: cards)
  let (rng, cards) = suiji.shuffle-f(rng, cards)
  return attach-rng-if-from-outside(rng-from-outside, rng, cards)
}

/// Choose `n` cards from the given array of cards, optionally allowing replacement and permutation.
/// This is useful for drawing random cards from a deck or selecting cards from a hand.
/// 
/// The function behaves as follows in case of different values of `n`:
/// - If `n` is 1 (the default), it will return a single card chosen randomly from the given cards. The card will be contained in an array of length 1.
/// - If `n` is greater than 1, it will return an array of `n` cards chosen randomly from the given cards.
///   - If `replacement` is `true`, the same card can be chosen multiple times. This means that the function can return duplicates in the resulting array.
/// - If `n` is greater than the number of cards and `replacement` is #value(false), the function will return all cards (optionally shuffled, if `permutation` is `true`). This corresponds to drawing all cards from the deck.
/// - If `n` is 0 or less, the function will return an empty array.
/// 
/// This function uses the `suiji.choose-f` function from the #universe("suiji") library to draw elements from the array. As such, it accepts a *random number generator* (`rng`) as an optional parameter (more information in the @cmd:deckz.mix:choose.rng parameter documentation).
/// 
/// The return value of this function depends on the `rng` parameter:
/// 
/// - If `rng` is set to #value(auto), the function will return only the chosen cards, i.e. an array of cards.
/// - If `rng` is set to a specific `rng`, the function will return a tuple containing the updated `rng` and the chosen cards. _(This is useful if you want to use the same `rng` across multiple calls involving pseudo-randomness, or if you want to use a specific random number generator that you have already created.)_
/// 
/// -> array
#let choose(
  /// The cards to choose from.
  /// -> array
  cards,
  /// The number of cards to choose.
  /// Default is 1, meaning that only one card will be chosen from the given cards.
  /// 
  /// If `n` is greater than the number of cards and `replacement` is `false`, the function will return an error. 
  /// If `replacement` is `true`, the function will return `n` cards, possibly including duplicates.
  /// If `n` is 0 or less, the function will return an empty array.
  /// -> int
  n: 1,
  /// Whether to allow replacement of cards. If `true`, the same card can be chosen multiple times. If `false`, each card can only be chosen once.
  /// -> bool
  replacement: false,
  /// Whether the sample is permuted when choosing. If `true`, the order of the chosen cards is random. If `false`, the order of the chosen cards is the same as in the original array.
  /// According to the `suiji` library, false provides a faster implementation, but the order of the chosen cards will not be random.
  /// -> bool
  permutation: false,
  /// The *random number generator* (`rng`) to use, from the #universe("suiji") package.
  /// 
  /// - *Default value* is #value(auto), which corresponds to creating a new `rng` internally and automatically, using a seed derived from the cards.
  ///   _(This means that the choice will be deterministic based on the input cards, and the same cards will always produce the same selection.)_
  ///   Using the #value(auto) value is recommended for most use cases, especially when this is the only time you need a pseudo-random number generator in your code.
  /// - The other option is to provide an *externally-defined* `rng`, which will be used and updated according to the Suiji library's conventions.
  ///   This is useful when you want to use the same `rng` across multiple calls, or when you want to use a specific random number generator that you have already created.
  /// 
  /// The value of this parameter also influences the return value of the function:
  /// - If `rng` is set to #value(auto), the function will return *only the chosen cards*, i.e. an array of cards.
  /// - If `rng` is set to a specific `rng`, the function will return *a tuple* containing the updated `rng` and the chosen cards.
  /// 
  /// -> (suiji.rng)
  rng: auto
) = {
  if n <= 0 {
    return ()
  }
  let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: cards)
  let (rng, sample) = suiji.choice-f(rng, cards, size: n, replacement: replacement, permutation: permutation)
  return attach-rng-if-from-outside(rng-from-outside, rng, sample)
}


// Auxiliary function.
// Reshape the array into a multi-dimensional array with the given dimensions.
// This is useful for creating multi-dimensional arrays from flat arrays.
// 
// Typst does not have a built-in function for reshaping arrays, so this function is implemented manually.
#let reshape(arr, dims) = {
  let num-elements = arr.len()
  if dims.product() != num-elements {
    panic("The product of the dimensions must be equal to the length of the array.")
  }
  let first-dim = dims.at(0)
  let length-of-sub-array = calc.div-euclid(num-elements, first-dim)

  // Chunk the array into sub-arrays of the specified length and reshape them according to the dimensions.
  return arr.chunks(length-of-sub-array, exact: true).map(arr => {
    if dims.len() > 2 {
      // If the dimensions are more than 2, we need to reshape the array into a multi-dimensional array
      return reshape(arr, dims.slice(1))
    }
    return arr
  })
}

/// Split the given deck of cards into groups of specified sizes.
/// This is useful for dealing cards to players or creating smaller decks from a larger one.
/// 
/// The split is governed by the @cmd:deckz.mix:split.size parameter, which can be a _single integer_ (if only one group of cards should be split from the original deck array) or an _array of integers_ (if multiple groups should be dealt from the same original deck array).
/// With this function, cards are guaranteed to be dealt *in-place*, meaning that the order of the cards in the original deck is preserved in the output groups. If you want to shuffle the cards before splitting them, you can use the @cmd:deckz.mix:shuffle function before calling this function.
///
/// The function produces an array containing *the groups of cards*, with some important warnings:
/// - if the @cmd:deckz.mix:split.rest is #value(true), the returned array will contain all cards in the input deck, with the remaining cards (i.e. those which were not split into groups of the specified sizes) at the end of the array, in one single group.
/// - if the @cmd:deckz.mix:split.rest is #value(false), the returned array will contain only the split cards, and those which are not contained in the split groups will be discarded.
/// 
/// Also, the function accepts a *random number generator* (`rng`) as an optional parameter. This `rng` follows the conventions of the #universe("suiji") library, which provides a random number generator. See the @cmd:deckz.mix:split.rng parameter documentation for more information.
/// 
/// The return value of this function depends on the `rng` parameter:
/// - If `rng` is set to #value(auto), the function will return only the split groups, i.e. an array of arrays of cards.
/// - If `rng` is set to a specific `rng`, the function will return a tuple containing the updated `rng` and the split groups. _(This is useful if you want to use the same `rng` across multiple calls involving pseudo-randomness, or if you want to use a specific random number generator that you have already created.)_
/// 
/// -> array
#let split(
  /// The deck of cards to split.
  /// -> array
  cards,
  /// The size of the groups that the deck will be split into. 
  /// This parameter can accept:
  /// - An *integer*, which will be used as the size of only one group.
  ///   ```typst
  ///   #deckz.split(cards, size: 5) // Splits the deck into a group of 5 cards, and the rest of the cards.
  ///    ```
  /// - An *array of sizes* (where "sizes" are integers or array of integers), which will be used as the sizes of the groups. 
  ///   ```typst
  ///    #deckz.split(cards, size: (5, 3, 2)) // Splits the deck into three groups of 5, 3, and 2 cards respectively, and the rest of the cards in a fourth group.
  ///    #deckz.split(cards, size: (5, (3, 2))) // Splits the deck into a first group of 5 cards, a second group with of 6 cards structured as a _bidimensional matrix_ of dimensions 3x2, and a last group with the remaining cards.
  ///    ```
  /// -> int | array
  size: 1,
  /// Whether or not the function should return the rest of the cards after splitting.
  /// If `true`, the returned array will contain all cards in the input deck, with the remaining cards (i.e. the non-split cards) at the end. Default is `true`.
  /// If `false`, the returned array will contain only the split cards, and those which are not contained in the split size will be discarded.
  /// -> bool
  rest: true,
  /// The *random number generator* (`rng`) to use, from the #universe("suiji") package.
  /// 
  /// - *Default value* is #value(auto), which corresponds to creating a new `rng` internally and automatically, using a seed derived from the cards.
  ///   _(This means that the split will be deterministic based on the input cards, and the same cards will always produce the same groups.)_
  ///   Using the #value(auto) value is recommended for most use cases, especially when this is the only time you need a pseudo-random number generator in your code.
  /// - The other option is to provide an *externally-defined* `rng`, which will be used and updated according to the Suiji library's conventions.
  ///   This is useful when you want to use the same `rng` across multiple calls, or when you want to use a specific random number generator that you have already created.
  /// 
  /// The value of this parameter also influences the return value of the function:
  /// - If `rng` is set to #value(auto), the function will return *only the produced groups*, i.e. an array of arrays of cards.
  /// - If `rng` is set to a specific `rng`, the function will return *a tuple* containing the updated `rng` and the produced content.
  /// 
  /// -> (suiji.rng)
  rng: auto,
) = {
  let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: cards)

  // Always convert the size to an array of size 
  let sizes-array = if type(size) == int {
    if size < 0 {
      panic("The `size` parameter must be a non-negative integer or an array of positive integers.")
    } else {
      (size, )
    }
  } else if type(size) == array {
    size
  } else {
    panic("The `size` parameter must be an integer or an array of integers.")
  }

  let current-index = 0
  let cards-indices = ()
  for group-size in sizes-array {
    if type(group-size) == int {
      cards-indices += (current-index, ) * group-size
      current-index += 1
    } else if type(group-size) == array {
      let last-dim = group-size.at(-1)
      let subgroups-num = group-size.slice(0, -1).product()
      for _ in range(subgroups-num) {
        cards-indices += (current-index, ) * last-dim
        current-index += 1
      }
    } else {
      panic("The `size` parameter must be an integer or an array of integers.")
    }
  }

  let temp-groups = ((), ) * current-index
  cards-indices += (current-index, ) * (cards.len() - cards-indices.len())
  temp-groups.push(())
  current-index += 1

  (rng, cards-indices) = suiji.shuffle-f(rng, cards-indices)
  
  for (idx, card) in cards-indices.zip(cards) {
    temp-groups.at(idx).push(card)
  }

  current-index = 0 // Referencing the current index in the groups array
  let groups = ()
  for group-size in sizes-array {
    if type(group-size) == int {
      // If the group size is an integer, we can just slice the array
      groups.push(temp-groups.at(current-index))
      current-index += 1
    } else if type(group-size) == array {
      // If the group size is an array, we need to reshape the array into a multi-dimensional array
      let num-subgroups = group-size.slice(0, -1).product()
      groups.push(reshape(temp-groups.slice(current-index, current-index + num-subgroups).flatten(), group-size))
      current-index += num-subgroups 
    }
  }
  // If the `rest` parameter is true, we need to add the remaining cards to the end of the array
  if rest {
    groups.push(temp-groups.at(current-index))
  }
  return attach-rng-if-from-outside(rng-from-outside, rng, groups)
}