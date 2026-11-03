
#import	"/internals/utils.typ"		:   *

#let	pick(target, source)		= {
	let	lookup				= (
		"none"				:  "none",
		"auto"				:  "scalar",
		"array"				:  "array",
		"dictionary"			:  "dict",
	)

	(
		lookup.at(repr(type-ish(target))),
		lookup.at(repr(type-ish(source))),
	).join("-")
}

#let	apply(rule, target, source, rules) = {
	let	rule				=   rules.at(rule)

	// Some rules perform a conversion on the source data, before feeding the
	// result into a second rule. This is a one-time deal for each affected
	// source — we intentionally disallow chaining conversions.
	if "then" in rule {
		source				=  (rule.mapper)(target, source)
		rule				=   rules.at(rule.then)
	}

	if rule.recurse {
		return (rule.mapper)(target, source, rules)
	}

	(rule.mapper)(target, source)
}


// Recursively merge two arrays using the selected rules.
#let	walk-array(first, other, rules)	= {
	let	remove				= ( )

	for (key, source) in other.enumerate() {
		if key >= first.len() {
			first.push(source)
			continue
		}

		let	target				=   first.at(
			default				:   none,
			key,
		)
		let	rule				=   pick(target, source)

		if none == rules.at(rule) {
			remove.insert(0, key)
		} else {
			first.at(key)			=   apply(rule, target, source, rules)
		}
	}

	if remove.len() > 0 {
		for key in remove {
			let	_				=   first.remove(
				default				:   none,
				key,
			)
		}
	}

	first
}

// Recursively merge two dictionaries using the selected rules.
#let	walk-dict(first, other, rules)	= {
	for (key, source) in other.pairs() {
		let	target				=   first.at(
			default				:   none,
			key,
		)

		let	rule				=   pick(target, source)

		// Special case: a rule value of `none` means to intentionally
		// remove the original value without overwriting it
		if none == rules.at(rule) {
			let	_				=   first.remove(
				default				:   none,
				key,
			)
			continue
		} else if key not in first {
			first.insert(key, source)
			continue
		}

		first.insert(key, apply(rule, target, source, rules))
	}

	first
}


#let	predefined			= (
	none-none			: (
		skip				: ( a, _ ) =>  a,
		remove				:   none,
	),

	none-scalar			: (
		skip				: ( a, _ ) =>  a,
		overwrite			: ( _, b ) =>  b,
	),

	none-array			: (
		skip				: ( a, _ ) =>  a,
		overwrite			: ( _, b ) =>  b,
	),

	none-dict			: (
		skip				: ( a, _ ) =>  a,
		overwrite			: ( _, b ) =>  b,
	),

	scalar-none			: (
		skip				: ( a, _ ) =>  a,
		overwrite			: ( _, b ) =>  b,
		remove				:   none,
	),

	scalar-scalar			: (
		skip				: ( a, _ ) =>  a,
		overwrite-strict		: ( a, b ) => {
			assert.eq(
				message				:   debug-message(
					"merge",
					"attempt to overwrite {a} with {b}",
					(
						a				:   debug-value(a),
						b				:   debug-value(b),
					),
				),
				type(a),
				type(b),
			)

			b
		},
		overwrite-same			: ( a, b ) =>  if type(a) == type(b) { b } else { a },
		overwrite			: ( _, b ) =>  b,
	),

	scalar-array			: (
		skip				: ( a, _ ) =>  a,
		prepend				: ( a, b ) =>  b   + (a,),
		append				: ( a, b ) => (a,) +  b,
		overwrite			: ( _, b ) =>  b,
	),

	scalar-dict			: (
		skip				: ( a, _ ) =>  a,
		numeric-key			: ( a, b ) =>  b + (str(b.len()): a),
		overwrite			: ( _, b ) =>  b,
	),

	array-none			: (
		skip				: ( a, _ ) =>  a,
		prepend				: ( a, b ) => (b,) +  a,
		append				: ( a, b ) =>  a   + (b,),
		empty				: (  ..  ) => ( ),
		overwrite			: ( _, b ) =>  b,
		remove				:   none,
	),

	array-scalar			: (
		skip				: ( a, _ ) =>  a,
		prepend				: ( a, b ) => (b,) +  a,
		append				: ( a, b ) =>  a   + (b,),
		overwrite			: ( _, b ) =>  b,
	),

	array-array			: (
		skip				: ( a, _ ) =>  a,
		prepend				: ( a, b ) =>  b   +  a,
		append				: ( a, b ) =>  a   +  b,
		zip				: ( a, b ) =>  a.zip(b),
		slice				: ( a, b ) =>  b   +  a.slice(calc.min(a.len(), b.len())),
		deep				: (
			mapper				:   walk-array,
			recurse				:   true,
		),
		overwrite			: ( _, b ) =>  b,
	),

	array-dict			: (
		skip				: ( a, _ ) =>  a,
		empty				: (  ..  ) => ( ),
		overwrite			: ( _, b ) =>  b,

		// Convert dictionary to array
		pairs				: (
			mapper				: ( _, b ) => b.pairs(),
			then				:  "array-array",
		),
		values				: (
			mapper				: ( _, b ) => b.values(),
			then				:  "array-array",
		),
		numeric-keys			: (
			mapper				: ( a, b ) => {
				let	k				=   b.keys().sorted()
				let	l				=  ( )

				for (k, v) in b {
					if str-is-int(k) {
						if int(k) < a.len() {
							a.at(int(k))			=   v
						} else {
							l.push(v)
						}
					}
				}

				a + l
			},
			then				:  "array-array",
		),
	),

	dict-none			: (
		skip				: ( a, _ ) =>  a,
		numeric-key			: ( a, b ) =>  a + (str(a.len()): b),
		empty				: (  ..  ) => (:),
		overwrite			: ( _, b ) =>  b,
		remove				:   none,
	),

	dict-scalar			: (
		skip				: ( a, _ ) =>  a,
		numeric-key			: ( a, b ) =>  a + (str(a.len()): b),
		overwrite			: ( _, b ) =>  b,
	),

	dict-array			: (
		skip				: ( a, _ ) =>  a,
		empty				: (  ..  ) => (:),
		overwrite			: ( _, b ) =>  b,

		// Convert array to dictionary
		enumerate			: (
			mapper				: ( _, b ) =>  b.enumerate().map(((k, v)) => (str(k): v)).join(),
			then				:  "dict-dict",
		),
	),

	dict-dict			: (
		deep				: (
			mapper				:   walk-dict,
			recurse				:   true,
		),
	),
)


#let	normalise(rules)		= {
	let	template			= (
		mapper				:   none,
		recurse				:   false,
	)

	for (name, rule) in rules.pairs() {
		if type(rule) == str {
			rule				=   predefined.at(name).at(rule)
		}

		if type(rule) == function {
			rule				=   template + (
				mapper				:   rule,
			)
		}

		rules.insert(name, rule)
	}

	rules.dict-dict			=   predefined.dict-dict.deep

	rules
}

