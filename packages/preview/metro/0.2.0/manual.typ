#import "src/lib.typ": *
#import units: *
#import prefixes: *

#import "@preview/tablex:0.0.4": tablex, hlinex, vlinex

#let example(it, dir) = {
  set text(size: 1.2em)
  let (a, b) = (
    eval(
      it.text, 
      mode: "markup",
      scope: units._dict + prefixes._dict + (
        unit: unit,
        num: num,
        metro-setup: metro-setup,
        qty: qty,
        declare-unit: declare-unit,
        declare-power: declare-power,
        declare-qualifier: declare-qualifier,
        create-prefix: create-prefix,
        declare-prefix: declare-prefix
      )
    ),
    raw(it.text.replace("\\\n", "\n"), lang: "typ")
  )
  block(
    breakable: false,
    spacing: 0em,
    pad(
      left: 1em,
      stack(
        dir: dir,
        ..if dir == ltr {
          (a, 1fr, par(leading: 0.9em, b), 1fr)
        } else {
          (b, linebreak(), a)
        }
      )
    )
  )
}

#show raw.where(lang: "example"): it => {
  example(it, ltr)
}

#show raw.where(lang: "example-stack"): it => {
  example(it, ttb)
}

#show link: set text(blue)

#let param(term, t, default: none, description) = {
  let types = (
    ch: "Choice",
    nu: "Number",
    li: "Literal",
    sw: "Switch",
    "in": "Integer"
  )


  if default != none {
    if t == "ch" {
      default = repr(default)
    }
    default = align(top + right, [(default: #raw(default))])
  }

  t = text(types.at(t, default: t), font: "Source Code Pro")

  stack(
    dir: ltr, 
    [*#term*#h(0.6em, weak: true)#t], 
    default
  )
  block(pad(description, left: 2em), above: 0.65em)
}

#align(center)[
  #text(16pt)[Metro]

  #link("https://github.com/fenjalien")[fenjalien] and #link("https://github.com/Mc-Zen")[Mc-Zen] \
  https://github.com/fenjalien/typst-units \
  Version 0.2.0
]

#outline(indent: auto)

#pagebreak()

#set heading(numbering: "1.1")

= Introduction

The Metro package aims to be a port of the Latex package siunitx. It allows easy typesetting of numbers and units with options. This package is very early in development and many features are missing, so any feature requests or bug reports are welcome!

Metro's name comes from Metrology, the study scientific study of measurement.

= Usage
#set pad(left: 1em)

== Options

```typ
#metro-setup(..options)
```

Options for Metro's can be modified by using the `metro-setup` function. It takes an argument sink and saves any named parameters found. The options for each function are specified in their respective sections.

All options and function parameters use the following types:
/ `Literal`: Takes the given value directly. Input type is a string, content and sometimes a number.
/ `Switch`: On-off switches. Input type is a boolean.
/ `Choice`: Takes a limited number of choices, which are described separately for each option. Input type is a string.
/ `Number`: Takes a float or integer.

== Numbers
```typ
#num(number, e: none, pm: none, pwr: none, ..options)
```
Formats a number. All parameters listed can be given as a string, content (including inside an equation)  or a number.

Also note that explicitly written parts of a number when using a number type will be lost as Typst automatically parses them.

#param("number", "li")[
  The number to format.
]
#param("pm", "li", default: "none", [
  The uncertainty of the number.
])
#param("e", "li", default: "none", [
  The exponent of the number. It can also be given as an integer in the number parameter when it is of type string or content. It should be prefixed with an "e" or "E".
  ```example
  #num("1e10")\
  #num[1E10]
  ```
])
#param("pwr", "li", default: "none", [
  The power of the number, it will be attached to the top. No processing is currently done to the power. It can also be passed as an integer in the number parameter when it is of type string or content. It should be prefixed after the exponent with an "^".
  ```example
  #num("1^2")\
  $num(1^2)$
  ```
])

```example
#num(123)\
#num("1234")\
#num[12345]\
#num(0.123)\
#num("0,1234")\
#num[.12345]\
#num(e: -4)[3.45]\
#num("-1", e: 10, print-unity-mantissa: false)
```


=== Options

==== Parsing

