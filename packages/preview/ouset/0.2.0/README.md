# ouset Package
[GitHub Repository including Examples and Changelog](https://github.com/ludwig-austermann/typst-ouset)

This is a small package providing over- and underset functions for math mode in [typst](https://typst.app/).

## Usage
To use this package simply `#import "@preview/ouset:0.2.0"`. To import all functions use `: *` and for specific ones, use either the module or as described in the [typst docs](https://typst.app/docs/reference/scripting#modules).

The main function provided in this package is `ouset` for math environments. This function can take arbitrary many arguments, but with the following rules:
- if the first argument is `&`, a 'alignpoint' is inserted immediately before the symbol
- next follows the symbol, then the content to put on top, and then the content to put at the bottom
- if the last argument is `&`, a 'alignpoint' is inserted immediately after the symbol

There is a named argument `insert-and`, which if false, does not insert an 'alignpoint' in the above cases, but only clips at these points.

This package provides furthermore 3 other functions:
- `overset(s, t, c: 0, insert-and: true)`: output the symbol s with t on top of it
- `underset(s, b, c: 0 insert-and: true)`: output the symbol s with b on below of it
- `overunderset(s, t, b, c: 0, insert-and: true)`: output the symbol s with t on top of it and b below it

All functions put enough spacing around the operator, such that other content does not interfere with it. However, this spacing can be disabled, by setting `c` to 1, 2 or 3. This is a flag system with
- `c=0`: normal spacing on the left and right
- `c=1`: left spacing is according to the operator / symbol s and right spacing is normal
- `c=2`: left spacing is normal and right spacing according to the operator / symbol s
- `c=3`: both spacings are according to the operator / symbol s

Hence: clip param `c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip}`

## Example usage
Try something like:
- `$ouset(-->,, n->oo)$`
- `$ouset(-,1,2)$`
- ```typst
  #import "@preview/ouset:0.2.0": ouset

  $ M &= sum_(k=0)^oo q^k = 1 + q + q^2 + q^3 + q^4 + dots\
      &= 1 + q (1 + q + q^2 + q^3 + dots)\
      ouset(&, =, "Def.", "of" M) 1 + q dot M $
  ```