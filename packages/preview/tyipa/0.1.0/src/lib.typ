/// Module providing symbols and functions for working with the International Phonetic Alphabet.

#import "sym.typ"
#import "diac.typ"
#import "_trans.typ": ipatext, ipabody

#let text(body, delim: "") = {
  assert(
    type(body) in (str, symbol, content),
    message: "Argument `body` must be of type str or content."
  )
  if type(body) == str or type(body) == symbol {
    ipatext(body, delim: delim)
  } else {
    ipabody(body, delim: delim)
  }
}
