#import "match.typ"
#import "stackframe.typ"

/// Inserts a non-backtracking point.
/// Returns #typ.none.
///
/// See: @pat-commit.
/// -> pattern
#let commit() = (call: match.commit)

/// Matches the end of the stream.
/// Returns #typ.none.
///
/// See: @pat-eof.
/// -> pattern
#let eof() = (call: match.eof)

/// Recursively invokes another rule.
///
/// See: @pat-label.
/// -> pattern
#let label(
  /// Label of a rule defined elsewhere in the grammar.
  /// -> str
  lab,
) = (lab: lab)

/// Uses a regular expression to more efficiently match a string.
/// Returns #typ.t.string.
///
/// See: @pat-regex.
#let regex(
  /// String representing a regular expression using the syntax of the
  /// #link("https://typst.app/docs/reference/foundations/regex/")[standard library]
  /// -> str
  re,
) = {
  let _ = std.regex(re)
  (call: match.regex, arg: re)
}

/// Matches a string literal. Returns a #typ.t.str.
///
/// See: @pat-str.
/// -> pattern
#let str(
  /// Any string to match as-is.
  /// -> str
  string,
) = (call: match.str, arg: string)

/// Automatically reinterprets builtin types/values to operators.
/// #property-priv()
/// -> pattern
#let auto-cast(
  /// Pattern to interpret.
  /// - #typ.t.function: native
  /// - #typ.t.string: cast through @cmd:prelude:str
  /// - #typ.t.label: cast through @cmd:prelude:label
  /// - #typ.t.array: cast through @cmd:prelude:seq
  /// - ```typc $$```: shorthand for @cmd:prelude:commit
  /// - #typ.raw: cast through @cmd:prelude:regex
  /// -> any
  pat
) = {
  if type(pat) == dictionary {
    assert("lab" in pat or "call" in pat)
    pat
  } else if type(pat) == std.label {
    label(std.str(pat))
  } else if type(pat) == std.str {
    str(pat)
  } else if type(pat) == array {
    (call: match.seq, pats: pat.map(auto-cast), array: true)
  } else if pat == $$ {
    commit()
  } else if type(pat) == content and pat.func() == std.raw {
    regex(pat.text)
  } else {
    panic("Cannot interpret an object of type " + str(type(pat)) + " as a parser")
  }
}

/// Matches a sequence of patterns in order.
/// Returns an #typ.t.array, except for possible optimizations where an implicit
/// invocation matches only one element.
///
/// See: @pat-seq.
/// -> pattern
#let seq(
  /// Patterns that need to be matched in order.
  /// -> array(pattern)
  ..pats,
  /// If true, forces the result to be an array even if it is of size 1.
  /// -> bool
  array: true,
) = {
  let pats = pats.pos().map(auto-cast)
  (call: match.seq, pats: pats, array: array)
}

// Helper to build sequences for variadic patterns.
// -> pattern
#let auto-seq(
  // Sub-patterns.
  // -> pattern
  ..pats,
  // If true, forces the result to be an array even if it is of size 1.
  // -> bool
  array: false,
) = {
  let pats = pats.pos()
  if (not array) and pats.len() == 1 {
    auto-cast(pats.at(0))
  } else {
    seq(array: array, ..pats)
  }
}

/// Matches 1 or more instances of the inner pattern.
/// Returns an #typ.t.array.
///
/// See: @pat-iter.
/// -> pattern
#let iter(
  /// List of patterns, implicitly cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  let pat = auto-seq(..pats)
  (call: match.iter, pat: pat)
}

/// Matches 0 or more instances of the inner pattern.
/// Returns an #typ.t.array.
///
/// See: @pat-star.
/// -> pattern
#let star(
  /// List of patterns, implicitly cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  let pat = auto-seq(..pats)
  (call: match.star, pat: pat)
}

