
#import	"/internals/utils.typ"		:   *

// Split a deep path string into individual keys/indices.
#let	deep-chunk(path, separator)	=   if type(path) == str {
	path.trim(separator).split(separator)
} else {
	path
}

// Pop the topmost deep path key/index.
#let	deep-drill(chunks)		= {
	if chunks.len() == 0 {
		return (none, none)
	}

	if chunks.len() == 1 {
		return (chunks.first(), none)
	}

	(chunks.first(), chunks.slice(1))
}

// Determine array bounds based on `zero` setting or negative index.
#let	deep-offset(
	func,
	zero,
	data,
	index,
) = {
	let	len				=   data.len()

	// Probably a more efficient way to calculate this, but it works.
	let	(min, max, actual)		= (
		( 0,	 len - 1,	index),		// positive, 0-indexed
		( 1,	 len,		index - 1),	// positive, 1-indexed
		(-1,	-len,		index),		// negative
	).at(if index < 0 {
		-1
	} else {
		int(not zero)
	})


	(actual, calc.min(min, max), calc.max(min, max))
}


#let	deep-has(
	func,
	data,
	path,
	..options,
) = {
	let	(zero,)				=   options.named()
	let	(key, rest)			=   deep-drill(path)

	if type(data) not in (array, dictionary) {
		return false
	}


	if type(data) == array {
		if not str-is-int(key) {
			return false
		}

		key				=   int(key)

		let	(index, min, max)		=   deep-offset(func, zero, data, key)

		if calc.clamp(key, min, max) != key {
			return false
		}

		key				=   index
	} else if key not in data {
		return false
	}

	if none == rest {
		return true
	}


	deep-has(func, data.at(key), rest, ..options)
}

/// Test whether or not the supplied deep path exists within a multi-level dictionary.
/// - data (dictionary): The data structure to test.
/// - path (str): The path to check for.
/// - separator (str): The character or substring on which to split `path` into segments.
/// - zero (bool): Whether numerical array indices in `path` should be treated as zero-based.
/// -> bool
#let	has(
	separator			:  ".",
	zero				:   true,
	data,
	path,
) = {
	let	func				=  "has"

	arg-assert-types(func, "data",		data,		(array, dictionary))
	arg-assert-types(func, "path",		path,		(str,))
	arg-assert-types(func, "zero",		zero,		(bool,))
	arg-assert-types(func, "separator",	separator,	(str,))

	deep-has(
		zero				:   zero,
		func,
		data,
		deep-chunk(path, separator),
	)
}


#let	deep-at(
	func,
	data,
	path,
	..options,
) = {
	let	(zero, separator, default)	=   options.named()
	let	(key, rest)			=   deep-drill(path)

	let	message				=   debug-message(func, "“{path}” not found in {data}", (
		path				:   path.join(separator),
		data				:   repr(data),
	))

	if type(data) not in (array, dictionary) {
		if auto == default {
			panic(message)
		}

		return default
	}


	if type(data) == array {
		arg-assert-numeric(func, key)

		key				=   int(key)

		let	(index, min, max)		=   deep-offset(func, zero, data, key)

		if auto == default {
			assert(
				message				:   debug-message(func, "array index out of bounds (index: {index}, min: {min}, max: {max}) in {data}", (
					min				:   str(min),
					max				:   str(max),
					index				:   str(key),
					data				:   repr(data),
				)),

				calc.clamp(key, min, max) == key,
			)
		}

		key				=   index
	} else if auto == default and key not in data {
		panic(message)
	}


	let	result				=   data.at(
		default				:   default,
		key,
	)

	if none == rest {
		return result
	}


	deep-at(func, result, rest, ..options)
}

/// Retrieve a value from deep within a multi-level dictionary.
/// - data (dictionary): The data structure to search.
/// - path (str): The path to take through the data structure.
/// - default (any): What to return if `path` does not exist within the data structure; if `auto`, an invalid `path` causes a panic.
/// - separator (str): The character or substring on which to split `path` into segments.
/// - zero (bool): Whether numerical array indices in `path` should be treated as zero-based.
#let	at(
	separator			:  ".",
	zero				:   true,
	default				:   auto,
	data,
	path,
) = {
	let	func				=  "at"

	arg-assert-types(func, "data",		data,		(array, dictionary))
	arg-assert-types(func, "path",		path,		(str,))
	arg-assert-types(func, "zero",		zero,		(bool,))
	arg-assert-types(func, "separator",	separator,	(str,))

	deep-at(
		separator			:   separator,
		zero				:   zero,
		default				:   default,
		func,
		data,
		deep-chunk(path, separator),
	)
}

