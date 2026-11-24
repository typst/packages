
#import	"/internals/utils.typ"		:   *
#import	"/internals/rules.typ"		:   *

// Validate arguments.
#let	deep-merge(first, ..others)	= {
	let	names				=   predefined.keys()
	let	rules				=   others.named()
	let	others				=   others.pos()
	let	func				=   rules.remove(
		default				:  "merge",
		"func",
	)

	arg-assert-types(func, "first", first, (dictionary,))

	assert(
		message				:   debug-message(func, "missing argument “others”", (:)),
		others.len() > 0,
	)

	let	_				=   others.map(
		other				=>  arg-assert-types(func, "others", other, (dictionary,)),
	)

	let	_				=   rules.keys().map(
		other				=>  arg-assert-expected(func, other, names)
	)

	let	_				=   names.map(
		name				=>  if name in rules {
			let	rule				=   rules.at(name)

			arg-assert-types(func, name, rule, (function, str))

			if type(rule) == str {
				arg-assert-values(func, name, rule, predefined.at(name).keys())
			}
		},
	)


	rules				=   normalise(rules)

	for other in others {
		first				=   walk-dict(first, other, rules)
	}


	first
}


/// Perform a deep merge operation on two or more dictionaries.
/// - first (dictionary): The initial (target) data structure.
/// - others (dictionary): One or more additional (source) data structures to merge into `first`.
/// -> dictionary
#let	merge-default(
	none-none			:  "skip",
	none-scalar			:  "overwrite",
	none-array			:  "overwrite",
	none-dict			:  "overwrite",
	scalar-none			:  "skip",
	scalar-scalar			:  "overwrite",
	scalar-array			:  "append",
	scalar-dict			:  "numeric-key",
	array-none			:  "skip",
	array-scalar			:  "append",
	array-array			:  "deep",
	array-dict			:  "values",
	dict-none			:  "skip",
	dict-scalar			:  "numeric-key",
	dict-array			:  "enumerate",

	first,
	..others,
) = deep-merge(
	none-none			:   none-none,
	none-scalar			:   none-scalar,
	none-array			:   none-array,
	none-dict			:   none-dict,
	scalar-none			:   scalar-none,
	scalar-scalar			:   scalar-scalar,
	scalar-array			:   scalar-array,
	scalar-dict			:   scalar-dict,
	array-none			:   array-none,
	array-scalar			:   array-scalar,
	array-array			:   array-array,
	array-dict			:   array-dict,
	dict-none			:   dict-none,
	dict-scalar			:   dict-scalar,
	dict-array			:   dict-array,

	first,
	..others,
)


/// Perform a deep merge operation on two or more dictionaries.
/// Whenever conflicts are discovered, aggressively overwrite older values with newer ones.
/// Compatible with `cetz.util.merge-dictionary()` and `t4t.get.dict-merge()`.
/// - first (dictionary): The initial (target) data structure.
/// - others (dictionary): One or more additional (source) data structures to merge into `first`.
/// -> dictionary
#let	merge-over(first, ..others)	=   deep-merge(
	none-none			:  "skip",
	none-scalar			:  "overwrite",
	none-array			:  "overwrite",
	none-dict			:  "overwrite",
	scalar-none			:  "overwrite",
	scalar-scalar			:  "overwrite",
	scalar-array			:  "overwrite",
	scalar-dict			:  "overwrite",
	array-none			:  "overwrite",
	array-scalar			:  "overwrite",
	array-array			:  "overwrite",
	array-dict			:  "overwrite",
	dict-none			:  "overwrite",
	dict-scalar			:  "overwrite",
	dict-array			:  "overwrite",

	func				:  "merge-over",
	first,
	..others,
)

/// Perform a deep merge operation on two or more dictionaries.
/// Whenever conflicts are discovered, preserve older values and discard newer ones.
/// Compatible with `cetz.util.merge-dictionary(overwrite: false)`.
/// - first (dictionary): The initial (target) data structure.
/// - others (dictionary): One or more additional (source) data structures to merge into `first`.
/// -> dictionary
#let	merge-skip(first, ..others)	=   deep-merge(
	none-none			:  "skip",
	none-scalar			:  "skip",
	none-array			:  "skip",
	none-dict			:  "skip",
	scalar-none			:  "skip",
	scalar-scalar			:  "skip",
	scalar-array			:  "skip",
	scalar-dict			:  "skip",
	array-none			:  "skip",
	array-scalar			:  "skip",
	array-array			:  "skip",
	array-dict			:  "skip",
	dict-none			:  "skip",
	dict-scalar			:  "skip",
	dict-array			:  "skip",

	func				:  "merge-skip",
	first,
	..others,
)


/// Perform a deep merge operation on two or more dictionaries.
/// Compatible with jQuery `$.extend()`.
/// - first (dictionary): The initial (target) data structure.
/// - others (dictionary): One or more additional (source) data structures to merge into `first`.
/// -> dictionary
#let	merge-jquery(first, ..others)	=   deep-merge(
	none-none			:  "skip",
	none-scalar			:  "overwrite",
	none-array			:  "overwrite",
	none-dict			:  "overwrite",
	scalar-none			:  "overwrite",
	scalar-scalar			:  "overwrite",
	scalar-array			:  "overwrite",
	scalar-dict			:  "overwrite",
	array-none			:  "overwrite",
	array-scalar			:  "overwrite",
	array-array			:  "deep",
	array-dict			:  "overwrite",
	dict-none			:  "overwrite",
	dict-scalar			:  "overwrite",
	dict-array			:  "overwrite",

	func				:  "merge-jquery",
	first,
	..others,
)

/// Perform a deep merge operation on two or more dictionaries.
/// Compatible with Lodash `_.merge()`.
/// - first (dictionary): The initial (target) data structure.
/// - others (dictionary): One or more additional (source) data structures to merge into `first`.
/// -> dictionary
#let	merge-lodash(first, ..others)	=   deep-merge(
	none-none			:  "skip",
	none-scalar			:  "overwrite",
	none-array			:  "overwrite",
	none-dict			:  "overwrite",
	scalar-none			:  "overwrite",
	scalar-scalar			:  "overwrite",
	scalar-array			:  "overwrite",
	scalar-dict			:  "overwrite",
	array-none			:  "overwrite",
	array-scalar			:  "overwrite",
	array-array			:  "deep",
	array-dict			:  "numeric-keys",
	dict-none			:  "overwrite",
	dict-scalar			:  "overwrite",
	dict-array			:  "overwrite",

	func				:  "merge-lodash",
	first,
	..others,
)

