#import "stateful.typ": *
#import "constants.typ": *
#import "rules.typ"

#let chem-style = (body) => {

  show: rules.formulae
  show: rules.isomers
  show: rules.enantiomers
  show: rules.greek
  show: rules.fischer-dropcaps
  show: rules.deuterated

  body
}
