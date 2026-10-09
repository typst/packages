# Newt
Newt is a [Typst](https://typst.app/) package for typesetting numerical data.

```typ
#import "@preview/newt:0.1.0": number as n
```

## Features
- Numbers
- Units

### Numbers
Numbers are to be typeset with the `number` element. The `number` element follows the definition :
```typ
#let number(
  value,
  e: none,
  pm: none,
  u: none,
  precision: auto,
  digits: auto,
  fixed: auto,
  point: auto, 
  explicit-sign: false,
  compact: false,
  u-opts: (per-mode: "^", product: ".")
)
```

`value` may be any number-like and may include an uncertainty using +-, an exponent using e, and units following a space. For example it may look like `number("6.67430(15)e−11 N m2 / kg2")`.

`e` is the number's exponent in base 10; it shall therefore be an `int`. If `fixed` is `false` - or `auto` and the `value` given is not a string - the displayed number will be shifted accordingly. `e` can also be set to `auto` to choose the correct factor at which the number will have a single digit before its decimal part. For example, `number("5e2")` will yield $5\times10^2$, but `number(5, e: 2)` will yield $0.05\times10^2$; and `number(0.005, e: auto)` will yield $5\times10^-3$

`pm` is the uncertainty of the number; it may be any number-like or a `dictionary` comprising of `high` and `low` values, for its upper and lower bound respectively. If `compact` is set to `true` and the uncertainty is symmetric, it will be shown in compact form, for example : `number("5.25(5)")` or `number(5.25, pm: 0.05, compact: true)` will both yield $5.25(5)$.

`u` is the unit part of the number (see Units). Its options are given in `u-opts`.

`precision` describes the number of significant figures the displayed number shall have. `digits` describes the number of digits the display number shall have. Both can be defined at the same time - in other words, a number may have three significant figures while having its digits fixed at two decimal places. They are both `auto` by default, which means digits will follow the precision and the precision will be infinite (i.e. `none`) for `value`s given as string and `3` for values given as other types.

`point` is simply the type of decimal separator. It shall be set to either a comma or a point and can be inferred from the `value`, if given as a string.

# Units
Units are to be typeset with the `unit` element. The `unit` element follows the definition :
```typ
#let unit(
  value,
  per-mode: "^",
  product: " "
)
```
`per-mode` is the mode at which units with negative powers will be displayed. It shall be one of `"^"`, which is the *power* mode; `"/"`, which is the *fraction* mode; and `"-"`, which is the *over* mode.

`product` is the seperator displayed between the units. It shall be one of `" "`, which displays a thin space; and `"."`, which displays a dot.
