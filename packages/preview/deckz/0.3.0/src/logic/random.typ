// src/logic/random.typ

#import "@preview/suiji:0.4.0" as suiji: gen-rng-f, shuffle-f, choice-f // Random number generation functions from the Suiji package
#import "@preview/digestify:0.1.0": sha256 // Hashing library, used to create a seed from the cards


// Extract a seed from the given value. The value can be of type:
// - `int`: the seed is returned as is.
// - `string`: the seed is generated from the string using a hash function.
// - `array` of `string`: the seed is generated from the array by concatenating the elements and hashing.
// - `array` of `int`: the seed is generated from the array by converting the integers to strings, concatenating them, and hashing.
// Guarantees that the seed is an integer.
#let extract-seed(value: 42) = {
  // Integer
  if type(value) == int {
    return value
  }
  // String
  else if type(value) == str {
    let hash = sha256(bytes(value))
    return int.from-bytes(hash.slice(0, 8))
  } 
  // Array
  else if type(value) == array {
    // -- empty
    if value.len() == 0 {
      return 42 // Default seed if the array is empty
    }
    // -- of Strings
    if value.all((it) => type(it) == str) {
      return extract-seed(value: value.join()) // Concatenate the strings and extract the seed
    } 
    // -- of Integers
    else if value.all((it) => type(it) == int) {
      return extract-seed(value: value.map(str).join()) // Convert integers to strings and extract the seed
    }
    else {
      return value.map((it) => {extract-seed(value: it)}).join() // Recursively extract seeds from mixed types
    }
  } else {
    panic("The seed must be an integer, a string, or an array of those.")
  }
}

#let prepare-rng(rng: auto, seed: 42) = {
  let rng-from-outside = true
  // If the rng is auto, create a new random number generator
  if rng == auto {
    rng-from-outside = false
    rng = gen-rng-f(extract-seed(value: seed))
  } else if type(rng) == array and rng.len() == 2 and type(rng.at(0)) == bool {
    // If the rng is a couple, with a boolean and some value
    // The boolean indicates if the rng is from outside or not
    // The value is the random number generator
    rng-from-outside = rng.at(0)
    rng = rng.at(1)
  } else {
    // Otherwise, assume the `rng` parameter's value is a random number generator
    rng-from-outside = true
    rng = rng
  }
  return (rng-from-outside, rng)
}

#let attach-rng-if-from-outside(rng-from-outside, rng, value) = {
  if rng-from-outside {
    return (rng, value)
  } else {
    return value
  }
}

// Helper function to call an RNG-using function and handle the return value properly.
// This is useful for hierarchical calls where a top-level function needs to manage RNG state across multiple bottom-level function calls.
#let call-rng-function(func, rng, ..args) = {
  // Call the function with the RNG marked as coming from outside
  let result = func(..args, rng: (true, rng))
  
  // The result should be a tuple (new_rng, value) since we passed rng from outside
  if type(result) == array and result.len() == 2 {
    return result  // (new_rng, value)
  } else {
    // This shouldn't happen if the function follows our convention
    panic("RNG function did not return (rng, value) tuple as expected")
  }
}