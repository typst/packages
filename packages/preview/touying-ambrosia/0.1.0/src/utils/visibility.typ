#import "../touying.typ": utils

// A labeled hiding scope makes visibility queryable by headers and footnotes.
#let hiding-cover(self: none, body) = {
  if self == utils.cover-kind-query { return "hide" }
  [#hide(body)<ambrosia-covered>]
}

#let is-covered(it) = query(selector(it.location()).within(<ambrosia-covered>)).len() > 0
