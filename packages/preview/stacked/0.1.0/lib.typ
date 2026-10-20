#import "PileCubes.typ": *
#import "Dés3D.typ": *

#let help-fr(..args) = {set text(.85em)
  import "@preview/tidy:0.4.3"
  let namespace = (
    ".": (
      read.with("/lib.typ"),
      read.with("/PileCubes.typ"),
      read.with("/Dés3D.typ"), 
      read.with("/Colors.typ"),
      read.with("/Exemples/help-fr.typ"),
      read.with("/Exemples/premanuel-fr.typ"),
    )
  )
  tidy.generate-help(namespace: namespace, package-name: "stacked")(..args)
}

#let help-en(..args) = {set text(.85em)
  import "@preview/tidy:0.4.3"
  let namespace = (
    ".": (
      read.with("/lib.typ"),
      read.with("/PileCubes.typ"),
      read.with("/Dés3D.typ"), 
      read.with("/Colors.typ"),
      read.with("/Exemples/help-en.typ"),
      read.with("/Exemples/premanual-en.typ"),
    )
  )
  tidy.generate-help(namespace: namespace, package-name: "stacked")(..args)
}

// #help-fr("dice")