/// Branching choice between multiple possible subpatterns.
/// Returns the first match.
///
/// See: @pat-fork.
/// -> pattern
#let fork(
  /// List of ordered patterns between which a choice is made.
  /// -> pattern
  ..pats,
) = {
  let pats = pats.pos().map(auto-cast)
  (call: match.fork, pats: pats)
}

#let auto-fork(
  ..pats,
) = {
  let pats = pats.pos()
  if pats.len() == 1 {
    auto-cast(pats.at(0))
  } else {
    fork(..pats)
  }
}

/// Matches 0 or 1 instances of the inner pattern.
/// Returns an #typ.t.array, either empty or singleton.
///
/// See: @pat-maybe.
/// -> pattern
#let maybe(
  /// Implicitly cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  let pat = auto-seq(..pats)
  (call: match.maybe, pat: pat)
}

/// Cancels out a @cmd:prelude:commit to re-enable backtracking.
/// Returns the inner match.
///
/// See: @pat-try
#let try(
  /// Implicitly cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  let pat = auto-seq(..pats)
  (call: match.try, pat: pat)
}

/// Matches an arbitrary pattern, but returns #typ.none.
///
/// See: @pat-drop.
/// -> pattern
#let drop(
  /// Implicitly cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  let pat = auto-seq(..pats)
  pat.rw = none
  pat
}

/// Currified so that common rewriting patterns can be conveniently
/// written as standalone functions.
/// The type of the return value is that of the function.
/// If multiple patterns are given, they are implicitly
/// cast to a @cmd:prelude:seq.
///
/// See: @pat-rewrite.
/// -> function(..pattern) => pattern
#let rewrite(
  /// Pattern to rewrite with.
  /// - #typ.none: the value is dropped,
  /// - #typ.auto: identity transformation,
  /// - #typ.t.function: applies the given function.
  /// -> none | auto | function
  fun,
) = {
  if fun == none {
    drop
  } else if fun == auto {
    (..pats) => auto-seq(..pats)
  } else if type(fun) == function {
    (..pats) => {
      let pat = auto-seq(..pats)
      if "rw" not in pat {
        pat.rw = fun
      } else if pat.rw != none {
        let old = pat.rw
        pat.rw = (x => fun(old(x)))
      } else {
        panic("Rewrite does not operate on rules that don't produce data")
      }
      pat
    }
  } else {
    panic(`transformation must be a function, none, or auto`)
  }
}

/// Turns a matching pattern into a custom error.
/// -> function(..pattern) => pattern
#let error(
  /// Message to emit in case of match.
  /// -> content
  msg,
) = (..pats) => {
  let pat = auto-seq(..pats)
  (call: match.error, msg: msg, pat: pat)
}

/// Positive lookahead: matches a pattern without consuming the input.
/// Returns #typ.none.
///
/// See: @pat-peek.
/// -> pattern
#let peek(
  /// Inner patterns that should match.
  /// Auto-cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  let pat = auto-seq(..pats)
  (call: match.peek, pat: pat)
}

/// Negative lookahead: checks that a pattern does not match.
/// Returns #typ.none and does not consume the input.
///
/// See: @pat-neg
/// -> pattern
#let neg(
  /// Inner patterns that should not match.
  /// Auto-cast to a @cmd:prelude:seq.
  /// -> pattern
  ..pats,
) = {
  let pat = seq(array: false, ..pats)
  (call: match.neg, pat: pat)
}

/// Fixed-length lookahead to determine which branch to take.
///
/// See: @pat-hint.
/// -> pattern
#let hint(
  /// How many characters to look ahead to determine the branch.
  /// -> int
  len,
  /// Dictionary with keys of length `len` that decide which pattern to
  /// pick. A default can be provided with the key `__`.
  /// -> dictionary
  mapping,
) = {
  assert(len >= 1)
  for (k, v) in mapping {
    mapping.at(k) = auto-cast(mapping.at(k))
  }
  (call: match.hint, len: len, mapping: mapping)
}

