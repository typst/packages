#import "utils.typ": *


// COMBINATORS //


/// Sequentially run a list of parsers.
///
/// *Tip*. This has syntactic sugar: just pass an array of parsers.
/// ```typc parse(multiple(p, q, r))[...] == parse((p, q, r))[...]```
///
/// `..parser => array(content) => match-result(array)`
///
/// ==== Example
///
/// ```example
/// #parse(([more], p.space, [than]))[more than one]
/// ```
#let multiple(
  /// Any number of parsers.
  /// -> args(parser)
  ..ps
) = cs => {
  let ps = ps.pos()
  assert(type(ps) == array, message: "Array expected but got " + repr(ps))

  if ps.len() == 0 {
    return (matched: true, match: none, rest: cs)
  }
  // try the first parser,
  // fail if failed,
  // otherwise continue with the next on the rest
  let res = run-parser(ps.at(0))(cs)
  if res.matched {
    let next = multiple(..ps.slice(1))(res.rest)
    (matched: next.matched, match: (res.match, ..next.match), rest: next.rest)
  } else {
    break-match(rest: cs)
  }
}


/// Fail if the parser fails,
/// otherwise succeed without consuming.
///
/// `parser => array(content) => match-result(none)`
///
/// ==== Example
///
/// ```example
/// #parse(p.test[test])[testing is not particularly exciting]
/// ```
#let test(
  /// -> parser
  p
) = cs => {
  let res = run-parser(p)(cs)
  if res.matched {
    (matched: true, match: none, rest: cs)
  } else {
    break-match(rest: cs)
  }
}


/// Fail if the parser succeeds,
/// otherwise succeed without consuming.
///
/// `parser => array(content) => match-result(none)`
///
/// ==== Example
///
/// ```example
/// #parse(p.test-not[not test])[testing is not particularly exciting]
/// ```
#let test-not(
  /// -> parser
  p
) = cs => {
  let res = run-parser(p)(cs)
  if not res.matched {
    (matched: true, match: none, rest: cs)
  } else {
    break-match(rest: cs)
  }
}


/// Run a parser optionally,
/// returning `none` instead of failing
/// when not matched.
///
/// `parser => array(content) => match-result(content | none)`
///
/// ==== Example
///
/// ```example
/// #parse(p.optional[actually])[nothing actual there]
/// ```
#let optional(p) = cs => {
  let res = run-parser(p)(cs)
  if res.matched {
    res
  } else {
    (matched: true, match: none, rest: cs)
  }
}


/// Try every parser until one succeeds.
///
/// `..parser => array(content) => match-result(any)`
///
/// ==== Example
///
/// ```example
/// #parse(p.one-of([first], [second], [third]))[second guess]
/// ```
#let one-of(
  /// Any number of parsers.
  /// -> args(parser)
  ..ps
) = cs => {
  let ps = ps.pos()
  if ps == () {
    return break-match(rest: cs)
  }

  let res = run-parser(ps.first())(cs)
  if res.matched {
    res
  } else {
    one-of(..ps.slice(1))(cs)
  }
}


/// Run all the parsers on the same content. If all succeed,
/// return the result of the first.
///
/// `..parser => array(content) => match-result(any)`
///
/// ==== Example
///
/// ```example
/// #parse(p.all(p.text, [part]))[part of the whole]
/// ```
#let all(
  /// Any number of parsers.
  /// -> args(parser)
  ..ps
) = cs => {
  let ps = ps.pos()
  if ps == () {
    return (matched: true, match: none, rest: cs)
  }

  let res = run-parser(ps.first())(cs)
  if res.matched and all(..ps.slice(1))(cs).matched {
    res
  } else {
    break-match(rest: cs)
  }
}


/// Run the parser multiple times,
/// with the minimum and the maximum number of times
/// specified by `min` and `max` parameters.
/// If `max` ≤ 0, repeat ad infinum. If `min` > `max`, `min` is ignored.
///
/// `(parser, min: int, max: int) => match-result(array)`
///
/// ==== Examples
///
/// ```example
/// #parse(p.repeat(("very", p.space)))[very very very many repetitions]
/// ```
///
/// ```example
/// #parse(p.repeat(("very", p.space), max: 2))[very very very many repetitions]
/// ```
///
/// ```example
/// #parse(p.repeat(("very", p.space), min: 4))[very very very many repetitions]
/// ```
#let repeat(
  /// -> parser
  p,
  /// Minimum number of times to repeat.
  /// Will fail if not reached.
  /// -> int
  min: 0,
  /// Maximum number of times to repeat.
  /// Will stop when reached. `-1` means unlimited.
  /// -> int
  max: -1
) = cs => {
  // if max exhausted, stop
  if max == 0 {
    (matched: true, match: (), rest: cs)

  } else {
    let res = run-parser(p)(cs)

    // parse until failed
    if res.matched {
      let next = repeat(p, min: min - 1, max: max - 1)(res.rest)
      (matched: next.matched, match: (res.match, ..next.match), rest: next.rest)

    // in case of a fail, succeed if min is reached
    } else if min <= 0 {
      (matched: true, match: (), rest: cs)
    } else {
      break-match(rest: cs)
    }
  }
}


