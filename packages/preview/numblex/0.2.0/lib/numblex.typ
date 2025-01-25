#import "./parser.typ": parser
#import "./model.typ": to_numbering

/// Numblex main function
#let numblex(s, ..options) = {
  return to_numbering(..parser(s))
}
