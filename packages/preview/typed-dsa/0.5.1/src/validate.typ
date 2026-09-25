// Shared argument validation and diagnostics for every public entry point.
//
// Public builders, operations, and customizations run their arguments through
// these helpers before any model is built, so an invalid call aborts
// compilation with an editor-visible Typst error that names the function, the
// offending value, and the accepted range. Model construction, layout, and
// rendering may therefore assume a valid model: they never re-check argument
// shape, and they never fall through to a generic dictionary, comparison, or
// CeTZ error.
//
// Three validation phases, in this order:
//
//   1. argument validation  — types, enums, numeric ranges, dictionary schemas
//   2. structure validation — the model the arguments describe is consistent
//   3. reference validation — customizations and operations name parts that
//                             exist in the resolved structure
//
// A reference that cannot exist is an error. A search that finds nothing is
// not: "not found" is a legitimate result and is reported through a step's
// `found:` field instead.

// ── Diagnostics ──────────────────────────────────────────────────────────────

#let _shown-value-limit = 60

// A short, readable rendering of any user value for an error message.
#let show-value(value) = {
  let rendered = repr(value)
  let glyphs = rendered.clusters()
  if glyphs.len() <= _shown-value-limit { return rendered }
  glyphs.slice(0, _shown-value-limit - 1).join() + "…"
}

#let show-list(values) = if values.len() == 0 {
  "(none)"
} else {
  values.map(show-value).join(", ")
}

// A type list is written with type values (`int`, `type(none)`). Anything else
// is rendered by value, so a malformed list still produces a readable message.
#let show-types(types) = types.map(
  candidate => if type(candidate) == type { str(candidate) } else { repr(candidate) },
).join(" or ")

// Every diagnostic follows the same shape so the four required facts —
// where, what was wrong, what is accepted, and how to fix it — always appear
// in the same order.
#let fail(where, problem, expected: none, fix: none) = {
  let message = "typed-dsa " + where + ": " + problem
  if expected != none { message += "\n  expected: " + expected }
  if fix != none { message += "\n  fix: " + fix }
  assert(false, message: message)
}

#let _shared-prefix-length(left, right) = {
  let left-glyphs = left.clusters()
  let right-glyphs = right.clusters()
  let shared = 0
  while (
    shared < left-glyphs.len()
      and shared < right-glyphs.len()
      and left-glyphs.at(shared) == right-glyphs.at(shared)
  ) {
    shared += 1
  }
  shared
}

// The candidate key a misspelling most likely meant, or `none` when nothing is
// close enough to be worth suggesting.
#let closest-name(name, candidates) = {
  let best-candidate = none
  let best-score = 1
  for candidate in candidates {
    let score = _shared-prefix-length(name, candidate)
    if score > best-score {
      best-score = score
      best-candidate = candidate
    }
  }
  best-candidate
}

#let _unknown-key-fix(name, candidates) = {
  let suggestion = closest-name(name, candidates)
  if suggestion == none {
    "remove it, or use one of the listed keys"
  } else {
    "did you mean \"" + suggestion + "\"?"
  }
}

// ── Type and value checks ────────────────────────────────────────────────────

#let is-number(value) = type(value) in (int, float)

#let check-type(where, what, value, types, fix: none) = {
  if type(value) in types { return }
  fail(
    where,
    what + " must be " + show-types(types) + ", got " + show-value(value),
    expected: show-types(types),
    fix: fix,
  )
}

#let check-bool(where, what, value) = check-type(
  where,
  what,
  value,
  (bool,),
  fix: "pass true or false",
)

#let check-function(where, what, value) = check-type(
  where,
  what,
  value,
  (function,),
  fix: "pass a function, for example " + what + ": value => value",
)

#let check-array(where, what, value, fix: none) = check-type(
  where,
  what,
  value,
  (array,),
  fix: fix,
)

#let check-dictionary(where, what, value, fix: none) = check-type(
  where,
  what,
  value,
  (dictionary,),
  fix: fix,
)

#let check-enum(where, what, value, allowed, fix: none) = {
  if value in allowed { return }
  fail(
    where,
    what + " is " + show-value(value) + ", which is not a supported value",
    expected: "one of " + show-list(allowed),
    fix: if fix != none {
      fix
    } else if type(value) == str {
      _unknown-key-fix(value, allowed.filter(item => type(item) == str))
    } else {
      none
    },
  )
}

