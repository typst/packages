#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#set text(lang:"fr")
#set raw(lang: "typ")
#let primary = teal.mix(eastern)
#show link: set text(primary)
#show: codly-init.with()
#codly(display-name: false, number-format: none, zebra-fill: none)

#[
  #set align(center)
  #let prop = toml("../typst.toml").package
  #text(2em, weight: "bold", primary)[moustaches]\
  #let subtitle = text(1.5em, prop.description)
  #subtitle

  #{//context 
    box(width: 1fr)[
      v#prop.version 
      #h(1fr)
      #prop.authors.join(
        ", ",
        last: " & ",
      )
      #h(1fr)#prop.license]
  }]

= A propos
En faisant mes cours, je me suis rendu compte qu'aucun des paquets pour présenter des diagrammes ne propose la gestion des effectifs ni les définitions françaises des quartiles, ni la construction d'histogrammes, des boîtes-à-moustaches tels que je les ai enseignées ... D'où ce paquet. 

Je me suis inspiré d'une partie de ProfCollege de LaTeX (auteur : Christophe Poulain) mais l'implémentation n'en est pas une copie et je n'ai pas utilisé du tout l'IA pour ce paquet.

== Module principal "stat"

#import "premanuel-fr.typ"
#import "/moustaches.typ"

// #show heading.where(level:2): it => {pagebreak(); it}

#let docs = tidy.parse-module(
  read("premanuel-fr.typ") + read("/moustaches.typ"),
  // name:"OpsM",
  scope: (moustaches: moustaches), 
  preamble: "#import moustaches: *\n",
)

#let show-example(
  ..args
) = {
  
  tidy.show-example.show-example(
    ..args,
    layout: (code, preview, ..args) => block(breakable: false, 
      tidy.show-example.default-layout-example(
        code, preview, 
        code-block: block.with(radius: 3pt, stroke: .5pt + luma(200)),
        preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
        col-spacing: 5pt,
        ..args
      )
    ),
  )
}

#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example),omit-private-definitions: true,)

== Sous-module pour les listes de couleurs et "hachures"

#import "../Hachures.typ"
#let docs = tidy.parse-module(
  read("/Hachures.typ"),
  // name:"OpsM",
  scope: (Hachures: Hachures), 
  preamble: "#import Hachures: *\n",
)
#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example))
