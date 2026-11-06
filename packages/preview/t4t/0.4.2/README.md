# Tools for Typst (v0.4.2)

> A utility package for typst package authors.

**Tools for Typst** (`t4t` in short) is a utility package for [Typst](typst/typst) package and template authors. It provides solutions to some recurring tasks in package development.

The package can be imported or any useful parts of it copied into a project. It is perfectly fine to treat `t4t` as a snippet collection and to pick and choose only some useful functions. For this reason, most functions are implemented without further dependencies.

Hopefully, this collection will grow over time with *Typst* to provide solutions for common problems.

## Usage

Either import the package from the Typst preview repository:

```typst
#import "@preview/t4t:0.4.2": *
```

If only a few functions from `t4t` are needed, simply copy the necessary code to the beginning of the document.

## Reference

----

**Note:** This reference might be out of date. Please refer to the manual for a complete overview of all functions.

----

The functions are categorized into different submodules that can be imported separately.

The modules are:
- `is`
- `def`
- `assert`
- `alias`
- `math`
- `get`

Any or all modules can be imported the usual way:

```typst
// Import as "t4t"
#import "@preview/t4t:0.4.2"
// Import all modules
#import "@preview/t4t:0.4.2": *
// Import specific modules
#import "@preview/t4t:0.4.2": is, def
```

In general, the main value is passed last to the utility functions. `#def.if-none()`, for example, takes the default value first and the value to test second. This is somewhat counterintuitive at first, but allows the use of `.with()` to generate derivative functions:

```typst
#let is-foo = eq.with("foo")
```

### Test functions

```typst
#import "@preview/t4t:0.4.2": *
#import "@preview/t4t:0.4.2": test
```

These functions provide shortcuts to common tests like `#is-eq()`. Some of these are not shorter as writing pure Typst code (e.g. `a == b`), but can easily be used in `.any()` or `.find()` calls:

```typst
// check all values for none
if some-array.any(is-none) {
	...
}

// find first not none value
let x = (none, none, 5, none).find(not-none)

// find position of a value
let pos-bar = args.pos().position(test.is-eq.with("|"))
```

Some of the more frequently used tests are available as top-level imports from `t4t`. The rest can be found in the `test` module.

```typst
#import "@preview/t4t:0.4.2"

#if t4t.is-none(none) [
	it is none
]
```

The following tests are available in the base `t4t` module:

- `#is-none( ..values )`: Tests if any of the passed `values` is `none`.
- `#not-none( ..values )`: Tests if all of the passed `values` are not `none`.
- `#is-auto( ..values )`: Tests if any of the passed `values` is `auto`.
- `#not-auto( ..values )`: Tests if all of the passed `values` are not `auto`.
- `#is-empty( value )`: Tests if `value` is _empty_. A value is considered _empty_ if it is an empty array, dictionary or string or `none` otherwise.
- `#not-empty( value )`: Tests if `value` is not empty.

- `#is-dict( value )`: Tests if `value` is a dictionary.
- `#is-arr( value )`: Tests if `value` is an array.
- `#is-content( value )`: Tests if `value` is of type content.
- `#is-color( value )`: Tests if `value` is a color.
- `#is-stroke( value )`: Tests if `value` is a stroke.
- `#is-loc( value )`: Tests if `value` is a location.
- `#is-bool( value )`: Tests if `value` is a boolean.
- `#is-str( value )`: Tests if `value` is a string.
- `#is-int( value )`: Tests if `value` is an integer.
- `#is-float( value )`: Tests if `value` is a float.
- `#is-num( value )`: Tests if `value` is a numeric value (`integer` or `float`).
- `#is-frac( value )`: Tests if `value` is a fraction.
- `#is-length( value )`: Tests if `value` is a length.
- `#is-relative( value )`: Tests if `value` is a relative length.
- `#is-ratio( value )`: Tests if `value` is a ratio.
- `#is-align( value )`: Tests if `value` is an alignment.
- `#is-align2d( value )`: Tests if `value` is a 2d alignment.
- `#is-func( value )`: Tests if `value` is a function.

- `#test.neg( test )`: Creates a new test function that is `true` when `test` is `false`. Can be used to create negations of tests like `#let not-raw = is.neg(is.raw)`.
- `#test.eq( a, b )`: Tests if values `a` and `b` are equal.
- `#test.neq( a, b )`: Tests if values `a` and `b` are not equal.
- `#test.any( ..compare, value )`: Tests if `value` is equal to any one of the other passed-in values.
- `#test.not-any( ..compare, value)`: Tests if `value` is not equal to any one of the other passed-in values.
- `#test.has( ..keys, value )`: Tests if `value` contains all the passed `keys`. Either as keys in a dictionary or elements in an array. If `value` is neither of those types, `false` is returned.
- `#test.is-type( t, value )`: Tests if `value` is of type `t`.
- `#test.is-elem( func, value )`: Tests if `value` is a content element with `value.func() == func`. If `func` is a string, `value` will be compared to `repr(value.func())` instead.

	Both of these effectively do the same:
	```typst
	#test.is-elem(raw, some_content)
	#test.is-elem("raw", some_content)
	```
