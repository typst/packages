/// Computes the modulus of two numbers (a mod b).
///
/// - a (int): The dividend.
/// - b (int): The divisor.
/// -> int
#let mod(a, b) = {
  let div = a / b
  div = int(div)
  let rem = a - (div * b)
  return rem
}

/// Generates a random float in [0, 1) and new seed using LCG algorithm.
/// 
/// Returns a tuple of (random_float, next).
///
/// - seed (int): Starting seed.
/// -> array
#let random(seed: 0) = {
  let a = 1664525
  let c = 1013904223
  let m = 2147483648
  let next = mod((seed * a + c), m)
  let random_float = next / m
  return (random_float, next)
}

/// Generates n random floats in [0, 1).
/// 
/// Returns a tuple of (random_floats, next).
///
/// - n (int): Number of random values to generate.
/// - seed (int): Starting seed.
/// -> array
#let randoms(n, seed: 0) = {
  let random_floats = ()
  for i in range(0, n) {
    let (random_float, next) = random(seed: seed)
    random_floats.insert(i, random_float)
    seed = next
  }
  return (random_floats, seed)
}

/// Generates a random integer in [a, b] (inclusive).
///
/// Returns a tuple of (random_int, next_seed).
/// 
/// - a (int): Lower bound (inclusive).
/// - b (int): Upper bound (inclusive).
/// - seed (int): Starting seed.
/// -> array
#let randint(a, b, seed: 0) = {
  let (random_float, seed) = random(seed: seed)
  let rand_int = int(random_float * (b - a + 1)) + a
  return (rand_int, seed)
}

/// Generates n random integers in [a, b] (inclusive).
///
/// Returns a tuple of (random_ints, next_seed).
/// 
/// - a (int): Lower bound (inclusive).
/// - b (int): Upper bound (inclusive).
/// - n (int): Number of random values to generate.
/// - seed (int): Starting seed.
/// -> array
#let randints(a, b, n, seed: 0) = {
  let random_ints = ()
  for i in range(0, n) {
    let (rand_int, next) = randint(a, b, seed: seed)
    random_ints.insert(i,rand_int)
    seed = next
  }
  return (random_ints, seed)
}

/// Chooses a random element from an array.
///
/// Returns a tuple of (random_element, next).
///
/// - arr (array): The array to choose from.
/// - seed (int): Starting seed.
/// -> array
#let choice(arr, seed: 0) = {
  let (index, next) = randint(0, arr.len() - 1, seed: seed)
  return (arr.at(index), next)
}

/// Shuffles an array in place.
///
/// Returns a tuple of (shuffled, next).
///
/// - arr (array): The array to shuffle.
/// - seed (int): Starting seed.
/// -> array
#let shuffle(arr, seed: 0) = {
  let shuffled = array(arr)
  for i in range(arr.len()-1, 0, step: -1) {
    let (j, next) = randint(0, i, seed: seed)
    let temp = shuffled.at(i)
    shuffled.at(i) = shuffled.at(j)
    shuffled.at(j) = temp
    seed = next
  }
  return (shuffled, seed)
}

/// Generates a random seed based on current date.
///
/// -> int
#let randominit() = {
  let d = datetime.today() - datetime(year: 1980, month: 1, day: 1)
  return mod(int(d.seconds()), 2147483647)
}
