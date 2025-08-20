# `big-rati`

`big-rati` is a package to work with rational numbers in Typst

## Usage

```typ
#import "@preview/big-rati:0.1.0"

#let a = 2      // 2/1
#let b = (1, 2) // 1/2

#let sum = big-rati.add(a, b) // 5/2

#let c = ("4", 6)
#let prod = big-rati.mul(c, sum) // 5/3

$#big-rati.repr(prod)$
```

Functions, exported by the package are:

```typ
// Converts `x` to bytes, representing the rational number,
// that can be used in the functions below.
// `x` might be an integer or a big integer string.
// If `x` is an array of length two, which elements are integers
// or big integer strings, then it is converted to the array of all
// big integer strings, and then into the bytes representation.
#let rational(x)

// Functions below work with "rational numbers", integers or big integer strings

// Returns `a + b`
#let add(a, b)

// Returns `a - b`
#let sub(a, b)

// Returns `a / b`
#let div(a, b)

// Returns `a * b`
#let mul(a, b)

// Returns `a % b`
#let rem(a, b)

// Returns `|a - b|`
#let abs-diff(a, b)

// Returns `-1` if `a < b`, `0` if `a == b`, `1` if `a > b`
#let cmp(a, b)

// Returns `-x`
#let neg(x)

// Returns `|x|`
#let abs(x)

// Rounds towards plus infinity
#let ceil(x)

// Rounds towards minus infinity
#let floor(x)

// Rounds to the nearest integer. Rounds half-way cases away from zero.
#let round(x)

// Rounds towards zero.
#let trunc(x)

// Returns the fractional part of a number, with division rounded towards zero.
// Satisfies `number == add(trunc(number), fract(number))`.
#let fract(number)

// Returns the reciprocal.
// Panics if the number is zero.
#let recip(x)

// Returns `x^y`. `y` must be an `int`, in range of `-2^32` to `2^32 - 1`
#let pow(x, y)

// Restrict a value to a certain interval.
//
// Returns `max` if `number` is greater than `max`,
// and `min` if `number` is less than `min`.
// Otherwise returns `number`.
//
// Returns error if `min` is greater than `max`.
#let clamp(number, min, max)

// Compares and returns the minimum of two values.
#let min(a, b)

// Compares and returns the maximum of two values.
#let max(a, b)

// Returns a value of type `content`, representing the rational number.
// If `is-mixed` is true, then the result is a mixed fraction,
// otherwise, it is a simple fraction.
#let repr(x, is-mixed: true)

// Returns a string, representing the rational number
#let to-decimal-str(x, precision: 8)

// Returns a floating-point number, representing the rational number
#let to-float(x, precision: 8)

// Returns a decimal number, representing the rational number
#let to-decimal(x, precision: 8)
```
