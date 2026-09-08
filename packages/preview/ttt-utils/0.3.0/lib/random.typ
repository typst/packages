#import "@preview/suiji:0.5.1" as suiji

// Global RNG state (stores the master seed integer)
#let rng-state = state("ttt-rng", 0)

/// Initialize the global random number generator with a seed.
///
/// - seed (int): The seed to use.
#let init-rng(seed) = {
  rng-state.update(seed)
}

/// Shuffle an array using the global RNG state and a unique identifier.
///
/// - choices (array): The array to shuffle.
/// - id (array): A unique identifier for the shuffle context (e.g. question counter).
#let shuffle(choices, id) = {
  let master-seed = rng-state.get()

  // Mix master seed with ID to get a deterministic local seed
  // Assumes id is an array of integers (like a counter value)
  let flat-idx = id.at(0) * 100 + id.at(1, default: 0)

  // Simple mixing to avoid linear correlation if seeds are close
  let local-seed = master-seed + flat-idx * 31337

  let rng = suiji.gen-rng(local-seed)
  let (_, shuffled) = suiji.shuffle(rng, choices)
  shuffled
}
