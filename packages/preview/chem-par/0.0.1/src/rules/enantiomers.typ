#import "../stateful.typ": *

#let enantiomers(body) = {
  show regex("\([EZRS]\)"): (it) => {
    if-state-enabled( it , {
      show regex("\w"): text.with(style:"italic")
      it
    } )
  }
  body
}
