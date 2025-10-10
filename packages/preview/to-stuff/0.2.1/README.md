# To-Stuff

To-Stuff is a small package of [Typst](https://typst.app/) functions for converting string values to native types. This is most useful when loading layout data from an external configuration source, such as a YAML file.


## How To Use

Import the module into the current scope, optionally renamed using the `as` keyword:

```typ
#import "@preview/to-stuff:0.2.1"
// Bindings available as to-stuff.alignment(), to-stuff.angle(), etc.

// …or…

#import "@preview/to-stuff:0.2.1" as to
// Bindings available as to.alignment(), to.angle(), etc.
```

The module’s `let` bindings have the same names as their return types, and rely on Typst’s `import` syntax to scope safely. It is not recommended to load the individual bindings into the current scope, as that may cause collisions with the types themselves.

```typ
#import "@preview/to-stuff:0.2.1": *
// NOT RECOMMENDED
// Bindings will collide with built-in types: alignment, angle, etc.
```


## Localisation

All conversions involving numeric values assume the number strings to be in a format understood by Typst code; specifically:

- All numeric digits must be ASCII characters 0-9.
- Decimals are indicated by a period; commas and other international decimal signs are not supported.
- Thousands separators are not supported.


## Functions

### `alignment()`

Attempts to convert a value to an `alignment`.

```typ
#alignment(
	str|alignment|dictionary,
	quiet: bool,
) -> none|alignment
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `alignment` or `dictionary` (positional, required)

The value that should be converted to an `alignment`.

- An `alignment` is returned unchanged.
- A string representation of any of the eight `alignment` values is converted to that value.
	- If the string includes the `alignment.…` scoping prefix, the conversion fails.
- A string consisting of two `alignment` representations joined by a plus sign is converted to the corresponding 2D alignment, provided the two strings do not correspond to alignments on the same axis.
- A `dictionary` containing one or more of the keys `x` and `y`, and no other keys, is converted.
	- The value of `x`, if present, must be either a horizontal `alignment` or a value that would convert to one.
	- The value of `y`, if present, must be either a vertical `alignment` or a value that would convert to one.

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

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

#let f = to.alignment(quiet: true, "top + bottom")
// -> none
```
</details>


### `angle()`

Attempts to convert a value to an `angle`.

```typ
#angle(
	str|angle,
	quiet: bool,
) -> none|angle
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `angle` (positional, required)

The value that should be converted to an `angle`.

- An `angle` is returned unchanged.
- A string representation of a number followed by the letters `deg` or `rad` is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

#let a = to.angle("45deg")
// -> 45deg

#let b = to.angle(45deg)
// -> 45deg

#let c = to.angle("42")
// panics with: "could not convert to angle: \"42\""

#let d = to.angle(quiet: true, "42")
// -> none
```
</details>


### `color()`

Attempts to convert a value to a `color`.

```typ
#angle(
	str|color,
	quiet: bool,
) -> none|color
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
	- If the string includes the `color.…` scoping prefix, the conversion fails. This includes the `hsl`, `hsv`, and `linear-rgb` functions.

**Note:** Color space function arguments are not currently checked for validity before the string is passed to `eval()`. Invalid function arguments causes a native Typst syntax error rather than a panic; this error cannot be suppressed by setting `quiet` to `true` (see below). This may change in a future version.

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

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

#let g = to.color(quiet: true, "indigo")
// -> none
```
</details>


### `direction()`

Attempts to convert a value to a `direction`.

```typ
#direction(
	str|direction,
	quiet: bool,
) -> none|direction
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `direction` (positional, required)

The value that should be converted to a `direction`.

- A `direction` is returned unchanged.
- A string representation of any of the four `direction` values is converted to that value.
	- If the string includes the `direction.…` scoping prefix, the conversion fails.

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

#let a = to.direction("rtl")
// -> rtl

#let b = to.direction(rtl)
// -> rtl

#let c = to.direction("btf")
// panics with: "could not convert to direction: \"btf\""

#let d = to.direction(quiet: true, "btf")
// -> none
```
</details>


### `fraction()`

Attempts to convert a value to a `fraction`.

```typ
#fraction(
	str|fraction,
	quiet: bool,
) -> none|fraction
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `fraction` (positional, required)

The value that should be converted to a `fraction`.

- A `fraction` is returned unchanged.
- A string representation of a number followed by the letters `fr` is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

#let a = to.fraction("2.5fr")
// -> 2.5fr

#let b = to.fraction(2.5fr)
// -> 2.5fr

#let c = to.fraction("42")
// panics with: "could not convert to fraction: \"42\""

#let d = to.fraction(quiet: true, "42")
// -> none
```
</details>


### `length()`

Attempts to convert a value to a `length`.

```typ
#length(
	str|length,
	quiet: bool,
) -> none|length
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `length` (positional, required)

The value that should be converted to a `length`.

- A `length` is returned unchanged.
- A string representation of a number followed by the letters `pt`, `mm`, `cm`, `in`, or `em`, is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

#let a = to.length("45pt")
// -> 45pt

#let b = to.length(45pt)
// -> 45pt

#let c = to.length("42")
// panics with: "could not convert to length: \"42\""

#let d = to.length(quiet: true, "42")
// -> none
```
</details>


### `ratio()`

Attempts to convert a value to a `ratio`.

```typ
#ratio(
	str|ratio,
	quiet: bool,
) -> none|ratio
```

<details>
	<summary>View arguments</summary>

#### `value`

`str` or `ratio` (positional, required)

The value that should be converted to a `ratio`.

- A `ratio` is returned unchanged.
- A string representation of a number followed by a percent sign is converted.
	- The number may be positive or negative, and may contain decimal places.

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

#let a = to.ratio("45%")
// -> 45%

#let b = to.ratio(45%)
// -> 45%

#let c = to.ratio("42")
// panics with: "could not convert to ratio: \"42\""

#let d = to.ratio(quiet: true, "42")
// -> none
```
</details>


### `relative()`

Attempts to convert a value to a `relative`.

```typ
#relative(
	str|relative|ratio|length|dictionary,
	quiet: bool,
) -> none|relative
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

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

