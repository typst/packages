# ouset Package
This is a small package providing over- and underset functions for math mode in [typst](https://typst.app/).

## Usage
To use this package simply `#import "@preview/ouset:0.1.0"`. To import all functions use `: *` and for specific ones, use either the module or as described in the [typst docs](https://typst.app/docs/reference/scripting#modules).

This package provides 3 functions:
- `overset(s, t, c: 0)`: output the symbol s with t on top of it
- `underset(s, b, c: 0)`: output the symbol s with b on below of it
- `overunderset(s, t, b, c: 0)`: output the symbol s with t on top of it and b below it

All functions put enough spacing around the operator, such that other content does not interfere with it. However, this spacing can be disabled, by setting `c` 1, 2 or 3. This is a flag system with
- `c=0`: normal spacing on the left and right
- `c=1`: left spacing is according to the operator / symbol s and right spacing is normal
- `c=2`: left spacing is normal and right spacing according to the operator / symbol s
- `c=3`: both spacings are according to the operator / symbol s

Hence: clip param `c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip}`