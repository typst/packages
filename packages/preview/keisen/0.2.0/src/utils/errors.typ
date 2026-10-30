///! Error grammar and validation helpers.
///!
///! Every failure in keisen is reported through this module, so the messages
///! read the same wherever they come from:
///!
///!   <scope>: <problem>; got <repr(value)>. <hint>
///!
///! Typst has no `try`, so callers pre-check anything fallible and call these
///! helpers on the failing branch rather than attempting and recovering.

// Build a message without raising it, which is what makes the grammar testable.
// Absence of a value is `auto`, not `none`: `none` is itself a value worth
// reporting, and an empty cell is exactly the case that needs naming.
#let message(scope, problem, value: auto, hint: none) = {
  let text = scope + ": " + problem
  if value != auto { text = text + "; got " + repr(value) }
  if hint != none { text = text + ". " + hint }
  text
}

#let fail(scope, problem, value: auto, hint: none) = {
  panic(message(scope, problem, value: value, hint: hint))
}

// A hint says what to write instead.
// Give one wherever naming the type does not show how to write one.
// An integer shows itself, so `decimals` and `significant` carry no hint.
// A selector, a renderer, a style, a row store and a date do not, so each of
// those names an example.
#let fail-type(scope, name, value, expected, hint: none) = {
  fail(scope, name + " must be " + expected, value: value, hint: hint)
}

#let fail-enum(scope, name, value, valid) = {
  fail(
    scope,
    name + " must be one of " + valid.map(repr).join(", "),
    value: value,
  )
}

#let check(condition, scope, problem, value: auto, hint: none) = {
  if not condition { fail(scope, problem, value: value, hint: hint) }
}

// A column name is written into the problem clause as it reads, so an unknown
// `price` is reported as `unknown column price`. A name that is not a string
// cannot be added to a string at all, and writing it as its repr is what lets
// the builder report whatever it is handed: a directive that takes its names
// positionally can pass one of any type, and the reader is owed the name they
// wrote rather than a line of this package.
#let column-name(name) = if type(name) == str { name } else { repr(name) }

// Every directive that names a column reports an unknown one the same way. The
// hint is built inside the failing branch, so listing the known columns costs
// nothing on the path where the name is fine.
//
// The list is written through `column-name` for the same reason the problem
// clause is: what a table knows about is not always a string. The stub carries
// whatever name it was given, and alignment resolves before the folded spec is
// validated, so a stub named by an integer reaches this hint first.
#let check-column(known, scope, name) = {
  if name in known { return }
  fail(
    scope,
    "unknown column " + column-name(name),
    hint: if known.len() == 0 {
      "The table has no columns."
    } else {
      "Known columns: " + known.map(column-name).join(", ") + "."
    },
  )
}