#param("input-decimal-markers", "Array<Literal>", default: "('\.', ',')")[
  An array of characters that indicate the sepration between the integer and decimal parts of a number. More than one inupt decimal marker can be used, it will be converted by the pacakge to the appropriate output marker.
]

#param("retain-explicit-decimal-marker", "sw", default: "false")[
  Allows a trailing decimal marker with no decimal part present to be printed.
  ```example
  #num[10.]\
  #num(retain-explicit-decimal-marker: true)[10.]
  ```
]

#param("retain-explicit-plus", "sw", default: "false")[
  Allows a leading plus sign to be printed.
  ```example
  #num[+345]\
  #num(retain-explicit-plus: true)[+345]
  ```
]

#param("retain-negative-zero", "sw", default: "false")[
  Allows a negative sign on an entirely zero value.
  ```example
  #num[-0]\
  #num(retain-negative-zero: true)[-0]
  ```
]

==== Post Processing

#param("drop-exponent", "sw", default: "false", [
  When `true` the exponent will be dropped (_after_ the processing of exponent)

  ```example
  #num("0.01e3")\
  #num("0.01e3", drop-exponent: true)
  ```
])

#param("drop-uncertainty", "sw", default: "false")[
  When `true` the uncertainty will be dropped.
  ```example
  #num("0.01", pm: 0.02)\
  #num("0.01", pm: 0.02, drop-uncertainty: true)\
  ```
]

#param("drop-zero-decimal", "sw", default: "false")[
  When `true`, if the decimal is zero it will be dropped before setting the minimum numbers of digits.

  ```example
  #num[2.1]\
  #num[2.0]\
  #metro-setup(drop-zero-decimal: true)
  #num[2.1]\
  #num[2.0]\
  ```
]

#param("exponent-mode", "ch", default: "input")[
  How to convert the number to scientific notation. Note that the calculated exponent will be added to the given exponent for all options.

  / input: Does not perform any conversions, the exponent will be displayed as given. 
  / scientific: Converts the number such that the integer will always be a single digit.
  / fixed: Convert the number to use the exponent value given by the `fixed-exponent` option.
  / engineering: Converts the number such that the exponent will be a multiple of three.
  / threshold: Like the `scientific` option except it will only convert the number when the exponent would be outside the range given by the `exponent-thresholds` option.

  ```example
  #let nums = [
    #num[0.001]\
    #num[0.0100]\
    #num[1200]\
  ]
  #nums
  #metro-setup(exponent-mode: "scientific")
  #nums
  #metro-setup(exponent-mode: "engineering")
  #nums
  #metro-setup(exponent-mode: "fixed", fixed-exponent: 2)
  #nums
  ```
  #metro-reset()
]

#param("exponent-thresholds", "Array<Integer>", default: "(-3, 3)")[
  Used to control the range of exponents that won't trigger when the `exponent-mode` is "threshold". The first value is the minimum inclusive, and the last value is the maximum inclusive.

  ```example-stack
  #let inputs = (
    "0.001",
    "0.012",
    "0.123",
    "1",
    "12",
    "123",
    "1234"
  )

  #table(
    columns: (auto,)*3,
    [Input], [Threshold $-3:3$], [Threshold $-2:2$],
    ..for i in inputs {(
      num(i),
      num(i, exponent-mode: "threshold"),
      num(i, exponent-mode: "threshold", exponent-thresholds: (-2, 2)),
    )}
  )
  ```
]

#param("fixed-exponent", "Integer", default: "0")[
  The exponent value to use when `exponent-mode` is "fixed". When zero, this may be used to remove scientific notation from the input.

  ```example
  #num("1.23e4")\
  #num("1.23e4", exponent-mode: "fixed", fixed-exponent: 0)
  ```
]

#param("minimum-decimal-digits", "Integer", default: "0")[
  May be used to pad the decimal component of a number to a given size.
  ```example
  #num(0.123)\
  #num(0.123, minimum-decimal-digits: 2)\
  #num(0.123, minimum-decimal-digits: 4)
  ```
]

#param("minimum-integer-digits", "Integer", default: "0")[
  May be used to pad the integer component of a number to a given size.
  ```example
  #num(123)\
  #num(123, minimum-integer-digits: 2)\
  #num(123, minimum-integer-digits: 4)
  ```
]

