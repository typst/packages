# Unify
`unify` is a [typst](https://github.com/typst/typst) package simplifying the typesetting of number, (physical) units, and ranges. It is the equivalent to LaTeX's `siunitx`, though not as mature.


## Overview
`unify` allows flexible numbers and units, and still mostly gets well typeset results.
```ts
#import "@preview/unify:0.1.0": num, unit, range, unit-range

$ #num("-1.3+-0.5e-6") $
$ #unit("1.3+1.2-0.3e3", "meter per second squared") $
$ #range("1e-2", "3e5") $
$ #unit-range("1e3", "2e3", "meter per second") $
```
<img src="examples/overview.jpg" width="200">


## `num`
`num` uses string parsing in order to typeset numbers. They can have the following form:
- `-`
- `float` or `integer` number
- either (`{}` stands for a number)
    - symmetric uncertainties with `+-{}`
    - asymmetric uncertainties with `+{}-{}`
- exponential notation `e{}`

Parentheses are automatically set as necessary.


## `unit`
`unit` allows a `num` as the first argument following the same rules. The second argument is the `unit`. If `raw_unit` is set to true, its value will be passed on to the result. Otherwise, the unit should be written in words. Later on, I made a shorthand notation. The value of `space` will be inserted between units if necessary.  
Units have four possible parts:
- `per` forms the inverse of the following unit.
- A prefix in the sense of SI. This is added before the unit.
- The unit itself.
- A postfix like `squared`. This is added after the unit and takes `per` into account.

The possible values of the three latter parts are loaded at runtime from `prefixes.csv`, `units.csv`, and `postfixes.csv` (in the library directory). There, you can also add your own units. The formats for the pre- and postfixes are:

| pre-/postfix | symbol       |
| ------------ | ------------ |
| milli        | upright("m") |

and for units:

| unit  | symbol       | space |
| ----- | ------------ | ----- |
| meter | upright("m") | true  |

The first column specifies the whole word that will be replaced. This should be unique. The second column represents the string that will be inserted as the unit symbol. For units, the last column describes whether there should be space before the unit (possible values: `true`/`false`, `1`,`0`). This is mostly the cases for degrees and other angle units (e.g. arcseconds).  
If you think there are units not included that are of interest for other users, you can create an issue or PR.


## `range`
`range` takes two `num`s as the first two arguments. If they have the same exponent, it is automatically factorized. The range symbol can be changed with `delimiter`, and the space between the numbers and symbols with `space`.


## `unit_range`
`unit_range` is just a combination of `unit` and `range`.