#import "@preview/elembic:1.1.1" as e

#let istype(x, t) = {
  return e.result.is-ok(e.types.cast(x, t))
}

#let remove-multiple-whitespace(s) = {
  string.replace("/\s\s+/g", " ")
}

#let capitalize(s) = {
  return upper(s.at(0)) + s.slice(1)
}
#let nth-letter(n) = {
  return numbering("a", n)
}