==== Printing

#param("group-digits", "ch", default: "all")[
  Whether to group digits into blocks to increase the ease of reading of numbers. Takes the values `all`, `none`, `decimal` and `integer`. Grouping can be acitivated separately for the integer and decimal parts of a number using the appropriately named values.

  ```example
  #num[12345.67890]\
  #num(group-digits: "none")[12345.67890]\
  #num(group-digits: "decimal")[12345.67890]\
  #num(group-digits: "integer")[12345.67890]
  ```
]

#param("group-separator", "li", default: "sym.space.thin")[
  The separator to use between groups of digits.
  ```example
  #num[12345]\
  #num(group-separator: ",")[12345]\
  #num(group-separator: " ")[12345]
  ```
]

#param("group-minimum-digits", "in", default: "5")[
  Controls how many digits must be present before grouping is applied. The number of digits is considered separately for the integer and decimal parts of the number: grouping does not "cross the boundary".

  ```example
  #num[1234]\
  #num[12345]\
  #num(group-minimum-digits: 4)[1234]\
  #num(group-minimum-digits: 4)[12345]\
  #num[1234.5678]\
  #num[12345.67890]\
  #num(group-minimum-digits: 4)[1234.5678]\
  #num(group-minimum-digits: 4)[12345.67890]
  ```
]

#param("digit-group-size", "in", default: "3")[
  Controls the number of digits in each group. Finer control can be achieved using `digit-group-first-size` and `digit-group-other-size`: the first group is that immediately by the decimal point, the other value applies to the second and subsequent groupings.

  ```example
  #num[1234567890]\
  #num(digit-group-size: 5)[1234567890]\
  #num(digit-group-other-size: 2)[1234567890]
  ```
]

#param("output-decimal-marker", "li", default: ".")[
  The decimal marker used in the output. This can differ from the input marker.

  ```example
  #num(1.23)\
  #num(output-decimal-marker: ",")[1.23]
  ```
]

#param("exponent-base", "li", default: "10")[
  The base of an exponent.
  ```example
  #num(exponent-base: "2", e: 2)[1]
  ```
]

#param("exponent-product", "li", default: "sym.times")[
  The symbol to use as the product between the number and its exponent.
  ```example
  #num(e: 2, exponent-product: sym.times)[1]\
  #num(e: 2, exponent-product: sym.dot)[1]
  ```
]

#param("output-exponent-marker", "li", default: "none")[
  When not `none`, the value stored will be used in place of the normal product and base combination.
  ```example
  #num(output-exponent-marker: "e", e: 2)[1]\
  #num(output-exponent-marker: "E", e: 2)[1]
  ```
]

#param("bracket-ambiguous-numbers", "sw", default: "true")[
  There are certain combinations of numerical input which can be ambiguous. This can be corrected by adding brackets in the appropriate place.

  ```example
  #num(e: 4, pm: 0.3)[1.2]\
  #num(bracket-ambiguous-numbers: false, e: 4, pm: 0.3)[1.2]
  ```
]

#param("bracket-negative-numbers", "sw", default: "false")[
  Whether or not to display negative numbers in brackets.

  ```example
  #num[-15673]\
  #num(bracket-negative-numbers: true)[-15673]
  ```
]

#param("tight-spacing", "sw", default: "false")[
  Compresses spacing where possible.

  ```example
  #num(e: 3)[2]\
  #num(e: 3, tight-spacing: true)[2]
  ```
]

#param("print-implicit-plus", "sw", default: "false")[
  Force the number to have a sign. This is used if given and if no sign was present in the input.
  ```example
  #num(345)\
  #num(345, print-implicit-plus: true)
  ```
  It is possible to set this behaviour for the exponent and mantissa independently using `print-mantissa-implicit-plus` and `print-exponent-implicit-plus` respectively.
]

#param("print-unity-mantissa", "sw", default: "true")[
  Controls the printing of a mantissa of 1.
  ```example
  #num(e: 4)[1]\
  #num(e: 4, print-unity-mantissa: false)[1]
  ```
]

