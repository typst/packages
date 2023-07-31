# Tools for Typst (v0.1.0)

> A utility package for typst package authors.

**Tools for Typst** (`t4t` in short) is a utility package for [Typst](typst/typst) package and template authors. It provides solutions to some recurring tasks in package development.

The package can be imported or any useful parts of it copied into a project. It is perfectly fine to treat `t4t` as a snippet collection and to pick and choose only some useful functions. For this reason, most functions are implemented without further dependencies. 

Hopefully, this collection will grow over time with *Typst* to provide solutions for common problems.

## Usage

Either import the package from the Typst preview repository:

```js
#import "@preview/t4t:0.1.0": *
```

If only a few functions from `t4t` are needed, simply copy the necessary code to the beginning of the document.

## Reference

The functions are categorized into different submodules that can be imported separately.

The modules are:
- `is`
- `def`
- `assert`
- `alias`
- `math` 
- `get`

Any or all modules cann be imported the usual way:

```js
// Import as "t4t"
#import "@preview/t4t:0.1.0"
// Import all modules
#import "@preview/t4t:0.1.0": *
// Import specific modules
#import "@preview/t4t:0.1.0": is, def
```

In general, the main value is passed last to the utility functions. `#def.if-none()` for example, takes the default value first and the value to test second. This is somewhat counterintuitive at first, but allows the use of `.with()` to generate derivative functions:

```js
#let is-foo = eq.with("foo")
```

### Test functions 

```js
#import "@preview/t4t:0.1.0": is
```

These functions provide shortcuts to common tests like `#is.eq()`. Some of these are not shorter as writing pure typst code (e.g. `a == b`), but can easily be used in `.any()` or `.find()` calls:

```js
// check all values for none
if some-array.any(is-none) { 
	...
}

// find first not none value
let x = (none, none, 5, none).find(is.not-none)

// find position of a value
let pos-bar = args.pos().position(is.eq.with("|"))
```

There are two exceptions: `is-none` and `is-auto`. Since keywords can't be used as function names, the `is` module can't define a function to do `is.none()`. Therefore the methods `is-none` and `is-auto` are provided in the base module of `t4t`:

```js
#import "@preview/t4t:0.1.0": is-none, is-auto
```

The `is` submodule still has these tests, but under different names (`is.n` and `is.non` for `none` and `is.a` and `is.aut` for `auto`).

