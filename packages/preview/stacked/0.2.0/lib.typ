#import "PileCubes.typ": *
#import "Dés3D.typ": *
#import "polysection.typ": *
#import "solidsection.typ": *
#import "solidunfold.typ": *
#import "solidvertices.typ": *

#let help-fr(..args) = {set text(.85em)
  import "@preview/tidy:0.4.3"
  let namespace = (
    ".": read.with("/Exemples/help-fr.typ"),
  )
  tidy.generate-help(namespace: namespace, package-name: "stacked")(..args)
}

#let help-en(..args) = {set text(.85em)
  import "@preview/tidy:0.4.3"
  let namespace = (
    ".": read.with("/Exemples/help-en.typ"),
  )
  tidy.generate-help(namespace: namespace, package-name: "stacked")(..args)
}

// #help-fr("globe")