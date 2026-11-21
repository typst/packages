# Zero-Calc
Calculations inside your [Typst](https://typst.app) document, with automatic error propagation, unit handling and significant figures, built on top of [Zero](https://typst.app/universe/package/zero).

## Quick start
Make sure you use the same version number as Zero. Use the `zcalc` functions where you would use `calc`. They accept zero quantities and numbers, floats, strings (`"30+-0.3"`) and content. Units are combined and uncertainties are propagated automatically.

```typst
#import "@preview/zero:0.7.1": *
#import "@preview/zero-calc:0.7.1": *
#zcalc.div(m[30+-0.3], s[5+-0.4])
```

<p align="center">
<img alt="The result of the operation thirty plus minus zero point three divided by five plus minus zero point four rendered with the zero package" src="https://raw.githubusercontent.com/Ants-Aare/zero-calc/0.7.1/tests/readme/ref/1.png" />
</p>

## Chaining operations and variable history
The result of an operation can be passed as arguments for the next one.

```typst
#let value = zcalc.div(m[30+-1.45], s[5.0+-0.20]) // 30 / 5 = 6
#let value = zcalc.pow(value, 2)                  // 6^2 = 36
```

`display.method` rebuilds the calculation as a math equation and `display.error-method` does the same for the uncertainty.

```typst
#display.method(value)
#display.error-method(value)
```
<p align="center">
<img alt="At the top an equation with the operations on the left and the result with properly combined units on the right. At the bottom a complex series of operations calculating the error propagation using the values and units." src="https://raw.githubusercontent.com/Ants-Aare/zero-calc/0.7.1/tests/readme/ref/2.png" />
</p>


`display.variable(x)` shows a value like its regular output, `show-error: false` hides the uncertainty.

`display.error(x)` shows only the uncertainty.

### Options
`display.method` and `display.error-method` take these options:

| option | applies to | meaning |
| --- | --- | --- |
| `show-result` | both | add `= result` and return an equation (default `true`) |
| `equals` | both | the symbol between calculation and result (default `sym.eq`) |
| `depth` | both | how many operations are expanded (default: all) |
| `product` | both | symbol between factors, `auto` follows zero's `product`, `none` is juxtaposition |
| `show-units` | both | show the units of the operands |
| `show-error` | `method` | show the uncertainty of the operands (default `false`) |
| `fraction` | `method` | `"fraction"` (stacked) or `"inline"` (a / b) |
| `exponential` | `method` | `e^x` as a `"power"` or as the function `"function"` |

```typst
#let value = zcalc.div(m[30+-1.45], s[5.0+-0.20])
#let value = zcalc.sqrt(value, 2)
#display.method(value, depth: 1, block: true)
#display.method(value, show-error: true, fraction: "inline", block: true)
$ #display.method(value, show-result: false) + 1 $
```
<p align="center">
<img alt="The same calculation shown with only the outermost operation expanded, with the uncertainties of the operands and an inline fraction, and as part of a larger expression." src="https://raw.githubusercontent.com/Ants-Aare/zero-calc/0.7.1/tests/readme/ref/4.png" />
</p>

## Equations
**Zero-Calc** also understands Typst math equations by using [Parsely](https://typst.app/universe/package/parsely). Define an equation once and call it with the variables. Combine it freely with `zcalc` operations. Numbers written in the equation are constants.

```typst
#let kinetic-energy-math = $E_"kin" = 1/2 m v^2$
#let kinetic-energy-function = equation.define(kinetic-energy-math)
#let value = kinetic-energy-function(m: g[10], v: zcalc.div(m[30], s[5.0]))

#kinetic-energy-math
#display.method(value)
```
<p align="center">
<img alt="At the top a regular typst math equation. At the bottom the same equation with values and units filled in and the result displayed." src="https://raw.githubusercontent.com/Ants-Aare/zero-calc/0.7.1/tests/readme/ref/3.png" />
</p>

**Constants** do not limit the precision. Declare one with `zcalc.const`, as in the last line above, or use `zcalc.pi`, `zcalc.e` and `zcalc.tau`.

```typst
#let avogadro = zcalc.const(num("6.022e+23"))
```

## Units
Units are multiplied, divided and raised to powers with the values. Sums need equal units.

| function | does |
| --- | --- |
| `zcalc.convert-units(value, unit)` | converts into the given unit |
| `zcalc.convert-units-to-si(value)` | converts into SI base units |
| `convert-si: true` on an operation | converts the operands to SI first |
| `zcalc.set-preferred-units(rules)` | shows SI base unit combinations as named units (`kg m^2 s^-2` as `J`) |

```typst
#display.method(zcalc.convert-units(zi.km-h("3.6"), zi.declare("m/s")))
#display.method(zcalc.convert-units(zi.km("1.5"), zi.m))
```
<p align="center">
<img alt="3.6 kilometres per hour equals 1.0 metres per second, and 1.5 kilometres equals 1.5 times ten to the three metres." src="https://raw.githubusercontent.com/Ants-Aare/zero-calc/0.7.1/tests/readme/ref/5.png" />
</p>

`set-preferred-units` takes a list of rules `(match:, preferred:, exact-match:, factor:)`. For example `(match: zi.declare("kg m^2 s^-2"), preferred: zi.joule, exact-match: false)` shows the product of a force and a length in joule.

### Named arguments
Named arguments of a zero number or quantity (`exponent`, `product`, ...). The `alt` text of a unit is only kept while the unit does not change. Zero's global settings (`set-num`, `set-round`, `set-group`, `set-unit`) apply to results as usual. The precision that follows from the significant figures of a calculation wins over a global `set-round`.

## Plain numbers
`zcalc.to-float(value, unit: none)` and `zcalc.to-uncertainty(value, unit: none)` return plain floats in case you want to work with other packages. A number without an uncertainty gives `none`. With `unit` the value is converted first.

```typst
#zcalc.to-float(zi.km("1.5"), unit: zi.m)   // 1500
#zcalc.to-uncertainty("3.0+-0.1")            // 0.1
```

### Operations
| function | |
| --- | --- |
| `zcalc.add(a, b, ..)` | sum |
| `zcalc.sub(minuend, subtrahend, ..)` | difference |
| `zcalc.abs(value)`, `zcalc.neg(value)` | absolute value, negation |
| `zcalc.mul(a, b, ..)` | product |
| `zcalc.div(dividend, divisor)` | quotient |
| `zcalc.pow(base, exponent)`, `zcalc.exp(exponent)` | power, `e^x` |
| `zcalc.root(radicand, index)`, `zcalc.sqrt(radicand)` | roots |
| `zcalc.log(value, base)`, `zcalc.ln(value)` | logarithms |
| `zcalc.sin(angle)`, `zcalc.cos(angle)`, `zcalc.tan(angle)` | angles in rad, ° , ′ or ″ (radians without unit) |
| `zcalc.asin(value)`, `zcalc.acos(value)`, `zcalc.atan(value)` | result in `unit:` (default °) |

Every operation also takes named arguments for zero (`exponent: "eng"`, ...). Operations with units (`add`, `sub`, `mul`, `div`, `pow`, `root`, ...) also take `convert-si: true`.

### Constants, conversions, numbers
| | |
| --- | --- |
| `zcalc.const(value)` | a constant that does not limit the precision |
| `zcalc.pi`, `zcalc.e`, `zcalc.tau`, `zcalc.inf` | mathematical constants |
| `zcalc.convert-units(value, unit)` | convert into a unit, e.g. `zcalc.convert-units(zi.declare("m^3")(5e-5), zi.liter)` |
| `zcalc.convert-units-to-si(value)` | convert into SI base units |
| `zcalc.set-preferred-units(rules)` | named units for SI combinations |
| `zcalc.to-float(value, unit: none)` | plain float |
| `zcalc.to-uncertainty(value, unit: none)` | plain uncertainty, or `none` |

### Display
| | |
| --- | --- |
| `display.method(value, ..options)` | the calculation|
| `display.error-method(value, ..options)` | the uncertainty calculation, |
| `display.variable(value, show-error: true)` | one value |
| `display.error(value)` | the uncertainty of a value |

### Equations
| | |
| --- | --- |
| `equation.define(math)` | turns a math equation into a function of its variables |

## For package authors
The `impl` namespace gives access to the internals:

- `impl.operations` mirrors `zcalc` but takes and returns dictionaries instead of content, so results can be chained without packing and unpacking. Use it when you only display at the end.
- `impl.utility.normalise-quantity` turns zero quantities, strings, content and floats into such a dictionary (and fails on undefined and infinite values).
- `impl.utility-display.display-info` turns a dictionary into displayed content.
- `impl.units` manipulates units.