- `#is.eq( a, b )`: Tests if values `a` and `b` are equal.
- `#is.neq( a, b )`: Tests if values `a` and `b` are not equal.
- `#is.n( ..values )`: Tests if any of the passed `values` is `none`.
- `#is.non( ..values )`: Alias for `is.n`.
- `#is.not-none( ..values )`: Tests if all of the passed `values` are not `none`.
- `#is.not-n( ..values )`: Alias for `is.not-none`.
- `#is.a( ..values )`: Tests if any of the passed `values` is `auto`.
- `#is.aut( ..values )`: Alias for `is-a`.
- `#is.not-auto( ..values )`: Tests if all of the passed `values` are not `auto`.
- `#is.not-a( ..values )`: Alias for `is.not-auto`.
- `#is.empty( value )`: Tests if `value` is _empty_. A value is considered _empty_ if it is an empty array, dictionary or string or `none` otherwise.
- `#is.not-empty( value )`: Tests if `value` is not empty. 
- `#is.any( ..compare, value )`: Tests if `value` is equal to any one of the other passed in values.
- `#is.not-any( ..compare, value)`: Tests if `value` is not equals to any one of the other passed in values.
- `#is.has( ..keys, value )`: Tests if `value` contains all the passed `keys`. Either as keys in a dictionary or elements in an array. If `value` is neither of those types, `false` is returned.
- `#is.type( t, value )`: Tests if `value` is of type `t`.
- `#is.dict( value )`: Tests if `value` is a dictionary.
- `#is.arr( value )`: Tests if `value` is an array.
- `#is.content( value )`: Tests if `value` is of type `content`.
- `#is.color( value )`: Tests if `value` is a color.
- `#is.stroke( value )`: Tests if `value` is a stroke.
- `#is.loc( value )`: Tests if `value` is a location.
- `#is.bool( value )`: Tests if `value` is a boolean.
- `#is.str( value )`: Tests if `value` is a string.
- `#is.int( value )`: Tests if `value` is an integer.
- `#is.float( value )`: Tests if `value` is a float.
- `#is.num( value )`: Tests if `value` is a numeric value (`integer` or `float`).
- `#is.frac( value )`: Tests if `value` is a fraction.
- `#is.length( value )`: Tests if `value` is a length.
- `#is.rlength( value )`: Tests if `value` is a relative length.
- `#is.ratio( value )`: Tests if `value` is a ratio.
- `#is.align( value )`: Tests if `value` is an alignment.
- `#is.align2d( value )`: Tests if `value` is a 2d alignment.
- `#is.func( value )`: Tests if `value` is a function.
- `#is.any-type( ..types, value )`: Tests if `value` has any of the passe in types.
- `#is.same-type( ..values )`: Tests if all passed in values have the same type.
- `#is.all-of-type( t, ..values )`: Tests if all of the passed in values have the type `t`.
- `#is.none-of-type( t, ..values )`: Tests if none of the passed in values has the type `t`.
- `#is.elem( func, value )`: Tests if `value` is a content element with `value.func() == func`.
- `#is.raw( value )`: Tests if `value` is a raw element.
- `#is.table( value )`: Tests if `value` is a table element.
- `#is.list( value )`: Tests if `value` is a list element.
- `#is.enum( value )`: Tests if `value` is an enum element.
- `#is.terms( value )`: Tests if `value` is a terms element.
- `#is.cols( value )`: Tests if `value` is a columns element.
- `#is.grid( value )`: Tests if `value` is a grid element.
- `#is.stack( value )`: Tests if `value` is a stack element.

### Default values 

```js
#import "@preview/t4t:0.1.0": def
```

These functions perform a test to decide, if a given `value` is _invalid_. If the test _passes_, the `default` is returned, the `value` otherwise.

- `#def.if-true( test, default, value )`: Returns `default` if `test` is `true`, `value` otherwise.
- `#def.if-false( test, default, value )`: Returns `default` if `test` is `false`, `value` otherwise.
- `#def.if-none( default, value )`: Returns `default` if `value` is `none`, `value` otherwise.
- `#def.if-auto( default, value )`: Returns `default` if `value` is `auto`, `value` otherwise.
- `#def.if-any( ..compare, default, value )`: Returns `default` if `value` is equal to any of the passed in values, `value` otherwise. (`#def.if-any(none, auto, 1pt, width)`)
- `#def.if-not-any( ..compare, default, value )`:  Returns `default` if `value` is not equal to any of the passed in values, `value` otherwise. (`#def.if-not-any(left, right, top, bottom, left, position)`)
- `#def.if-empty( default, value )`: Returns `default` if `value` is _empty_, `value` otherwise.

### Assertions

```js
#import "@preview/t4t:0.1.0": assert
```

This submodule overloads the default `assert` function and provides more asserts to quickly check if given values are valid. All functions use `assert` in the background.

Since a module in typst is not callable, the `assert` functino is now available as `assert.that()`. `assert.eq` and `assert.ne` work as expected.

All assert functions take an optional argument `message` to set the error message shown if the assert fails.

- `#assert.that( test )`: Asserts that the passed `test` is `true`.
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

	```js
	#let assert-foo = assert.new(is.eq.with("foo"))

	#let assert-length = assert.new(is.length)
	```

## Element helpers

```js
#import "@preview/t4t:0.1.0": get
```

This submodule is a collection of functions, that mostly deal with content elements and _get_ some information from them. Though some handle other types like dictionaries.

- `#get.dict( ..values )`: Creat a new dictionary from the passed `values`. All named arguments are stored in the new dictionary as is. All positional arguments are grouped in key/value-pairs and inserted into the dictionary:

	```js
	#get.dict("a", 1, "b", 2, "c", d:4, e:5)

	// (a:1, b:2, c:none, d:4, e:5)
	```
