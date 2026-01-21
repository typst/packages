#import "../stateful.typ": *
#import "../constants.typ": elements, pseudo-elements

// Prepare array of elements
#let all-elements = elements + pseudo-elements
#all-elements = all-elements.sorted( (it) => it.len() )

#let ChemRegex = "(\(?((" + all-elements.map(it=>{"("+it+")"}).join("|") + ")+\d?)+(\)\d*)?(\d*([\+-])?)*)"

#let formulae(body) = {
  show regex(ChemRegex): (it) => {
    if-state-enabled( it , {
      show regex("\d"): sub
      show regex("\d*[+-]"): super
      it
    })
  }
  body
}