#param("print-zero-exponent", "sw", default: "false")[
  Controls the printing of an exponent of 0.
  ```example
  #num(e: 0)[444]\
  #num(e: 0, print-zero-exponent: true)[444]
  ```
]

#param("print-zero-integer", "sw", default: "true")[
  Controls the printing of an integer component of 0.
  ```example
  #num(0.123)\
  #num(0.123, print-zero-integer: false)
  ```
]

#param("zero-decimal-as-symbol", "sw", default: "false")[
  Whether to show entirely zero decimal parts as a symbol. Uses the symbol stroed using `zero-symbol` as the replacement.

  ```example
  #num[123.00]\
  #metro-setup(zero-decimal-as-symbol: true)
  #num[123.00]\
  #num(zero-symbol: [[#sym.bar.h]])[123.00]
  ```
]

#param("zero-symbol", "li", default: "sym.bar.h")[
  The symbol to use when `zero-decimal-as-symbol` is `true`.
]

== Units

```typ
#unit(unit, ..options)
```

Typsets a unit and provides full control over output format for the unit. The type passed to the function can be either a string or some math content.

When using math Typst accepts single characters but multiple characters together are expected to be variables. So Metro defines units and prefixes which you can import to be use. #pad[
  ```typ
  #import "@preview/metro:0.2.0": unit, units, prefixes
  #unit($units.kg m/s^2$)
  // because `units` and `prefixes` here are modules you can import what you need
  #import units: gram, metre, second
  #import prefixes: kilo
  $unit(kilo gram metre / second^2)$
  // You can also just import everything instead
  #import units: *
  #import prefixes: *
  $unit(joule / mole / kelvin)$
  ```

  #unit($units.kg m/s^2$)\
  $unit(kilo gram metre / second^2)$\
  $unit(joule / mole / kelvin)$
]

When using strings there is no need to import any units or prefixes as the string is parsed. Additionally several variables have been defined to allow the string to be more human readable. You can also use the same syntax as with math mode. 
```example-stack
// String
#unit("kilo gram metre per square second")\
// Math equivalent
#unit($kilo gram metre / second^2$)\
// String using math syntax
#unit("kilo gram metre / second^2")
```

`per` used as in "metres _per_ second" is equivalent to a slash `/`. When using this in a string you don't need to specify a numerator.
```example-stack
#unit("metre per second")\
$unit(metre/second)$\

#unit("per square becquerel")\
#unit("/becquerel^2")
```

`square` and `cubic` apply their respective powers to the units after them, while `squared` and `cubed` apply to units before them. 
```example-stack
#unit("square becquerel")\
#unit("joule squared per lumen")\
#unit("cubic lux volt tesla cubed")
```

Generic powers can be inserted using the `tothe` and `raiseto` functions. `tothe` specifically is equivalent to using caret `^`.
```example-stack
#unit("henry tothe(5)")\
#unit($henry^5$)\
#unit("henry^5")

#unit("raiseto(4.5) radian")\
#unit($radian^4.5$)\
#unit("radian^4.5")
```

You can also use the `sqrt` function for half powers. If you want to maintain the square root, you must set the `power-half-as-sqrt` option.

```example
$unit(sqrt(H))$\
#unit("sqrt(H)", power-half-as-sqrt: true)\
```

Generic qualifiers are available using the `of` function which is equivalent to using an underscore `_`. Note that when using an underscore for qualifiers in a string with a space, to capture the whole qualifier use brackets `()`.
```example-stack
#unit("kilogram of(metal)")\
#unit($kilogram_"metal"$)\
#unit("kilogram_metal")

#metro-setup(qualifier-mode: "bracket")
#unit("milli mole of(cat) per kilogram of(prod)")\
#unit($milli mole_"cat" / kilogram_"prod"$)\
#unit("milli mole_(cat) / kilogram_(prod)")
```

=== Options

#param("inter-unit-product", "li", default: "sym.space.thin", [
The separator between each unit. The default setting is a thin space: another common choice is a centred dot.
```example
#unit("farad squared lumen candela")\
#unit("farad squared lumen candela", inter-unit-product: $dot.c$)
```
])