- `#get.dict-merge( ..dicts )`: Recursivley merges the passed in dictionaries:

	```js
	#get.dict-merge(
		(a: 1),
		(a: (one: 1, two:2)),
		(a: (two: 4, three:3))
	)

	// (a:(one:1, two:4, three:3))
	```
- `#get.args( args, prefix: "" )`: Creats a function to extract values from an argument sink `args`. 

	The resulting function takes any number of positional and named arguments and creates a dictionary with values from `args.named()`. Positional arguments are present in the result, if they are present in `args.named()`. Named arguments are always present, either with their value from `args.named()` or with the provided value.

	A `prefix` can be specified, to extract only specific arguments. The resulting dictionary will have all keys with the prefix removed, though.

	```js
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
- `#get-text( element, sep: "" )`: Recursively extracts the text content of a content element. 
	
	If present, all child elements are converted to text and joined with `sep`.
- `#stroke-paint( stroke, default: black )`: Returns the color of `stroke`. If no color information is available, `default` is used.
- `#stroke-thickness( stroke, default: 1pt )`: Returns the thickness of `stroke`. If no thickness information is available, `default` is used.
- `#stroke-dict( stroke, ..overrides )`: Creates a dictionary with the keys necessary for a stroke. The returned dictionary is guaranteed to have the keys `paint`, `thickness`, `dash`, `cap` and `join`.

	If `stroke` is a dictionary itself, all key/value-pairs are copied to the resulting stroke. Any named arguments in `overrides` will override the previous value.
- `#inset-at( direction, inset, default: 0pt )`: Returns the inset (or outset) in a given `direction`, ascertained from `inset`.
- `#inset-dict( inset, ..overrides )`: Creates a dictionary usable as an inset (or outset) argument.

	The resulting dictionary is guaranteed to have the keys `top`, `left`, `bottom` and `right`.

	If `inset` is a dictionary itself, all key/value-pairs are copied to the resulting stroke. Any named arguments in `overrides` will override the previous value.
- `#x-align( align, default:left )`: Returns the alignment along the x-axis from the passed in `align` value. If none is present, `default` is returned.

	```js
	#get.x-align(top + center) // center
	```
- `#y-align( align, default:top )`: Returns the alignment along the y-axis from the passed in `align` value. If none is present, `default` is returned.

== Math functions

```js
#import "@preview/t4t:0.1.0": math
```

Some functions to complement the native `calc` module.

- `#math.minmax( a, b )`: Returns an array with the minimum of `a` and `b` as the first element and the maximum as the second:

	```js
	#let (min, max) = math.minmax(a, b)
	```
- `#math.clamp( min, max, value )`: Clamps a value between `min` and `max`. In contrast to `calc.clamp()` this function works for other values than numbers, as long as they are comparable. 

	```js
	text-size = math.clamp(0.8em, 1.2em, text-size)
	```
- `#lerp( min, max, t )`: Calculates the linear interpolation of `t` between `min` and `max`. 

	```js
	#let width = math.lerp(0%, 100%, x)
	```

	`t` should be a value between 0 and 1, but the interpolation works with other values, too. To constrain the result into the given interval, use `math.clamp`:

	```js
	#let width = math.lerp(0%, 100%, math.clamp(0, 1, x))
	```
- `#map( min, max, range-min, range-max, value )`: Maps a `value` from the interval `[min, max]` into the interval `[range-min, range-max]`:

	```js
	#let text-weight = int(math.map(8pt, 16pt, 400, 800, text-size))
	```

## Alias functions

```js
#import "@preview/t4t:0.1.0": alias
```

Some of the native Typst function as aliases, to prevent collisions with some common argument namens.

For example using `numbering` as an argument is not possible, if the value is supposed to be passed to the `numbering()` function. To still allow argument names, that are in line with the common typst names (like `numbering`, `align` ...), these alias functions can be used:

```js
#let excercise( no, numbering: "1)" ) = [
	Exercise #alias.numbering(numbering, no)
]
```

The following functions have aliases right now:

- `numbering`
- `align`
- `type`
- `text`
- `raw`
- `table`
- `list`
- `enum`
- `terms`
- `grid`
- `stack`
- `columns`