#let a = to.relative("45pt + 3%")
// -> 3% + 45pt

#let b = to.relative(45pt + 3%)
// -> 3% + 45pt

#let c = to.relative((ratio: "3%", length: "45pt"))
// -> 3% + 45pt

#let d = to.relative("42")
// panics with: "could not convert to relative: \"42\""

#let e = to.relative(quiet: true, "42")
// -> none
```
</details>


### `stroke()`

Attempts to convert a value to a `stroke`.

```typ
#stroke(
	str|stroke|color|length|array|dictionary,
	quiet: bool,
) -> none|stroke
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

#### `quiet`

`bool`

Whether to return `none` if the value could not be converted. If `false`, invalid values cause a panic.

Default: `false`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/to-stuff:0.2.1" as to

#let a = to.stroke("red")
// -> rgb("#ff4136")

#let b = to.stroke(45pt)
// -> 45pt

#let c = to.stroke("densely-dashed")
// -> (dash: array(3pt, 2pt), phase: 0pt)

#let d = to.stroke((3pt, 2pt))
// -> (dash: array(3pt, 2pt), phase: 0pt)

#let e = to.stroke((paint: red, thickness: 2pt, dash: "densely-dashed"))
// -> (paint: rgb("#ff4136"), thickness: 2pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let f = to.stroke("2pt + red + densely-dashed + silver + 5pt")
// -> (paint: oklab(77.85%, 0.1, 0.054), thickness: 7pt, dash: (array: (3pt, 2pt), phase: 0pt))

#let g = to.stroke("deep-dish")
// panics with: "could not convert to stroke: \"deep-dish\""

#let h = to.stroke(quiet: true, "deep-dish")
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


[setup_universe]: https://github.com/typst/packages
[setup_sparse]: https://github.com/typst/packages/blob/main/docs/tips.md#sparse-checkout-of-the-repository
[setup_exclude]: https://github.com/typst/packages/blob/main/docs/tips.md#what-to-commit-what-to-exclude