#param("per-mode", "ch", default: "power", [
  Use to alter the handling of `per`. 

  / power: Reciprocal powers
  ```example
  #unit("joule per mole per kelvin")\
  #unit("metre per second squared")
  ```

  / fraction: Uses the `math.frac` function (also known as `$ / $`) to typeset positive and negative powers of a unit separately.
  ```example
  #unit("joule per mole per kelvin", per-mode: "fraction")\
  #unit("metre per second squared", per-mode: "fraction")
  ```

  / symbol: Separates the two parts of a unit using the symbol in `per-symbol`. This method for displaying units can be ambiguous, and so brackets are added unless `bracket-unit-denominator` is set to `false`. Notice that `bracket-unit-denominator` only applies when `per-mode` is set to symbol.
  ```example
  #metro-setup(per-mode: "symbol")
  #unit("joule per mole per kelvin")\
  #unit("metre per second squared")
  ```
])

#param("per-symbol", "li", default: "sym.slash")[
  The symbol to use to separate the two parts of a unit when `per-symbol` is `"symbol"`.
  ```example-stack
  #unit("joule per mole per kelvin", per-mode: "symbol", per-symbol: [ div ])
  ```
]

#param("bracket-unit-denominator", "sw", default: "true")[
  Whether or not to add brackets to unit denominators when `per-symbol` is `"symbol"`.
  ```example-stack
  #unit("joule per mole per kelvin", per-mode: "symbol", bracket-unit-denominator: false)
  ```
]

#metro-setup(per-mode: "power")

#param("sticky-per", "sw", default: "false")[
  Normally, `per` applies only to the next unit given. When `sticky-per` is `true`, this behaviour is changed so that `per` applies to all subsequent units.
  ```example
  #unit("pascal per gray henry")\
  #unit("pascal per gray henry", sticky-per: true)
  ```
]

#param("qualifier-mode", "ch", default: "subscript")[
  Sets how unit qualifiers can be printed.
  / subscript:
  ```example-stack
  #unit("kilogram of(pol) squared per mole of(cat) per hour")
  ```

  / bracket:
  ```example-stack
  #unit("kilogram of(pol) squared per mole of(cat) per hour", qualifier-mode: "bracket")
  ```

  / combine: Powers can lead to ambiguity and are automatically detected and brackets added as appropriate.
  ```example
  #unit("deci bel of(i)", qualifier-mode: "combine")
  ```

  / phrase: Used with `qualifier-phrase`, which allows for example a space or other linking text to be inserted.
  ```example-stack
  #metro-setup(qualifier-mode: "phrase", qualifier-phrase: sym.space)
  #unit("kilogram of(pol) squared per mole of(cat) per hour")\
  #metro-setup(qualifier-phrase: [ of ])
  #unit("kilogram of(pol) squared per mole of(cat) per hour")
  ```
]

#param("power-half-as-sqrt", "sw", default: "false")[
  When `true` the power of $0.5$ is shown by giving the unit sumbol as a square root. This 
  ```example
  #unit("Hz tothe(0.5)")\
  #unit("Hz tothe(0.5)", power-half-as-sqrt: true)
  ```
]

#metro-reset()

== Quantities

```typ
#qty(number, unit, ..options)
```

This function combines the functionality of `num` and `unit` and formats the number and unit together. The `number` and `unit` arguments work exactly like those for the `num` and `unit` functions respectively.

```example
#qty(1.23, "J / mol / kelvin")\
$qty(.23, candela, e: 7)$\
#qty(1.99, "per kilogram", per-mode: "symbol")\
#qty(1.345, "C/mol", per-mode: "fraction")
```

=== Options

#param("allow-quantity-breaks", "sw", default: "false")[
  Controls whether the combination of the number and unit can be split across lines.
  ```example-stack
  #box(width: 4.5cm)[Some filler text #qty(10, "m")]\
  #metro-setup(allow-quantity-breaks: true)
  #box(width: 4.5cm)[Some filler text #qty(10, "m")]
  ```
]

#param("quantity-product", "li", default: "sym.space.thin")[
  The product symbol between the number and unit.
  ```example-stack
  #qty(2.67, "farad")\
  #qty(2.67, "farad", quantity-product: sym.space)\
  #qty(2.67, "farad", quantity-product: none)
  ```
]