- `#test.any-type( ..types, value )`: Tests if `value` has any of the passed-in types.
- `#test.same-type( ..values )`: Tests if all passed-in values have the same type.
- `#test.all-of-type( t, ..values )`: Tests if all of the passed-in values have the type `t`.
- `#test.none-of-type( t, ..values )`: Tests if none of the passed-in values has the type `t`.
- `#test.one-not-none( ..values )`: Checks, if at least one value in `values` is not equal to `none`. Useful for checking multiple optional arguments for a valid value: `#if is.one-not-none(..args.pos()) [ #args.pos().find(is.not-none) ]`

- `#test.is-sequence( value )`: Tests if `value` is a sequence of content.
- `#test.is-raw( value )`: Tests if `value` is a raw element.
- `#test.is-table( value )`: Tests if `value` is a table element.
- `#test.is-list( value )`: Tests if `value` is a list element.
- `#test.is-enum( value )`: Tests if `value` is an enum element.
- `#test.is-terms( value )`: Tests if `value` is a terms element.
- `#test.is-cols( value )`: Tests if `value` is a columns element.
- `#test.is-grid( value )`: Tests if `value` is a grid element.
- `#test.is-stack( value )`: Tests if `value` is a stack element.
- `#test.is-label( value )`: Tests if `value` is of type `label`.

### Default values

```typst
#import "@preview/t4t:0.4.2": def
```

These functions perform a test to decide if a given `value` is _invalid_. If the test _passes_, the default `def` is returned, `value` otherwise.

Almost all functions support an optional `do` argument to be set to a function of one argument that will be applied to the value if the test fails. For example:
```typst
// Sets date to a datetime from an optional
// string argument in the format "YYYY-MM-DD"
#let date = def.if-none(
	passed_date, 		// passed-in argument
	def: datetime.today(), 	// default
	do: (d) >= {		// post-processor
		d = d.split("-")
		datetime(year=d[0], month=d[1], day=d[2])
	}
)
```

Note that previous versions of these functions got the default passed in as the first positional argument. Since Version 0.4.0 the default is now a named argument in favor of more readable code. To restore the old behaviour, you can import the `def.compat` module as `def`:
```typst
#import "@preview/t4t:0.4.2": def
#import def.compat as def
```

- `#def.if-true( value, test, def:none, do:none )`: Returns `def` if `test` is `true`, `value` otherwise.
- `#def.if-false( value, test, def:none, do:none  )`: Returns `def` if `test` is `false`, `value` otherwise.
- `#def.if-none( value, def:none, do:none )`: Returns `def` if `value` is `none`, `value` otherwise.
- `#def.if-auto( value,  def:none, do:none )`: Returns `def` if `value` is `auto`, `value` otherwise.
- `#def.if-any( value,  ..compare, def:none, do:none )`: Returns `def` if `value` is equal to any of the passed-in values, `value` otherwise. (`#def.if-any(none, auto, 1pt, width)`)
- `#def.if-not-any( value,  ..compare, def:none, do:none )`:  Returns `def` if `value` is not equal to any of the passed-in values, `value` otherwise. (`#def.if-not-any(left, right, top, bottom, position)`)
- `#def.if-empty( def:none, do:none,  value )`: Returns `def` if `value` is _empty_, `value` otherwise.
- `#def.as-arr( ..values )`: Always returns an array containing all `values`. Any arrays in `values` will be flattened into the result. This is useful for arguments, that can have one element or an array of elements: `#def.as-arr(author).join(", ")`.

### Assertions

```typst
#import "@preview/t4t:0.4.2": assert
```

This submodule overloads the default `assert` function and provides more asserts to quickly check if given values are valid. All functions use `assert` in the background.

Since a module in Typst is not callable, the `assert` function is now available as `assert.that()`. `assert.eq` and `assert.ne` work as expected.

All assert functions take an optional argument `message` to set the error message shown if the assert fails.

- `#assert.that( test )`: Asserts that the passed `test` is `true`.
- `#assert.that-not( test )`: Asserts that the passed `test` is `false`.
- `#assert.eq( a, b )`: Asserts that  `a` is equal to `b`.
- `#assert.ne( a, b )`: Asserts that `a` is not equal to `b`.
- `#assert.neq( a, b )`: Alias for `assert.ne`.
- `#assert.not-none( value )`: Asserts that `value` is not equal to `none`.
- `#assert.any( ..values, value )`: Asserts that `value` is one of the passed `values`.
- `#assert.not-any( ..values, value )`: Asserts that `value` is not one of the passed `values`.
- `#assert.any-type( ..types, value )`: Asserts that the type of `value` is one of the passed `types`.
- `#assert.not-any-type( ..types, value )`: Asserts that the type of `value` is not one of the passed `types`.
- `#assert.all-of-type( t, ..values )`: Asserts that the type of all passed `values` is equal to `t`.
- `#assert.none-of-type( t, ..values )`: Asserts that the type of all passed `values` is not equal to `t`.
- `#assert.not-empty( value )`: Asserts that `value` is not _empty_.
- `#assert.new( test )`: Creates a new assert function that uses the passed `test`. `test` is a function with signature `(any) => boolean`. This is a quick way to create an assertion from any of the `is` functions:

	```typst
	#let assert-foo = assert.new(is.eq.with("foo"))

	#let assert-length = assert.new(is.length)
	```

