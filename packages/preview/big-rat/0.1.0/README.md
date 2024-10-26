# Typst plugin to work with big rational numbers

The WASM binary exports the following several functions:

```rust
#[wasm_func]
fn add(
    a_numer: &[u8],
    a_denom: &[u8],
    b_numer: &[u8],
    b_denom: &[u8],
) -> Result<Vec<u8>, Box<dyn Error>>;

#[wasm_func]
fn sub(
    a_numer: &[u8],
    a_denom: &[u8],
    b_numer: &[u8],
    b_denom: &[u8],
) -> Result<Vec<u8>, Box<dyn Error>>;

#[wasm_func]
fn mul(
    a_numer: &[u8],
    a_denom: &[u8],
    b_numer: &[u8],
    b_denom: &[u8],
) -> Result<Vec<u8>, Box<dyn Error>>;

#[wasm_func]
fn div(
    a_numer: &[u8],
    a_denom: &[u8],
    b_numer: &[u8],
    b_denom: &[u8],
) -> Result<Vec<u8>, Box<dyn Error>>;

#[wasm_func]
fn repr(numer: &[u8], denom: &[u8]) -> Result<Vec<u8>, Box<dyn Error>>;

#[wasm_func]
fn to_decimal_string(
    numer: &[u8],
    denom: &[u8],
    precision: &[u8],
) -> Result<Vec<u8>, Box<dyn Error>>;

#[wasm_func]
fn abs_diff(
    a_numer: &[u8],
    a_denom: &[u8],
    b_numer: &[u8],
    b_denom: &[u8],
) -> Result<Vec<u8>, Box<dyn Error>>;

#[wasm_func]
fn cmp(
    a_numer: &[u8],
    a_denom: &[u8],
    b_numer: &[u8],
    b_denom: &[u8],
) -> Result<Vec<u8>, Box<dyn Error>>;
```

Those functions can be used in Typst via the `rational.typ` file:

```typ
#import "rational.typ": *

#let a = 2      // 2/1
#let b = (1, 2) // 1/2

#let sum = add(a, b) // 5/2

$#repr(sum)$
```

Functions, exported by the `rational.typ` file are:

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