#param("separate-uncertainty", "ch", default: "bracket")[
  When a number has multiple parts, then the unit must apply to all parts of the number.

  / bracket: Places the entire numericalpart in brackets and use a single unit symbol.
  ```example
  #qty(12.3, "kg", pm: 0.4)
  ```

  / repeat: Prints the unit for each part of the number.
  ```example
  #qty(12.3, "kg", pm: 0.4, separate-uncertainty: "repeat")
  ```

  / single: Prints only one unit symbol: mathematically incorrect.
  ```example
  #qty(12.3, "kg", pm: 0.4, separate-uncertainty: "single")
  ```
]

= Meet the Units

The following tables show the currently supported prefixes, units and their abbreviations. Note that unit abbreviations that have single letter commands are not available for import for use in math. This is because math mode already accepts single letter variables.


// Turn off tables while editing docs as compiling tablex is very slow
#if true {

set figure(kind: "Table", supplement: "Table")

let generate(..units) = {
  units.pos().map(x => {
    let (name, command) = if type(x) == "array" {
      x
    } else {
      (x, x)
    }
    (name, raw(command), unit(command))
  }).join()
}

let headers = ([Unit], [Command], [Symbol])

figure(
  tablex(
    columns: 3,
    auto-lines: false,
    hlinex(),
    ..headers,
    hlinex(),
    ..generate(
      "ampere",
      "candela",
      "kelvin",
      "kilogram",
      "metre",
      "mole",
      "second"
    ),
    hlinex(),
  ),
  caption: [SI base units.]
)

figure(
  tablex(
    columns: 6,
    auto-lines: false,
    hlinex(),
    ..headers * 2,
    hlinex(),
    ..generate(
      "becquerel", "newton",
      ("degree Celsius", "degreeCelsius"), "ohm",
      "coulomb", "pascal",
      "farad", "radian",
      "gray", "siemens",
      "hertz", "sievert",
      "henry", "steradian",
      "joule", "tesla",
      "lumen", "volt",
      "katal", "watt",
      "lux", "weber"
    ),
    hlinex()
  ),
  caption: [Coherent derived units in the SI with special names and symbols.]
)

figure(
  tablex(
    columns: 3,
    auto-lines: false,
    hlinex(),
    ..headers,
    hlinex(),
    ..generate(
      "astronomicalunit",
      "bel",
      "dalton",
      "day",
      "decibel",
      "degree",
      "electronvolt",
      "hectare",
      "hour",
      "litre",
      ("", "liter"),
      ("minute (plane angle)", "arcminute"),
      ("minute (time)", "minute"),
      ("second (plane angle)", "arcsecond"),
      "neper",
      "tonne"
    ),
    hlinex(),
  ),
  caption: [Non-SI units accepted for use with the International System of Units.]
)

figure(
  tablex(
    columns: 3,
    auto-lines: false,
    hlinex(),
    ..headers,
    hlinex(),
    ..generate(
      "byte",
    ),
    hlinex(),
  ),
  caption: [Non-SI units.]
)

figure(
  tablex(
    columns: 8,
    auto-lines: false,
    hlinex(),
    ..([Prefix], [Command], [Symbol], [$10^x$]) * 2,
    hlinex(),
    ..((
      ("quecto", -30), ("deca", 1),
      ("ronto", -27), ("hecto", 2),
      ("yocto", -24), ("kilo", 3), 
      ("atto", -21), ("mega", 6),
      ("zepto", -18), ("giga", 9),
      ("femto", -15), ("tera", 12),
      ("pico", -12), ("peta", 15),
      ("nano", -9), ("exa", 18),
      ("micro", -6), ("zetta", 21),
      ("milli", -3), ("yotta", 24),
      ("centi", -2), ("ronna", 27),
      ("deci", -1), ("quetta", 30)
    ).map(x => (x.first(), raw(x.first()), unit(x.first()), num(x.last()))).join()),
    hlinex(),
  ),
  caption: [SI prefixes]
)
figure(
  tablex(
    columns: 4,
    auto-lines: false,
    hlinex(),
    [Prefix], [Command], [Symbol], [$2^x$],
    hlinex(),
    ..((
      ("kibi", 10),
      ("mebi", 20),
      ("gibi", 30),
      ("tebi", 40),
      ("pebi", 50),
      ("exbi", 60),
      ("zebi", 70),
      ("yobi", 80),
    ).map(x => (x.first(), raw(x.first()), unit(x.first()), num(x.last()))).join()),
    hlinex(),
  ),
  caption: [Binary prefixes]
)

