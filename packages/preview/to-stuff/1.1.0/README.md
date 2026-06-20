# To-Stuff

To-Stuff is a collection of [Typst](https://typst.app/) functions for converting string values to native types. This is most useful when loading layout data from an external configuration source, such as a YAML file.

- Avoids any use of [`eval()`][typst_eval].
- All [direct conversion functions](#direct-conversion-functions) optionally accept a default value to return on failure.
- Where no default value is specified, a failed direct conversion panics with a sensible error message.


## How to use

Import the package into the current scope, optionally renamed using the `as` keyword:

```typ
#import "@preview/to-stuff:1.1.0"
// Bindings available as to-stuff.alignment(), to-stuff.angle(), etc.

// …or…

#import "@preview/to-stuff:1.1.0" as to
// Bindings available as to.alignment(), to.angle(), etc.
```

The package’s `let` bindings have the same names as their return types, and rely on Typst’s `import` syntax to scope safely. It is not recommended to load the individual bindings into the current scope, as that may cause [collisions with the types themselves][typst_shadow].

```typ
#assert(type(42pt) == length) // Expected behaviour

#import "@preview/to-stuff:1.1.0": * // NOT RECOMMENDED

#assert(type(42pt) != length) // To-Stuff bindings collide with standard types
#assert(type(42pt) == std.length) // Workaround
```


## Localisation

All conversions involving numeric values assume the number strings to be in a format understood by Typst code; specifically:

- All numeric digits must be ASCII characters 0-9 and/or A-F (case non-sensitive).
- Decimal separators must be a full stop/period; commas, apostrophes, etc. are not supported.
- Thousands separators are not supported.


## General Purpose Function

### `stuff`

Attempts to convert a value to the most appropriate data type, based on brute-force process of elimination. If no valid conversion can be found, the original value is returned unaltered.

Unlike the [direct conversion functions](#direct-conversion-functions), this function does not panic in the event of a failed conversion, and does not accept a default value.

```typ
#stuff(
	value, // any
	recursive: false, // bool
	arguments-collapse: false, // bool
	numbers-as: auto, // type
	none-from: (), // str | array
	skip-strings: (), // type | array
	skip-dictionaries: (), // type | array
) -> any
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `array` or `dictionary` or `arguments` or [others](#direct-conversion-functions) (positional, required)

The value that should be converted to a native data type.

- A string with the value `"auto"` is converted to `auto`.
- A string representation of a native data type that is recognised by a [direct conversion function](#direct-conversion-functions) is converted accordingly.
- A `dictionary` that conforms to a valid [`alignment`](#alignment), [`relative`](#relative) or [`stroke`](#stroke) is converted.
- An `array` that conforms to a valid [`version`](#version) is converted.
- Any other value is returned unchanged.

#### `recursive`

`bool`

Whether to recurse through the items of `arguments` and `array` values, and of `dictionary` values that could not otherwise be converted.

Note that recursing an `array` means that it will not be converted to a single `version`, even if otherwise suitable; `version`-like strings will still be converted as expected.

Default: `false`

#### `arguments-collapse`

`bool`

Whether to return an `arguments` value as an `array` or `dictionary`, where possible.

Has no effect when `recursive` is not `true`.

- A setting of `true` returns an `arguments` value with no named arguments as an `array`, or an `arguments` value with no positional arguments as a `dictionary`. An `arguments` value with both named and positional arguments will always be returned as an `arguments`.
- A setting of `false` returns an `arguments` value as an `arguments`, regardless of its lack of named or positional arguments.

Default: `false`

#### `numbers-as`

`type`

The standard type to which to attempt to convert basic numbers.

- A setting of [`std.int`](#int) converts `decimal`s, `float`s and eligible strings to `int` types.
- A setting of [`std.float`](#float) converts `int`s, `decimal`s and eligible strings to `float` types.
- A setting of [`std.decimal`](#decimal) converts `int`s and eligible strings to `decimal` types, but [ignores `float`s][typst_decimal].
- A setting of [`std.version`](#version) converts `int`s and eligible strings to `version` types, but ignores `float`s and `decimal`s.
- A setting of `auto` applies the [`number`](#number) direct conversion function, which if successful returns either an `int` or a `float` as appropriate.

Default: `auto`

#### `none-from`

`str` or `array`

A string (or list of strings) to convert to `none`. Case non-sensitive.

Default: `()`

#### `skip-strings`

`type` or `array`

Standard type (or list of standard types) to which **not** to attempt to convert string values.

This argument may be one or more of:

- [`std.alignment`](#alignment)
- [`std.angle`](#angle)
- [`std.bool`](#bool)
- [`std.color`](#color)
- [`std.direction`](#direction)
- [`std.fraction`](#fraction)
- [`std.length`](#length)
- [`std.ratio`](#ratio)
- [`std.relative`](#relative)
- [`std.stroke`](#stroke)
- [`std.version`](#version)

Default: `()`

#### `skip-dictionaries`

`type` or `array`

Standard type (or list of standard types) to which **not** to attempt to convert `dictionary` values.

This argument may be one or more of:

- [`std.alignment`](#alignment)
- [`std.relative`](#relative)
- [`std.stroke`](#stroke)

Default: `()`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.stuff("auto")
// -> auto

#let ex02 = to.stuff("true")
// -> true

#let ex03 = to.stuff("top + right")
// -> right + top

#let ex04 = to.stuff((x: "right", y: "top"))
// -> right + top

#let ex05 = to.stuff("45deg")
// -> 45deg

#let ex06 = to.stuff("rgb(255, 65, 54)")
// -> rgb("#ff4136")

#let ex07 = to.stuff("rtl")
// -> rtl

#let ex08 = to.stuff("25e-1")
// -> 2.5

#let ex09 = to.stuff("2.5fr")
// -> 2.5fr

#let ex10 = to.stuff("0x2a")
// -> 42

#let ex11 = to.stuff("45pt")
// -> 45pt

#let ex12 = to.stuff("45%")
// -> 45%

#let ex13 = to.stuff("45pt + 3%")
// -> 3% + 45pt

#let ex14 = to.stuff((ratio: "3%", length: "45pt"))
// -> 3% + 45pt

#let ex15 = to.stuff("2pt + red + densely-dashed")
// -> (paint: rgb("#ff4136"), thickness: 2pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let ex16 = to.stuff((paint: red, thickness: 2pt, dash: "densely-dashed"))
// -> (paint: rgb("#ff4136"), thickness: 2pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let ex17 = to.stuff(recursive: true, (
	mixed: ("A", "2", "33.3%", "auto", "5pt", "horizon + center"),
	origin: (x: "center", y: "horizon"),
	line: (thickness: "0.5pt", paint: "blue", dash: "dotted"),
))
/* -> (
	mixed: ("A", 2, 33.3%, auto, 5pt, center + horizon),
	origin: center + horizon,
	line: (paint: rgb("#0074d9"), thickness: 0.5pt, dash: (array: ("dot", 2pt), phase: 0pt)),
) */

#let ex18 = to.stuff(recursive: true, skip-strings: alignment, (
	mixed: ("A", "2", "33.3%", "auto", "5pt", "horizon + center"),
	origin: (x: "center", y: "horizon"),
	line: (thickness: "0.5pt", paint: "blue", dash: "dotted"),
))
/* -> (
	mixed: ("A", 2, 33.3%, auto, 5pt, "horizon + center"),
	origin: center + horizon,
	line: (paint: rgb("#0074d9"), thickness: 0.5pt, dash: (array: ("dot", 2pt), phase: 0pt)),
) */

#let ex19 = to.stuff(recursive: true, skip-dictionaries: alignment, (
	mixed: ("A", "2", "33.3%", "auto", "5pt", "horizon + center"),
	origin: (x: "center", y: "horizon"),
	line: (thickness: "0.5pt", paint: "blue", dash: "dotted"),
))
/* -> (
	mixed: ("A", 2, 33.3%, auto, 5pt, center + horizon),
	origin: (x: center, y: horizon),
	line: (paint: rgb("#0074d9"), thickness: 0.5pt, dash: (array: ("dot", 2pt), phase: 0pt)),
) */

#let ex20 = to.stuff(recursive: true, arguments-collapse: false, arguments(paint: "black", thickness: "0.9pt"))
// -> arguments(paint: luma(0%), thickness: 0.9pt)

#let ex21 = to.stuff(recursive: true, arguments-collapse: true, arguments(paint: "black", thickness: "0.9pt"))
// -> 0.9pt + luma(0%)

#let ex22 = to.stuff(numbers-as: version, "2.5")
// -> version(2, 5)

#let ex23 = to.stuff(numbers-as: decimal, "2.5")
// -> decimal("2.5")

#let ex24 = to.stuff(numbers-as: float, "2.5")
// -> 2.5

#let ex25 = to.stuff(numbers-as: int, "2.5")
// -> 2

#let ex26 = to.stuff(recursive: false, ("2", "5"))
// -> version(2, 5)

#let ex27 = to.stuff(recursive: true, ("2", "5"))
// -> (2, 5)

#let ex28 = to.stuff("")
// -> ""

#let ex29 = to.stuff(none-from: "", "")
// -> none

#let ex30 = to.stuff(none-from: ("", "none"), "none")
// -> none

#let ex31 = to.stuff(none-from: ("", "none"), "nil")
// -> "nil"
```
</details>


## Direct Conversion Functions

### `alignment`

Attempts to convert a value to an `alignment`.

```typ
#alignment(
	value, // str | alignment | dictionary
	default: auto, // auto | none | alignment
) -> none | alignment
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `alignment` or `dictionary` (positional, required)

The value that should be converted to an `alignment`.

- An `alignment` is returned unchanged.
- A string representation of any of the eight `alignment` values is converted to that value.
	- The string must not contain any scoping prefix, e.g. `alignment.…`, or the conversion will fail.
- A string consisting of two `alignment` representations joined by a plus sign is converted to the corresponding 2D alignment.
	- The two alignments must be on different axes, or the conversion will fail.
- A `dictionary` containing one or more of the keys `x` and `y`, and no other keys, is converted.
	- The value of `x`, if present, must be either a horizontal `alignment` or a value that would convert to one.
	- The value of `y`, if present, must be either a vertical `alignment` or a value that would convert to one.

#### `default`

`auto` or `none` or `alignment`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.alignment("top + right")
// -> right + top

#let ex02 = to.alignment(top + right)
// -> right + top

#let ex03 = to.alignment((x: "right", y: "top"))
// -> right + top

#let ex04 = to.alignment("turnwise")
// panics with: could not convert to alignment: "turnwise"

#let ex05 = to.alignment("top + bottom")
// panics with: cannot add two vertical alignments: "top + bottom"

#let ex06 = to.alignment(default: top + right, "top + bottom")
// -> right + top

#let ex07 = to.alignment(default: none, "top + bottom")
// -> none
```
</details>


### `angle`

Attempts to convert a value to an `angle`.

```typ
#angle(
	value, // str | angle
	default: auto, // auto | none | angle
) -> none | angle
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `angle` (positional, required)

The value that should be converted to an `angle`.

- An `angle` is returned unchanged.
- A string representation of a number followed by the letters `deg` or `rad` is converted.
	- The number may be positive or negative, and may contain decimal places and/or an exponent.

#### `default`

`auto` or `none` or `angle`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.angle("45deg")
// -> 45deg

#let ex02 = to.angle(45deg)
// -> 45deg

#let ex03 = to.angle("42")
// panics with: could not convert to angle: "42"

#let ex04 = to.angle(default: 45deg, "42")
// -> 45deg

#let ex05 = to.angle(default: none, "42")
// -> none
```
</details>


### `bool`

Attempts to convert a value to a `bool`.

```typ
#bool(
	value, // str | bool
	default: auto, // auto | none | bool
) -> none | bool
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `bool` (positional, required)

The value that should be converted to a `bool`.

- A `bool` is returned unchanged.
- A string value of `"true"` is converted to `true`. Case non-sensitive.
- A string value of `"false"` is converted to `false`. Case non-sensitive.


#### `default`

`auto` or `none` or `bool`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.bool("true")
// -> true

#let ex02 = to.bool(true)
// -> true

#let ex03 = to.bool("auto")
// panics with: could not convert to boolean: "auto"

#let ex04 = to.bool(default: true, "auto")
// -> true

#let ex05 = to.bool(default: none, "auto")
// -> none
```
</details>


### `color`

Attempts to convert a value to a `color`.

```typ
#color(
	value, // str | color
	default: auto, // auto | none | color
) -> none | color
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `color` (positional, required)

The value that should be converted to a `color`.

- A `color` is returned unchanged.
- A string representation of a predefined color value is converted to that built-in color.
- A string representation of an optional hash symbol followed by a 3-, 4-, 6-, or 8-digit hexadecimal code is converted to the corresponding RGB or RGBA value.
	- *Deprecated*: the hash symbol will no longer be optional in To-Stuff version `2.0.0`.
- A string representation of a color space function followed by parentheses and arguments is converted.
	- The string must not contain any scoping prefix, e.g. `color.…`, or the conversion will fail. This includes the `hsl`, `hsv`, and `linear-rgb` functions.

#### `default`

`auto` or `none` or `color`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.color("red")
// -> rgb("#ff4136")

#let ex02 = to.color(red)
// -> rgb("#ff4136")

#let ex03 = to.color("#FF4136FF")
// -> rgb("#ff4136")

#let ex04 = to.color("rgb(255, 65, 54)")
// -> rgb("#ff4136")

#let ex05 = to.color("hsv(135deg,75%,127,100)")
// -> color.hsv(135deg, 75%, 49.8%, 39.22%)

#let ex06 = to.color("indigo")
// panics with: could not convert to color: "indigo"

#let ex07 = to.color(default: red, "indigo")
// -> rgb("#ff4136")

#let ex08 = to.color(default: none, "indigo")
// -> none
```
</details>


### `decimal`

Attempts to convert a value to a `decimal`.

While the standard [`decimal` constructor][typst_decimal] throws an error on failure, this function [panics][typst_panic] instead, which may be suppressed if desired via the `default` argument.

```typ
#decimal(
	value, // str | int | decimal
	default: auto, // auto | none | int | decimal
) -> none | decimal
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `int` or `decimal` (positional, required)

The value that should be converted to a `decimal`.

- A `decimal` is returned unchanged.
- An `int` is converted.
- A string representation of a number is converted.
	- The number may be positive or negative, and may contain decimal places, but not an exponent.
	- Hexadecimal numbers, prefixed with `0x`, are permitted.
	- Octal numbers, prefixed with `0o`, are permitted.
	- Binary numbers, prefixed with `0b`, are permitted.

#### `default`

`auto` or `none` or `int` or `decimal`

What to return if `value` could not be converted; `int` defaults are converted to `decimal`. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.decimal("42")
// -> decimal("42")

#let ex02 = to.decimal(42)
// -> decimal("42")

#let ex03 = to.decimal("0x2a")
// -> decimal("42")

#let ex04 = to.decimal(0x2a)
// -> decimal("42")

#let ex05 = to.decimal("2.5")
// -> decimal("2.5")

#let ex06 = to.decimal(2.5)
// panics with: could not convert to decimal: 2.5

#let ex07 = to.decimal("25e-1")
// panics with: could not convert to decimal: "25e-1"

#let ex08 = to.decimal(default: 42, "25e-1")
// -> decimal("42")

#let ex09 = to.decimal(default: none, "25e-1")
// -> none
```
</details>


### `direction`

Attempts to convert a value to a `direction`.

```typ
#direction(
	value, // str | direction
	default: auto, // auto | none | direction
) -> none | direction
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `direction` (positional, required)

The value that should be converted to a `direction`.

- A `direction` is returned unchanged.
- A string representation of any of the four `direction` values is converted to that value.
	- The string must not contain any scoping prefix, e.g. `direction.…`, or the conversion will fail.


#### `default`

`auto` or `none` or `direction`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.direction("rtl")
// -> rtl

#let ex02 = to.direction(rtl)
// -> rtl

#let ex03 = to.direction("btf")
// panics with: could not convert to direction: "btf"

#let ex04 = to.direction(default: rtl, "btf")
// -> rtl

#let ex05 = to.direction(default: none, "btf")
// -> none
```
</details>


### `float`

Attempts to convert a value to a `float`.

While the standard [`float` constructor][typst_float] throws an error on failure, this function [panics][typst_panic] instead, which may be suppressed if desired via the `default` argument.

```typ
#float(
	value, // str | int | float | decimal
	default: auto, // auto | none | int | float | decimal
) -> none | float
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `int` or `float` or `decimal` (positional, required)

The value that should be converted to a `float`.

- A `float` is returned unchanged.
- A `decimal` or `int` is converted.
- A string representation of a number is converted.
	- The number may be positive or negative, and may contain decimal places and/or an exponent.
	- Hexadecimal numbers, prefixed with `0x`, are permitted.
	- Octal numbers, prefixed with `0o`, are permitted.
	- Binary numbers, prefixed with `0b`, are permitted.

#### `default`

`auto` or `none` or `int` or `float` or `decimal`

What to return if `value` could not be converted; `decimal` and `int` defaults are converted to `float`. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.float("42")
// -> 42.0

#let ex02 = to.float(42)
// -> 42.0

#let ex03 = to.float("2.5")
// -> 2.5

#let ex04 = to.float(2.5)
// -> 2.5

#let ex05 = to.float(25e-1)
// -> 2.5

#let ex06 = to.float("25e-1")
// -> 2.5

#let ex07 = to.float("0x2a")
// -> 42.0

#let ex08 = to.float(0x2a)
// -> 42.0

#let ex09 = to.float("42%")
// panics with: could not convert to float: "42%"

#let ex10 = to.float(default: 42, "42%")
// -> 42.0

#let ex11 = to.float(default: none, "42%")
// -> none
```
</details>


### `fraction`

Attempts to convert a value to a `fraction`.

```typ
#fraction(
	value, // str | fraction
	default: auto, // auto | none | fraction
) -> none | fraction
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `fraction` (positional, required)

The value that should be converted to a `fraction`.

- A `fraction` is returned unchanged.
- A string representation of a number followed by the letters `fr` is converted.
	- The number may be positive or negative, and may contain decimal places and/or an exponent.

#### `default`

`auto` or `none` or `fraction`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.fraction("2.5fr")
// -> 2.5fr

#let ex02 = to.fraction(2.5fr)
// -> 2.5fr

#let ex03 = to.fraction("42")
// panics with: could not convert to fraction: "42"

#let ex04 = to.fraction(default: 2.5fr, "42")
// -> 2.5fr

#let ex05 = to.fraction(default: none, "42")
// -> none
```
</details>


### `int`

Attempts to convert a value to an `int`.

While the standard [`int` constructor][typst_int] throws an error on failure, this function [panics][typst_panic] instead, which may be suppressed if desired via the `default` argument.

This function can also parse correctly-prefixed strings in hexadecimal, octal and binary.

```typ
#int(
	value, // str | int | float | decimal
	default: auto, // auto | none | int
) -> none | int
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `int` or `float` or `decimal` (positional, required)

The value that should be converted to an `int`.

- An `int` is returned unchanged.
- A `decimal` or `float` is rounded towards zero and converted.
- A string representation of a number is converted.
	- The number may be positive or negative, and may contain decimal places and/or an exponent.
	- Hexadecimal numbers, prefixed with `0x`, are permitted.
	- Octal numbers, prefixed with `0o`, are permitted.
	- Binary numbers, prefixed with `0b`, are permitted.

#### `default`

`auto` or `none` or `int`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.int("42")
// -> 42

#let ex02 = to.int(42)
// -> 42

#let ex03 = to.int("2.5")
// -> 2

#let ex04 = to.int(2.5)
// -> 2

#let ex05 = to.int(25e-1)
// -> 2

#let ex06 = to.int("25e-1")
// -> 2

#let ex07 = to.int("0x2a")
// -> 42

#let ex08 = to.int(0x2a)
// -> 42

#let ex09 = to.int("42%")
// panics with: could not convert to int: "42%"

#let ex10 = to.int(default: 42, "42%")
// -> 42

#let ex11 = to.int(default: none, "42%")
// -> none
```
</details>


### `length`

Attempts to convert a value to a `length`.

```typ
#length(
	value, // str | length
	default: auto, // auto | none | length
) -> none | length
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `length` (positional, required)

The value that should be converted to a `length`.

- A `length` is returned unchanged.
- A string representation of a number followed by the letters `pt`, `mm`, `cm`, `in`, or `em`, is converted.
	- The number may be positive or negative, and may contain decimal places and/or an exponent.

#### `default`

`auto` or `none` or `length`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.length("45pt")
// -> 45pt

#let ex02 = to.length(45pt)
// -> 45pt

#let ex03 = to.length("42")
// panics with: could not convert to length: "42"

#let ex04 = to.length(default: 45pt, "42")
// -> 45pt

#let ex05 = to.length(default: none, "42")
// -> none
```
</details>


### `number`

Attempts to convert a value to an `int` or a `float` as appropriate.


```typ
#number(
	value, // str | int | float | decimal
	default: auto, // auto | none | int | float | decimal
) -> none | int | float | decimal
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `int` or `float` or `decimal` (positional, required)

The value that should be converted to a `float` or `int`.

- A `decimal`, `float` or `int` is returned unchanged.
- A string representation of a number is converted.
	- The number may be positive or negative.
	- A number that contains decimal places and/or an exponent, is converted to a `float`.
	- Hexadecimal numbers, prefixed with `0x`, are converted to an `int`.
	- Octal numbers, prefixed with `0o`, are converted to an `int`.
	- Binary numbers, prefixed with `0b`, are converted to an `int`.

#### `default`

`auto` or `none` or `int` or `float` or `decimal`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.number("42")
// -> 42

#let ex02 = to.number(42)
// -> 42

#let ex03 = to.number("2.5")
// -> 2.5

#let ex04 = to.number(2.5)
// -> 2.5

#let ex05 = to.number(25e-1)
// -> 2.5

#let ex06 = to.number("25e-1")
// -> 2.5

#let ex07 = to.number("0x2a")
// -> 42

#let ex08 = to.number(0x2a)
// -> 42

#let ex09 = to.number("42%")
// panics with: could not convert to int or float: "42%"

#let ex10 = to.number(default: 42, "42%")
// -> 42

#let ex11 = to.number(default: none, "42%")
// -> none
```
</details>


### `ratio`

Attempts to convert a value to a `ratio`.

```typ
#ratio(
	value, // str | ratio
	default: auto, // auto | none | ratio
) -> none | ratio
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `ratio` (positional, required)

The value that should be converted to a `ratio`.

- A `ratio` is returned unchanged.
- A string representation of a number followed by a percent sign is converted.
	- The number may be positive or negative, and may contain decimal places and/or an exponent.

#### `default`

`auto` or `none` or `ratio`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.ratio("45%")
// -> 45%

#let ex02 = to.ratio(45%)
// -> 45%

#let ex03 = to.ratio("42")
// panics with: could not convert to ratio: "42"

#let ex04 = to.ratio(default: 45%, "42")
// -> 45%

#let ex05 = to.ratio(default: none, "42")
// -> none
```
</details>


### `relative`

Attempts to convert a value to a `relative`.

```typ
#relative(
	value, // str | relative | ratio | length | dictionary
	default: auto, // auto | none | relative | ratio | length
) -> none | relative
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `relative` or `ratio` or `length` or `dictionary` (positional, required)

The value that should be converted to a `relative`.

- A `relative` is returned unchanged.
- A `ratio` is returned as a `relative` with a `length` of `0pt`.
- A `length` is returned as a `relative` with a `ratio` of `0%`.
- A string representation of a `ratio` (see [above](#ratio)) is converted.
- A string representation of a `length` (see [above](#length)) is converted.
- A string consisting of multiple `ratio`s and `length`s joined by plus signs or minus signs is converted to a single `relative` length.
	- All `length`-like substrings are added.
	- All `ratio`-like substrings are added.
- A `dictionary` containing one or more of the keys `ratio` and `length`, and no other keys, is converted.
	- The value of `ratio`, if present, must be either a `ratio` or a value that would convert to one.
	- The value of `length`, if present, must be either a `length` or a value that would convert to one.

#### `default`

`auto` or `none` or `relative` or `ratio` or `length`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.relative("45pt + 3%")
// -> 3% + 45pt

#let ex02 = to.relative(45pt + 3%)
// -> 3% + 45pt

#let ex03 = to.relative((ratio: "3%", length: "45pt"))
// -> 3% + 45pt

#let ex04 = to.relative("42")
// panics with: could not convert to relative: "42"

#let ex05 = to.relative(default: 45pt + 3%, "42")
// -> 3% + 45pt

#let ex06 = to.relative(default: none, "42")
// -> none
```
</details>


### `stroke`

Attempts to convert a value to a `stroke`.

```typ
#stroke(
	value, // str | stroke | color | length | array | dictionary
	default: auto, // auto | none | stroke | color | length
) -> none | stroke
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `stroke` or `color` or `length` or `array` or `dictionary` (positional, required)

The value that should be converted to a `stroke`.

- A `stroke`, `color` or `length` is returned unchanged.
- A string representation of a `color` (see [above](#color)) is converted.
- A string representation of a `length` (see [above](#length)) is converted.
- A valid [dash pattern][typst_dash] is converted.
- A string representation of one or more valid `color`s, `length`s and/or predefined dash patterns joined by plus signs is converted.
	- All `color`-like substrings are combined via `color.mix()`.
	- All `length`-like substrings added.
- A `dictionary` that would otherwise be accepted as a valid `stroke` is converted.

#### `default`

`auto` or `none` or `stroke` or `color` or `length`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.stroke("red")
// -> rgb("#ff4136")

#let ex02 = to.stroke(45pt)
// -> 45pt

#let ex03 = to.stroke("densely-dashed")
// -> (dash: (array: (3pt, 2pt), phase: 0pt))

#let ex04 = to.stroke((3pt, 2pt))
// -> (dash: (array: (3pt, 2pt), phase: 0pt))

#let ex05 = to.stroke((paint: red, thickness: 2pt, dash: "densely-dashed"))
// -> (paint: rgb("#ff4136"), thickness: 2pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let ex06 = to.stroke("2pt + red + densely-dashed + silver + 5pt")
// -> (paint: oklab(77.85%, 0.1, 0.054), thickness: 7pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let ex07 = to.stroke("deep-dish")
// panics with: could not convert to stroke: "deep-dish"

#let ex08 = to.stroke(default: red + 45pt, "deep-dish")
// -> 45pt + rgb("#ff4136")

#let ex09 = to.stroke(default: none, "deep-dish")
// -> none
```
</details>


### `version`

Attempts to convert a value to a `version`.

```typ
#version(
	value, // str | version | int | array
	default: auto, // auto | none | version
) -> none | version
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `version` or `int` or `array` (positional, required)

The value that should be converted to a `version`.

- A `version` is returned unchanged.
- An `int` is converted.
- A string representation of positive integers separated by periods is converted.
- An array of any combination of the above is flattened and converted.

#### `default`

`auto` or `none` or `version`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:1.1.0" as to

#let ex01 = to.version("42")
// -> version(42)

#let ex02 = to.version(42)
// -> version(42)

#let ex03 = to.version("2.5")
// -> version(2, 5)

#let ex04 = to.version(2.5)
// panics with: expected integer, array or version, found float 2.5

#let ex05 = to.version("2.5.1")
// -> version(2, 5, 1)

#let ex06 = to.version((2, 5, 1))
// -> version(2, 5, 1)

#let ex07 = to.version((2, -5, 1))
// panics with: number must be greater than zero: -5

#let ex08 = to.version((2, (5, 1)))
// -> version(2, 5, 1)

#let ex09 = to.version((2, version(5, 1)))
// -> version(2, 5, 1)

#let ex10 = to.version("42%")
// panics with: could not convert to version: "42%"

#let ex11 = to.version(default: sys.version, "42%")
// -> version(0, 15, 0)

#let ex12 = to.version(default: none, "42%")
// -> none
```
</details>


[typst_eval]: https://typst.app/docs/reference/foundations/eval/
[typst_panic]: https://typst.app/docs/reference/foundations/panic/
[typst_decimal]: https://typst.app/docs/reference/foundations/decimal/#constructor
[typst_float]: https://typst.app/docs/reference/foundations/float/#constructor
[typst_int]: https://typst.app/docs/reference/foundations/int/#constructor
[typst_dash]: https://typst.app/docs/reference/visualize/stroke/#constructor-dash
[typst_shadow]: https://typst.app/docs/reference/foundations/std/#using-shadowed-definitions


## Changelog

### 1.1.0 - 2026-06-21

#### Added

- New `skip-strings` argument allows more selective general conversions.
- New `skip-dictionaries` argument allows more selective general conversions.

#### Changed

- Deprecate converting RGB/A hex codes to color without initial hash character.
- Allow `none-from` to take a single string argument, as well as an array.

### 1.0.0 - 2026-06-08

#### Changed

- **Breaking:** less strict, more natural handling of integers and floats.
	- Integer and float conversions may accept integers, floats or decimals.
	- Float and generic number conversions may default to an integer, float, or decimal.
	- Integer conversions may only default to an integer (or `none`).

#### Added

- New general-purpose function `stuff` to guess most appropriate conversion.
- Expose new conversions:
	- bool
	- decimal
	- version

#### Removed

- **Breaking:** remove deprecated `quiet` argument from all direct conversion functions.
- **Breaking:** remove deprecated `scalar` function alias.

### 0.5.1 - 2026-01-16

#### Changed

- Invalid `default` and `quiet` values throw failed assertions instead of panicking.

#### Fixed

- Reject empty dictionaries when converting:
	- alignment
	- relative
	- stroke

### 0.5.0 - 2025-12-20

#### Changed

- Rename scalar to number.
- Deprecate scalar (retained as alias of number for backward compatibility).

#### Added

- Add `default` argument to every conversion ([#2][issue_002]).
- Deprecate the `quiet` argument (equivalent to `default: none`).

#### Fixed

- Additional validation restraints for color constructors ([#1][issue_001]).

### 0.4.0 - 2025-12-06

#### Changed

- Remove reliance on `eval()` from:
	- color
- All use of `eval()` now entirely eliminated.

#### Added

- Expose new conversions:
	- float
	- int
	- scalar (returns either float or int as appropriate)

#### Fixed

- Color conversion via constructor now checks validity of all arguments.
- Stroke miter-limit now treated as scalar.

### 0.3.1 - 2025-10-30

#### Added

- Dictionary conversion to stroke now checks validity of cap, join and miter-limit.

### 0.3.0 - 2025-10-19

#### Changed

- Improve conversion logic and error checking for stroke.

### 0.2.1 - 2025-10-10

#### Changed

- Remove reliance on `eval()` from:
	- alignment

### 0.2.0 - 2025-10-08

#### Changed

- Remove reliance on `eval()` from:
	- angle
	- fraction
	- length
	- ratio
	- relative

#### Added

- Allow exponential notation in numeric conversions.

### 0.1.0 - 2025-09-30

_Initial release._


[issue_001]:https://codeberg.org/boondoc/typst-to-stuff/issues/1
[issue_002]:https://codeberg.org/boondoc/typst-to-stuff/issues/2

