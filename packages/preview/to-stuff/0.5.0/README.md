# To-Stuff

To-Stuff is a small package of [Typst](https://typst.app/) functions for converting string values to native types. This is most useful when loading layout data from an external configuration source, such as a YAML file.

- Avoids any use of [`eval()`](https://typst.app/docs/reference/foundations/eval/).
- All conversion functions optionally accept a default value to return on failure.
- Where no default value is specified, a failed conversion panics with a sensible error message.


## How to use

Import the package into the current scope, optionally renamed using the `as` keyword:

```typ
#import "@preview/to-stuff:0.5.0"
// Bindings available as to-stuff.alignment(), to-stuff.angle(), etc.

// …or…

#import "@preview/to-stuff:0.5.0" as to
// Bindings available as to.alignment(), to.angle(), etc.
```

The package’s `let` bindings have the same names as their return types, and rely on Typst’s `import` syntax to scope safely. It is not recommended to load the individual bindings into the current scope, as that may cause collisions with the types themselves.

```typ
#assert(type(42pt) == length) // Expected behaviour

#import "@preview/to-stuff:0.5.0": * // NOT RECOMMENDED

#assert(type(42pt) != length) // To-Stuff bindings collide with standard types
#assert(type(42pt) == std.length) // Workaround
```


## Localisation

All conversions involving numeric values assume the number strings to be in a format understood by Typst code; specifically:

- All numeric digits must be ASCII characters 0-9 and/or A-F (case non-sensitive).
- Decimal separators must be a full stop/period; commas, apostrophes, etc. are not supported.
- Thousands separators are not supported.


## Functions

### `alignment()`

Attempts to convert a value to an `alignment`.

```typ
#alignment(
	value, // str | alignment | dictionary
	default: auto, // auto | none | alignment
	quiet: false, // bool; DEPRECATED
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

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.alignment("top + right")
// -> right + top

#let b = to.alignment(top + right)
// -> right + top

#let c = to.alignment((x: "right", y: "top"))
// -> right + top

#let d = to.alignment("turnwise")
// panics with: "could not convert to alignment: \"turnwise\""

#let e = to.alignment("top + bottom")
// panics with: "cannot add two vertical alignments: \"top + bottom\""

#let f = to.alignment(default: top + right, "top + bottom")
// -> right + top

#let g = to.alignment(default: none, "top + bottom")
// -> none

#let h = to.alignment(quiet: true, "top + bottom")
// -> none
```
</details>


### `angle()`

Attempts to convert a value to an `angle`.

```typ
#angle(
	value, // str | angle
	default: auto, // auto | none | angle
	quiet: false, // bool; DEPRECATED
) -> none | angle
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `angle` (positional, required)

The value that should be converted to an `angle`.

- An `angle` is returned unchanged.
- A string representation of a number followed by the letters `deg` or `rad` is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.angle("45deg")
// -> 45deg

#let b = to.angle(45deg)
// -> 45deg

#let c = to.angle("42")
// panics with: "could not convert to angle: \"42\""

#let d = to.angle(default: 45deg, "42")
// -> 45deg

#let e = to.angle(default: none, "42")
// -> none

#let f = to.angle(quiet: true, "42")
// -> none
```
</details>


### `color()`

Attempts to convert a value to a `color`.

```typ
#color(
	value, // str | color
	default: auto, // auto | none | color
	quiet: false, // bool; DEPRECATED
) -> none | color
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `color` (positional, required)

The value that should be converted to a `color`.

- A `color` is returned unchanged.
- A string representation of a predefined color value is converted to that built-in color.
- A string representation of a hash symbol followed by a 6- or 8-digit hexadecimal code is converted to the corresponding RGB or RGBA value.
- A string representation of a color space function followed by parentheses and arguments is converted.
	- The string must not contain any scoping prefix, e.g. `color.…`, or the conversion will fail. This includes the `hsl`, `hsv`, and `linear-rgb` functions.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.color("red")
// -> rgb("#ff4136")

#let b = to.color(red)
// -> rgb("#ff4136")

#let c = to.color("#FF4136FF")
// -> rgb("#ff4136")

#let d = to.color("rgb(255, 65, 54)")
// -> rgb("#ff4136")

#let e = to.color("hsv(135deg,75%,127,100)")
// -> color.hsv(135deg, 75%, 49.8%, 39.22%)

#let f = to.color("indigo")
// panics with: "could not convert to color: \"indigo\""

#let g = to.color(default: red, "indigo")
// -> rgb("#ff4136")

#let h = to.color(default: none, "indigo")
// -> none

#let i = to.color(quiet: true, "indigo")
// -> none
```
</details>


### `direction()`

Attempts to convert a value to a `direction`.

```typ
#direction(
	value, // str | direction
	default: auto, // auto | none | direction
	quiet: false, // bool; DEPRECATED
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

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.direction("rtl")
// -> rtl

#let b = to.direction(rtl)
// -> rtl

#let c = to.direction("btf")
// panics with: "could not convert to direction: \"btf\""

#let d = to.direction(default: rtl, "btf")
// -> rtl

#let e = to.direction(default: none, "btf")
// -> none

#let f = to.direction(quiet: true, "btf")
// -> none
```
</details>


### `float()`

Attempts to convert a value to a `float`.

While the standard [`float` constructor][typst_float] throws an error on failure, this function [panics][typst_panic] instead, which may be suppressed if desired via the `default` and `quiet` arguments.

```typ
#float(
	value, // str | float
	default: auto, // auto | none | float
	quiet: false, // bool; DEPRECATED
) -> none | float
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `float` (positional, required)

The value that should be converted to a `float`.

- A `float` is returned unchanged.
- A string representation of a number is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.float("2.5")
// -> 2.5

#let b = to.float(2.5)
// -> 2.5

#let c = to.float("25e-1")
// -> 2.5

#let d = to.float("42%")
// panics with: "could not convert to float: \"42%\""

#let e = to.float(default: 2.5, "42%")
// -> 2.5

#let f = to.float(default: none, "42%")
// -> none

#let g = to.float(quiet: true, "42%")
// -> none
```
</details>


### `fraction()`

Attempts to convert a value to a `fraction`.

```typ
#fraction(
	value, // str | fraction
	default: auto, // auto | none | fraction
	quiet: false, // bool; DEPRECATED
) -> none | fraction
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `fraction` (positional, required)

The value that should be converted to a `fraction`.

- A `fraction` is returned unchanged.
- A string representation of a number followed by the letters `fr` is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.fraction("2.5fr")
// -> 2.5fr

#let b = to.fraction(2.5fr)
// -> 2.5fr

#let c = to.fraction("42")
// panics with: "could not convert to fraction: \"42\""

#let d = to.fraction(default: 2.5fr, "42")
// -> 2.5fr

#let e = to.fraction(default: none, "42")
// -> none

#let f = to.fraction(quiet: true, "42")
// -> none
```
</details>


### `int()`

Attempts to convert a value to an `int`.

While the standard [`int` constructor][typst_int] throws an error on failure, this function [panics][typst_panic] instead, which may be suppressed if desired via the `default` and `quiet` arguments.

This function can also parse correctly-prefixed strings in hexadecimal, octal and binary.

```typ
#int(
	value, // str | int
	default: auto, // auto | none | int
	quiet: false, // bool; DEPRECATED
) -> none | int
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `int` (positional, required)

The value that should be converted to an `int`.

- An `int` is returned unchanged.
- A string representation of a number is converted.
	- The number may be positive or negative, but may *not* contain decimal places.
	- Hexadecimal numbers, prefixed with `0x`, are permitted.
	- Octal numbers, prefixed with `0o`, are permitted.
	- Binary numbers, prefixed with `0b`, are permitted.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.int("42")
// -> 42

#let b = to.int(42)
// -> 42

#let c = to.int("0x2a")
// -> 42

#let d = to.int("2.5")
// panics with: "could not convert to int: \"2.5\""

#let e = to.int(default: 42, "2.5")
// -> 42

#let f = to.int(default: none, "2.5")
// -> none

#let g = to.int(quiet: true, "2.5")
// -> none
```
</details>


### `length()`

Attempts to convert a value to a `length`.

```typ
#length(
	value, // str | length
	default: auto, // auto | none | length
	quiet: false, // bool; DEPRECATED
) -> none | length
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `length` (positional, required)

The value that should be converted to a `length`.

- A `length` is returned unchanged.
- A string representation of a number followed by the letters `pt`, `mm`, `cm`, `in`, or `em`, is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.length("45pt")
// -> 45pt

#let b = to.length(45pt)
// -> 45pt

#let c = to.length("42")
// panics with: "could not convert to length: \"42\""

#let d = to.length(default: 45pt, "42")
// -> 45pt

#let e = to.length(default: none, "42")
// -> none

#let f = to.length(quiet: true, "42")
// -> none
```
</details>


### `number()`

Attempts to convert a value to a `float` or an `int` as appropriate.


```typ
#number(
	value, // str | float | int
	default: auto, // auto | none | float | int
	quiet: false, // bool; DEPRECATED
) -> none | float | int
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `float` or `int` (positional, required)

The value that should be converted to a `float` or `int`.

- A `float` or `int` is returned unchanged.
- A string representation of a `float` (see [above](#float)) is converted.
- A string representation of an `int` (see [above](#int)) is converted.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.number("42")
// -> 42

#let b = to.number(42)
// -> 42

#let c = to.number("0x2a")
// -> 42

#let d = to.number("2.5")
// -> 2.5

#let e = to.number(2.5)
// -> 2.5

#let f = to.float("25e-1")
// -> 2.5

#let g = to.number("45%")
// panics with: "could not convert to int or float: \"45%\""

#let h = to.number(default: 42, "45%")
// -> 42

#let i = to.number(default: none, "45%")
// -> none

#let j = to.number(quiet: true, "45%")
// -> none
```
</details>


### `ratio()`

Attempts to convert a value to a `ratio`.

```typ
#ratio(
	value, // str | ratio
	default: auto, // auto | none | ratio
	quiet: false, // bool; DEPRECATED
) -> none | ratio
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `ratio` (positional, required)

The value that should be converted to a `ratio`.

- A `ratio` is returned unchanged.
- A string representation of a number followed by a percent sign is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.ratio("45%")
// -> 45%

#let b = to.ratio(45%)
// -> 45%

#let c = to.ratio("42")
// panics with: "could not convert to ratio: \"42\""

#let d = to.ratio(default: 45%, "42")
// -> 45%

#let e = to.ratio(default: none, "42")
// -> none

#let f = to.ratio(quiet: true, "42")
// -> none
```
</details>


### `relative()`

Attempts to convert a value to a `relative`.

```typ
#relative(
	value, // str | relative | ratio | length | dictionary
	default: auto, // auto | none | relative | ratio | length
	quiet: false, // bool; DEPRECATED
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
- A string consisting of multiple `ratio`s and `lengths` joined by plus signs or minus signs is converted to a single `relative` length.
	- All `length`-like substrings are added.
	- All `ratio`-like substrings are added.
- A `dictionary` containing one or more of the keys `ratio` and `length`, and no other keys, is converted.
	- The value of `ratio`, if present, must be either a `ratio` or a value that would convert to one.
	- The value of `length`, if present, must be either a `length` or a value that would convert to one.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.relative("45pt + 3%")
// -> 3% + 45pt

#let b = to.relative(45pt + 3%)
// -> 3% + 45pt

#let c = to.relative((ratio: "3%", length: "45pt"))
// -> 3% + 45pt

#let d = to.relative("42")
// panics with: "could not convert to relative: \"42\""

#let e = to.relative(default: 45pt + 3%, "42")
// -> 3% + 45pt

#let f = to.relative(default: none, "42")
// -> none

#let g = to.relative(quiet: true, "42")
// -> none
```
</details>


### `scalar()`

Alias of [`number()`](#number)

*Deprecated*: `scalar()` will be removed in To-Stuff version `1.0.0`.


### `stroke()`

Attempts to convert a value to a `stroke`.

```typ
#stroke(
	value, // str | stroke | color | length | array | dictionary
	default: auto, // auto | none | stroke | color | length
	quiet: false, // bool; DEPRECATED
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
- A valid [dash pattern](https://typst.app/docs/reference/visualize/stroke/#constructor-dash) is converted.
- A string representation of one or more valid `color`s, `length`s and/or predefined dash patterns joined by plus signs is converted.
	- All `color`-like substrings are combined via `color.mix()`.
	- All `length`-like substrings added.
- A `dictionary` that would otherwise be accepted as a valid `stroke` is converted.

#### `default`

What to return if `value` could not be converted. If `auto`, failed conversions cause a [panic][typst_panic].

Default: `auto`

#### `quiet`

`bool`

Setting to `true` is equivalent to setting `default: none`.

Default: `false`

*Deprecated*: `quiet` will be removed in To-Stuff version `1.0.0`.
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.5.0" as to

#let a = to.stroke("red")
// -> rgb("#ff4136")

#let b = to.stroke(45pt)
// -> 45pt

#let c = to.stroke("densely-dashed")
// -> (dash: (array(3pt, 2pt), phase: 0pt))

#let d = to.stroke((3pt, 2pt))
// -> (dash: (array(3pt, 2pt), phase: 0pt))

#let e = to.stroke((paint: red, thickness: 2pt, dash: "densely-dashed"))
// -> (paint: rgb("#ff4136"), thickness: 2pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let f = to.stroke("2pt + red + densely-dashed + silver + 5pt")
// -> (paint: oklab(77.85%, 0.1, 0.054), thickness: 7pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let g = to.stroke("deep-dish")
// panics with: "could not convert to stroke: \"deep-dish\""

#let h = to.stroke(default: red + 45pt, "deep-dish")
// -> 45pt + rgb("#ff4136")

#let i = to.stroke(default: none, "deep-dish")
// -> none

#let j = to.stroke(quiet: true, "deep-dish")
// -> none
```
</details>


## Development

### Requirements

Local development of To-Stuff relies on the following software:

- [`tytanic`](https://github.com/typst-community/tytanic)
- [`task`](https://github.com/go-task/task)
- [`direnv`](https://github.com/direnv/direnv)
- [`yq`](https://github.com/mikefarah/yq)


### Setup

1. Fork the [Typst Packages][setup_universe] repository and clone it locally. A [sparse checkout][setup_sparse] is recommended.

	For demonstration purposes, we assume your local clone of your Typst Packages fork is at `~/my-typst-dev/universe`.

2. Clone this repository.

	```sh
	cd ~/my-typst-dev
	git clone https://codeberg.org/boondoc/typst-to-stuff
	```

3. Create and activate an environment file to link To-Stuff’s `taskfile` to your local copy of Typst Packages. You may need to edit your `direnv` settings to recognise `.env` files.

	```sh
	cd ~/my-typst-dev/typst-to-stuff
	echo "LOCAL_UNIVERSE=${HOME}/my-typst-dev/universe/packages/preview" > .env
	direnv allow
	```

	Note that the above command should write an **absolute path** to `.env`; `task` seems not to parse shell variables inside `.env` files, even when `direnv` itself expands them correctly.

4. Initialise tests.

	```sh
	cd ~/my-typst-dev/typst-to-stuff
	task
	```

	The default `task` operation runs all unit tests once.

5. Begin monitoring the repository for file edits.

	```sh
	cd ~/my-typst-dev/typst-to-stuff
	task watch
	```

	Running the `watch` task in a clean repository can incorrectly skip several tests, taking multiple refreshes to successfully compile the entire suite; running a single pass first (see step 4) seems to solve the problem.


### Updating the project version

To set a new project version:

1. Edit the `package.version` setting in `typst.toml`
2. Run `task docs` to automatically update the `README.md` file to reflect the correct version number.


### Packaging for Universe

Running `task package` will copy selected files to the the path specified in `$LOCAL_UNIVERSE` (set in `.env`), under a subdirectory structure according to the project name and version specified in `typst.toml`. The list of files copied is defined in `taskfile.yml` under `vars.MODULE` and `vars.IGNORE`.

Only files [relevant][setup_exclude] to Typst Universe itself should be packaged in this way; for instance, Universe has no use for the `tests` subdirectory.


[typst_panic]: https://typst.app/docs/reference/foundations/panic/
[typst_float]: https://typst.app/docs/reference/foundations/float/#constructor
[typst_int]: https://typst.app/docs/reference/foundations/int/#constructor
[setup_universe]: https://github.com/typst/packages
[setup_sparse]: https://github.com/typst/packages/blob/main/docs/tips.md#sparse-checkout-of-the-repository
[setup_exclude]: https://github.com/typst/packages/blob/main/docs/tips.md#what-to-commit-what-to-exclude

