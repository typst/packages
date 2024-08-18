
#import "is.typ"
#import "def.typ"
#import "assert.typ"

#import "alias.typ"

#import "get.typ"
#import "math.typ"

#let is-none( ..values ) = {
  return none in values.pos()
}

#let is-auto( ..values ) = {
  return auto in values.pos()
}
