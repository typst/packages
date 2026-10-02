# Deep Dish

Deep Dish is a [Typst](https://typst.app/) package for performing deep merge operations on complex dictionary structures, with customisable rules for resolving key conflicts.


## How to use

Import the package into the current scope, optionally renamed using the `as` keyword:

```typ
#import "@preview/deep-dish:0.1.0"
// Bindings available as deep-dish.merge(), deep-dish.at(), etc.

// …or…

#import "@preview/deep-dish:0.1.0" as deep
// Bindings available as deep.merge(), deep.at(), etc.
```


## Merge Functions

### `merge`

Returns the result of recursively merging a series of `dictionary` values according to the specified rules.

```typ
#merge(
	first, // dictionary
	..others, // dictionaries

	none-none: "skip", // str | function
	none-scalar: "overwrite", // str | function
	none-array: "overwrite", // str | function
	none-dict: "overwrite", // str | function
	scalar-none: "skip", // str | function
	scalar-scalar: "overwrite", // str | function
	scalar-array: "append", // str | function
	scalar-dict: "numeric-key", // str | function
	array-none: "skip", // str | function
	array-scalar: "append", // str | function
	array-array: "deep", // str | function
	array-dict: "values", // str | function
	dict-none: "skip", // str | function
	dict-scalar: "numeric-key", // str | function
	dict-array: "enumerate", // str | function
) -> dictionary
```

<details>
	<summary>View arguments</summary>

#### `first`

`dictionary` (positional, required)

The first data structure, into which any `others` will be merged.

#### `others`

`dictionary` (positional, required, variadic)

Additional data structures, each of which will be recursively merged with `first`. When multiple `others` are specified they are processed from left to right, and each `other` completes a full recursive merge process before the next one begins.

- Where a key appears in either `first` or an `other`, but not both, that key and its value will be added to the output.
- Where a key is found both in `first` and in an `other`, a [merge rule](#merge-rules) will be applied to both values, and the result of that rule will be added to the output at the corresponding key.

#### Merge rules

`function` or hardcoded string (see [table](#merge-rule-presets))

Merge rules determine how to resolve conflicts that arise when the same key exists in two dictionaries being merged. A merge rule is a function that takes two positional arguments, and returns a single value:

```typ
#let custom-merge-rule = (first, other) => {
	let output
	// Process `first` and `other` as desired.
	return output
}
```

The choice of merge rule to use in a given situation is made automatically according to the `type`s of the two values being compared, each of which may be either `none`, an `array`, a `dictionary`, or a “scalar” (effectively “none of the above”). The various merge rule arguments are named for the interactions between elements of these types; for example, the merge rule `scalar-array` determines what happens when an `array` value in one of the `other` data structures is merged onto a “scalar” value at the equivalent location in the `first` data structure.

Note that no `dict-dict` rule exists, as this scenario is automatically treated as a recursive application of the original `merge()` call.

Deep Dish provides a number of predefined merge rules, which may be selected by passing a string constant to the corresponding argument. While the names and descriptions of these predefined rules imply alterations applying from right (`other`) to left (`first`), this is merely a naming convention; as with all Typst functions, the original data structures remain untouched, and an entirely new variable is returned.

<table width="100%" id="merge-rule-presets">
	<caption>Merge rule presets</caption>
	<thead>
		<tr valign="top"><th><th colspan="4"><tt>type(other)</tt></th></tr>
		<tr valign="top">
			<th align="left"><tt>type(first)</tt></th>
			<th align="left"><tt>none</tt></th>
			<th align="left">scalar</th>
			<th align="left"><tt>array</tt></th>
			<th align="left"><tt>dictionary</tt></th>
		</tr>
	</thead>
	<tbody>
		<tr valign="top">
			<th align="left"><tt>none</tt></th>
			<td>
				<tt>none-none:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#remove"><tt>"remove"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>none-scalar:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>none-array:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>none-dict:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
		</tr>
		<tr valign="top">
			<th align="left">scalar</th>
			<td>
				<tt>scalar-none:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
					<li><a href="#remove"><tt>"remove"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>scalar-scalar:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
					<li><a href="#overwrite-same"><tt>"overwrite-same"</tt></a></li>
					<li><a href="#overwrite-strict"><tt>"overwrite-strict"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>scalar-array:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#prepend"><tt>"prepend"</tt></a></li>
					<li><a href="#append"><tt>"append"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>scalar-dict:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#numeric-key"><tt>"numeric-key"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
		</tr>
		<tr valign="top">
			<th align="left"><tt>array</tt></th>
			<td>
				<tt>array-none:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#prepend"><tt>"prepend"</tt></a></li>
					<li><a href="#append"><tt>"append"</tt></a></li>
					<li><a href="#empty"><tt>"empty"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
					<li><a href="#remove"><tt>"remove"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>array-scalar:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#prepend"><tt>"prepend"</tt></a></li>
					<li><a href="#append"><tt>"append"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>array-array:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#prepend"><tt>"prepend"</tt></a></li>
					<li><a href="#append"><tt>"append"</tt></a></li>
					<li><a href="#zip"><tt>"zip"</tt></a></li>
					<li><a href="#slice"><tt>"slice"</tt></a></li>
					<li><a href="#deep"><tt>"deep"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>array-dict:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#empty"><tt>"empty"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
					<li><a href="#numeric-keys"><tt>"numeric-keys"</tt></a> <a href="#conv-array-dict">†</a></li>
					<li><a href="#values"><tt>"values"</tt></a> <a href="#conv-array-dict">†</a></li>
					<li><a href="#pairs"><tt>"pairs"</tt></a> <a href="#conv-array-dict">†</a></li>
				</ul>
			</td>
		</tr>
		<tr valign="top">
			<th align="left"><tt>dictionary</tt></th>
			<td>
				<tt>dict-none:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#numeric-key"><tt>"numeric-key"</tt></a></li>
					<li><a href="#empty"><tt>"empty"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
					<li><a href="#remove"><tt>"remove"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>dict-scalar:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#numeric-key"><tt>"numeric-key"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
				</ul>
			</td>
			<td>
				<tt>dict-array:</tt>
				<ul>
					<li><a href="#skip"><tt>"skip"</tt></a></li>
					<li><a href="#empty"><tt>"empty"</tt></a></li>
					<li><a href="#overwrite"><tt>"overwrite"</tt></a></li>
					<li><a href="#enumerate"><tt>"enumerate"</tt></a> <a href="#conv-dict-array">‡</a></li>
				</ul>
			</td>
			<td>—</td>
		</tr>
	</tbody>
	<tfoot>
		<td colspan="5">
			<p id="conv-array-dict">† <tt>array-dict</tt> rules marked with a single dagger convert <tt>other</tt> (a <tt>dictionary</tt>) to an <tt>array</tt>, before handing off to the configured <tt>array-array</tt> rule.</p>
			<p id="conv-dict-array">‡ <tt>dict-array</tt> rules marked with a double dagger convert <tt>other</tt> (an <tt>array</tt>) to a <tt>dictionary</tt>, before handing off to the standard dictionary deep merge behaviour.</p>
			<p>Such conversions are only possible when using these presets, and cannot currently be replicated with custom functions.</p>
		</td>
	</tfoot>
</table>

##### `append`

Valid for `scalar-array`, `array-none`, `array-scalar`, or `array-array`.

Outputs a new array equivalent to `first + other`. If either element is not already an `array`, it is first converted to a single-element `array`.

##### `deep`

Valid for `array-array`.

Recursively merge the two `array`s, applying the same set of merge rules as for a pair of `dictionary`s.

##### `empty`

Valid for `array-none`, `array-dict`, `dict-none`, or `dict-array`.

Outputs an empty `array` or `dictionary` as appropriate to the `type` of the `first` element.

##### `enumerate`

Valid for `dict-array`.

Outputs the recursive `dictionary` merge process as applied to `first` and a `dictionary` consisting of the values from `other` with numeric key strings.

##### `numeric-key`

Valid for `scalar-dict`, `dict-none`, or `dict-scalar`.

Outputs a copy of whichever of `first` or `other` is a `dictionary`, with the “scalar”/`none` element inserted at a key equal to the original length of the `dictionary` element.

##### `numeric-keys`

Valid for `array-dict`.

First creates a copy of `first`; if any keys in `other` are numeric strings:

- A value whose key is an integer less than the original length of `first` overwrites the value in `first` at that index.
- A value whose key is an integer equal to or greater than the original length of `first` is appended to the output.

Finally outputs the result of the `array-array` merge rule as applied to `first` and the above copy.

*Warning:* This merge rule is highly customised for compatibility with [Lodash’s][js_lodash_merge] `_.merge()` (see [`merge-lodash()`](#merge-lodash)), and is probably not suitable for general usage.

##### `overwrite`

Valid for all merge rules except `none-none`.

Outputs the `other` element unchanged, “overwriting” the `first`.

##### `overwrite-same`

Valid for `scalar-scalar`.

- If both compared elements have the same `type`, outputs the `other` unchanged, [“overwriting”](#overwrite) the `first`.
- Otherwise, outputs the `first` element unchanged, [“skipping”](#skip) the `other`.

##### `overwrite-strict`

Valid for `scalar-scalar`.

- If both compared elements have the same `type`, outputs the `other` unchanged, [“overwriting”](#overwrite) the `first`.
- Otherwise, throws an [assertion error][typst_docs_assert_eq].

##### `pairs`

Valid for `array-dict`.

Outputs the result of the `array-array` merge rule as applied to `first` and `other.pairs()`.

##### `prepend`

Valid for `scalar-array`, `array-none`, `array-scalar`, or `array-array`.

Outputs a new array equivalent to `other + first`. If either element is not already an `array`, it is first converted to a single-element `array`.

##### `remove`

Valid for `none-none`, `scalar-none`, `array-none`, and `dict-none`.

Outputs neither element, instead excluding the corresponding dictionary key entirely.

This behaviour is unique to this preset, and cannot be replicated with a custom function.

##### `skip`

Valid for all merge rules.

Outputs the `first` element unchanged, “skipping” the `other`.

##### `slice`

Valid for `array-array`.

Outputs a copy of `other`. If `first` is longer than `other`, appends a subslice of `first` starting at the index equal to `other.len()`.

##### `values`

Valid for `array-dict`.

Outputs the result of the `array-array` merge rule as applied to `first` and `other.values()`.

##### `zip`

Valid for `array-array`.

Outputs a new array equivalent to `first.zip(other)`.

</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/deep-dish:0.1.0" as deep

#let test1 = (
	a: (i: red, j: green, k: blue),
	b: ("ABC", "IJK", "XYZ"),
	c: "foo",
	d: (
		(x: 12,   y: 45,   z: 78),
		(x: 12.3, y: 45.6, z: 78.9),
		(x: 12.9, y: 45.9, z: 78.9),
	),
)

#let test2 = (
	a: (i: aqua, j: fuchsia, k: yellow, l: black),
	c: "bar",
	d: (
		(w: 39),
		(w: 39.7),
		(w: 39.8),
	),
)

#let test3 = (
	a: "lorem",
	b: ("D", "E", "F"),
	d: none,
	e: "ipsum",
)


#deep.merge(test1, test2) /* -> (
	a: (i: rgb("#7fdbff"), j: rgb("#f012be"), k: rgb("#ffdc00"), l: luma(0%)),
	b: ("ABC", "IJK", "XYZ"),
	c: "bar",
	d: (
		(x: 12, y: 45, z: 78, w: 39),
		(x: 12.3, y: 45.6, z: 78.9, w: 39.7),
		(x: 12.9, y: 45.9, z: 78.9, w: 39.8),
	),
) */
#deep.merge(test1, test3) /* -> (
	a: (i: rgb("#ff4136"), j: rgb("#2ecc40"), k: rgb("#0074d9"), "3": "lorem"),
	b: ("D", "E", "F"),
	c: "foo",
	d: (
		(x: 12, y: 45, z: 78),
		(x: 12.3, y: 45.6, z: 78.9),
		(x: 12.9, y: 45.9, z: 78.9),
	),
	e: "ipsum",
) */
#deep.merge(test1, test2, test3) /* -> (
	a: (i: rgb("#7fdbff"), j: rgb("#f012be"), k: rgb("#ffdc00"), l: luma(0%), "4": "lorem"),
	b: ("D", "E", "F"),
	c: "bar",
	d: (
		(x: 12, y: 45, z: 78, w: 39),
		(x: 12.3, y: 45.6, z: 78.9, w: 39.7),
		(x: 12.9, y: 45.9, z: 78.9, w: 39.8),
	),
	e: "ipsum",
) */


#let merge-custom = deep.merge.with(
//	none-none: "skip", // default
//	none-scalar: "overwrite", // default
//	none-array: "overwrite", // default
//	none-dict: "overwrite", // default
	scalar-none: "remove",
	scalar-scalar: (f, l) => {
		if type(f) == color and type(l) == color {
			color.mix(f, l, space: f.space())
		} else {
			(str(f), str(l)).join(" ")
		}
	},
	scalar-array: "overwrite",
	scalar-dict: "overwrite",
	array-none: "remove",
	array-scalar: "skip",
	array-array: "append",
//	array-dict: "values", // default
	dict-none: "remove",
	dict-scalar: "skip",
//	dict-array: "enumerate", // default
)

#merge-custom(test1, test2) /* -> (
	a: (i: rgb("#bf8e9b"), j: rgb("#8f6f7f"), k: rgb("#80a86c"), l: luma(0%)),
	b: ("ABC", "IJK", "XYZ"),
	c: "foo bar",
	d: (
		(x: 12, y: 45, z: 78),
		(x: 12.3, y: 45.6, z: 78.9),
		(x: 12.9, y: 45.9, z: 78.9),
		(w: 39),
		(w: 39.7),
		(w: 39.8),
	),
) */
#merge-custom(test1, test3) /* -> (
	a: (i: rgb("#ff4136"), j: rgb("#2ecc40"), k: rgb("#0074d9")),
	b: ("ABC", "IJK", "XYZ", "D", "E", "F"),
	c: "foo",
	e: "ipsum",
) */
#merge-custom(test1, test2, test3) /* -> (
	a: (i: rgb("#bf8e9b"), j: rgb("#8f6f7f"), k: rgb("#80a86c"), l: luma(0%)),
	b: ("ABC", "IJK", "XYZ", "D", "E", "F"),
	c: "foo bar",
	e: "ipsum",
) */
```
</details>


### `merge-over`

Returns the result of recursively merging a series of `dictionary` values, resolving any key conflicts by [overwriting](#overwrite) the `first` value with the `other`.

```typ
#merge-over(
	first, // dictionary
	..others, // dictionaries
) -> dictionary
```

This function is a wrapper for [`merge()`](#merge), with rules preconfigured for compatibility with [cetz’][typst_package_cetz] `util.merge-dictionary()`, and with [t4t’s][typst_package_t4t] `get.dict-merge()`.


### `merge-skip`

Returns the result of recursively merging a series of `dictionary` values, resolving any key conflicts by [skipping](#skip) the `other` value and returning the `first`.

```typ
#merge-skip(
	first, // dictionary
	..others, // dictionaries
) -> dictionary
```

This function is a wrapper for [`merge()`](#merge), with rules preconfigured for compatibility with [cetz’][typst_package_cetz] `util.merge-dictionary(overwrite: false)`.


### `merge-jquery`

Returns the result of recursively merging a series of `dictionary` values, resolving most key conflicts by [overwriting](#overwrite) the `first` value with the `other`; where an `array` value is to be merged into another `array`, it is done so [recursively](#deep).

```typ
#merge-jquery(
	first, // dictionary
	..others, // dictionaries
) -> dictionary
```

This function is a wrapper for [`merge()`](#merge), with rules preconfigured for compatibility with [jQuery’s][js_jquery_extend] `$.extend()`.


### `merge-lodash`

Returns the result of recursively merging a series of `dictionary` values, resolving most merge conflicts by [overwriting](#overwrite) the `first` value with the `other`.

- Where an `other` value of type `array` is to be merged into a `first` value of type `array`, it is done so [recursively](#deep).
- Where an `other` value of type `dictionary` is to be merged into a `first` value of type `array`, the [numeric keys](#numeric-keys) of the `dictionary` are extracted as an `array`, which is then recursively merged as above.

```typ
#merge-lodash(
	first, // dictionary
	..others, // dictionaries
) -> dictionary
```

This function is a wrapper for [`merge()`](#merge), with rules preconfigured for compatibility with [Lodash’s][js_lodash_merge] `_.merge()`.


## Helper Functions

### `has`

Tests whether the supplied deep path exists within a multi-level dictionary.

Note: Deep Dish uses an intentionally simplistic syntax for deep paths, of the form `deep.path.segment.schema`, on the assumption that the developer only wishes to test a single, already-known location within the data structure. For a more comprehensive query language, try the [jsonpath][typst_package_jsonpath] or [yak][typst_package_yak] packages.

```typ
#has(
	data, // dictionary
	path, // str
	separator: ".", // str
	zero: true, // bool
) -> bool
```

<details>
	<summary>View arguments</summary>

#### `data`

`dictionary` (positional, required)

The data structure to test.

#### `path`

`str` (positional, required)

The path to check for.

The `path` is first split on `separator` into a list of segments; each segment is then tested as a dictionary key or an array index as appropriate to the data structure, like a filesystem path.

Array indices may be positive or negative numbers encoded within the string; negative numbers work the same as they do for [`array.at()`][typst_docs_array_at].

#### `separator`

`str`

The character or substring on which to split `path` into segments.

Developers should take care to choose a `separator` that does not appear as a substring of any dictionary keys, and to craft their `path`s accordingly. Choosing a `separator` that is contained within a dictionary key will yield undesired results.

Default: `"."`

#### `zero`

`bool`

Whether numeric array indices in `path` should be treated as zero-based.

- If `false`, a `path` segment of `"1"` will be matched to the first entry in an array.
- If `true`, a `path` segment of `"0"` will be matched to the first entry in an array.

A numeric `path` segment of `"-1"` will always match to the last entry in an array, regardless of the value of `zero`.

Default: `true`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/deep-dish:0.1.0" as deep

#let test = (
	a: (i: red, j: green, k: blue),
	b: ("ABC", "IJK", "XYZ"),
	c: (
		(x: 12,   y: 45,   z: 78),
		(x: 12.3, y: 45.6, z: 78.9),
		(x: 12.9, y: 45.9, z: 78.9),
	),
)

#deep.has(test, "a") // -> true
#deep.has(test, "d") // -> false
#deep.has(test, "a.j") // -> true
#deep.has(test, "a.j.q") // -> false
#deep.has(test, "b.1") // -> true
#deep.has(test, "b.a") // -> false
#deep.has(test, "c.1.y") // -> true
#deep.has(test, "c.5.y") // -> false
#deep.has(test, "c.3.y", zero: true) // -> false
#deep.has(test, "c.3.y", zero: false) // -> true
#deep.has(test, "c.-3.y", zero: true) // -> true
#deep.has(test, "c.-3.y", zero: false) // -> true
#deep.has(test, "c.-4.y") // -> false
#deep.has(test, "c.1.y", separator: "/") // -> false
#deep.has(test, "c/1/y", separator: "/") // -> true
```
</details>


