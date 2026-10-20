#import "/Operations.typ": *
#import "/Priorités.typ": detail, etapes-calcul
#import "/durées.typ": *

#let help-fr(..args) = {
  import "@preview/tidy:0.4.3"
  let namespace = (
    ".": (
    read.with("/help-fr.typ"),
  )
)
  tidy.generate-help(namespace: namespace, package-name: "longops")(..args)
}

#let help-en(..args) = {
  import "@preview/tidy:0.4.3"
  let namespace = (
    ".": (
    read.with("/help-en.typ"),
  )
)
  tidy.generate-help(namespace: namespace, package-name: "longops")(..args)
}

// #help-en("division")