let ge(..xs) = {
  let xs = xs.pos()
  for i in range(0, xs.len()-1, step: 2) {
    let name = xs.at(i)
    let abbr = xs.at(i+1)
    (name, raw(abbr), unit(abbr))
  }
}

page(
  margin: 1cm,
  figure(
    caption: [Unit abbreviations],
    stack(
      dir: ltr,
      tablex(
        columns: 3,
        auto-lines: false,
        hlinex(),
        [Unit], [Abbreviation], [Symbol],
        hlinex(),
        ..ge(
          "femtogram", "fg",
          "picogram", "pg",
          "nanogram", "ng",
          "microgram", "ug",
          "milligram", "mg",
          "gram", "g",
          "kilogram", "kg"
        ),
        hlinex(),
        ..ge(
          "picometre", "pm",
          "nanometre", "nm",
          "micrometre", "um",
          "millimetre", "mm",
          "centimetre", "cm",
          "decimetre", "dm",
          "metre", "m",
          "kilometre", "km",
        ),
        hlinex(),
        ..ge(
          "attosecond", "as",
          "femtosecond", "fs",
          "picosecond", "ps",
          "nanosecond", "ns",
          "microsecond", "us",
          "millisecond", "ms",
          "second", "s",
        ),
        hlinex(),
        ..ge(
          "femtomole", "fmol",
          "picomole", "pmol",
          "nanomole", "nmol",
          "micromole", "umol",
          "millimole", "mmol",
          "mole", "mol",
          "kilomole", "kmol",
        ),
        hlinex(),
        ..ge(
          "picoampere", "pA",
          "nanoampere", "nA",
          "microampere", "uA",
          "milliampere", "mA",
          "ampere", "A",
          "kiloampere", "kA",
        ),
        hlinex(),
        ..ge(
          "microlitre", "uL",
          "millilitre", "mL",
          "litre", "L",
          "hectolitre", "hL",
        )
      ),
      tablex(
        columns: 3,
        auto-lines: false,
        vlinex(),
        hlinex(),
        [Unit], [Abbreviation], [Symbol],
        hlinex(),
        ..ge(
          "millihertz", "mHz",
          "hertz", "Hz",
          "kilohertz", "kHz",
          "megahertz", "MHz",
          "gigahertz", "GHz",
          "terahertz", "THz",
        ),
        hlinex(),
        ..ge(
          "millinewton", "mN",
          "newton", "N",
          "kilonewton", "kN",
          "meganewton", "MN",
        ),
        hlinex(),
        ..ge(
          "pascal", "Pa",
          "kilopascal", "kPa",
          "megapascal", "MPa",
          "gigapascal", "GPa",
        ),
        hlinex(),
        ..ge(
          "milliohm", "mohm",
          "kilohm", "kohm",
          "megohm", "Mohm",
        ),
        hlinex(),
        ..ge(
          "picovolt", "pV",
          "nanovolt", "nV",
          "microvolt", "uV",
          "millivolt", "mV",
          "volt", "V",
          "kilovolt", "kV",
        ),
        hlinex(),
        ..ge(
          "watt", "W",
          "nanowatt", "nW",
          "microwatt", "uW",
          "milliwatt", "mW",
          "kilowatt", "kW",
          "megawatt", "MW",
          "gigawatt", "GW",
        ),
        hlinex(),
        ..ge(
          "joule", "J",
          "microjoule", "uJ",
          "millijoule", "mJ",
          "kilojoule", "kJ",
        ),
        hlinex(),
        ..ge(
          "electronvolt", "eV",
          "millielectronvolt", "meV",
          "kiloelectronvolt", "keV",
          "megaelectronvolt", "MeV",
          "gigaelectronvolt", "GeV",
          "teraelectronvolt", "TeV",
        ),
        hlinex(),
        ..ge(
          "kilowatt hour", "kWh"
        )
      ),
      tablex(
        columns: 3,
        auto-lines: false,
        vlinex(),
        hlinex(),
        [Unit], [Abbreviation], [Symbol],
        hlinex(),
        ..ge(
          "farad", "F",
          "femtofarad", "fF",
          "picofarad", "pF",
          "nanofarad", "nF",
          "microfarad", "uF",
          "millifarad", "mF",
        ),
        hlinex(),
        ..ge(
          "henry", "H",
          "femtohenry", "fH",
          "picohenry", "pH",
          "nanohenry", "nH",
          "millihenry", "mH",
          "microhenry", "uH",
        ),
        hlinex(),
        ..ge(
          "coulomb", "C",
          "nanocoulomb", "nC",
          "millicoulomb", "mC",
          "microcoulomb", "uC",
        ),
        hlinex(),
        ..ge(
          "kelvin", "K",
          "decibel", "dB",
          "astrnomicalunit", "au",
          "becquerel", "Bq",
          "candela", "cd",
          "dalton", "Da",
          "gray", "Gy",
          "hectare", "ha",
          "katal", "kat",
          "lumen", "lm",
          "neper", "Np",
          "radian", "rad",
          "sievert", "Sv",
          "steradian", "sr",
          "weber", "Wb"
        ),
        hlinex(),
        ..ge(
          "kilobyte", "kB",
          "megabyte", "MB",
          "gigabyte", "GB",
          "terabyte", "TB",
          "petabyte", "PB",
          "exabyte", "EB",
          "kibibyte", "KiB",
          "mebibyte", "MiB",
          "gibibyte", "GiB",
          "tebibyte", "TiB",
          "pebibyte", "PiB",
          "exbibyte", "EiB",
        ),
      )
    )
  )
)
}

