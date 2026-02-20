#import "/src/operators.typ" as ops

/// Adds one case to the rule.
/// Multiple invocations are globally taken as a @cmd:prelude:fork.
/// -> rule
#let pat(
  /// Pattern that the rule matches.
  /// If there are multiple, they are cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  ((pat: ops.auto-seq(..pats)),)
}

/// Adds a rewrite to all preceding @cmd:prelude:pat that do not already have one.
/// See @pat-rewrite for more information.
/// -> rule
#let rw(
  /// Rewriting a function. Uses the same convention as @pat-rewrite,
  /// where #typ.auto is the identity (also the default), and #typ.none
  /// removes the matched value entirely.
  /// -> function | auto | none
  fun,
) = {
  ((rw: fun),)
}

/// Declares one or more positive unit tests.
/// They must parse correctly and pass validation.
/// See @tests for details.
/// -> rule
#let yy(
  /// Inputs passed to the parser.
  /// -> raw
  ..tests,
  /// Additional checks to run on the output.
  /// If a function, it will be given two arguments: the input and the parsed output.
  /// -> function | auto
  validate: auto,
) = {
  ((yy: tests.pos(), validate: validate),)
}

/// Declares one or more negative unit tests.
/// They must produce a parsing error and pass validation.
/// See @tests for details.
/// -> rule
#let nn(
  /// Inputs passed to the parser.
  /// -> raw
  ..tests,
  /// Additional checks to run on the output.
  /// If a function, it will be given two arguments: the input and the error message.
  /// -> function | auto
  validate: auto,
) = {
  ((nn: tests.pos(), validate: validate),)
}

