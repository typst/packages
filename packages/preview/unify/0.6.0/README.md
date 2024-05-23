# Unify
`unify` is a [Typst](https://github.com/typst/typst) package simplifying the typesetting of numbers, (physical and monetary) units, and ranges. It is the equivalent to LaTeX's `siunitx`, though not as mature.


## Overview
`unify` allows flexible numbers and units, and still mostly gets well typeset results.
```typ
#import "@preview/unify:0.6.0": num,qty,numrange,qtyrange

$ num("-1.32865+-0.50273e-6") $
$ qty("1.3+1.2-0.3e3", "erg/cm^2/s", space: "#h(2mm)") $
$ numrange("1,1238e-2", "3,0868e5", thousandsep: "'") $
$ qtyrange("1e3", "2e3", "meter per second squared", per: "/", delimiter: "\"to\"") $
```
<img src="examples/overview.jpg" width="300">

## Multilingual support 
The Unify package supports multiple languages. Currently, the supported languages are English and Russian. The fallback is English. If you want to add your language, you should add two files: `prefixes-xx.csv` and `units-xx.csv`, and in the `lib.typ` file you should fix the `lang-db` state for your files.

## `num`
`num` uses string parsing in order to typeset numbers, including separators between the thousands. They can have the following form:
- `float` or `integer` number
- either (`{}` stands for a number)
    - symmetric uncertainties with `+-{}`
    - asymmetric uncertainties with `+{}-{}`
- exponential notation `e{}`

Parentheses are automatically set as necessary. Use `thousandsep` to change the separator between the thousands, and `multiplier` to change the multiplication symbol between the number and exponential.


## `unit`
`unit` takes the unit in words or in symbolic notation as its first argument. The value of `space` will be inserted between units if necessary. Setting `per` to `symbol` will format the number with exponents (i.e. `^(-1)`), and `fraction` or `/` using fraction.  
Units in words have four possible parts:
- `per` forms the inverse of the following unit.
- A written-out prefix in the sense of SI (e.g. `centi`). This is added before the unit.
- The unit itself written out (e.g. `gram`).
- A postfix like `squared`. This is added after the unit and takes `per` into account.

The shorthand notation also has four parts:
- `/` forms the inverse of the following unit.
- A short prefix in the sense of SI (e.g. `c`). This is added before the unit.
- The short unit itself (e.g. `g`).
- An exponent like `^2`. This is added after the unit and takes `/` into account.

Note: Use `u` for micro.

The possible values of the three latter parts are loaded at runtime from `prefixes.csv`, `units.csv`, and `postfixes.csv` (in the library directory). There, you can also add your own units. The formats for the pre- and postfixes are:

| pre-/postfix | shorthand | symbol       |
| ------------ | --------- | ------------ |
| milli        | m         | upright("m") |

and for units:

| unit  | shorthand | symbol       | space |
| ----- | --------- | ------------ | ----- |
| meter | m         | upright("m") | true  |

The first column specifies the written-out word, the second one the shorthand. These should be unique. The third column represents the string that will be inserted as the unit symbol. For units, the last column describes whether there should be space before the unit (possible values: `true`/`false`, `1`,`0`). This is mostly the cases for degrees and other angle units (e.g. arcseconds).  
If you think there are units not included that are of interest for other users, you can create an issue or PR.


## `qty`
`qty` allows a `num` as the first argument following the same rules. The second argument is a unit. If `rawunit` is set to true, its value will be passed on to the result (note that the string passed on will be passed to `eval`, so add escaped quotes `\"` if necessary). Otherwise, it follows the rules of `unit`. The value of `space` will be inserted between units if necessary, `thousandsep` between the thousands, and `per` switches between exponents and fractions.  


## `numrange`
`numrange` takes two `num`s as the first two arguments. If they have the same exponent, it is automatically factorized. The range symbol can be changed with `delimiter`, and the space between the numbers and symbols with `space`.


## `qtyrange`
`qtyrange` is just a combination of `unit` and `range`.