/**
Returns the exponent of 10 for the first digit of a given number.
*/
#let getHighest(x) = calc.floor(calc.log(calc.abs(x)))

/**
Returns the first significant digit of a given positive number.
*/
#let getFirstDigit(x) = {
  assert(x > 0)
  calc.floor(x / calc.pow(10, getHighest(x)))
}