#let check-number(
  where,
  what,
  value,
  min: none,
  max: none,
  min-exclusive: false,
) = {
  if not is-number(value) {
    fail(
      where,
      what + " must be a number, got " + show-value(value),
      expected: "an integer or float",
    )
  }
  if min != none {
    let below-minimum = if min-exclusive { value <= min } else { value < min }
    if below-minimum {
      fail(
        where,
        what + " is " + show-value(value) + ", which is out of range",
        expected: (
          if min-exclusive { "greater than " } else { "at least " } + str(min)
        ),
      )
    }
  }
  if max != none and value > max {
    fail(
      where,
      what + " is " + show-value(value) + ", which is out of range",
      expected: "at most " + str(max),
    )
  }
}

#let check-positive(where, what, value) = check-number(
  where,
  what,
  value,
  min: 0,
  min-exclusive: true,
)

#let check-non-negative(where, what, value) = check-number(
  where,
  what,
  value,
  min: 0,
)

#let check-integer(where, what, value, min: none, max: none) = {
  check-type(where, what, value, (int,))
  check-number(where, what, value, min: min, max: max)
}

// A position into a sequence of `count` items. `inclusive: true` also accepts
// `count` itself, for insertion points that may append past the last item.
#let check-index(where, what, value, count, inclusive: false, subject: "array") = {
  check-type(
    where,
    what,
    value,
    (int,),
    fix: "pass a whole number index",
  )
  let last-valid = if inclusive { count } else { count - 1 }
  if value >= 0 and value <= last-valid { return }
  if count == 0 and not inclusive {
    fail(
      where,
      what + " is " + str(value) + ", but the " + subject + " is empty",
      expected: "no valid index; the " + subject + " has no elements",
      fix: "add elements before referring to one by index",
    )
  }
  fail(
    where,
    what + " is " + str(value) + ", which is out of bounds for a " + str(count) + "-element " + subject,
    expected: "0 to " + str(last-valid),
  )
}

// ── Dictionary schemas ───────────────────────────────────────────────────────

#let check-known-keys(where, what, options, allowed) = {
  check-dictionary(where, what, options)
  for key in options.keys() {
    if key in allowed { continue }
    fail(
      where,
      what + " has unknown key \"" + key + "\"",
      expected: "one of " + allowed.map(name => "\"" + name + "\"").join(", "),
      fix: _unknown-key-fix(key, allowed),
    )
  }
}

// ── Structural checks ────────────────────────────────────────────────────────

#let check-non-empty(where, what, values, fix: none) = {
  if values.len() > 0 { return }
  fail(
    where,
    what + " is empty",
    expected: "at least one value",
    fix: fix,
  )
}

#let check-unique(where, what, values, subject: "value") = {
  let seen = (:)
  for value in values {
    let identity = repr(value)
    if identity in seen {
      fail(
        where,
        what + " contains " + show-value(value) + " more than once",
        expected: "each " + subject + " to appear exactly once",
        fix: "remove the duplicate " + subject,
      )
    }
    seen.insert(identity, true)
  }
}

// Typst can order numbers against numbers and strings against strings, but
// nothing else and nothing across those groups. Structures that sort or search
// by key check this up front so an unsupported key never reaches a comparison
// deep inside an algorithm.
#let comparison-group(value) = if is-number(value) {
  "number"
} else if type(value) == str {
  "string"
} else {
  none
}

#let check-comparable(where, what, values, subject: "value") = {
  let first-group = none
  for value in values {
    let group = comparison-group(value)
    if group == none {
      fail(
        where,
        what + " contains " + show-value(value) + ", which cannot be ordered against other " + subject + "s",
        expected: "integers, floats, or strings",
        fix: "use a comparable " + subject + ", or set the drawn text with a label instead",
      )
    }
    if first-group == none {
      first-group = group
    } else if group != first-group {
      fail(
        where,
        what + " mixes " + first-group + " and " + group + " " + subject + "s (" + show-value(value) + ")",
        expected: "all " + subject + "s to be numbers, or all to be strings",
        fix: "use one " + subject + " type throughout",
      )
    }
  }
}

