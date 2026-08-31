#import "src/utils.typ": *
#import "src/parsers.typ" as parsers

/// Run a parser on content.
/// Split content automatically.
///
/// `parser, content => match-result`
#let parse(
  /// -> parser
  p,
  /// -> content
  c
) = {
  assert(type(c) == content, message: "Content expected, but got " + repr(c))
  let cs = if c.has("children") {c.children} else {(c,)}
  run-parser(p)(cs)
}

/// Parse a paragraph (or any content) trying every parser,
/// and apply the corresponding handler to the first success,
/// otherwise keep the paragraph as is.
///
/// `..(parser, handler), content => content`\
/// where `handler := (any, content) => content`
#let crawl(
  /// Any number of pairs (parser, handler), where the handler takes the match and the rest
  /// (joined automatically) and produces content from them.
  /// -> args(parser, handler)
  ..prefs,
  /// Either a simple content (sequence) or anything that has fields `body` (like `par`).
  /// -> content
  par
) = {
  for (parser, map) in prefs.pos() {
    let (matched, match, rest) = parse(parser, par.at("body", default: par))
    if matched {
      return map(match, rest.join())
    }
  }
  par
}
