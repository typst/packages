# Dice

A versatile random number toolkit for Typst.

## Usage

```typst
// Get a seed from current datetime
#let seed = randominit()

// Get a random float in [0, 1)
#let (random_float, seed) = random(seed:seed)

// Get 10 random floats in [0, 1)
#let (random_floats, seed) = randoms(10, seed:seed)

// Get a random integer in [a, b]
#let (random_int, seed) = randint(1, 6, seed:seed)

// Get 10 random integers in [a, b]
#let (random_ints, seed) = randints(1, 6, 10, seed:seed)

// Choice from an array
#let arr = (1,2,3,4,5,6)
#let (choice, seed) = choice(arr, seed:seed)

// Shuffle an array
#let (shuffled_arr, seed) = shuffle(arr, seed:seed)
```