// Checks one value against an already-established key group, for operations
// that add to or look inside an existing structure.
#let check-comparable-with(where, what, value, existing, subject: "key") = {
  check-comparable(where, what, (value,), subject: subject)
  if existing.len() == 0 { return }
  let existing-group = comparison-group(existing.first())
  if existing-group == none { return }
  if comparison-group(value) != existing-group {
    fail(
      where,
      what + " is " + show-value(value) + ", which cannot be compared with the " + existing-group + " " + subject + "s already in the structure",
      expected: "a " + existing-group,
      fix: "use the same " + subject + " type as the structure was built with",
    )
  }
}

// ── Reference checks ─────────────────────────────────────────────────────────

// A customization, label, or operation naming a part of the structure. The
// available identifiers are listed so the caller can see what they could have
// meant.
#let check-reference(where, what, id, available, subject: "node") = {
  if id in available { return }
  fail(
    where,
    what + " refers to " + subject + " " + show-value(id) + ", which does not exist in the structure",
    expected: "one of the " + subject + "s: " + show-list(available),
    fix: _unknown-key-fix(
      if type(id) == str { id } else { repr(id) },
      available.filter(item => type(item) == str),
    ),
  )
}

// `(target, options)` and `(from, to, options)` customization tuples share this
// shape check, so every customization list reports the same way.
// `check-options` validates the trailing options dictionary of one entry.
#let check-customization-entries(where, what, entries, arity, check-options) = {
  check-array(
    where,
    what,
    entries,
    fix: "pass an array of "
      + str(arity)
      + "-element tuples, for example "
      + what
      + ": ((…),)",
  )
  for (entry-index, entry) in entries.enumerate() {
    let entry-name = what + " entry " + str(entry-index)
    if type(entry) != array or entry.len() != arity {
      fail(
        where,
        entry-name + " is " + show-value(entry),
        expected: "an array of exactly " + str(arity) + " elements, ending with an options dictionary",
        fix: "write it as "
          + (
            if arity == 2 { "(target, (…options))" } else { "(from, to, (…options))" }
          ),
      )
    }
    check-options(where, entry-name + " options", entry.last())
  }
}

// Accepts the two spellings every id-keyed argument supports: a dictionary
// keyed by identifier, or an array of `(identifier, value)` pairs.
#let normalize-id-value-entries(where, what, entries) = {
  if type(entries) == dictionary {
    return entries.pairs()
  }
  check-array(
    where,
    what,
    entries,
    fix: "pass a dictionary keyed by identifier, or an array of (id, value) pairs",
  )
  for (entry-index, entry) in entries.enumerate() {
    if type(entry) != array or entry.len() != 2 {
      fail(
        where,
        what + " entry " + str(entry-index) + " is " + show-value(entry),
        expected: "an (id, value) pair",
        fix: "write it as (id, value)",
      )
    }
  }
  entries.map(entry => (entry.at(0), entry.at(1)))
}

// Identifier-keyed arguments such as `labels:` and `node-labels:` accept a
// dictionary keyed by the stringified identifier as well as `(id, value)`
// pairs, so both spellings are checked against the same identifier set.
#let check-id-value-references(where, what, entries, available, subject: "node") = {
  let stringable-ids = available.filter(id => type(id) in (str, int, float))
  if type(entries) == dictionary {
    let available-keys = stringable-ids.map(id => str(id))
    for key in entries.keys() {
      if key in available-keys { continue }
      fail(
        where,
        what + " has an entry for " + subject + " \"" + key + "\", which does not exist in the structure",
        expected: "one of the " + subject + "s: " + show-list(available),
        fix: _unknown-key-fix(key, available-keys),
      )
    }
    return
  }
  for (identifier, _) in normalize-id-value-entries(where, what, entries) {
    check-reference(where, what, identifier, available, subject: subject)
  }
}

// ── Callback results ─────────────────────────────────────────────────────────

// A user callback that returns the wrong type must blame the callback, not the
// package code that called it.
#let check-callback-result(where, what, value, types) = {
  if type(value) in types { return }
  fail(
    where,
    what + " returned " + show-value(value),
    expected: show-types(types),
    fix: "return " + show-types(types) + " from " + what,
  )
}