/// Continuously run the first parser
/// until the second succeeds.
/// Does not consume the match of the second parser.
///
/// `(parser, parser) => array(content) => match-result(array)`
///
/// ==== Example
///
/// ```example
/// #parse(p.until(p.anything, [...]))[wait wait wait... you can go]
/// ```
#let until(
  /// Parser to repeat.
  /// -> parser
  p,
  /// Parser to check and stop if it succeeds.
  /// -> parser
  end
) = cs => {

  // run the end parser
  let end-res = run-parser(end)(cs)
  if end-res.matched {
    return (matched: true, match: (), rest: cs)
  }

  // otherwire run the second and continue
  let res = run-parser(p)(cs)
  if res.matched {
    let next = until(p, end)(res.rest)
    (matched: next.matched, match: (res.match, ..next.match), rest: next.rest)
  } else {
    break-match(rest: cs)
  }
}


// BASIC //

/// Parse a single piece of content that corresponds to a predicate.
///
/// `(content => bool) => array(content) => match-result(content)`
///
/// ==== Example
///
/// ```example
/// #parse(p.predicate(it => it.func() == box))[#box[a box] and text]
/// ```
#let predicate(
  /// A predicate on a single piece of content.
  /// -> function
  p
) = cs => {
  if cs.len() > 0 and p(cs.first()) {
    (matched: true, match: cs.first(), rest: cs.slice(1))
  } else {
    break-match(rest: cs)
  }
}

/// Parse the text that matches the parser string or regex exactly
/// from the beginning of the contents.
///
/// *TIP*. This has syntactic sugar: just pass a string or a regex.
/// ```typc parse(string("..."))[...] == parse("...")[...]```,
/// ```typc parse(string(regex(".*")))[...] == parse(regex(".*"))[...]```
///
/// `str | regex => array(content) => match-result(content)`
///
/// ==== Example
///
/// ```example
/// #parse(regex("\d+"))[15mm]
/// ```
#let string(
  /// A string or a regex.
  /// -> str | regex
  p
) = cs => {
  if cs.len() > 0 and cs.first().has("text") and cs.first().text.starts-with(p) {
    let t = cs.first().text
    let (end,) = t.match(p)
    let rest = if t.len() > end {(text(t.slice(end)),)} else {none}
    (matched: true, match: text(t.slice(0, end)), rest: rest + cs.slice(1))
  } else {
    break-match(rest: cs)
  }
}

/// Parse possibly multipart content that matches the parser content exactly
/// or begins with it.
///
/// *TIP*. This has syntactic sugar: just pass pure content.
/// ```typc parse(exact[...])[...] == parse([...])[...]```
///
/// `content => array(content) => match-result(content)`
///
/// ==== Examples
///
/// ```example
/// #parse([but is it])[but is it a proper example?]
/// ```
///
/// ```example
/// #parse([but _is_ it])[but _is_ it a proper example?]
/// ```
#let exact(
  /// A content, possibly complex.
  /// -> content
  p
) = cs => {

  if p.has("children") {
    // try matching a slice of contents first
    let len = p.children.len()
    if cs.len() > len and cs.slice(0, len) == p.children {
      return (matched: true,
              match: cs.slice(0, len).join(),
              rest: cs.slice(len))
    }
    // then parse one by one
    let (matched, match, rest) = multiple(..p.children)(cs)
    return (matched: matched,
            match: if type(match) == array {match.join()} else {match},
            rest: rest)
  }

  // match the first content precisely
  let full-res = predicate(it => it == p)(cs)
  if full-res.matched {
    return full-res
  }
  if p.has("text") {
    let str-res = string(p.text)(cs)
    if str-res.matched {
      return str-res
    }
  }

  break-match(rest: cs)
}


// CONSTANTS //

/// Any piece of content.
/// Defined as `predicate(_ => true)`.
///
/// `array(content) => match-result(content)`
///
/// ==== Example
///
/// ```example
/// #parse(p.anything)[_*well*_, anyway]
/// ```
#let anything = predicate(_ => true)

/// Any piece of content of type `text`.
/// Defined as `predicate(c => c.func() == text)`.
///
/// `array(content) => match-result(content)`
///
/// ==== Example
///
/// ```example
/// #parse(p.text)[might _probably_ turn out useful.]
/// ```
#let text = predicate(c => c.func() == text)

/// Either a space element or a " " string.
/// Defined as `one-of([ ], " ")`
///
/// `array(content) => match-result(content)`
///
/// ==== Example
///
/// ```example
/// #parse(("a", p.space))[a text with spaces]
/// ```
///
/// ```example
/// #parse(p.space)[  a so-called tabulation]
/// ```
#let space = one-of([ ], " ")

/// Empty content.
///
/// `array(content) => match-result(none)`
///
/// ==== Example
///
/// ```example
/// #parse(p.end)[]
/// ```
#let end = cs => {
  if cs == () {
    (matched: true, match: none, rest: cs)
  } else {
    break-match(rest: cs)
  }
}
