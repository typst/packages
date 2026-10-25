// Subject of an error message: an option, or an argument of a function.
#let _subject(name, of) = if of == none {
  "Option '" + name + "'"
} else {
  "Argument '" + name + "' of " + of
}

// Assert that the option `name` (or the argument `name` of `of`) is set,
// i.e. not none.
#let assert-set(name, value, of: none) = assert(
  value != none,
  message: _subject(name, of) + " must be set",
)

// Assert that the option `name` (or the argument `name` of `of`) has one of
// the `allowed` values.
#let assert-one-of(name, value, allowed, of: none) = assert(
  value in allowed,
  message: _subject(name, of) + " must be one of [" +
    allowed.map(repr).join(", ") +
    "], but was set to " + repr(value),
)

// Assert that the argument sink `args` of the function `of` holds no named
// arguments, i.e. that no unknown (e.g. misspelled) argument was given.
#let assert-no-extra(args, of) = assert(
  args.named().len() == 0,
  message: "Unknown argument(s) of " + of + ": " +
    args.named().keys().join(", "),
)
