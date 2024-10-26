# `big-rat`

`big-rat` is a package to work with rational numbers in Typst

## Usage

```typ
#import "@preview/big-rat:0.1.0"

#let a = 2      // 2/1
#let b = (1, 2) // 1/2

#let sum = big-rat.add(a, b) // 5/2

$#big-rat.repr(sum)$
```

Functions, exported by the package are:

```typ
// Converts `x` to an array of length two, representing the rational number,
// that can be used in the functions below.
// `x` might be an integer or a big integer, written as a string.
// If `x` is an array of length two, which elements are integers or big integers,
// then it is converted to the array of all big integers.
#let rational(x)

// Functions below work with "rational numbers", integers or big integers, written as strings

// Returns a + b
#let add(a, b)

// Returns a - b
#let sub(a, b)

// Returns a / b
#let div(a, b)

// Returns a * b
#let mul(a, b)

// Returns a value of type `content`, representing the rational number
#let repr(x)

// Returns a string, representing the rational number
#let to-decimal-str(x, precision: 8)

// Returns a floating-point number, representing the rational number
#let to-float(x, precision: 8)

// Returns a decimal number, representing the rational number
#let to-decimal(x, precision: 8)

// Returns |a - b|
#let abs-diff(a, b)

// Returns -1 if a < b, 0 if a == b, 1 if a > b
#let cmp(a, b)
```