### `at`

Retrieves a value from deep within a multi-level dictionary.

Note: Deep Dish uses an intentionally simplistic syntax for deep paths, of the form `deep.path.segment.schema`, on the assumption that the developer only wishes to test a single, already-known location within the data structure. For a more comprehensive query language, try the [jsonpath][typst_package_jsonpath] or [yak][typst_package_yak] packages.

```typ
#at(
	data, // dictionary
	path, // str
	default: auto, // any
	separator: ".", // str
	zero: true, // bool
) -> bool
```

<details>
	<summary>View arguments</summary>

#### `data`

`dictionary` (positional, required)

The data structure to search.

#### `path`

`str` (positional, required)

The path to take through the data structure.

The `path` is first split on `separator` into a list of segments; each segment is then tested as a dictionary key or an array index as appropriate to the data structure, like a filesystem path.

Array indices may be positive or negative numbers encoded within the string; negative numbers work the same as they do for [`array.at()`][typst_docs_array_at].

#### `default`

any

What to return if `path` does not exist within the data structure.

If set to `auto`, an invalid `path` causes a [panic][typst_docs_panic].

Default: `auto`

#### `separator`

`str`

The character or substring on which to split `path` into segments.

Developers should take care to choose a `separator` that does not appear as a substring of any dictionary keys, and to craft their `path`s accordingly. Choosing a `separator` that is contained within a dictionary key will yield undesired results.

