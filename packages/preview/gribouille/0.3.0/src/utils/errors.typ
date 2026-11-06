// Unified error reporting for src/.
//
// Typst cannot catch a panic, so the message *builders* are pure functions
// returning strings (tests/unit/test-errors.typ asserts their wording) and the
// `fail-*` / `check` wrappers raise them via `panic` / `assert`.
//
// Message grammar:
//   "<scope>: <problem>; got <repr(value)>. <hint>"
//   - scope:   the public function or module ("compose", "geom-curve").
//   - problem: the expectation, without a trailing period.
//   - got:     appended only when a value is shown; always via repr().
//   - one trailing full stop.
//   - hint:    optional final sentence giving the fix.
//
// Never inline a panic string elsewhere in src/; route every validation here.

// Render an array of values as a quoted, comma-joined list: "a", "b", "c".
#let quote-each(values) = values.map(v => "\"" + str(v) + "\"").join(", ")

// Append a hint sentence when one is supplied.
#let _with-hint(text, hint) = if hint == none { text } else {
  text + " " + hint
}

// "<scope>: <problem>." plus optional hint. `problem` may already carry its own
// "; got ..." clause for bespoke messages.
#let error-text(scope, problem, hint: none) = {
  _with-hint(scope + ": " + problem + ".", hint)
}

// "<scope>: <name> must be one of "a", "b"; got <repr(value)>."
#let enum-text(scope, name, value, valid, hint: none) = {
  error-text(
    scope,
    name + " must be one of " + quote-each(valid) + "; got " + repr(value),
    hint: hint,
  )
}

// "<scope>: <name> must be <expected>; got <repr(value)>."
// `expected` is a noun phrase, e.g. "a positive integer", "a length or `auto`".
#let type-text(scope, name, value, expected, hint: none) = {
  error-text(
    scope,
    name + " must be " + expected + "; got " + repr(value),
    hint: hint,
  )
}

// "<scope>: <name> must be in (lo, hi); got <repr(value)>."
// lo-open/hi-open pick the bracket: open -> "(" / ")", closed -> "[" / "]".
#let range-text(
  scope,
  name,
  value,
  lo,
  hi,
  lo-open: true,
  hi-open: true,
  hint: none,
) = {
  let open = if lo-open { "(" } else { "[" }
  let close = if hi-open { ")" } else { "]" }
  let interval = open + repr(lo) + ", " + repr(hi) + close
  error-text(
    scope,
    name + " must be in " + interval + "; got " + repr(value),
    hint: hint,
  )
}

// Panic / assert wrappers ----------------------------------------------------

#let fail(scope, problem, hint: none) = {
  panic(error-text(scope, problem, hint: hint))
}

#let fail-enum(scope, name, value, valid, hint: none) = {
  panic(enum-text(scope, name, value, valid, hint: hint))
}

#let fail-type(scope, name, value, expected, hint: none) = {
  panic(type-text(scope, name, value, expected, hint: hint))
}

#let fail-range(
  scope,
  name,
  value,
  lo,
  hi,
  lo-open: true,
  hi-open: true,
  hint: none,
) = {
  panic(range-text(
    scope,
    name,
    value,
    lo,
    hi,
    lo-open: lo-open,
    hi-open: hi-open,
    hint: hint,
  ))
}

#let check(cond, scope, problem, hint: none) = {
  assert(cond, message: error-text(scope, problem, hint: hint))
}

// Panic unless `align` is a Typst alignment (the house type for every text /
// legend alignment). `none` is allowed: it means "inherit the default". Guards
// against passing a string like "left" (which silently never matches the
// alignment comparisons downstream).
#let assert-halign(scope, align) = {
  if align != none and type(align) != alignment {
    fail-type(
      scope,
      "align",
      align,
      "a Typst alignment `left`, `center`, or `right`",
      hint: "Use the alignment value `left`, not the string \"left\".",
    )
  }
}