= Creating 

The following functions can be used to define cutom units, prefixes, powers and qualifiers that can be used with the `unit` function.

== Units
```typ
#declare-unit(unit, symbol, ..options)
```

Declare's a custom unit to be used with the `unit` and `qty` functions.

#param("unit", "string")[The string to use to identify the unit for string input.]
#param("symbol", "li")[The unit's symbol. A string or math content can be used. When using math content it is recommended to pass it through `unit` first.]

```example-stack
#let inch = "in"
#declare-unit("inch", inch)
#unit("inch / s")\
#unit($inch / s$)
```

== Prefixes
```typ
#create-prefix(symbol)
```
Use this function to correctly create the symbol for a prefix. Metro uses Typst's #link("https://typst.app/docs/reference/math/class/", `math.class`) function with the `class` parameter `"unary"` to designate a prefix. This function does it for you.

#param("symbol", "li")[The prefix's symbol. A string or math content can be used. When using math content it is recommended to pass it through `unit` first.]

```typ
#declare-prefix(prefix, symbol, power-tens)
```

Declare's a custom prefix to be used with the `unit` and `qty` functions.

#param("prefix", "string")[The string to use to identify the prefix for string input.]
#param("symbol", "li")[The prefix's symbol. This should be the output of the `create-prefix` function specified above.]
#param("power-tens", "nu")[The power ten of the prefix.]

```example-stack
#let myria = create-prefix("my")
#declare-prefix("myria", myria, 4)
#unit("myria meter")\
#unit($myria meter$)
```

== Powers
```typ
#declare-power(before, after, power)
```

This function adds two symbols for string input, one for use before a unit, the second for use after a unit, both of which are equivalent to the `power`. 

#param("before", "string")[The string that specifies this power before a unit.]
#param("after", "string")[The string that specifies this power after a unit.]
#param("power", "nu")[The power.]

```example-stack
#declare-power("quartic", "tothefourth", 4)
#unit("kilogram tothefourth")\
#unit("quartic metre")
```

== Qualifiers
```typ
#declare-qualifier(qualifier, symbol)
```

This function defines a custom qualifier for string input.

#param("qualifier", "string")[The string that specifies this qualifier.]
#param("symbol", "li")[The qualifier's symbol. Can be string or content.]

```example-stack
#declare-qualifier("polymer", "pol")
#declare-qualifier("catalyst", "cat")
#unit("gram polymer per mole catalyst per hour")
```