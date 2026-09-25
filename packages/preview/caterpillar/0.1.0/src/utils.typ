/// *`match-result`* schema.
/// a match result is a dictionary with fields
///
/// ```
/// match-result := (
///   matched :: bool
///   match :: any
///   match :: array(content)
/// )
/// ```
#let is-match-result(v) = (
  type(v) == dictionary
  and v.has("matched") and type(v.matched) == bool
  and v.has("match")
  and v.has("rest")
)

#let break-match(matched: false, match: none, rest: none) = (matched: matched, match: match, rest: rest)


/// *`parser`* schema.
/// A parser is a singleton expression that gets compared to the content.
///
/// ```
/// parser :=
///     content
///   | string
///   | content => match-result
///   | array(parser)
/// ```
#let is-parser(v) = (
  type(v) in (function, content, string, regex, array)
  and if type(v) == array {
    v.all(v_ => is-parser(v_))
  }
)

/// A low-level parser runner. Curried:
/// turns a parser (polymorphic) into a parser function,
/// to be run on an array of contents.
///
/// `function | content => function`
#let run-parser(p) = {
  import "parsers.typ": exact, string, multiple
  let f = (
    function: p => p,
    content:  p => exact(p),
    string:   p => string(p),
    regex:    p => string(p),
    array:    p => multiple(..p)
  ).at(str(type(p)), default: none)(p)

  if f != none {
    return f
  } else {
    assert(is-parser(p), message: "A parser must be one of: function, content, string (regex), array, but got " + repr(p))
  }
}