Default: `"."`

#### `zero`

`bool`

Whether numeric array indices in `path` should be treated as zero-based.

- If `false`, a `path` segment of `"1"` will be matched to the first entry in an array.
- If `true`, a `path` segment of `"0"` will be matched to the first entry in an array.

A numeric `path` segment of `"-1"` will always match to the last entry in an array, regardless of the value of `zero`.

Default: `true`
</details>

<details>
	<summary>View examples</summary>

```typ
#import "@preview/deep-dish:0.1.0" as deep

#let test = (
	a: (i: red, j: green, k: blue),
	b: ("ABC", "IJK", "XYZ"),
	c: (
		(x: 12,   y: 45,   z: 78),
		(x: 12.3, y: 45.6, z: 78.9),
		(x: 12.9, y: 45.9, z: 78.9),
	),
)

#deep.at(test, "a") // -> (i: rgb("#ff4136"), j: rgb("#2ecc40"), k: rgb("#0074d9"))
#deep.at(test, "d") // panics with: “d” not found in…
#deep.at(test, "a.j") // -> rgb("#2ecc40")
#deep.at(test, "a.j.q") // panics with: “q” not found in…
#deep.at(test, "b.1") // -> "IJK"
#deep.at(test, "b.a") // -> panics with: array index must be numeric, found string "a"
#deep.at(test, "c.1.y") // -> 45.6
#deep.at(test, "c.5.y") // panics with: array index out of bounds (index: 5, min: 0, max: 2) in…
#deep.at(test, "c.3.y", zero: true) // panics with: array index out of bounds (index: 3, min: 0, max: 2) in…
#deep.at(test, "c.3.y", zero: false) // -> 45.9
#deep.at(test, "c.-3.y", zero: true) // -> 45
#deep.at(test, "c.-3.y", zero: false) // -> 45
#deep.at(test, "c.-4.y") // panics with: array index out of bounds (index: -4, min: -3, max: -1) in…
#deep.at(test, "c.1.y", separator: "/") // panics with: “c.1.y” not found in…
#deep.at(test, "c/1/y", separator: "/") // -> 45.6
```
</details>


[typst_docs_panic]: https://typst.app/docs/reference/foundations/panic/
[typst_docs_assert_eq]: https://typst.app/docs/reference/foundations/assert/#definitions-eq
[typst_docs_array_at]: https://typst.app/docs/reference/foundations/array/#definitions-at

[typst_package_cetz]: https://typst.app/universe/package/cetz
[typst_package_t4t]: https://typst.app/universe/package/t4t
[typst_package_jsonpath]: https://typst.app/universe/package/jsonpath
[typst_package_yak]: https://typst.app/universe/package/yak

[js_jquery_extend]: https://api.jquery.com/jQuery.extend/
[js_lodash_merge]: https://lodash.com/docs/#merge


## Changelog

### 0.1.0 - 2026-10-03

_Initial release._


