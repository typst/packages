# Matset
_What if you could put a graphing calculator into Typst?_

The aim of this project is to provide a calculator for Typst that has an
extremely ergonomic Typst-side API. Namely, everything is done entirely
in Typst equation objects.

## Features
- Real numbers
  - Rational numbers
  - Floating point numbers
- Complex numbers
- Matrices
- Functions & (Capturing) Closures

## Getting started
```typ
#import "@preview/matset:0.1.0"
```

## Example
```typ
insert($ g(z) := vec(z, 1/2 z) $)
$ evaluate(g(3+i)) $
$ evaluate(mat(1, 2; 4, 5) g(12)) $
$ evaluate(g(5)^T) $
$ evaluate((g(3 + i)^* mat(1, 2; 4, 5))^T) $
$ evaluate(det(mat(1, 2; 3, 4))) $
```
![](./example.png)


## API
- `insert` takes a typst equation and registers it. Requires the equation be of either of these two shapes:
  - `ident := expr`
  - `ident(ident,+) := expr`
- `evaluate` takes a typst equation and evaluates it as an expression.
- `floateval` performs the same operation as `evaluate` but always evaluates all rationals into floats.
- `floatexpr` wraps an element inside of a context expression to allow for direct querying for use in a plotter (See example).

Please refer to the example pdf in this project's repo for detailed features and usage.


# Compilation
```sh
cargo build --release --target wasm32-unknown-unknown
cp ./target/wasm32-unknown-unknown/release/matset.wasm . 
```