## Element helpers

```typst
#import "@preview/t4t:0.4.2": get
```

This submodule is a collection of functions, that mostly deal with content elements and _get_ some information from them. Though some handle other types like dictionaries.

- `#get.dict( ..values )`: Create a new dictionary from the passed `values`. All named arguments are stored in the new dictionary as is. All positional arguments are grouped in key-value pairs and inserted into the dictionary:

	```typst
	#get.dict("a", 1, "b", 2, "c", d:4, e:5)

	// (a:1, b:2, c:none, d:4, e:5)
	```
- `#get.dict-merge( ..dicts )`: Recursively merges the passed-in dictionaries:

	```typst
	#get.dict-merge(
		(a: 1),
		(a: (one: 1, two:2)),
		(a: (two: 4, three:3))
	)

	// (a:(one:1, two:4, three:3))
	```
- `#get.args( args, prefix: "" )`: Creates a function to extract values from an argument sink `args`.

	The resulting function takes any number of positional and named arguments and creates a dictionary with values from `args.named()`. Positional arguments are present in the result if they are present in `args.named()`. Named arguments are always present, either with their value from `args.named()` or with the provided value.

	A `prefix` can be specified, to extract only specific arguments. The resulting dictionary will have all keys with the prefix removed, though.

	```typst
	#let my-func( ..options, title ) = block(
		..get.args(options)(
			"spacing", "above", "below",
			width:100%
		)
	)[
		#text(..get.args(options, prefix:"text-")(
			fill:black, size:0.8em
		), title)
	]

	#my-func(
		width: 50%,
		text-fill: red, text-size: 1.2em
	)[#lorem(5)]
	```
- `#get.text( element, sep: "" )`: Recursively extracts the text content of a content element.
	If present, all child elements are converted to text and joined with `sep`.
- `#get.stroke-paint( stroke, default: black )`: Returns the color of `stroke`. If no color information is available, `def` is used. (Deprecated, use `stroke.paint` instead.)
- `#get.stroke-thickness( stroke, default: 1pt )`: Returns the thickness of `stroke`. If no thickness information is available, `def` is used. (Deprecated, use `stroke.thickness` instead.)
- `#get.stroke-dict( stroke, ..overrides )`: Creates a dictionary with the keys necessary for a stroke. The returned dictionary is guaranteed to have the keys `paint`, `thickness`, `dash`, `cap` and `join`.

	If `stroke` is a dictionary itself, all key-value pairs are copied to the resulting stroke. Any named arguments in `overrides` will override the previous value.
- `#get.inset-at( direction, inset, default: 0pt )`: Returns the inset (or outset) in a given `direction`, ascertained from `inset`.
- `#get.inset-dict( inset, ..overrides )`: Creates a dictionary usable as an inset (or outset) argument.

	The resulting dictionary is guaranteed to have the keys `top`, `left`, `bottom` and `right`.

	If `inset` is a dictionary itself, all key-value pairs are copied to the resulting stroke. Any named arguments in `overrides` will override the previous value.
- `#get.x-align( align, default:left )`: Returns the alignment along the x-axis from the passed-in `align` value. If none is present, `def` is returned. (Deprecated, use `align.x` instead.)

	```typst
	#get.x-align(top + center) // center
	```
- `#get.y-align( align, default:top )`: Returns the alignment along the y-axis from the passed-in `align` value. If none is present, `def` is returned. (Deprecated, use `align.y` instead.)

## Math functions

```typst
#import "@preview/t4t:0.4.2": math
```

Some functions to complement the native `calc` module.

- `#math.minmax( a, b )`: Returns an array with the minimum of `a` and `b` as the first element and the maximum as the second:

	```typst
	#let (min, max) = math.minmax(a, b)
	```
- `#math.clamp( min, max, value )`: Clamps a value between `min` and `max`. In contrast to `calc.clamp()` this function works for other values than numbers, as long as they are comparable.

	```typst
	text-size = math.clamp(0.8em, 1.2em, text-size)
	```
- `#lerp( min, max, t )`: Calculates the linear interpolation of `t` between `min` and `max`.

	```typst
	#let width = math.lerp(0%, 100%, x)
	```

	`t` should be a value between 0 and 1, but the interpolation works with other values, too. To constrain the result into the given interval, use `math.clamp`:

	```typst
	#let width = math.lerp(0%, 100%, math.clamp(0, 1, x))
	```
- `#map( min, max, range-min, range-max, value )`: Maps a `value` from the interval `[min, max]` into the interval `[range-min, range-max]`:

	```typst
	#let text-weight = int(math.map(8pt, 16pt, 400, 800, text-size))
	```
